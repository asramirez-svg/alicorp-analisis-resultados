-- Modelo estrella de Alicorp (1T24–2T26) en SQLite.
-- Mismo modelo que el dashboard de Power BI: 2 dimensiones y 3 tablas de hechos,
-- más una tabla de control con los totales anuales publicados para validar los datos.

DROP TABLE IF EXISTS fact_unidades;
DROP TABLE IF EXISTS fact_consolidado;
DROP TABLE IF EXISTS fact_deuda;
DROP TABLE IF EXISTS control_totales_2024;
DROP TABLE IF EXISTS dim_unidad;
DROP TABLE IF EXISTS dim_trimestre;

CREATE TABLE dim_trimestre (
    trimestre           TEXT PRIMARY KEY,          -- '2025-Q3'
    anio                INTEGER NOT NULL,
    num_trimestre       INTEGER NOT NULL CHECK (num_trimestre BETWEEN 1 AND 4),
    etiqueta            TEXT NOT NULL,             -- '3T25'
    orden               INTEGER NOT NULL UNIQUE,   -- 1..10, para ordenar y comparar contra 4 trimestres atrás
    tc_promedio_pen_usd REAL                       -- tipo de cambio promedio del trimestre (BCRP)
);

CREATE TABLE dim_unidad (
    unidad TEXT PRIMARY KEY
);

CREATE TABLE fact_unidades (
    trimestre           TEXT NOT NULL REFERENCES dim_trimestre (trimestre),
    unidad              TEXT NOT NULL REFERENCES dim_unidad (unidad),
    volumen_miles_tm    REAL,
    ventas              REAL,                      -- en la moneda original
    utilidad_bruta      REAL,
    ebitda_ajustado     REAL,
    moneda              TEXT NOT NULL CHECK (moneda IN ('PEN', 'USD')),
    fuente              TEXT NOT NULL,
    tc_promedio_pen_usd REAL,
    ventas_pen          REAL,                      -- convertido a soles
    utilidad_bruta_pen  REAL,
    ebitda_ajustado_pen REAL,
    comparable_con_2024 INTEGER NOT NULL,          -- 0 = quiebre de serie (Bolivia, NIC 21)
    PRIMARY KEY (trimestre, unidad)
);

CREATE TABLE fact_consolidado (
    trimestre                TEXT PRIMARY KEY REFERENCES dim_trimestre (trimestre),
    volumen_miles_tm         REAL,
    ventas                   REAL,
    utilidad_bruta           REAL,
    ebitda_reportado         REAL,
    ebitda_ajustado          REAL,
    utilidad_neta            REAL,
    fuente                   TEXT NOT NULL,
    partidas_no_recurrentes  REAL
);

CREATE TABLE fact_deuda (
    trimestre             TEXT PRIMARY KEY REFERENCES dim_trimestre (trimestre),
    deuda_financiera_neta REAL,
    deuda_neta_ebitda_x   REAL,
    fuente                TEXT NOT NULL
);

-- Totales anuales 2024 publicados por Alicorp (reporte 4T25), para el control de calidad.
CREATE TABLE control_totales_2024 (
    alcance   TEXT NOT NULL,   -- 'Consolidado' o el nombre de la unidad
    metrica   TEXT NOT NULL,
    publicado REAL NOT NULL,
    PRIMARY KEY (alcance, metrica)
);

INSERT INTO control_totales_2024 (alcance, metrica, publicado) VALUES
    ('Consolidado', 'volumen_miles_tm', 2114.7),
    ('Consolidado', 'ventas',           10598.3),
    ('Consolidado', 'utilidad_bruta',   2865.3),
    ('Consolidado', 'ebitda_ajustado',  1616.4),
    ('Consolidado', 'ebitda_reportado', 1460.4),
    ('Consolidado', 'utilidad_neta',    350.5),
    ('Consumo Masivo Perú',       'volumen_miles_tm', 592.0),
    ('Consumo Masivo Perú',       'ventas',           3867.4),
    ('Consumo Masivo Perú',       'utilidad_bruta',   1505.0),
    ('Consumo Masivo Perú',       'ebitda_ajustado',  861.5),
    ('Alicorp Soluciones (B2B)',  'volumen_miles_tm', 708.0),
    ('Alicorp Soluciones (B2B)',  'ventas',           2671.8),
    ('Alicorp Soluciones (B2B)',  'utilidad_bruta',   599.5),
    ('Alicorp Soluciones (B2B)',  'ebitda_ajustado',  377.8),
    ('Vitapro (Acuicultura)',     'volumen_miles_tm', 672.3),
    ('Vitapro (Acuicultura)',     'ventas',           808.8),
    ('Vitapro (Acuicultura)',     'utilidad_bruta',   110.4),
    ('Vitapro (Acuicultura)',     'ebitda_ajustado',  71.0);

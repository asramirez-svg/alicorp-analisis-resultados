-- Alicorp (1T24–2T26) en SQL Server: crea la base, el modelo estrella y carga los datos.
-- Ejecutar completo en SQL Server Management Studio (F5). Se puede volver a correr: borra y recrea la base.
USE master;
GO
IF DB_ID(N'Alicorp') IS NOT NULL
BEGIN
    ALTER DATABASE Alicorp SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE Alicorp;
END;
GO
CREATE DATABASE Alicorp;
GO
USE Alicorp;
GO

CREATE TABLE dim_trimestre (
    trimestre           VARCHAR(7)    NOT NULL PRIMARY KEY,   -- '2025-Q3'
    anio                SMALLINT      NOT NULL,
    num_trimestre       TINYINT       NOT NULL CHECK (num_trimestre BETWEEN 1 AND 4),
    etiqueta            VARCHAR(4)    NOT NULL,                -- '3T25'
    orden               TINYINT       NOT NULL UNIQUE,
    tc_promedio_pen_usd DECIMAL(8,4)  NULL
);

CREATE TABLE dim_unidad (
    unidad NVARCHAR(40) NOT NULL PRIMARY KEY
);

CREATE TABLE fact_unidades (
    trimestre           VARCHAR(7)    NOT NULL REFERENCES dim_trimestre (trimestre),
    unidad              NVARCHAR(40)  NOT NULL REFERENCES dim_unidad (unidad),
    volumen_miles_tm    DECIMAL(14,4) NULL,
    ventas              DECIMAL(14,4) NULL,
    utilidad_bruta      DECIMAL(14,4) NULL,
    ebitda_ajustado     DECIMAL(14,4) NULL,
    moneda              CHAR(3)       NOT NULL CHECK (moneda IN ('PEN', 'USD')),
    fuente              NVARCHAR(80)  NOT NULL,
    tc_promedio_pen_usd DECIMAL(8,4)  NULL,
    ventas_pen          DECIMAL(14,4) NULL,
    utilidad_bruta_pen  DECIMAL(14,4) NULL,
    ebitda_ajustado_pen DECIMAL(14,4) NULL,
    comparable_con_2024 BIT           NOT NULL,
    CONSTRAINT pk_fact_unidades PRIMARY KEY (trimestre, unidad)
);

CREATE TABLE fact_consolidado (
    trimestre               VARCHAR(7)    NOT NULL PRIMARY KEY REFERENCES dim_trimestre (trimestre),
    volumen_miles_tm        DECIMAL(14,4) NULL,
    ventas                  DECIMAL(14,4) NULL,
    utilidad_bruta          DECIMAL(14,4) NULL,
    ebitda_reportado        DECIMAL(14,4) NULL,
    ebitda_ajustado         DECIMAL(14,4) NULL,
    utilidad_neta           DECIMAL(14,4) NULL,
    fuente                  NVARCHAR(80)  NOT NULL,
    partidas_no_recurrentes DECIMAL(14,4) NULL
);

CREATE TABLE fact_deuda (
    trimestre             VARCHAR(7)    NOT NULL PRIMARY KEY REFERENCES dim_trimestre (trimestre),
    deuda_financiera_neta DECIMAL(14,4) NULL,
    deuda_neta_ebitda_x   DECIMAL(5,2)  NULL,
    fuente                NVARCHAR(80)  NOT NULL
);

CREATE TABLE control_totales_2024 (
    alcance   NVARCHAR(40)  NOT NULL,
    metrica   VARCHAR(30)   NOT NULL,
    publicado DECIMAL(12,1) NOT NULL,
    CONSTRAINT pk_control PRIMARY KEY (alcance, metrica)
);
GO

INSERT INTO dim_trimestre (trimestre, anio, num_trimestre, etiqueta, orden, tc_promedio_pen_usd) VALUES
    (N'2024-Q1', 2024, 1, N'1T24', 1, 3.7592),
    (N'2024-Q2', 2024, 2, N'2T24', 2, 3.7445),
    (N'2024-Q3', 2024, 3, N'3T24', 3, 3.7583),
    (N'2024-Q4', 2024, 4, N'4T24', 4, 3.7563),
    (N'2025-Q1', 2025, 1, N'1T25', 5, 3.6988),
    (N'2025-Q2', 2025, 2, N'2T25', 6, 3.654),
    (N'2025-Q3', 2025, 3, N'3T25', 7, 3.5337),
    (N'2025-Q4', 2025, 4, N'4T25', 8, 3.3842),
    (N'2026-Q1', 2026, 1, N'1T26', 9, 3.387),
    (N'2026-Q2', 2026, 2, N'2T26', 10, 3.4283);

INSERT INTO dim_unidad (unidad) VALUES
    (N'Consumo Masivo Perú'),
    (N'Alicorp Soluciones (B2B)'),
    (N'Vitapro (Acuicultura)'),
    (N'Negocios Internacionales');

INSERT INTO fact_unidades (trimestre, unidad, volumen_miles_tm, ventas, utilidad_bruta, ebitda_ajustado, moneda, fuente, tc_promedio_pen_usd, ventas_pen, utilidad_bruta_pen, ebitda_ajustado_pen, comparable_con_2024) VALUES
    (N'2024-Q1', N'Consumo Masivo Perú', 136.0, 884.3, 344.2, 204.0, N'PEN', N'ER 1T25', 3.7592, 884.3, 344.2, 204.0, 1),
    (N'2024-Q2', N'Consumo Masivo Perú', 139.3, 909.9, 375.7, 207.6, N'PEN', N'ER 2T25', 3.7445, 909.9, 375.7, 207.6, 1),
    (N'2024-Q3', N'Consumo Masivo Perú', 152.4, 981.9, 386.2, 221.2, N'PEN', N'ER 3T25', 3.7583, 981.9, 386.2, 221.2, 1),
    (N'2024-Q4', N'Consumo Masivo Perú', 164.4, 1091.3, 398.9, 228.7, N'PEN', N'ER 4T25', 3.7563, 1091.3, 398.9, 228.7, 1),
    (N'2025-Q1', N'Consumo Masivo Perú', 148.6, 944.2, 357.2, 197.9, N'PEN', N'ER 1T26 (re-expresado)', 3.6988, 944.2, 357.2, 197.9, 1),
    (N'2025-Q2', N'Consumo Masivo Perú', 156.9, 960.6, 353.3, 175.1, N'PEN', N'ER 2T26 (re-expresado)', 3.654, 960.6, 353.3, 175.1, 1),
    (N'2025-Q3', N'Consumo Masivo Perú', 165.0, 1035.2, 398.6, 206.6, N'PEN', N'Derivado: anual 2025 - otros trimestres', 3.5337, 1035.2, 398.6, 206.6, 1),
    (N'2025-Q4', N'Consumo Masivo Perú', 167.7, 1078.0, 409.1, 228.2, N'PEN', N'ER 4T25', 3.3842, 1078.0, 409.1, 228.2, 1),
    (N'2026-Q1', N'Consumo Masivo Perú', 167.2, 1039.0, 414.6, 240.5, N'PEN', N'ER 1T26', 3.387, 1039.0, 414.6, 240.5, 1),
    (N'2026-Q2', N'Consumo Masivo Perú', 169.1, 1068.5, 396.9, 198.5, N'PEN', N'ER 2T26', 3.4283, 1068.5, 396.9, 198.5, 1),
    (N'2024-Q1', N'Alicorp Soluciones (B2B)', 142.3, 530.1, 114.1, 67.3, N'PEN', N'ER 1T25', 3.7592, 530.1, 114.1, 67.3, 1),
    (N'2024-Q2', N'Alicorp Soluciones (B2B)', 159.6, 577.9, 138.6, 86.6, N'PEN', N'ER 2T25', 3.7445, 577.9, 138.6, 86.6, 1),
    (N'2024-Q3', N'Alicorp Soluciones (B2B)', 190.3, 698.7, 151.4, 98.4, N'PEN', N'ER 3T25', 3.7583, 698.7, 151.4, 98.4, 1),
    (N'2024-Q4', N'Alicorp Soluciones (B2B)', 215.8, 865.0, 195.4, 125.5, N'PEN', N'ER 4T25', 3.7563, 865.0, 195.4, 125.5, 1),
    (N'2025-Q1', N'Alicorp Soluciones (B2B)', 192.2, 772.8, 167.4, 98.6, N'PEN', N'ER 1T26 (re-expresado)', 3.6988, 772.8, 167.4, 98.6, 1),
    (N'2025-Q2', N'Alicorp Soluciones (B2B)', 202.0, 779.7, 166.6, 106.1, N'PEN', N'ER 2T26 (re-expresado)', 3.654, 779.7, 166.6, 106.1, 1),
    (N'2025-Q3', N'Alicorp Soluciones (B2B)', 220.2, 854.3, 187.2, 122.4, N'PEN', N'Derivado: anual 2025 - otros trimestres', 3.5337, 854.3, 187.2, 122.4, 1),
    (N'2025-Q4', N'Alicorp Soluciones (B2B)', 213.8, 827.7, 173.6, 100.5, N'PEN', N'ER 4T25', 3.3842, 827.7, 173.6, 100.5, 1),
    (N'2026-Q1', N'Alicorp Soluciones (B2B)', 199.2, 752.4, 165.5, 102.7, N'PEN', N'ER 1T26', 3.387, 752.4, 165.5, 102.7, 1),
    (N'2026-Q2', N'Alicorp Soluciones (B2B)', 204.8, 795.3, 168.7, 99.9, N'PEN', N'ER 2T26', 3.4283, 795.3, 168.7, 99.9, 1),
    (N'2024-Q1', N'Vitapro (Acuicultura)', 138.1, 172.7, 17.0, 6.1, N'USD', N'ER 1T25', 3.7592, 649.2, 63.9, 22.9, 1),
    (N'2024-Q2', N'Vitapro (Acuicultura)', 166.3, 200.8, 23.4, 13.4, N'USD', N'ER 2T25', 3.7445, 751.9, 87.6, 50.2, 1),
    (N'2024-Q3', N'Vitapro (Acuicultura)', 170.3, 206.1, 29.7, 20.7, N'USD', N'ER 3T25', 3.7583, 774.6, 111.6, 77.8, 1),
    (N'2024-Q4', N'Vitapro (Acuicultura)', 197.6, 229.1, 40.2, 30.8, N'USD', N'ER 4T25', 3.7563, 860.6, 151.0, 115.7, 1),
    (N'2025-Q1', N'Vitapro (Acuicultura)', 220.3, 252.0, 47.4, 37.2, N'USD', N'ER 1T26 (re-expresado)', 3.6988, 932.1, 175.3, 137.6, 1),
    (N'2025-Q2', N'Vitapro (Acuicultura)', 226.1, 258.4, 48.1, 40.1, N'USD', N'ER 2T26 (re-expresado)', 3.654, 944.2, 175.8, 146.5, 1),
    (N'2025-Q3', N'Vitapro (Acuicultura)', 232.3, 265.1, 45.9, 36.0, N'USD', N'Derivado: anual 2025 - otros trimestres', 3.5337, 936.8, 162.2, 127.2, 1),
    (N'2025-Q4', N'Vitapro (Acuicultura)', 238.8, 266.3, 45.0, 30.2, N'USD', N'ER 4T25', 3.3842, 901.2, 152.3, 102.2, 1),
    (N'2026-Q1', N'Vitapro (Acuicultura)', 238.4, 259.6, 42.5, 32.4, N'USD', N'ER 1T26', 3.387, 879.3, 143.9, 109.7, 1),
    (N'2026-Q2', N'Vitapro (Acuicultura)', 267.8, 295.3, 47.7, 36.3, N'USD', N'ER 2T26', 3.4283, 1012.4, 163.5, 124.4, 1),
    (N'2024-Q1', N'Negocios Internacionales', 35.4, 244.0, 69.8, 18.5, N'PEN', N'ER 1T25 (tipo de cambio oficial Bolivia)', 3.7592, 244.0, 69.8, 18.5, 1),
    (N'2024-Q2', N'Negocios Internacionales', 39.3, 268.0, 89.4, 36.4, N'PEN', N'ER 2T25 (tipo de cambio oficial Bolivia)', 3.7445, 268.0, 89.4, 36.4, 1),
    (N'2024-Q3', N'Negocios Internacionales', 37.7, 274.6, 100.8, 52.3, N'PEN', N'ER 3T25 (tipo de cambio oficial Bolivia)', 3.7583, 274.6, 100.8, 52.3, 1),
    (N'2024-Q4', N'Negocios Internacionales', 30.1, 62.3, 22.8, 8.1, N'USD', N'ER 4T25 (tipo de cambio oficial Bolivia)', 3.7563, 234.0, 85.6, 30.4, 1),
    (N'2025-Q1', N'Negocios Internacionales', 33.3, 49.4, 13.5, 1.0, N'USD', N'ER 1T26 (re-expresado)', 3.6988, 182.7, 49.9, 3.7, 0),
    (N'2025-Q2', N'Negocios Internacionales', 34.4, 47.8, 16.7, 6.1, N'USD', N'ER 2T26 (re-expresado)', 3.654, 174.7, 61.0, 22.3, 0),
    (N'2025-Q3', N'Negocios Internacionales', 29.9, 51.1, 13.6, 3.6, N'USD', N'Derivado: anual 2025 - otros trimestres', 3.5337, 180.6, 48.1, 12.7, 0),
    (N'2025-Q4', N'Negocios Internacionales', 40.9, 74.3, 18.9, -0.4, N'USD', N'ER 4T25', 3.3842, 251.4, 64.0, -1.4, 0),
    (N'2026-Q1', N'Negocios Internacionales', 40.4, 75.9, 19.6, 4.1, N'USD', N'ER 1T26', 3.387, 257.1, 66.4, 13.9, 0),
    (N'2026-Q2', N'Negocios Internacionales', 42.6, 80.9, 27.6, 14.0, N'USD', N'ER 2T26', 3.4283, 277.3, 94.6, 48.0, 0);

INSERT INTO fact_consolidado (trimestre, volumen_miles_tm, ventas, utilidad_bruta, ebitda_reportado, ebitda_ajustado, utilidad_neta, fuente, partidas_no_recurrentes) VALUES
    (N'2024-Q1', 451.8, 2307.8, 591.8, 286.6, 306.8, 79.8, N'ER 1T25', 20.2),
    (N'2024-Q2', 504.4, 2507.7, 691.6, 366.7, 368.8, 196.0, N'ER 2T25', 2.1),
    (N'2024-Q3', 550.7, 2730.6, 750.2, 425.9, 432.3, 183.1, N'ER 3T25', 6.4),
    (N'2024-Q4', 607.8, 3052.3, 831.3, 381.1, 508.5, -108.4, N'ER 4T25', 127.4),
    (N'2025-Q1', 594.5, 2833.1, 750.2, 428.1, 435.3, 170.0, N'ER 1T26 (re-expresado)', 7.2),
    (N'2025-Q2', 619.4, 2861.7, 757.2, 432.4, 437.3, 166.8, N'ER 2T26 (re-expresado)', 4.9),
    (N'2025-Q3', 647.5, 3008.2, 796.4, 456.1, 467.9, 185.7, N'Derivado: anual 2025 - otros trimestres', 11.8),
    (N'2025-Q4', 661.1, 3060.8, 799.4, 152.8, 436.2, -63.3, N'ER 4T25', 283.4),
    (N'2026-Q1', 645.2, 2930.1, 787.0, 432.8, 459.3, 167.2, N'ER 1T26', 26.5),
    (N'2026-Q2', 684.3, 3154.5, 824.1, 458.2, 470.2, 203.6, N'ER 2T26', 12.0);

INSERT INTO fact_deuda (trimestre, deuda_financiera_neta, deuda_neta_ebitda_x, fuente) VALUES
    (N'2024-Q4', 3090, 1.83, N'ER 4T25'),
    (N'2025-Q1', 3339, 1.85, N'ER 1T25'),
    (N'2025-Q2', 3482, 1.87, N'ER 2T25'),
    (N'2025-Q3', 3695, 1.96, N'ER 3T25'),
    (N'2025-Q4', 3355, 1.85, N'ER 4T25'),
    (N'2026-Q1', 3610, 2.07, N'ER 1T26'),
    (N'2026-Q2', 3850, 2.18, N'ER 2T26');

INSERT INTO control_totales_2024 (alcance, metrica, publicado) VALUES
    (N'Consolidado', 'volumen_miles_tm', 2114.7),
    (N'Consolidado', 'ventas',           10598.3),
    (N'Consolidado', 'utilidad_bruta',   2865.3),
    (N'Consolidado', 'ebitda_ajustado',  1616.4),
    (N'Consolidado', 'ebitda_reportado', 1460.4),
    (N'Consolidado', 'utilidad_neta',    350.5),
    (N'Consumo Masivo Perú',       'volumen_miles_tm', 592.0),
    (N'Consumo Masivo Perú',       'ventas',           3867.4),
    (N'Consumo Masivo Perú',       'utilidad_bruta',   1505.0),
    (N'Consumo Masivo Perú',       'ebitda_ajustado',  861.5),
    (N'Alicorp Soluciones (B2B)',  'volumen_miles_tm', 708.0),
    (N'Alicorp Soluciones (B2B)',  'ventas',           2671.8),
    (N'Alicorp Soluciones (B2B)',  'utilidad_bruta',   599.5),
    (N'Alicorp Soluciones (B2B)',  'ebitda_ajustado',  377.8),
    (N'Vitapro (Acuicultura)',     'volumen_miles_tm', 672.3),
    (N'Vitapro (Acuicultura)',     'ventas',           808.8),
    (N'Vitapro (Acuicultura)',     'utilidad_bruta',   110.4),
    (N'Vitapro (Acuicultura)',     'ebitda_ajustado',  71.0);
GO

SELECT 'dim_trimestre' AS tabla, COUNT(*) AS filas FROM dim_trimestre
UNION ALL SELECT 'fact_unidades', COUNT(*) FROM fact_unidades
UNION ALL SELECT 'fact_consolidado', COUNT(*) FROM fact_consolidado
UNION ALL SELECT 'fact_deuda', COUNT(*) FROM fact_deuda;

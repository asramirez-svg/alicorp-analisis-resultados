-- ¿El crecimiento de 2025 vino de vender más caro o de vender más toneladas?
-- Descomposición del cambio en ventas: efecto precio + efecto volumen + efecto cruzado.
--   precio por tonelada p = ventas / volumen
--   efecto precio  = (p25 - p24) * v24
--   efecto volumen = (v25 - v24) * p24
--   efecto cruzado = (p25 - p24) * (v25 - v24)
WITH anual AS (
    SELECT
        u.unidad,
        SUM(CASE WHEN d.anio = 2024 THEN u.ventas_pen       END) AS ventas_24,
        SUM(CASE WHEN d.anio = 2025 THEN u.ventas_pen       END) AS ventas_25,
        SUM(CASE WHEN d.anio = 2024 THEN u.volumen_miles_tm END) AS vol_24,
        SUM(CASE WHEN d.anio = 2025 THEN u.volumen_miles_tm END) AS vol_25
    FROM fact_unidades AS u
    JOIN dim_trimestre AS d USING (trimestre)
    GROUP BY u.unidad
),
precios AS (
    SELECT *, ventas_24 / vol_24 AS p24, ventas_25 / vol_25 AS p25
    FROM anual
)
SELECT
    unidad,
    ROUND(ventas_25 - ventas_24, 1)        AS delta_ventas,
    ROUND((p25 - p24) * vol_24, 1)         AS efecto_precio,
    ROUND((vol_25 - vol_24) * p24, 1)      AS efecto_volumen,
    ROUND((p25 - p24) * (vol_25 - vol_24), 1) AS efecto_cruzado
FROM precios
ORDER BY delta_ventas DESC;

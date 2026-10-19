-- ¿Cómo evolucionan las ventas frente al mismo trimestre del año anterior? (T-SQL)
USE Alicorp;
WITH trimestres AS (
    SELECT d.orden, d.etiqueta, c.ventas, c.ebitda_ajustado
    FROM fact_consolidado AS c
    JOIN dim_trimestre    AS d ON d.trimestre = c.trimestre
)
SELECT
    etiqueta                                                 AS trimestre,
    ROUND(ventas, 1)                                         AS ventas,
    ROUND(LAG(ventas, 4) OVER (ORDER BY orden), 1)           AS ventas_anio_anterior,
    ROUND(100.0 * (ventas / LAG(ventas, 4) OVER (ORDER BY orden) - 1), 1) AS var_interanual_pct,
    ROUND(100.0 * ebitda_ajustado / ventas, 1)               AS margen_ebitda_pct
FROM trimestres
ORDER BY orden;

-- ¿Cómo evolucionan las ventas frente al mismo trimestre del año anterior?
-- LAG(…, 4) toma el valor de 4 trimestres atrás, es decir, el mismo trimestre del año anterior.
WITH trimestres AS (
    SELECT d.orden, d.etiqueta, c.ventas, c.ebitda_ajustado
    FROM fact_consolidado AS c
    JOIN dim_trimestre    AS d USING (trimestre)
)
SELECT
    etiqueta                                              AS trimestre,
    ROUND(ventas, 1)                                      AS ventas,
    ROUND(LAG(ventas, 4) OVER w, 1)                       AS ventas_anio_anterior,
    ROUND(100.0 * (ventas / LAG(ventas, 4) OVER w - 1), 1) AS var_interanual_pct,
    ROUND(100.0 * ebitda_ajustado / ventas, 1)            AS margen_ebitda_pct
FROM trimestres
WINDOW w AS (ORDER BY orden)
ORDER BY orden;

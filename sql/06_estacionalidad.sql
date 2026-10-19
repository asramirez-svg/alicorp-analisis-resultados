-- ¿Los cuartos trimestres son sistemáticamente peores?
-- Promedio de cada trimestre del año (Q1–Q4) con todos los años disponibles.
SELECT
    'Q' || d.num_trimestre                                     AS trimestre_del_anio,
    COUNT(*)                                                   AS anios,
    ROUND(AVG(100.0 * c.ebitda_ajustado / c.ventas), 1)        AS margen_ebitda_prom_pct,
    ROUND(AVG(100.0 * c.utilidad_neta / c.ventas), 1)          AS margen_neto_prom_pct,
    ROUND(AVG(c.partidas_no_recurrentes), 1)                   AS no_recurrentes_prom
FROM fact_consolidado AS c
JOIN dim_trimestre    AS d USING (trimestre)
GROUP BY d.num_trimestre
ORDER BY d.num_trimestre;

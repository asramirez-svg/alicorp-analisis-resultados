-- Control de calidad: los trimestres de 2024 deben sumar los totales anuales publicados.
-- Se "despivotan" las métricas con UNION ALL y se comparan contra la tabla de control.
WITH t24 AS (
    SELECT trimestre FROM dim_trimestre WHERE anio = 2024
),
calculado AS (
    SELECT 'Consolidado' AS alcance, 'volumen_miles_tm' AS metrica, SUM(volumen_miles_tm) AS valor FROM fact_consolidado WHERE trimestre IN t24
    UNION ALL SELECT 'Consolidado', 'ventas',           SUM(ventas)           FROM fact_consolidado WHERE trimestre IN t24
    UNION ALL SELECT 'Consolidado', 'utilidad_bruta',   SUM(utilidad_bruta)   FROM fact_consolidado WHERE trimestre IN t24
    UNION ALL SELECT 'Consolidado', 'ebitda_ajustado',  SUM(ebitda_ajustado)  FROM fact_consolidado WHERE trimestre IN t24
    UNION ALL SELECT 'Consolidado', 'ebitda_reportado', SUM(ebitda_reportado) FROM fact_consolidado WHERE trimestre IN t24
    UNION ALL SELECT 'Consolidado', 'utilidad_neta',    SUM(utilidad_neta)    FROM fact_consolidado WHERE trimestre IN t24
    UNION ALL SELECT unidad, 'volumen_miles_tm', SUM(volumen_miles_tm) FROM fact_unidades WHERE trimestre IN t24 GROUP BY unidad
    UNION ALL SELECT unidad, 'ventas',           SUM(ventas)           FROM fact_unidades WHERE trimestre IN t24 GROUP BY unidad
    UNION ALL SELECT unidad, 'utilidad_bruta',   SUM(utilidad_bruta)   FROM fact_unidades WHERE trimestre IN t24 GROUP BY unidad
    UNION ALL SELECT unidad, 'ebitda_ajustado',  SUM(ebitda_ajustado)  FROM fact_unidades WHERE trimestre IN t24 GROUP BY unidad
)
SELECT
    c.alcance,
    c.metrica,
    ROUND(c.valor, 1)                             AS calculado,
    k.publicado,
    CASE WHEN ABS(c.valor - k.publicado) <= 0.6 THEN 'OK' ELSE 'FALLA' END AS resultado
FROM calculado            AS c
JOIN control_totales_2024 AS k USING (alcance, metrica)
ORDER BY c.alcance = 'Consolidado' DESC, c.alcance, c.metrica;

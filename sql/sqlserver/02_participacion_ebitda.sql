-- ¿Qué unidad de negocio aporta más al EBITDA del grupo cada año? (T-SQL)
USE Alicorp;
WITH por_unidad AS (
    SELECT d.anio, u.unidad, SUM(u.ebitda_ajustado_pen) AS ebitda_pen
    FROM fact_unidades AS u
    JOIN dim_trimestre AS d ON d.trimestre = u.trimestre
    GROUP BY d.anio, u.unidad
)
SELECT
    anio,
    unidad,
    ROUND(ebitda_pen, 1)                                                    AS ebitda_ajustado_pen,
    ROUND(100.0 * ebitda_pen / SUM(ebitda_pen) OVER (PARTITION BY anio), 1) AS participacion_pct,
    RANK() OVER (PARTITION BY anio ORDER BY ebitda_pen DESC)                AS puesto
FROM por_unidad
ORDER BY anio, puesto;

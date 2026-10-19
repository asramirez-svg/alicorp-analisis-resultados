-- ¿Qué unidad creció más en 2025 y cuál cayó? (T-SQL)
USE Alicorp;
WITH anual AS (
    SELECT
        u.unidad,
        SUM(CASE WHEN d.anio = 2024 THEN u.ventas_pen          END) AS ventas_2024,
        SUM(CASE WHEN d.anio = 2025 THEN u.ventas_pen          END) AS ventas_2025,
        SUM(CASE WHEN d.anio = 2024 THEN u.ebitda_ajustado_pen END) AS ebitda_2024,
        SUM(CASE WHEN d.anio = 2025 THEN u.ebitda_ajustado_pen END) AS ebitda_2025,
        MIN(CAST(u.comparable_con_2024 AS INT))                     AS comparable
    FROM fact_unidades AS u
    JOIN dim_trimestre AS d ON d.trimestre = u.trimestre
    GROUP BY u.unidad
)
SELECT
    RANK() OVER (ORDER BY ebitda_2025 / ebitda_2024 DESC) AS puesto,
    unidad,
    ROUND(100.0 * (ventas_2025 / ventas_2024 - 1), 1)    AS var_ventas_pct,
    ROUND(100.0 * (ebitda_2025 / ebitda_2024 - 1), 1)    AS var_ebitda_pct,
    CASE comparable WHEN 1 THEN N'sí' ELSE N'no (cambio de tipo de cambio en Bolivia)' END AS comparable_2024
FROM anual
ORDER BY puesto;

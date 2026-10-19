-- Control de calidad: los trimestres de 2024 deben sumar los totales anuales publicados. (T-SQL)
-- CROSS APPLY (VALUES …) "despivota" las métricas en filas.
USE Alicorp;
WITH t24 AS (
    SELECT trimestre FROM dim_trimestre WHERE anio = 2024
),
consolidado AS (
    SELECT N'Consolidado' AS alcance, v.metrica, SUM(v.valor) AS valor
    FROM fact_consolidado AS c
    CROSS APPLY (VALUES ('volumen_miles_tm', c.volumen_miles_tm), ('ventas', c.ventas),
                        ('utilidad_bruta', c.utilidad_bruta), ('ebitda_ajustado', c.ebitda_ajustado),
                        ('ebitda_reportado', c.ebitda_reportado), ('utilidad_neta', c.utilidad_neta)) AS v (metrica, valor)
    WHERE c.trimestre IN (SELECT trimestre FROM t24)
    GROUP BY v.metrica
),
unidades AS (
    SELECT u.unidad AS alcance, v.metrica, SUM(v.valor) AS valor
    FROM fact_unidades AS u
    CROSS APPLY (VALUES ('volumen_miles_tm', u.volumen_miles_tm), ('ventas', u.ventas),
                        ('utilidad_bruta', u.utilidad_bruta), ('ebitda_ajustado', u.ebitda_ajustado)) AS v (metrica, valor)
    WHERE u.trimestre IN (SELECT trimestre FROM t24)
    GROUP BY u.unidad, v.metrica
),
calculado AS (
    SELECT * FROM consolidado
    UNION ALL
    SELECT * FROM unidades
)
SELECT
    c.alcance,
    c.metrica,
    ROUND(c.valor, 1) AS calculado,
    k.publicado,
    CASE WHEN ABS(c.valor - k.publicado) <= 0.6 THEN 'OK' ELSE 'FALLA' END AS resultado
FROM calculado            AS c
JOIN control_totales_2024 AS k ON k.alcance = c.alcance AND k.metrica = c.metrica
ORDER BY CASE WHEN c.alcance = N'Consolidado' THEN 0 ELSE 1 END, c.alcance, c.metrica;

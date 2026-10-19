-- ¿Cómo cambia la deuda con las adquisiciones?
-- La deuda es un saldo: se toma el último trimestre disponible de cada año, no la suma del año.
WITH cierre AS (
    SELECT d.anio, d.etiqueta, f.deuda_financiera_neta, f.deuda_neta_ebitda_x
    FROM fact_deuda    AS f
    JOIN dim_trimestre AS d USING (trimestre)
    WHERE d.orden IN (
        SELECT MAX(d2.orden)
        FROM fact_deuda    AS f2
        JOIN dim_trimestre AS d2 USING (trimestre)
        GROUP BY d2.anio
    )
)
SELECT
    anio,
    etiqueta                                   AS trimestre_cierre,
    deuda_financiera_neta,
    deuda_financiera_neta - LAG(deuda_financiera_neta) OVER (ORDER BY anio) AS variacion,
    deuda_neta_ebitda_x                        AS deuda_neta_ebitda
FROM cierre
ORDER BY anio;

-- ¿Cómo cambia la deuda con las adquisiciones? Saldo al último trimestre de cada año. (T-SQL)
USE Alicorp;
WITH cierre AS (
    SELECT d.anio, d.etiqueta, f.deuda_financiera_neta, f.deuda_neta_ebitda_x
    FROM fact_deuda    AS f
    JOIN dim_trimestre AS d ON d.trimestre = f.trimestre
    WHERE d.orden IN (
        SELECT MAX(d2.orden)
        FROM fact_deuda    AS f2
        JOIN dim_trimestre AS d2 ON d2.trimestre = f2.trimestre
        GROUP BY d2.anio
    )
)
SELECT
    anio,
    etiqueta              AS trimestre_cierre,
    deuda_financiera_neta,
    deuda_financiera_neta - LAG(deuda_financiera_neta) OVER (ORDER BY anio) AS variacion,
    deuda_neta_ebitda_x   AS deuda_neta_ebitda
FROM cierre
ORDER BY anio;

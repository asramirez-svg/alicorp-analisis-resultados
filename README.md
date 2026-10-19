# Alicorp: ¿qué está impulsando sus resultados? (2024–2026)

**Augusto Set Ramírez Ames** · Analista de datos · [LinkedIn](https://linkedin.com/in/AugustoRamirezA) · [Portafolio](https://github.com/asramirez-svg)

**Herramientas:** Python (pandas, matplotlib) · SQL (SQLite y SQL Server) · Excel · Power BI (modelo estrella + DAX)

![Alicorp: análisis de resultados 1T24–2T26](img/00_portada.png)

## Resumen
Este análisis estudia qué explica los resultados de **Alicorp**, la mayor empresa de consumo masivo del Perú, entre el 1T24 y el 2T26 (10 trimestres y 4 unidades de negocio). A partir de sus reportes trimestrales públicos y del tipo de cambio del BCRP, construí un dataset trazable y validado (18 de 18 chequeos contra totales publicados), lo modelé en un esquema estrella consultado con SQL y Power BI, y apliqué una descomposición precio-volumen y un análisis de estacionalidad. Los resultados muestran que el crecimiento de 2025 vino casi todo del **volumen** y no del precio, que **Vitapro** fue el motor del año (EBITDA ×2), que las pérdidas de los cuartos trimestres son **contables y no operativas**, y que la **deuda sube con las adquisiciones** (de 1,83x a 2,18x EBITDA).

**Palabras clave:** análisis financiero · consumo masivo · Perú · descomposición precio-volumen · SQL · Power BI

## Contenido
1. [Introducción](#1-introducción)
2. [Datos](#2-datos)
3. [Metodología](#3-metodología)
4. [Resultados](#4-resultados)
5. [Discusión](#5-discusión)
6. [Conclusiones](#6-conclusiones)
7. [Limitaciones y trabajo futuro](#7-limitaciones-y-trabajo-futuro)
8. [Reproducibilidad](#8-reproducibilidad)
9. [Referencias](#9-referencias)

## 1. Introducción
Alicorp opera en cuatro unidades de negocio: Consumo Masivo Perú, Alicorp Soluciones (B2B), Vitapro (acuicultura) y Negocios Internacionales. Entre 2024 y 2026 combinó crecimiento de ventas, adquisiciones de empresas y un cambio contable en Bolivia que hace difícil leer sus resultados trimestre a trimestre.

**Objetivo:** identificar qué impulsa y qué frena los resultados de la empresa, separando lo operativo de lo contable.

**Preguntas de investigación:**
1. ¿Las ventas crecen por precio o por volumen?
2. ¿Qué unidad de negocio impulsa la ganancia y cuál la frena?
3. ¿Por qué la utilidad neta sale negativa en algunos trimestres?
4. ¿Cómo está cambiando la deuda con las adquisiciones?

## 2. Datos
### 2.1 Fuentes
- Seis reportes trimestrales de resultados de Alicorp (Earnings Reports 1T25 a 2T26), que cubren del 1T24 al 2T26.
- Tipo de cambio interbancario promedio del BCRP (serie PN01207PM), consultado por su API pública.

El detalle de cada documento, con enlaces y fecha de extracción, está en [data/raw/fuentes.md](data/raw/fuentes.md).

### 2.2 Tratamiento de los datos
Los reportes no son una base de datos limpia. Estos fueron los problemas y cómo los resolví:

| Problema | Tratamiento |
|---|---|
| Alicorp **re-expresó 2025** al cambiar el tipo de cambio de Bolivia: el mismo trimestre tiene cifras distintas según el reporte | Usar siempre la versión más reciente, con una columna `fuente` en cada fila |
| No hay un 3T25 re-expresado publicado por separado | **Derivarlo**: total anual 2025 − 1T − 2T − 4T |
| Unas unidades reportan en soles y otras en dólares (y Negocios Internacionales cambió de moneda) | Convertir a soles con el tipo de cambio promedio trimestral del **BCRP** |
| Negocios Internacionales 2024 no es comparable con 2025 | Marcarlo con la columna `comparable_con_2024` |

### 2.3 Validación
Los trimestres de 2024 se comparan contra los totales anuales publicados por Alicorp (consolidado y por unidad): **18 de 18 chequeos OK**, con una tolerancia de ±0,6 millones por redondeo. La misma validación se repite en Python y en SQL.

## 3. Metodología
### 3.1 Flujo de trabajo
Un pipeline reproducible de scripts numerados construye el dataset, lo valida, genera los gráficos, calcula el análisis avanzado y corre las consultas SQL (ver [sección 8](#8-reproducibilidad)).

### 3.2 Modelo de datos
Esquema estrella con 3 tablas de hechos (unidades, consolidado y deuda) y 2 dimensiones (trimestre y unidad). El mismo modelo se usa en tres herramientas:
- **SQLite** ([sql/schema.sql](sql/schema.sql)): llaves primarias y foráneas, restricciones `CHECK` y una tabla de control con los totales publicados.
- **SQL Server** ([sql/sqlserver/](sql/sqlserver)): la misma base en T-SQL.
- **Power BI**: medidas DAX documentadas en [docs/documentacion_powerbi.md](docs/documentacion_powerbi.md).

### 3.3 Indicadores
- **EBITDA ajustado:** ganancia operativa antes de depreciación, sin partidas no recurrentes (deterioros, reestructuraciones, gastos de adquisiciones).
- **Margen EBITDA y margen neto:** sobre ventas.
- **Variación interanual:** cada trimestre contra el mismo trimestre del año anterior.
- **Deuda neta / EBITDA:** la deuda se toma como **saldo al cierre** del periodo, no como suma, porque es un stock y no un flujo.

### 3.4 Descomposición precio-volumen
Para cada unidad, el cambio en ventas entre 2024 y 2025 se separa en tres efectos, con el precio por tonelada *p* = ventas / volumen:

| Efecto | Fórmula |
|---|---|
| Precio | (p₂₀₂₅ − p₂₀₂₄) × volumen₂₀₂₄ |
| Volumen | (volumen₂₀₂₅ − volumen₂₀₂₄) × p₂₀₂₄ |
| Cruzado | (p₂₀₂₅ − p₂₀₂₄) × (volumen₂₀₂₅ − volumen₂₀₂₄) |

### 3.5 Estacionalidad
Se promedia cada posición trimestral (Q1 a Q4) con todos los años disponibles, para ver si los cuartos trimestres son peores de forma sistemática o fue algo puntual.

### 3.6 Consultas SQL
Cada pregunta de investigación tiene su consulta:

| Consulta | Pregunta | Técnicas |
|---|---|---|
| [`01_variacion_interanual.sql`](sql/01_variacion_interanual.sql) | ¿Cómo cambian las ventas frente al mismo trimestre del año anterior? | `LAG()`, cláusula `WINDOW` |
| [`02_participacion_ebitda.sql`](sql/02_participacion_ebitda.sql) | ¿Qué unidad aporta más al EBITDA cada año? | `SUM() OVER (PARTITION BY)`, `RANK()` |
| [`03_ranking_crecimiento.sql`](sql/03_ranking_crecimiento.sql) | ¿Qué unidad creció más en 2025? | agregación condicional (`CASE`), `RANK()` |
| [`04_precio_volumen.sql`](sql/04_precio_volumen.sql) | ¿Se creció por precio o por volumen? | CTE encadenadas (`WITH`) |
| [`05_deuda_cierre.sql`](sql/05_deuda_cierre.sql) | ¿Cómo cambia la deuda con las adquisiciones? | subconsulta, saldo de cierre, `LAG()` |
| [`06_estacionalidad.sql`](sql/06_estacionalidad.sql) | ¿Los 4T son sistemáticamente peores? | `GROUP BY` + `AVG()` |
| [`07_control_calidad.sql`](sql/07_control_calidad.sql) | ¿Los datos cuadran con lo publicado? | `UNION ALL`, `JOIN` contra tabla de control |

Ejemplo: participación de cada unidad en el EBITDA del grupo, con una función de ventana por año.

```sql
WITH por_unidad AS (
    SELECT d.anio, u.unidad, SUM(u.ebitda_ajustado_pen) AS ebitda_pen
    FROM fact_unidades AS u
    JOIN dim_trimestre AS d USING (trimestre)
    GROUP BY d.anio, u.unidad
)
SELECT anio, unidad,
       ROUND(100.0 * ebitda_pen / SUM(ebitda_pen) OVER (PARTITION BY anio), 1) AS participacion_pct,
       RANK() OVER (PARTITION BY anio ORDER BY ebitda_pen DESC)               AS puesto
FROM por_unidad
ORDER BY anio, puesto;
```

**Validación cruzada:** `src/05_consultas_sql.py` compara los resultados de SQL con los calculados en Python. La descomposición precio-volumen y la estacionalidad coinciden al decimal.

### 3.7 Dashboard
Dashboard de 6 páginas en Power BI sobre el mismo modelo estrella. Sus capturas están en la [sección 4.5](#45-dashboard).

## 4. Resultados
### 4.1 Ventas: más volumen, menor precio por kilo
En 2025 las ventas subieron **11 %** (S/ 10 598 M → 11 764 M) y el volumen **19 %**. El precio promedio bajó de S/ 5,0 a S/ 4,7 por kilo, porque crecieron más los negocios de alto volumen y bajo precio por kilo (alimento acuícola de Vitapro, insumos B2B) que los de consumo masivo.

La descomposición lo confirma por unidad (tabla 1): en Vitapro y Consumo Masivo Perú el efecto precio fue **negativo** y todo el crecimiento vino del volumen. Solo Alicorp Soluciones (B2B) creció por precio y por volumen a la vez. En Negocios Internacionales, el 90 % de la caída es efecto precio, consistente con el cambio de tipo de cambio en Bolivia.

**Tabla 1.** Variación de ventas 2025 vs. 2024 por efecto (S/ millones).

| Unidad | Δ ventas | Efecto precio | Efecto volumen | Efecto cruzado |
|---|---:|---:|---:|---:|
| Vitapro (Acuicultura) | +678,0 | −314,6 | +1 107,4 | −114,8 |
| Alicorp Soluciones (B2B) | +562,8 | +93,4 | +453,6 | +15,9 |
| Consumo Masivo Perú | +150,6 | −139,6 | +301,1 | −10,9 |
| Negocios Internacionales | −231,2 | −208,4 | −28,6 | +5,8 |

![Ventas consolidadas](img/01_ventas_consolidadas.png)
*Figura 1. Ventas consolidadas por trimestre.*

![Descomposición precio-volumen](img/05_descomposicion_precio_volumen.png)
*Figura 2. Descomposición precio-volumen por unidad de negocio, 2025 vs. 2024.*

### 4.2 Unidades de negocio
- **Vitapro fue el motor de 2025:** su EBITDA ajustado se duplicó (USD 71 M → 143,5 M), su margen pasó de 8,8 % a 13,8 % y su peso en el EBITDA del grupo subió de 16 % a 29 %. En el primer semestre de 2026 vende 13 % más toneladas, pero su EBITDA cae 11 %.
- **Consumo Masivo Perú es el corazón del negocio:** aporta 45–52 % del EBITDA con el mejor margen (≈ 20–22 %). En el primer semestre de 2026 se recupera (ventas +10,6 %, EBITDA +17,7 %), en parte por empresas adquiridas como Inka Crops.
- **Negocios Internacionales cae por un cambio contable:** desde 2025 Alicorp convierte Bolivia con un tipo de cambio de mercado (NIC 21). Sus ventas caen aunque las toneladas casi no cambien, así que 2024 y 2025 no son comparables para esa unidad.

**Tabla 2.** Participación en el EBITDA ajustado del grupo (consulta `02_participacion_ebitda.sql`).

| Año | 1.° | 2.° | 3.° | 4.° |
|---|---|---|---|---|
| 2024 | Consumo Masivo Perú 52,4 % | B2B 23,0 % | Vitapro 16,2 % | Neg. Internacionales 8,4 % |
| 2025 | Consumo Masivo Perú 45,2 % | **Vitapro 28,7 %** | B2B 23,9 % | Neg. Internacionales 2,1 % |

![EBITDA por unidad](img/02_ebitda_por_unidad.png)
*Figura 3. EBITDA ajustado por unidad de negocio.*

### 4.3 Calidad de la utilidad
La utilidad neta fue negativa en el 4T24 (−S/ 108 M) y en el 4T25 (−S/ 63 M), aunque el EBITDA ajustado de esos trimestres fue normal. En el 4T25 hubo **S/ 283 M de partidas no recurrentes**, sobre todo un deterioro de S/ 191 M en Bolivia.

El patrón se repite: el margen EBITDA es parejo todo el año (14,8 %–15,7 %), pero el margen neto cae a **−2,8 % en promedio en Q4**. Las partidas no recurrentes promedian S/ 205 M en Q4, frente a S/ 6–18 M en los otros trimestres.

![EBITDA reportado vs ajustado](img/03_ebitda_reportado_vs_ajustado.png)
*Figura 4. EBITDA reportado vs. ajustado: la brecha son las partidas no recurrentes.*

![Estacionalidad](img/06_estacionalidad_margen.png)
*Figura 5. Margen EBITDA y margen neto promedio por trimestre del año.*

### 4.4 Deuda y adquisiciones
La deuda financiera neta pasó de **S/ 3 090 M (dic-24) a S/ 3 850 M (jun-26)**, +25 %, y el apalancamiento de **1,83x a 2,18x** EBITDA. El aumento acompaña la compra de empresas como Inka Crops, Jabonería Wilson e Industrias del Espino.

![Deuda neta](img/04_deuda_neta.png)
*Figura 6. Deuda financiera neta y deuda neta / EBITDA al cierre de cada trimestre.*

### 4.5 Dashboard
**Página 1 — Resumen ejecutivo:** ventas, variación interanual, margen EBITDA y apalancamiento.

![Dashboard - Resumen ejecutivo](img/07_dashboard_resumen_ejecutivo.png)

**Página 2 — Unidades de negocio:** EBITDA ajustado y participación de cada unidad.

![Dashboard - Unidades de negocio](img/08_dashboard_unidades_negocio.png)

**Página 3 — Calidad de la utilidad:** EBITDA ajustado vs. reportado y utilidad neta por trimestre.

![Dashboard - Calidad de la utilidad](img/09_dashboard_calidad_utilidad.png)

**Página 4 — Deuda y adquisiciones:** deuda financiera neta y deuda neta / EBITDA.

![Dashboard - Deuda y adquisiciones](img/10_dashboard_deuda_adquisiciones.png)

**Página 5 — Notas de datos:** fuente y moneda original de cada fila del dataset.

![Dashboard - Notas de datos](img/11_dashboard_notas_datos.png)

**Página 6 — Precio vs. volumen:** descomposición del crecimiento de 2025 y márgenes promedio por trimestre.

![Dashboard - Precio vs. volumen](img/12_dashboard_precio_volumen.png)

## 5. Discusión
**Respuesta a las preguntas de investigación:**

| Pregunta | Respuesta |
|---|---|
| ¿Precio o volumen? | **Volumen.** En 2025 se vendieron 19 % más toneladas, pero a menor precio promedio por kilo; ninguna unidad creció por subir precios, salvo B2B. |
| ¿Qué unidad impulsa y cuál frena? | **Vitapro impulsó 2025** (EBITDA ×2) y **Consumo Masivo Perú sostiene el negocio** (casi la mitad del EBITDA). **Negocios Internacionales frena**, por el cambio de tipo de cambio en Bolivia. |
| ¿Por qué hay utilidad neta negativa? | Por **partidas contables de cierre de año** (deterioros, reestructuración), no por la operación: el EBITDA de esos trimestres es normal. |
| ¿Cómo cambia la deuda? | **Sube con las adquisiciones:** de 1,83x a 2,18x EBITDA entre dic-24 y jun-26. Manejable, pero en aumento. |

**Implicancias y recomendaciones:**
1. Seguir el **margen EBITDA de Vitapro** cada trimestre: es la unidad más volátil y la que más movió el resultado.
2. Medir el crecimiento de Consumo Masivo Perú **sin las adquisiciones** (orgánico) para saber si las marcas propias crecen solas.
3. No comparar Negocios Internacionales 2024 con 2025 sin advertir el cambio de tipo de cambio.
4. Vigilar que la **deuda neta / EBITDA no pase de ~2,5x** mientras se integran las adquisiciones.
5. Al proyectar un 4T, **presupuestar una partida no recurrente** (promedio histórico ≈ S/ 200 M) en vez de asumir que el EBITDA se traduce directo en utilidad neta.
6. Antes de celebrar un crecimiento de ventas, **separar precio y volumen**: el crecimiento por volumen es más frágil ante una baja de demanda.

## 6. Conclusiones
Alicorp crece, pero crece vendiendo más volumen y no cobrando más. Su ganancia operativa es estable y las caídas de utilidad neta vienen de ajustes contables de fin de año, no del negocio. El riesgo a vigilar es la combinación de un crecimiento que depende del volumen con una deuda que sube por las adquisiciones.

## 7. Limitaciones y trabajo futuro
- Los datos vienen de reportes públicos, no de la contabilidad interna de Alicorp.
- El 3T25 es **derivado** (total anual menos los otros tres trimestres), porque Alicorp aún no publica el 3T25 re-expresado de forma aislada.
- Las cifras en dólares se convirtieron con el tipo de cambio promedio del BCRP, que puede diferir ligeramente del que usa Alicorp.
- La suma de las unidades no es exactamente igual al consolidado, por eliminaciones entre unidades y otros negocios.
- **Trabajo futuro:** incorporar el reporte 3T26 y medir el crecimiento orgánico de Consumo Masivo Perú sin las adquisiciones.

El detalle de cada hallazgo está en [docs/hallazgos.md](docs/hallazgos.md).

## 8. Reproducibilidad
```bash
pip install -r requirements.txt
python src/01_construir_dataset.py   # genera data/processed/*.csv y alicorp_powerbi.xlsx
python src/02_validar.py             # chequea sumas contra los totales publicados
python src/03_graficos.py            # genera los gráficos de img/
python src/04_analisis_avanzado.py   # descomposición precio-volumen + estacionalidad
python src/05_consultas_sql.py       # crea data/alicorp.db, corre las consultas de sql/ y valida contra Python
```
En SQL Server: ejecutar [sql/sqlserver/00_crear_base.sql](sql/sqlserver/00_crear_base.sql), que crea la base y carga los datos, y luego las consultas `01` a `07` de esa carpeta.

```
data/raw/fuentes.md        enlaces a cada reporte y a la API del BCRP
data/processed/            CSV limpios + Excel para Power BI (y resultados de las consultas en sql/)
data/alicorp.db            base SQLite con el modelo estrella
sql/                       esquema y consultas SQL (SQLite); sql/sqlserver/ en T-SQL
src/                       construcción, validación, gráficos, análisis avanzado y consultas
docs/                      hallazgos y documentación técnica del dashboard
img/                       gráficos y capturas del dashboard
powerbi/                   dashboard de Power BI (.pbix)
```

## 9. Referencias
- Alicorp S.A.A. (2025–2026). *Earnings Reports* 1T25, 2T25, 3T25, 4T25, 1T26 y 2T26. Sección Inversionistas de alicorp.com.pe. Enlaces en [data/raw/fuentes.md](data/raw/fuentes.md).
- Banco Central de Reserva del Perú. Serie PN01207PM: tipo de cambio interbancario, promedio mensual. API de estadísticas del BCRP.

*Proyecto personal con información pública. No está afiliado a Alicorp y no es una recomendación de inversión.*

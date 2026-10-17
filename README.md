# Alicorp: ¿qué está impulsando sus resultados? (2024–2026)

Análisis de los resultados trimestrales de **Alicorp**, la mayor empresa de consumo masivo del Perú, con datos públicos: sus reportes de resultados y el tipo de cambio del BCRP. Cubre 10 trimestres, del 1T24 al 2T26, y sus 4 unidades de negocio.

**Herramientas:** Python (pandas, matplotlib) · Excel · Power BI (modelo estrella + DAX)

![Ventas consolidadas](img/01_ventas_consolidadas.png)

## Las preguntas de negocio
1. ¿Las ventas crecen por precio o por volumen?
2. ¿Qué unidad de negocio impulsa la ganancia y cuál la frena?
3. ¿Por qué la utilidad neta sale negativa en algunos trimestres?
4. ¿Cómo está cambiando la deuda con las adquisiciones?

## Hallazgos principales
- **Vende más, pero más barato por kilo:** en 2025 el volumen creció 19 % y las ventas 11 %. El precio promedio bajó de S/ 5,0 a S/ 4,7 por kg porque crecieron más los negocios de alto volumen (alimento acuícola, insumos B2B).
- **Vitapro fue el motor de 2025:** su EBITDA se duplicó (USD 71 M → 143,5 M) y pasó de aportar 16 % a 29 % del EBITDA del grupo. En 2026 se frena: −11 % en el primer semestre.
- **Consumo Masivo Perú es el corazón:** aporta casi la mitad del EBITDA, con el mejor margen (≈ 20 %), y se recupera en 2026 (EBITDA +18 % en el primer semestre).
- **Las pérdidas de los 4T son contables, no operativas:** en el 4T25 hubo S/ 283 M de partidas no recurrentes, sobre todo un deterioro de S/ 191 M en Bolivia.
- **Las adquisiciones suben la deuda:** la deuda neta pasó de S/ 3 090 M a S/ 3 850 M y el apalancamiento de 1,83x a 2,18x.

![EBITDA por unidad](img/02_ebitda_por_unidad.png)

El detalle, con recomendaciones y límites, está en [docs/hallazgos.md](docs/hallazgos.md).

## El reto de los datos (y cómo lo resolví)
Los reportes no son una base de datos limpia:

| Problema | Solución |
|---|---|
| Alicorp **re-expresó 2025** al cambiar el tipo de cambio de Bolivia: el mismo trimestre tiene cifras distintas según el reporte | Usar siempre la versión más reciente, con una columna `fuente` en cada fila |
| No hay un 3T25 re-expresado publicado por separado | **Derivarlo**: total anual 2025 − 1T − 2T − 4T |
| Unas unidades reportan en soles y otras en dólares (y Negocios Internacionales cambió de moneda) | Convertir a soles con el tipo de cambio promedio trimestral del **BCRP** (API pública) |
| Negocios Internacionales 2024 no es comparable con 2025 | Marcarlo con la columna `comparable_con_2024` |
| ¿Están bien copiadas las cifras? | Script de validación: los trimestres de 2024 suman los totales anuales publicados (18 de 18 chequeos OK) |

![EBITDA reportado vs ajustado](img/03_ebitda_reportado_vs_ajustado.png)

## Dashboard en Power BI
Modelo estrella con 3 tablas de hechos (unidades, consolidado, deuda) y 2 dimensiones (trimestre, unidad), más medidas DAX:
- margen EBITDA;
- variación frente al mismo trimestre del año anterior;
- precio por kg;
- participación por unidad;
- deuda como saldo de cierre.

Guía de construcción: [docs/guia_powerbi.md](docs/guia_powerbi.md) · Archivo: `powerbi/alicorp_dashboard.pbix`

![Dashboard - Resumen ejecutivo](img/07_dashboard_resumen_ejecutivo.png)

![Deuda neta](img/04_deuda_neta.png)

## Análisis avanzado: ¿por qué crecieron las ventas, y por qué son tan malos los 4T?
Dos preguntas que el análisis inicial dejaba solo cualitativas, ahora cuantificadas:

**¿El crecimiento de 2025 vino de vender más caro o de vender más?** Descomposición precio-volumen por unidad de negocio (ver [docs/hallazgos.md](docs/hallazgos.md#7-el-crecimiento-de-2025-fue-casi-todo-volumen-no-precio)): en Vitapro y Consumo Masivo Perú, el efecto precio fue **negativo** — todo el crecimiento fue volumen.

![Descomposición precio-volumen](img/05_descomposicion_precio_volumen.png)

**¿Los 4T son realmente peores, o fue casualidad de 2 años?** Promediando cada trimestre (Q1-Q4) con los años disponibles: el margen EBITDA es parejo todo el año (~15 %), pero el margen de utilidad neta se desploma a **−2.8 % en Q4**, por partidas no recurrentes de cierre de año (ver [docs/hallazgos.md](docs/hallazgos.md#8-los-cuartos-trimestres-son-sistemáticamente-peores-en-utilidad-neta-no-en-ebitda)).

![Estacionalidad](img/06_estacionalidad_margen.png)

## Cómo reproducirlo
```bash
pip install -r requirements.txt
python src/01_construir_dataset.py   # genera data/processed/*.csv y alicorp_powerbi.xlsx
python src/02_validar.py             # chequea sumas contra los totales publicados
python src/03_graficos.py            # genera los gráficos de img/
python src/04_analisis_avanzado.py   # descomposición precio-volumen + estacionalidad
```

## Estructura
```
data/raw/fuentes.md        enlaces a cada reporte y a la API del BCRP
data/processed/            CSV limpios + Excel para Power BI
src/                       construcción, validación y gráficos
docs/                      hallazgos y guía de Power BI
img/                       gráficos
powerbi/                   dashboard (.pbix y .pdf)
```

## Fuentes
- Alicorp, Earnings Reports 1T25, 2T25, 3T25, 4T25, 1T26 y 2T26 (sección Inversionistas de alicorp.com.pe). Enlaces en [data/raw/fuentes.md](data/raw/fuentes.md).
- BCRP, serie PN01207PM (tipo de cambio interbancario promedio).

*Proyecto personal con información pública. No está afiliado a Alicorp y no es una recomendación de inversión.*

## Otros proyectos
Parte de mi portafolio de análisis de datos: [github.com/asramirez-svg](https://github.com/asramirez-svg)

**Autor:** Augusto Set Ramírez Ames: analista de datos, IBM Data Analyst Professional Certificate. [LinkedIn](https://linkedin.com/in/AugustoRamirezA)

# Dashboard de Alicorp en Power BI — documentación técnica

Dashboard de 6 páginas construido sobre `data/processed/alicorp_powerbi.xlsx`, el dataset limpio que genera el pipeline de Python de este repositorio. Este documento describe cómo está armado: la carga de datos, el modelo, las medidas DAX y las decisiones de diseño de cada página.

## 1. Carga y preparación de datos
- Fuente: el libro de Excel con 6 hojas: `fact_unidades`, `fact_consolidado`, `fact_deuda`, `dim_trimestre`, `descomposicion_precio_vol` y `estacionalidad_trimestral`.
- En Power Query se fijan los tipos de cada columna:
  - texto: `trimestre`, `unidad`, `moneda`, `fuente`;
  - número decimal: todos los montos;
  - verdadero/falso: `comparable_con_2024`.
- `dim_unidad` se deriva de `fact_unidades` (referencia → solo la columna `unidad` → quitar duplicados), para filtrar todas las tablas de hechos con la misma lista de unidades.

## 2. Modelo de datos (esquema estrella)
Relaciones de uno a varios, con filtro en una sola dirección:

| Desde (1) | Hacia (*) |
|---|---|
| `dim_trimestre[trimestre]` | `fact_unidades[trimestre]` |
| `dim_trimestre[trimestre]` | `fact_consolidado[trimestre]` |
| `dim_trimestre[trimestre]` | `fact_deuda[trimestre]` |
| `dim_unidad[unidad]` | `fact_unidades[unidad]` |

`descomposicion_precio_vol` y `estacionalidad_trimestral` quedan **fuera del esquema estrella** a propósito: ya vienen agregadas (una fila por unidad, o una fila por Q1–Q4), no por trimestre individual. Se usan solas en la página 6.

Otros ajustes:
- `dim_trimestre[etiqueta]` se ordena por la columna `orden`; si no, "1T25" aparecería antes que "4T24".
- Las columnas de las tablas de hechos que ya están en las dimensiones (`trimestre`, `unidad`) están ocultas en la vista de informe.

## 3. Medidas DAX
Todas las medidas viven en una tabla vacía `_Medidas`.

```DAX
Ventas consolidadas = SUM ( fact_consolidado[ventas] )
Utilidad bruta = SUM ( fact_consolidado[utilidad_bruta] )
EBITDA ajustado = SUM ( fact_consolidado[ebitda_ajustado] )
EBITDA reportado = SUM ( fact_consolidado[ebitda_reportado] )
Utilidad neta = SUM ( fact_consolidado[utilidad_neta] )
Volumen (miles TM) = SUM ( fact_consolidado[volumen_miles_tm] )

Margen bruto % = DIVIDE ( [Utilidad bruta], [Ventas consolidadas] )
Margen EBITDA % = DIVIDE ( [EBITDA ajustado], [Ventas consolidadas] )
Precio promedio S/ por kg = DIVIDE ( [Ventas consolidadas], [Volumen (miles TM)] )
No recurrentes = [EBITDA ajustado] - [EBITDA reportado]

-- Variación del último trimestre visible frente al mismo trimestre del año anterior
Var % ventas ultimo trimestre =
VAR ultimo = MAX ( dim_trimestre[orden] )
VAR actual =
    CALCULATE ( [Ventas consolidadas],
        FILTER ( ALL ( dim_trimestre ), dim_trimestre[orden] = ultimo ) )
VAR anterior =
    CALCULATE ( [Ventas consolidadas],
        FILTER ( ALL ( dim_trimestre ), dim_trimestre[orden] = ultimo - 4 ) )
RETURN DIVIDE ( actual - anterior, anterior )

-- Unidades de negocio (todo en soles)
Ventas unidad S/ = SUM ( fact_unidades[ventas_pen] )
EBITDA unidad S/ = SUM ( fact_unidades[ebitda_ajustado_pen] )
Margen EBITDA unidad % = DIVIDE ( [EBITDA unidad S/], [Ventas unidad S/] )
Participación EBITDA % =
DIVIDE ( [EBITDA unidad S/], CALCULATE ( [EBITDA unidad S/], ALL ( dim_unidad ) ) )

-- Deuda: es un saldo, se toma el último trimestre del filtro (no se suma)
Deuda neta =
VAR ultimo = MAX ( fact_deuda[trimestre] )
RETURN CALCULATE ( SUM ( fact_deuda[deuda_financiera_neta] ), fact_deuda[trimestre] = ultimo )
Deuda neta / EBITDA =
VAR ultimo = MAX ( fact_deuda[trimestre] )
RETURN CALCULATE ( SUM ( fact_deuda[deuda_neta_ebitda_x] ), fact_deuda[trimestre] = ultimo )

-- Descomposición precio-volumen (tabla ya agregada)
Efecto precio = SUM ( descomposicion_precio_vol[efecto_precio_pen] )
Efecto volumen = SUM ( descomposicion_precio_vol[efecto_volumen_pen] )
Efecto interacción = SUM ( descomposicion_precio_vol[efecto_cruzado_pen] )

-- Formato condicional de la página 5 (devuelven un color hex)
Color fuente =
VAR f = SELECTEDVALUE ( fact_unidades[fuente] )
RETURN SWITCH ( TRUE (),
    LEFT ( f, 8 ) = "Derivado", "#F7941D",
    CONTAINSSTRING ( f, "re-expresado" ), "#0056A3",
    "#002B5C" )
Color moneda = IF ( SELECTEDVALUE ( fact_unidades[moneda] ) = "USD", "#C0504D", "#002B5C" )
```

Formato de las medidas:
- `%` para márgenes, variaciones y participación;
- `0.00"x"` para Deuda neta / EBITDA;
- separador de miles para los montos.

Por qué la deuda no se suma: la **deuda es un saldo** (una foto al cierre del trimestre) y las **ventas son un flujo** (se acumulan en el período). Sumar la deuda de cuatro trimestres daría un número sin sentido.

## 4. Páginas del informe
Todas las páginas comparten la misma estructura: un título que dice la conclusión, un subtítulo con la unidad de medida y, salvo en la página 6, un segmentador de año arriba a la derecha.

**Página 1 — Resumen ejecutivo**
- 4 tarjetas: Ventas consolidadas, Var % ventas último trimestre vs. año anterior, Margen EBITDA % y Deuda neta / EBITDA.
- Columnas: ventas consolidadas por trimestre (el último trimestre resaltado).
- Línea: margen EBITDA % por trimestre.

**Página 2 — Unidades de negocio**
- Líneas: EBITDA ajustado por unidad y trimestre.
- Columnas apiladas al 100 %: participación de cada unidad en el EBITDA del grupo, por año.
- Matriz unidad × año con ventas, EBITDA y margen, con escala de color en el margen.

**Página 3 — Calidad de la utilidad**
- Columnas agrupadas: EBITDA ajustado vs. reportado por trimestre.
- Columnas: utilidad neta por trimestre (los 4T salen negativos).
- Texto: qué son las partidas no recurrentes y qué pasó en Bolivia en el 4T25.

**Página 4 — Deuda y adquisiciones**
- Columnas: deuda financiera neta por trimestre.
- Línea: deuda neta / EBITDA.
- Texto: las adquisiciones (Inka Crops, Jabonería Wilson, Industrias del Espino) y su efecto en el apalancamiento.

**Página 5 — Notas de datos**
- Tabla de trazabilidad con `trimestre`, `unidad`, `moneda` y `fuente`, con formato condicional por tipo de fuente (re-expresado, derivado) y moneda (USD).
- Cuatro notas: la re-expresión de 2025, el 3T25 derivado, la conversión de dólares con el tipo de cambio del BCRP y la validación contra los totales anuales.

**Página 6 — Precio vs. volumen y estacionalidad**
- Barras apiladas: efecto volumen, precio e interacción en la variación de ventas 2025 vs. 2024, por unidad.
- Columnas + línea: margen EBITDA promedio (columnas) y margen neto promedio (línea) por trimestre del año. Los dos ejes usan el mismo rango para que ambos porcentajes sean comparables.
- Esta página no tiene segmentador de año: la descomposición compara dos años fijos y la estacionalidad promedia todos los años disponibles.

## 5. Decisiones de diseño
- Paleta corporativa: azul marino `#002B5C` para títulos, azul `#0056A3` para la cifra principal, naranja `#F7941D` para destacar, y un color fijo por unidad en todas las páginas.
- Títulos que dicen la conclusión y no solo el dato: "Vitapro duplicó su EBITDA en 2025", no "EBITDA por unidad".
- Montos y porcentajes van en gráficos separados; el único gráfico combinado (página 6) compara dos porcentajes en la misma escala.

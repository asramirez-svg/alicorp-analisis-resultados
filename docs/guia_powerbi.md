# Guía paso a paso — Dashboard de Alicorp en Power BI

Objetivo: armar un dashboard de 4 páginas con `data/processed/alicorp_powerbi.xlsx`. Cada paso practica una habilidad que evalúa el examen **PL-300**; la etiqueta [PL-300] dice cuál.

## 1. Cargar los datos [PL-300: Preparar los datos]
1. Power BI Desktop → **Inicio → Obtener datos → Libro de Excel** → elige `alicorp_powerbi.xlsx`.
2. Marca las 4 hojas: `fact_unidades`, `fact_consolidado`, `fact_deuda`, `dim_trimestre` → **Transformar datos**.
3. En Power Query revisa los tipos de cada columna:
   - texto: `trimestre`, `unidad`, `moneda`, `fuente`;
   - número decimal: todos los montos;
   - verdadero/falso: `comparable_con_2024`.
4. Crea la tabla de unidades: clic derecho en `fact_unidades` → **Referencia** → deja solo la columna `unidad` → **Quitar duplicados** → renómbrala `dim_unidad`.
5. **Cerrar y aplicar**.

> Trampa: si Excel guardó los números como texto, Power BI no los suma. Revisa que el ícono de la columna sea "1.2" y no "ABC".

## 2. Modelo de datos (esquema estrella) [PL-300: Modelar los datos]
Ve a la vista **Modelo** y crea estas relaciones (uno a varios, filtro en una dirección):

| Desde (1) | Hacia (*) |
|---|---|
| `dim_trimestre[trimestre]` | `fact_unidades[trimestre]` |
| `dim_trimestre[trimestre]` | `fact_consolidado[trimestre]` |
| `dim_trimestre[trimestre]` | `fact_deuda[trimestre]` |
| `dim_unidad[unidad]` | `fact_unidades[unidad]` |

Luego ajusta el orden de las etiquetas:
- En `dim_trimestre`, selecciona `etiqueta` → **Herramientas de columnas → Ordenar por columna → orden**. Si no lo haces, "1T25" aparece antes que "4T24".
- Oculta en la vista de informe las columnas de las tablas de hechos que ya están en las dimensiones (`trimestre`, `unidad`).

## 3. Medidas DAX [PL-300: Modelar los datos]
Crea una tabla vacía `_Medidas` (**Inicio → Especificar datos** → Cargar) y agrega estas medidas:

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

-- Mismo trimestre del año anterior (4 trimestres antes)
Ventas año anterior =
VAR ordenActual = MAX ( dim_trimestre[orden] )
RETURN
    CALCULATE ( [Ventas consolidadas],
        FILTER ( ALL ( dim_trimestre ), dim_trimestre[orden] = ordenActual - 4 ) )

Var % ventas vs año anterior =
DIVIDE ( [Ventas consolidadas] - [Ventas año anterior], [Ventas año anterior] )

-- Unidades de negocio (todo en soles)
Ventas unidad S/ = SUM ( fact_unidades[ventas_pen] )
EBITDA unidad S/ = SUM ( fact_unidades[ebitda_ajustado_pen] )
Margen EBITDA unidad % = DIVIDE ( [EBITDA unidad S/], [Ventas unidad S/] )
Participación EBITDA % =
DIVIDE ( [EBITDA unidad S/], CALCULATE ( [EBITDA unidad S/], ALL ( dim_unidad ) ) )

-- Deuda (es un saldo: se toma el último trimestre del filtro, no se suma)
Deuda neta =
VAR ultimo = MAX ( fact_deuda[trimestre] )
RETURN CALCULATE ( SUM ( fact_deuda[deuda_financiera_neta] ), fact_deuda[trimestre] = ultimo )
Deuda neta / EBITDA =
VAR ultimo = MAX ( fact_deuda[trimestre] )
RETURN CALCULATE ( SUM ( fact_deuda[deuda_neta_ebitda_x] ), fact_deuda[trimestre] = ultimo )
```

Formato:
- `%` para las medidas de margen, variación y participación;
- `0.00"x"` para Deuda neta / EBITDA;
- separador de miles para los montos.

> Concepto clave de entrevista: la **deuda es un saldo** (una foto al cierre) y las **ventas son un flujo** (se acumulan). Por eso las ventas se suman y la deuda no.

## 4. Páginas del informe [PL-300: Visualizar y analizar]

**Página 1 — Resumen ejecutivo**
- 4 tarjetas: Ventas consolidadas, Var % ventas vs año anterior, Margen EBITDA %, Deuda neta / EBITDA.
- Gráfico de columnas: Ventas consolidadas por `dim_trimestre[etiqueta]`.
- Gráfico de líneas: Margen EBITDA % por trimestre.
- Segmentador de `dim_trimestre[anio]` arriba.

**Página 2 — Unidades de negocio**
- Gráfico de líneas: EBITDA unidad S/ por trimestre, con `dim_unidad[unidad]` en Leyenda.
- Columnas apiladas al 100 %: Participación EBITDA % por `anio` y unidad.
- Matriz: filas = unidad; columnas = anio; valores = Ventas unidad S/, EBITDA unidad S/, Margen EBITDA unidad %.
- Formato condicional en el margen: escala de un solo color.

**Página 3 — Calidad de la utilidad**
- Columnas agrupadas: EBITDA ajustado vs EBITDA reportado por trimestre.
- Columnas: Utilidad neta por trimestre (los 4T salen negativos).
- Cuadro de texto: qué son las partidas no recurrentes y qué pasó en Bolivia en el 4T25.

**Página 4 — Deuda y adquisiciones**
- Columnas: Deuda neta por trimestre, con etiqueta de datos.
- Línea: Deuda neta / EBITDA.
- Cuadro de texto: adquisiciones (Inka Crops, Jabonería Wilson, Industrias del Espino).

**Página 5 — Notas de datos** (muy valorada en entrevistas)
- Tabla con `trimestre`, `unidad`, `moneda` y `fuente`.
- Texto que explique la re-expresión de 2025, el 3T25 derivado y la conversión de dólares con el tipo de cambio del BCRP.

## 5. Diseño
- Una paleta: azul para la cifra principal; un color fijo por unidad en todas las páginas (Vista → Temas → Personalizar).
- Títulos que digan la conclusión y no solo el dato: "Vitapro duplicó su EBITDA en 2025", no "EBITDA por unidad".
- Sin gráficos de doble eje: si comparas montos y porcentajes, usa dos gráficos.

## 6. Publicar y llevarlo a GitHub
1. Guarda `alicorp_dashboard.pbix` en la carpeta `powerbi/` del repositorio.
2. **Archivo → Exportar → PDF** → `powerbi/alicorp_dashboard.pdf`.
3. Toma capturas de cada página → `img/dashboard_p1.png`, etc. → agrégalas al README (GitHub no muestra archivos .pbix).
4. Opcional: publica en el servicio de Power BI. "Publicar en la web" requiere una cuenta laboral o educativa y que tu organización lo permita; tu correo PUCP podría funcionar.

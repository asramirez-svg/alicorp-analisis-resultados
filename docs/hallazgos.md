# Hallazgos — Alicorp, 1T24 a 2T26

Todas las cifras están en S/ millones salvo que se indique otra cosa. "EBITDA ajustado" es la ganancia operativa antes de depreciación, sin contar gastos que no se repiten (deterioros, reestructuraciones, compras de empresas). Es la mejor medida de cuánto genera el negocio en el día a día.

## 1. Alicorp vende más toneladas, pero cada tonelada vale menos
- En 2025 las ventas subieron **11 %** (de 10 598 a 11 764) y el volumen **19 %** (de 2 115 a 2 523 miles de TM).
- El precio promedio bajó de **S/ 5,0 a S/ 4,7 por kilo**. No es que Alicorp cobre menos por cada producto: crecieron más los negocios de alto volumen y bajo precio por kilo, como el alimento para peces y camarones de Vitapro (≈ S/ 4 por kilo) y la harina e insumos de B2B, que los productos de consumo masivo (≈ S/ 6,3 por kilo).
- **Por qué importa:** al comparar periodos hay que separar el efecto precio del efecto mezcla de productos.

## 2. Vitapro fue el motor de 2025 y en 2026 se está frenando
- El EBITDA ajustado de Vitapro se duplicó en 2025 (USD 71 M → USD 143,5 M) y su margen pasó de 8,8 % a 13,8 %.
- Su participación en el EBITDA del grupo subió de **16 % a 29 %**.
- En el primer semestre de 2026 vende 13 % más toneladas, pero su EBITDA cae **11 %** en dólares frente al primer semestre de 2025: crece en volumen, pero gana menos por tonelada.

## 3. Consumo Masivo Perú sigue siendo el corazón del negocio
- Aporta **casi la mitad del EBITDA** (45–52 %) y tiene el margen más alto (≈ 20–22 %).
- En 2025 su margen se apretó (de 22,3 % a 20,1 %).
- En el primer semestre de 2026 se recupera: ventas +10,6 % y EBITDA +17,7 %. Influyen las marcas y empresas adquiridas (Inka Crops desde marzo de 2026), así que parte del crecimiento no es orgánico.

## 4. Bolivia: un cambio contable que se ve como una caída
- Desde 2025, Alicorp convierte los resultados de Bolivia con un **tipo de cambio de mercado** en lugar del oficial (por la norma contable NIC 21). Por eso las ventas de Negocios Internacionales caen en 2025, aunque las toneladas casi no cambien.
- Es un **quiebre de serie**: 2024 no es comparable con 2025 para esta unidad. En el dataset lo marca la columna `comparable_con_2024`.
- En el 4T25 Alicorp registró un deterioro de **S/ 191 M** en Bolivia, es decir, bajó el valor contable de esos activos.

## 5. Los cuartos trimestres esconden pérdidas no recurrentes
- La utilidad neta fue **negativa en el 4T24 (−108) y en el 4T25 (−63)**, aunque el EBITDA ajustado de esos trimestres fue normal.
- En el 4T25 hubo **S/ 283 M** de partidas no recurrentes: deterioros por 247, reestructuración por 28 y gastos de compras de empresas por 8.
- **Por qué importa:** quien mira solo la utilidad neta del trimestre concluye que la empresa "perdió plata"; el EBITDA ajustado muestra que la operación siguió estable.

## 6. Las compras de empresas se pagan con deuda
- La deuda financiera neta pasó de **S/ 3 090 (dic-24) a S/ 3 850 (jun-26)**, un aumento de 25 %.
- El apalancamiento subió de **1,83x a 2,18x**. Eso significa que la deuda equivale a poco más de 2 años de EBITDA.
- Sigue en un rango manejable, pero la tendencia es a subir.

## 7. El crecimiento de 2025 fue casi todo volumen, no precio
Descomponiendo el cambio en ventas de 2025 vs 2024 en efecto precio y efecto volumen (cuánto del cambio viene de cobrar distinto vs. de vender más toneladas):
- **Vitapro:** +S/ 678 M en ventas, pero el efecto precio fue **negativo** (−S/ 315 M) — todo el crecimiento vino de vender más toneladas (+S/ 1 107 M por volumen). Cada tonelada se vendió más barata que en 2024.
- **Negocios Internacionales:** cayó S/ 231 M, y el 90 % de esa caída es efecto precio (−S/ 208 M), no menos toneladas vendidas — coherente con el cambio de tipo de cambio de Bolivia (punto 4).
- **Consumo Masivo Perú:** su crecimiento (+S/ 151 M, solo 3.9 %) también es puro volumen; el efecto precio fue negativo (−S/ 140 M), otra señal de que la mezcla de productos se movió hacia lo más barato.
- **Alicorp Soluciones (B2B):** es la única unidad con efecto precio y efecto volumen positivos a la vez — creció de forma más "sana".
- **Por qué importa:** confirma con números (no solo con el argumento cualitativo del punto 1) que ninguna unidad está subiendo precios reales — el crecimiento depende de vender más.

## 8. Los cuartos trimestres son sistemáticamente peores en utilidad neta, no en EBITDA
Promediando cada posición trimestral (Q1, Q2, Q3, Q4) con los años disponibles (2024-2026):
- El **margen EBITDA ajustado es parejo** todo el año: 14.8 % en Q1 hasta 15.7 % en Q3 — no hay estacionalidad operativa real.
- El **margen de utilidad neta se desploma en Q4**: pasa de +5 % a +7 % en Q1-Q3 a **−2.8 % en promedio en Q4**.
- La causa es contable, no operativa: las partidas no recurrentes promedian **S/ 205 M en Q4**, muy por encima de los S/ 6-18 M de los otros trimestres — es cuando Alicorp registra los deterioros y ajustes de cierre de año.
- **Por qué importa:** si alguien proyecta el 4T26 solo mirando el EBITDA, va a sobreestimar la utilidad neta — hay que presupuestar una partida no recurrente de cierre de año, no asumir que no va a pasar.

## Qué haría un analista con esto (recomendaciones)
1. Seguir el **margen EBITDA de Vitapro** cada trimestre, porque es la unidad más volátil y la que más movió el resultado.
2. Medir el crecimiento de Consumo Masivo Perú **sin las adquisiciones** (orgánico) para saber si las marcas propias crecen solas.
3. No comparar Negocios Internacionales 2024 con 2025 sin advertir el cambio de tipo de cambio.
4. Vigilar que la deuda neta / EBITDA no pase de ~2,5x mientras se integran las adquisiciones.
5. Al proyectar un 4T, presupuestar una partida no recurrente (el promedio histórico es ~S/ 200 M), no asumir que el margen EBITDA se traduce directo a utilidad neta.
6. Para cualquier unidad, revisar si el crecimiento de ventas es por precio o por volumen antes de celebrarlo — en 2025 casi todo fue volumen, lo que es más frágil ante una baja de demanda.

## Límites del análisis
- Los datos vienen de reportes trimestrales públicos, no de la contabilidad interna de Alicorp.
- El 3T25 es **derivado** (total anual menos los otros tres trimestres), porque Alicorp aún no publica el 3T25 re-expresado de forma aislada.
- Las cifras en dólares se convirtieron con el tipo de cambio promedio trimestral del BCRP. Alicorp usa sus propios tipos de cambio, así que puede haber diferencias pequeñas.
- La suma de las unidades no es exactamente igual al consolidado, por eliminaciones entre unidades y por otros negocios.

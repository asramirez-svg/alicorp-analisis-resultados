# Fuentes de datos

Todos son documentos públicos.

## Reportes de resultados de Alicorp (Earnings Reports, en español)
| Reporte | Se usa para | Enlace |
|---|---|---|
| 1T25 | 1T24; deuda a mar-25 | https://www.alicorp.com.pe/media/conference_calls/Alicorp%20Earnings%20Report%201Q25%20ES_VF.pdf |
| 2T25 | 2T24; deuda a jun-25 | https://www.alicorp.com.pe/media/conference_calls/Alicorp-Earnings-Report-2Q25-ES_VF.pdf |
| 3T25 | 3T24; deuda a sep-25; 3T25 original (solo para comparar) | https://www.alicorp.com.pe/media/conference_calls/Alicorp%20Earnings%20Report%203Q25%20ES_VF.pdf |
| 4T25 | 4T24, 4T25, totales anuales 2024 y 2025, puente de EBITDA, cambio de tipo de cambio en Bolivia | https://www.alicorp.com.pe/media/investor_kit/Alicorp%20Earnings%20Report%204Q25%20ES_VF.pdf |
| 1T26 | 1T26 y 1T25 re-expresado | https://www.alicorp.com.pe/media/investor_kit/Alicorp%20Earnings%20Report%201Q26%20ES_VF.pdf |
| 2T26 | 2T26 y 2T25 re-expresado | https://www.alicorp.com.pe/media/investor_kit/1784902560_AlicorpEarningsReport2Q26ES_VF.pdf |

## Tipo de cambio — Banco Central de Reserva del Perú (BCRP)
- Serie `PN01207PM`: tipo de cambio interbancario, promedio mensual (S/ por US$).
- API: https://estadisticas.bcrp.gob.pe/estadisticas/series/api/PN01207PM/json/2024-1/2026-6
- Se usa el promedio de los 3 meses de cada trimestre para convertir a soles las unidades que reportan en dólares (Vitapro, y Negocios Internacionales desde el 4T24).

Fecha de extracción: 12 de octubre de 2026.

"""
Construye el dataset trimestral de Alicorp (1T24-2T26) a partir de los
Earnings Reports públicos de la empresa (ver data/raw/fuentes.md).

Regla de versiones: para cada trimestre se usa la cifra MÁS RECIENTE publicada.
- 2024: cifras originales (Alicorp no re-expresó 2024).
- 2025: cifras re-expresadas por el cambio de tipo de cambio en Bolivia (NIC 21).
  1T25 y 2T25 salen de los reportes 1T26 y 2T26; 4T25 del reporte 4T25;
  3T25 se DERIVA: total anual 2025 (reporte 4T25) - 1T25 - 2T25 - 4T25.
- 2026: cifras de los reportes 1T26 y 2T26.
Montos en millones; volumen en miles de toneladas (TM).
"""
import pandas as pd
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "data" / "processed"
OUT.mkdir(parents=True, exist_ok=True)

# ---------- 1. Resultados por unidad de negocio ----------
# (trimestre, volumen, ventas, utilidad_bruta, ebitda_ajustado, moneda, fuente)
U = {
 "Consumo Masivo Perú": [
  ("2024-Q1",136.0, 884.3,344.2,204.0,"PEN","ER 1T25"),
  ("2024-Q2",139.3, 909.9,375.7,207.6,"PEN","ER 2T25"),
  ("2024-Q3",152.4, 981.9,386.2,221.2,"PEN","ER 3T25"),
  ("2024-Q4",164.4,1091.3,398.9,228.7,"PEN","ER 4T25"),
  ("2025-Q1",148.6, 944.2,357.2,197.9,"PEN","ER 1T26 (re-expresado)"),
  ("2025-Q2",156.9, 960.6,353.3,175.1,"PEN","ER 2T26 (re-expresado)"),
  ("2025-Q3",None,None,None,None,"PEN","Derivado: anual 2025 - otros trimestres"),
  ("2025-Q4",167.7,1078.0,409.1,228.2,"PEN","ER 4T25"),
  ("2026-Q1",167.2,1039.0,414.6,240.5,"PEN","ER 1T26"),
  ("2026-Q2",169.1,1068.5,396.9,198.5,"PEN","ER 2T26"),
 ],
 "Alicorp Soluciones (B2B)": [
  ("2024-Q1",142.3,530.1,114.1, 67.3,"PEN","ER 1T25"),
  ("2024-Q2",159.6,577.9,138.6, 86.6,"PEN","ER 2T25"),
  ("2024-Q3",190.3,698.7,151.4, 98.4,"PEN","ER 3T25"),
  ("2024-Q4",215.8,865.0,195.4,125.5,"PEN","ER 4T25"),
  ("2025-Q1",192.2,772.8,167.4, 98.6,"PEN","ER 1T26 (re-expresado)"),
  ("2025-Q2",202.0,779.7,166.6,106.1,"PEN","ER 2T26 (re-expresado)"),
  ("2025-Q3",None,None,None,None,"PEN","Derivado: anual 2025 - otros trimestres"),
  ("2025-Q4",213.8,827.7,173.6,100.5,"PEN","ER 4T25"),
  ("2026-Q1",199.2,752.4,165.5,102.7,"PEN","ER 1T26"),
  ("2026-Q2",204.8,795.3,168.7, 99.9,"PEN","ER 2T26"),
 ],
 "Vitapro (Acuicultura)": [
  ("2024-Q1",138.1,172.7,17.0, 6.1,"USD","ER 1T25"),
  ("2024-Q2",166.3,200.8,23.4,13.4,"USD","ER 2T25"),
  ("2024-Q3",170.3,206.1,29.7,20.7,"USD","ER 3T25"),
  ("2024-Q4",197.6,229.1,40.2,30.8,"USD","ER 4T25"),
  ("2025-Q1",220.3,252.0,47.4,37.2,"USD","ER 1T26 (re-expresado)"),
  ("2025-Q2",226.1,258.4,48.1,40.1,"USD","ER 2T26 (re-expresado)"),
  ("2025-Q3",None,None,None,None,"USD","Derivado: anual 2025 - otros trimestres"),
  ("2025-Q4",238.8,266.3,45.0,30.2,"USD","ER 4T25"),
  ("2026-Q1",238.4,259.6,42.5,32.4,"USD","ER 1T26"),
  ("2026-Q2",267.8,295.3,47.7,36.3,"USD","ER 2T26"),
 ],
 "Negocios Internacionales": [
  ("2024-Q1",35.4,244.0, 69.8,18.5,"PEN","ER 1T25 (tipo de cambio oficial Bolivia)"),
  ("2024-Q2",39.3,268.0, 89.4,36.4,"PEN","ER 2T25 (tipo de cambio oficial Bolivia)"),
  ("2024-Q3",37.7,274.6,100.8,52.3,"PEN","ER 3T25 (tipo de cambio oficial Bolivia)"),
  ("2024-Q4",30.1, 62.3, 22.8, 8.1,"USD","ER 4T25 (tipo de cambio oficial Bolivia)"),
  ("2025-Q1",33.3, 49.4, 13.5, 1.0,"USD","ER 1T26 (re-expresado)"),
  ("2025-Q2",34.4, 47.8, 16.7, 6.1,"USD","ER 2T26 (re-expresado)"),
  ("2025-Q3",None,None,None,None,"USD","Derivado: anual 2025 - otros trimestres"),
  ("2025-Q4",40.9, 74.3, 18.9,-0.4,"USD","ER 4T25"),
  ("2026-Q1",40.4, 75.9, 19.6, 4.1,"USD","ER 1T26"),
  ("2026-Q2",42.6, 80.9, 27.6,14.0,"USD","ER 2T26"),
 ],
}
# Totales anuales 2025 (ER 4T25) para derivar el 3T25: volumen, ventas, UB, EBITDA aj.
ANUAL_2025 = {
 "Consumo Masivo Perú":      (638.2,4018.0,1518.2,807.8),
 "Alicorp Soluciones (B2B)": (828.2,3234.5, 694.8,427.6),
 "Vitapro (Acuicultura)":    (917.5,1041.8, 186.4,143.5),
 "Negocios Internacionales": (138.5, 222.6,  62.7, 10.3),
}
METRICAS = ["volumen_miles_tm","ventas","utilidad_bruta","ebitda_ajustado"]

filas = []
for unidad, regs in U.items():
    regs = [list(r) for r in regs]
    otros_2025 = [r for r in regs if r[0].startswith("2025") and r[0] != "2025-Q3"]
    q3 = next(r for r in regs if r[0] == "2025-Q3")
    for i in range(4):
        q3[1+i] = round(ANUAL_2025[unidad][i] - sum(r[1+i] for r in otros_2025), 1)
    for t, vol, ven, ub, eb, mon, src in regs:
        filas.append(dict(trimestre=t, unidad=unidad, volumen_miles_tm=vol, ventas=ven,
                          utilidad_bruta=ub, ebitda_ajustado=eb, moneda=mon, fuente=src))
uni = pd.DataFrame(filas)

# ---------- 2. Tipo de cambio BCRP (PN01207PM, promedio mensual interbancario) ----------
tc_mensual = {
 "2024-01":3.7407,"2024-02":3.8279,"2024-03":3.7090,"2024-04":3.7150,"2024-05":3.7317,"2024-06":3.7867,
 "2024-07":3.7641,"2024-08":3.7419,"2024-09":3.7690,"2024-10":3.7544,"2024-11":3.7791,"2024-12":3.7355,
 "2025-01":3.7469,"2025-02":3.6969,"2025-03":3.6525,"2025-04":3.7000,"2025-05":3.6599,"2025-06":3.6022,
 "2025-07":3.5569,"2025-08":3.5424,"2025-09":3.5018,"2025-10":3.4132,"2025-11":3.3726,"2025-12":3.3669,
 "2026-01":3.3561,"2026-02":3.3566,"2026-03":3.4484,"2026-04":3.4435,"2026-05":3.4353,"2026-06":3.4060,
}
tc = pd.Series(tc_mensual).rename("tc").to_frame()
tc.index = pd.PeriodIndex(tc.index, freq="M")
tc["trimestre"] = [f"{p.year}-Q{p.quarter}" for p in tc.index]
tc_trim = tc.groupby("trimestre")["tc"].mean().round(4).rename("tc_promedio_pen_usd").reset_index()

uni = uni.merge(tc_trim, on="trimestre")
factor = uni["moneda"].map({"PEN":1.0}).fillna(uni["tc_promedio_pen_usd"])
for m in ["ventas","utilidad_bruta","ebitda_ajustado"]:
    uni[f"{m}_pen"] = (uni[m] * factor).round(1)
uni["comparable_con_2024"] = ~((uni["unidad"]=="Negocios Internacionales") & (uni["trimestre"]>="2025"))

# ---------- 3. Consolidado ----------
C = [ # trimestre, volumen, ventas, UB, EBITDA reportado, EBITDA ajustado, utilidad neta, fuente
 ("2024-Q1",451.8,2307.8,591.8,286.6,306.8, 79.8,"ER 1T25"),
 ("2024-Q2",504.4,2507.7,691.6,366.7,368.8,196.0,"ER 2T25"),
 ("2024-Q3",550.7,2730.6,750.2,425.9,432.3,183.1,"ER 3T25"),
 ("2024-Q4",607.8,3052.3,831.3,381.1,508.5,-108.4,"ER 4T25"),
 ("2025-Q1",594.5,2833.1,750.2,428.1,435.3,170.0,"ER 1T26 (re-expresado)"),
 ("2025-Q2",619.4,2861.7,757.2,432.4,437.3,166.8,"ER 2T26 (re-expresado)"),
 ("2025-Q3",None,None,None,None,None,None,"Derivado: anual 2025 - otros trimestres"),
 ("2025-Q4",661.1,3060.8,799.4,152.8,436.2,-63.3,"ER 4T25"),
 ("2026-Q1",645.2,2930.1,787.0,432.8,459.3,167.2,"ER 1T26"),
 ("2026-Q2",684.3,3154.5,824.1,458.2,470.2,203.6,"ER 2T26"),
]
ANUAL_C_2025 = (2522.5,11763.8,3103.2,1469.4,1776.7,459.2)
C = [list(r) for r in C]
q3 = next(r for r in C if r[0]=="2025-Q3")
otros = [r for r in C if r[0].startswith("2025") and r[0]!="2025-Q3"]
for i in range(6):
    q3[1+i] = round(ANUAL_C_2025[i] - sum(r[1+i] for r in otros), 1)
con = pd.DataFrame(C, columns=["trimestre","volumen_miles_tm","ventas","utilidad_bruta",
                               "ebitda_reportado","ebitda_ajustado","utilidad_neta","fuente"])
con["partidas_no_recurrentes"] = (con["ebitda_ajustado"] - con["ebitda_reportado"]).round(1)

# ---------- 4. Deuda neta (saldo al cierre del trimestre) ----------
deuda = pd.DataFrame([
 ("2024-Q4",3090,1.83,"ER 4T25"),
 ("2025-Q1",3339,1.85,"ER 1T25"),
 ("2025-Q2",3482,1.87,"ER 2T25"),
 ("2025-Q3",3695,1.96,"ER 3T25"),
 ("2025-Q4",3355,1.85,"ER 4T25"),
 ("2026-Q1",3610,2.07,"ER 1T26"),
 ("2026-Q2",3850,2.18,"ER 2T26"),
], columns=["trimestre","deuda_financiera_neta","deuda_neta_ebitda_x","fuente"])

# ---------- 5. Calendario ----------
cal = pd.DataFrame({"trimestre": con["trimestre"]})
cal["anio"] = cal["trimestre"].str[:4].astype(int)
cal["num_trimestre"] = cal["trimestre"].str[-1].astype(int)
cal["etiqueta"] = cal["num_trimestre"].astype(str) + "T" + cal["anio"].astype(str).str[-2:]
cal["orden"] = range(1, len(cal)+1)
cal = cal.merge(tc_trim, on="trimestre")

uni.to_csv(OUT/"fact_unidades.csv", index=False, encoding="utf-8-sig")
con.to_csv(OUT/"fact_consolidado.csv", index=False, encoding="utf-8-sig")
deuda.to_csv(OUT/"fact_deuda.csv", index=False, encoding="utf-8-sig")
cal.to_csv(OUT/"dim_trimestre.csv", index=False, encoding="utf-8-sig")
with pd.ExcelWriter(OUT/"alicorp_powerbi.xlsx") as xw:
    for name, df in [("fact_unidades",uni),("fact_consolidado",con),("fact_deuda",deuda),("dim_trimestre",cal)]:
        df.to_excel(xw, sheet_name=name, index=False)
print("Dataset generado en", OUT)

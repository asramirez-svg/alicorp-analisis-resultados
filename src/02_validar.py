"""Chequeos de calidad: los trimestres deben sumar los totales anuales publicados."""
import pandas as pd
from pathlib import Path
P = Path(__file__).resolve().parents[1]/"data"/"processed"
uni = pd.read_csv(P/"fact_unidades.csv"); con = pd.read_csv(P/"fact_consolidado.csv")
fallas = 0
def chk(nombre, calc, publicado, tol=0.6):
    global fallas
    ok = abs(calc-publicado) <= tol
    fallas += (not ok)
    print(f"{'OK ' if ok else 'FALLA'} {nombre}: suma={calc:,.1f} publicado={publicado:,.1f}")
c24 = con[con.trimestre.str.startswith("2024")]
for col, pub in [("volumen_miles_tm",2114.7),("ventas",10598.3),("utilidad_bruta",2865.3),
                 ("ebitda_ajustado",1616.4),("ebitda_reportado",1460.4),("utilidad_neta",350.5)]:
    chk(f"Consolidado 2024 {col}", c24[col].sum(), pub)
anual24 = {"Consumo Masivo Perú":(592.0,3867.4,1505.0,861.5),
           "Alicorp Soluciones (B2B)":(708.0,2671.8,599.5,377.8),
           "Vitapro (Acuicultura)":(672.3,808.8,110.4,71.0)}
for u,v in anual24.items():
    d = uni[(uni.unidad==u)&uni.trimestre.str.startswith("2024")]
    for col,pub in zip(["volumen_miles_tm","ventas","utilidad_bruta","ebitda_ajustado"],v):
        chk(f"{u} 2024 {col}", d[col].sum(), pub)
# El 3T25 derivado debe parecerse al 3T25 original (diferencia = re-expresión Bolivia)
orig_3t25 = {"Consumo Masivo Perú":1031.8,"Alicorp Soluciones (B2B)":857.8,"Vitapro (Acuicultura)":265.1}
for u,o in orig_3t25.items():
    d = uni[(uni.unidad==u)&(uni.trimestre=="2025-Q3")].ventas.iloc[0]
    print(f"INFO {u} ventas 3T25 derivado={d} vs original={o} (dif {d-o:+.1f})")
print("\nFallas:", fallas)

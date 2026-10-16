"""Gráficos de referencia para el README (el dashboard final se arma en Power BI)."""
import pandas as pd, matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from pathlib import Path
R = Path(__file__).resolve().parents[1]; P = R/"data"/"processed"; IMG = R/"img"; IMG.mkdir(exist_ok=True)
u = pd.read_csv(P/"fact_unidades.csv"); c = pd.read_csv(P/"fact_consolidado.csv")
d = pd.read_csv(P/"fact_deuda.csv"); cal = pd.read_csv(P/"dim_trimestre.csv")
lab = dict(zip(cal.trimestre, cal.etiqueta))
COL = {"Consumo Masivo Perú":"#2a78d6","Alicorp Soluciones (B2B)":"#eb6834",
       "Vitapro (Acuicultura)":"#1baf7a","Negocios Internacionales":"#eda100"}
INK, MUTED, GRID, SURF = "#0b0b0b", "#52514e", "#e6e5e1", "#fcfcfb"
plt.rcParams.update({"font.family":"DejaVu Sans","font.size":10,"axes.edgecolor":GRID,
    "axes.labelcolor":MUTED,"xtick.color":MUTED,"ytick.color":MUTED,"axes.spines.top":False,
    "axes.spines.right":False,"figure.facecolor":SURF,"axes.facecolor":SURF})
def base(ax, title, sub):
    ax.set_title(title, loc="left", fontsize=13, color=INK, fontweight="bold", pad=22)
    ax.text(0, 1.02, sub, transform=ax.transAxes, color=MUTED, fontsize=9)
    ax.grid(axis="y", color=GRID, lw=0.8); ax.set_axisbelow(True)
x = [lab[t] for t in c.trimestre]

# 1. Ventas consolidadas
fig, ax = plt.subplots(figsize=(9,4.2))
ax.bar(x, c.ventas, color="#2a78d6", width=0.6)
for i,v in enumerate(c.ventas): ax.text(i, v+40, f"{v:,.0f}", ha="center", fontsize=8, color=MUTED)
ax.axvline(3.5, color=MUTED, lw=1, ls="--"); ax.text(3.55, 3300, "2025: cifras re-expresadas\n(tipo de cambio Bolivia)", fontsize=8, color=MUTED, va="top")
base(ax, "Ventas netas consolidadas por trimestre", "S/ millones · Fuente: Earnings Reports Alicorp")
ax.set_ylim(0,3400); fig.tight_layout(); fig.savefig(IMG/"01_ventas_consolidadas.png", dpi=150); plt.close()

# 2. EBITDA ajustado por unidad (S/)
fig, ax = plt.subplots(figsize=(9,4.6))
for un, col in COL.items():
    s = u[u.unidad==un]; ax.plot([lab[t] for t in s.trimestre], s.ebitda_ajustado_pen, color=col, lw=2, marker="o", ms=4)
    ax.text(9.15, s.ebitda_ajustado_pen.iloc[-1], un, color=INK, fontsize=8, va="center")
ax.axhline(0, color=MUTED, lw=0.8)
base(ax, "EBITDA ajustado por unidad de negocio", "S/ millones · Vitapro y Neg. Internacionales convertidos con TC promedio BCRP del trimestre")
ax.set_xlim(-0.3, 12.5); fig.tight_layout(); fig.savefig(IMG/"02_ebitda_por_unidad.png", dpi=150); plt.close()

# 3. EBITDA reportado vs ajustado
fig, ax = plt.subplots(figsize=(9,4.2)); import numpy as np; i = np.arange(len(x))
ax.bar(i-0.2, c.ebitda_ajustado, 0.38, color="#2a78d6", label="EBITDA ajustado")
ax.bar(i+0.2, c.ebitda_reportado, 0.38, color="#eb6834", label="EBITDA reportado")
for k in [3,7]: ax.text(k+0.2, c.ebitda_reportado[k]+12, f"−{c.partidas_no_recurrentes[k]:.0f}", ha="center", fontsize=9, color=INK, fontweight="bold")
ax.set_xticks(i, x); ax.legend(frameon=False, loc="upper left", fontsize=9, ncol=2)
base(ax, "Los 4T concentran deterioros y gastos extraordinarios", "S/ millones · número = partidas no recurrentes · 4T25: deterioro Bolivia (S/ 191 M), inmueble ocioso, reestructuración")
ax.set_ylim(0,600); fig.tight_layout(); fig.savefig(IMG/"03_ebitda_reportado_vs_ajustado.png", dpi=150); plt.close()

# 4. Deuda neta
fig, ax = plt.subplots(figsize=(9,4.2)); xd = [lab[t] for t in d.trimestre]
ax.bar(xd, d.deuda_financiera_neta, color="#2a78d6", width=0.55)
for k,(v,r) in enumerate(zip(d.deuda_financiera_neta, d.deuda_neta_ebitda_x)):
    ax.text(k, v+60, f"{v:,.0f}\n{r:.2f}x", ha="center", fontsize=8, color=INK)
base(ax, "Deuda financiera neta y apalancamiento", "S/ millones al cierre · etiqueta: deuda neta / EBITDA ajustado (veces)")
ax.set_ylim(0,4600); fig.tight_layout(); fig.savefig(IMG/"04_deuda_neta.png", dpi=150); plt.close()
print("ok")

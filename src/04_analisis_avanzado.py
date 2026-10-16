"""
Análisis avanzado — Alicorp 1T24-2T26

Dos preguntas de negocio nuevas que no estaban cuantificadas en la primera
versión del proyecto:

1. Descomposición precio-volumen: de cuánto crecieron las ventas por vender
   más toneladas vs. por vender más caro cada kilo (efecto precio, efecto
   volumen y el término cruzado), por unidad de negocio, 2025 vs 2024.

2. Estacionalidad: ¿los cuartos trimestres son sistemáticamente peores en
   margen EBITDA y utilidad neta, o es casualidad de 2024-2025? Se promedia
   cada posición trimestral (Q1, Q2, Q3, Q4) con los años disponibles.

Genera:
  data/processed/descomposicion_precio_volumen.csv
  data/processed/estacionalidad_trimestral.csv
  img/05_descomposicion_precio_volumen.png
  img/06_estacionalidad_margen.png
"""
import pandas as pd
import matplotlib.pyplot as plt
from pathlib import Path

BASE = Path(__file__).resolve().parent.parent
PROC = BASE / "data" / "processed"
IMG = BASE / "img"


def cargar():
    unidades = pd.read_csv(PROC / "fact_unidades.csv")
    consolidado = pd.read_csv(PROC / "fact_consolidado.csv")
    dim = pd.read_csv(PROC / "dim_trimestre.csv")
    return unidades, consolidado, dim


def descomposicion_precio_volumen(unidades: pd.DataFrame, dim: pd.DataFrame) -> pd.DataFrame:
    """Descompone el cambio en ventas (PEN) de 2025 vs 2024 en efecto precio,
    efecto volumen y término cruzado, por unidad de negocio.

    Fórmula estándar de descomposición de variación (variance decomposition):
      Delta_ventas = (P1-P0)*V0        -> efecto precio
                   + P0*(V1-V0)        -> efecto volumen
                   + (P1-P0)*(V1-V0)   -> término cruzado (interacción)
    donde P = precio promedio por tonelada (ventas_pen / volumen_miles_tm)
          V = volumen (miles de TM)
    """
    u = unidades.merge(dim[["trimestre", "anio"]], on="trimestre", how="left")
    u["precio_pen_ton"] = u["ventas_pen"] / u["volumen_miles_tm"]

    anual = (
        u.groupby(["unidad", "anio"])
        .agg(ventas_pen=("ventas_pen", "sum"), volumen_miles_tm=("volumen_miles_tm", "sum"))
        .reset_index()
    )
    anual["precio_pen_ton"] = anual["ventas_pen"] / anual["volumen_miles_tm"]

    filas = []
    for unidad, g in anual.groupby("unidad"):
        g = g.set_index("anio")
        if 2024 not in g.index or 2025 not in g.index:
            continue
        p0, v0, s0 = g.loc[2024, ["precio_pen_ton", "volumen_miles_tm", "ventas_pen"]]
        p1, v1, s1 = g.loc[2025, ["precio_pen_ton", "volumen_miles_tm", "ventas_pen"]]

        efecto_precio = (p1 - p0) * v0
        efecto_volumen = p0 * (v1 - v0)
        efecto_cruzado = (p1 - p0) * (v1 - v0)
        delta_total = s1 - s0

        # chequeo: los 3 efectos deben sumar exactamente el delta total
        assert abs((efecto_precio + efecto_volumen + efecto_cruzado) - delta_total) < 0.5, unidad

        filas.append(
            {
                "unidad": unidad,
                "ventas_2024_pen": round(s0, 1),
                "ventas_2025_pen": round(s1, 1),
                "delta_ventas_pen": round(delta_total, 1),
                "delta_ventas_pct": round(100 * delta_total / s0, 1),
                "efecto_precio_pen": round(efecto_precio, 1),
                "efecto_volumen_pen": round(efecto_volumen, 1),
                "efecto_cruzado_pen": round(efecto_cruzado, 1),
                "efecto_precio_pct_del_delta": round(100 * efecto_precio / delta_total, 1) if delta_total else None,
                "efecto_volumen_pct_del_delta": round(100 * efecto_volumen / delta_total, 1) if delta_total else None,
            }
        )

    out = pd.DataFrame(filas).sort_values("delta_ventas_pen", ascending=False)
    out.to_csv(PROC / "descomposicion_precio_volumen.csv", index=False)
    return out


def estacionalidad(consolidado: pd.DataFrame, dim: pd.DataFrame) -> pd.DataFrame:
    """Promedia margen EBITDA y utilidad neta por posición trimestral
    (Q1/Q2/Q3/Q4) usando todos los años disponibles para esa posición."""
    c = consolidado.merge(dim[["trimestre", "num_trimestre", "anio"]], on="trimestre", how="left")
    c["margen_ebitda_ajustado"] = 100 * c["ebitda_ajustado"] / c["ventas"]
    c["margen_utilidad_neta"] = 100 * c["utilidad_neta"] / c["ventas"]

    out = (
        c.groupby("num_trimestre")
        .agg(
            n_anios=("anio", "nunique"),
            margen_ebitda_prom=("margen_ebitda_ajustado", "mean"),
            margen_neta_prom=("margen_utilidad_neta", "mean"),
            utilidad_neta_prom=("utilidad_neta", "mean"),
            partidas_no_recurrentes_prom=("partidas_no_recurrentes", "mean"),
        )
        .reset_index()
        .round(1)
    )
    out.insert(1, "etiqueta", out["num_trimestre"].map({1: "Q1", 2: "Q2", 3: "Q3", 4: "Q4"}))
    out.to_csv(PROC / "estacionalidad_trimestral.csv", index=False)
    return out


def fig_descomposicion(df: pd.DataFrame):
    fig, ax = plt.subplots(figsize=(9, 5))
    unidades = df["unidad"]
    ax.barh(unidades, df["efecto_precio_pen"], label="Efecto precio", color="#4C72B0")
    ax.barh(unidades, df["efecto_volumen_pen"], left=df["efecto_precio_pen"], label="Efecto volumen", color="#DD8452")
    base = df["efecto_precio_pen"] + df["efecto_volumen_pen"]
    ax.barh(unidades, df["efecto_cruzado_pen"], left=base, label="Interacción", color="#C0C0C0")
    ax.axvline(0, color="black", linewidth=0.8)
    ax.set_xlabel("S/ millones (contribución al cambio en ventas, 2025 vs 2024)")
    ax.set_title("¿El crecimiento de ventas 2025 vino de vender más caro o de vender más?")
    ax.legend()
    fig.tight_layout()
    fig.savefig(IMG / "05_descomposicion_precio_volumen.png", dpi=130)
    plt.close(fig)


def fig_estacionalidad(df: pd.DataFrame):
    fig, ax1 = plt.subplots(figsize=(8, 5))
    x = df["etiqueta"]
    ax1.bar(x, df["margen_ebitda_prom"], color="#55A868", alpha=0.85, label="Margen EBITDA ajustado prom.")
    ax1.set_ylabel("Margen EBITDA ajustado (%)")
    ax2 = ax1.twinx()
    ax2.plot(x, df["margen_neta_prom"], color="#C44E52", marker="o", linewidth=2, label="Margen utilidad neta prom.")
    ax2.axhline(0, color="#C44E52", linewidth=0.6, linestyle="--")
    ax2.set_ylabel("Margen utilidad neta (%)")
    lines1, labels1 = ax1.get_legend_handles_labels()
    lines2, labels2 = ax2.get_legend_handles_labels()
    ax1.legend(lines1 + lines2, labels1 + labels2, loc="upper right")
    ax1.set_title("Estacionalidad: margen promedio por posición trimestral (2024-2026)")
    fig.tight_layout()
    fig.savefig(IMG / "06_estacionalidad_margen.png", dpi=130)
    plt.close(fig)


def main():
    unidades, consolidado, dim = cargar()

    print("== Descomposición precio-volumen (2025 vs 2024) ==")
    desc = descomposicion_precio_volumen(unidades, dim)
    print(desc.to_string(index=False))
    fig_descomposicion(desc)

    print("\n== Estacionalidad trimestral ==")
    est = estacionalidad(consolidado, dim)
    print(est.to_string(index=False))
    fig_estacionalidad(est)

    # Agrega las 2 tablas nuevas como hojas del Excel que usa Power BI,
    # sin tocar las 4 hojas que ya existen.
    xlsx_path = PROC / "alicorp_powerbi.xlsx"
    with pd.ExcelWriter(xlsx_path, mode="a", engine="openpyxl", if_sheet_exists="replace") as xw:
        desc.to_excel(xw, sheet_name="descomposicion_precio_vol", index=False)
        est.to_excel(xw, sheet_name="estacionalidad_trimestral", index=False)

    print("\nListo: data/processed/descomposicion_precio_volumen.csv, "
          "data/processed/estacionalidad_trimestral.csv, "
          "img/05_descomposicion_precio_volumen.png, img/06_estacionalidad_margen.png, "
          "+ 2 hojas nuevas en alicorp_powerbi.xlsx")


if __name__ == "__main__":
    main()

"""
Capa SQL del proyecto.

1. Crea una base SQLite (data/alicorp.db) con el modelo estrella de sql/schema.sql
   y la llena con los CSV limpios de data/processed/.
2. Ejecuta cada consulta de sql/ (01_…07_) y guarda su resultado en data/processed/sql/.
3. Validación cruzada: los resultados de SQL deben coincidir con los calculados en
   Python (descomposición precio-volumen y estacionalidad) y el control de calidad
   debe dar 18 de 18 chequeos OK.
"""
import shutil
import sqlite3
import tempfile
from pathlib import Path

import pandas as pd

R = Path(__file__).resolve().parents[1]
P = R / "data" / "processed"
SQL = R / "sql"
OUT = P / "sql"
DB = R / "data" / "alicorp.db"


def construir_base(ruta):
    con = sqlite3.connect(ruta)
    con.execute("PRAGMA foreign_keys = ON")
    con.executescript((SQL / "schema.sql").read_text(encoding="utf-8"))
    lee = lambda f: pd.read_csv(P / f, encoding="utf-8-sig")
    dim_t = lee("dim_trimestre.csv")
    uni = lee("fact_unidades.csv")
    uni["comparable_con_2024"] = uni["comparable_con_2024"].astype(int)
    dim_u = uni[["unidad"]].drop_duplicates()
    # Orden de carga: primero dimensiones, luego hechos (respeta las llaves foráneas)
    for nombre, df in [("dim_trimestre", dim_t), ("dim_unidad", dim_u), ("fact_unidades", uni),
                       ("fact_consolidado", lee("fact_consolidado.csv")), ("fact_deuda", lee("fact_deuda.csv"))]:
        df.to_sql(nombre, con, if_exists="append", index=False)
    con.commit()
    return con


def main():
    OUT.mkdir(exist_ok=True)
    tmp = Path(tempfile.mkdtemp()) / "alicorp.db"
    con = construir_base(tmp)
    resultados = {}
    for f in sorted(SQL.glob("0*.sql")):
        df = pd.read_sql_query(f.read_text(encoding="utf-8"), con)
        df.to_csv(OUT / f"{f.stem}.csv", index=False, encoding="utf-8")
        resultados[f.stem] = df
        print(f"\n=== {f.name} ({len(df)} filas)\n{df.to_string(index=False)}")
    con.close()
    shutil.copyfile(tmp, DB)

    # Validación cruzada SQL vs Python
    fallas = 0
    pv_sql = resultados["04_precio_volumen"].set_index("unidad")
    pv_py = pd.read_csv(P / "descomposicion_precio_volumen.csv").set_index("unidad")
    for col_sql, col_py in [("delta_ventas", "delta_ventas_pen"), ("efecto_precio", "efecto_precio_pen"),
                            ("efecto_volumen", "efecto_volumen_pen"), ("efecto_cruzado", "efecto_cruzado_pen")]:
        dif = (pv_sql[col_sql] - pv_py.loc[pv_sql.index, col_py]).abs().max()
        fallas += dif > 0.15
        print(f"{'OK ' if dif <= 0.15 else 'FALLA'} precio-volumen {col_sql}: diferencia máx. {dif:.2f}")
    es_sql = resultados["06_estacionalidad"]
    es_py = pd.read_csv(P / "estacionalidad_trimestral.csv")
    for col_sql, col_py in [("margen_ebitda_prom_pct", "margen_ebitda_prom"), ("margen_neto_prom_pct", "margen_neta_prom")]:
        dif = (es_sql[col_sql].values - es_py[col_py].values).__abs__().max()
        fallas += dif > 0.15
        print(f"{'OK ' if dif <= 0.15 else 'FALLA'} estacionalidad {col_sql}: diferencia máx. {dif:.2f}")
    control = resultados["07_control_calidad"]
    ok = (control["resultado"] == "OK").sum()
    fallas += ok != len(control)
    print(f"Control de calidad en SQL: {ok} de {len(control)} chequeos OK")
    print(f"\nBase creada en {DB.relative_to(R)} · Fallas: {fallas}")
    if fallas:
        raise SystemExit(1)


if __name__ == "__main__":
    main()

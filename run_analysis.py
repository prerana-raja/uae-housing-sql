"""Run every query in sql/ against uae_housing.db and save results to results/*.csv."""
import csv
import sqlite3
from pathlib import Path

here = Path(__file__).parent
db = here / "uae_housing.db"
if not db.exists():
    raise SystemExit("uae_housing.db not found - run `python load_data.py` first.")

con = sqlite3.connect(db)
out_dir = here / "results"
out_dir.mkdir(exist_ok=True)

for path in sorted((here / "sql").glob("0*.sql")):
    cur = con.execute(path.read_text())
    cols = [c[0] for c in cur.description]
    rows = cur.fetchall()
    with open(out_dir / f"{path.stem}.csv", "w", newline="") as f:
        w = csv.writer(f)
        w.writerow(cols)
        w.writerows(rows)
    print(f"\n=== {path.stem} ({len(rows)} rows) ===")
    print(" | ".join(cols))
    for r in rows[:12]:
        print(" | ".join(str(v) for v in r))
con.close()

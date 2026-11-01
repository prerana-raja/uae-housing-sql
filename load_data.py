"""Load data/uae_housing_clean.csv into a SQLite database (standard library only)."""
import csv
import sqlite3
from pathlib import Path

here = Path(__file__).parent
db_path = here / "uae_housing.db"

con = sqlite3.connect(db_path)
con.executescript((here / "sql" / "schema.sql").read_text())

INT_COLS = {"listing_id", "bedrooms", "bathrooms", "handover_year"}
REAL_COLS = {"price_aed", "area_sqft", "price_per_sqft"}

rows = []
with open(here / "data" / "uae_housing_clean.csv", newline="", encoding="utf-8") as f:
    reader = csv.DictReader(f)
    cols = reader.fieldnames
    for r in reader:
        row = []
        for c in cols:
            v = r[c].strip()            # source file has stray leading spaces in text columns
            row.append(int(float(v)) if c in INT_COLS else float(v) if c in REAL_COLS else v)
        rows.append(row)

con.executemany(f"INSERT INTO listings ({','.join(cols)}) VALUES ({','.join('?' * len(cols))})", rows)
con.commit()
print(f"Loaded {len(rows):,} listings into {db_path.name}")
con.close()

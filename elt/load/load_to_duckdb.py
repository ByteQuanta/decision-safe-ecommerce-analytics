from dotenv import load_dotenv
load_dotenv()

import duckdb
import os
from pathlib import Path

RAW_DIR = Path("data/raw/olist")
DB_PATH = os.getenv("DUCKDB_PATH", "warehouse/duckdb/analytics.duckdb")

RAW_TABLE_PREFIX = "raw_"

def main():
    print(f"Connecting to DuckDB at {DB_PATH}")
    conn = duckdb.connect(DB_PATH)

    csv_files = list(RAW_DIR.glob("*.csv"))
    if not csv_files:
        raise RuntimeError("No CSV files found in raw directory")

    for csv_path in csv_files:
        table_name = RAW_TABLE_PREFIX + csv_path.stem.lower()
        print(f"Loading {csv_path.name} → {table_name}")

        conn.execute(f"""
            CREATE OR REPLACE TABLE {table_name} AS
            SELECT * FROM read_csv_auto('{csv_path.as_posix()}');
        """)

    conn.close()
    print("All raw tables loaded successfully.")

if __name__ == "__main__":
    main()

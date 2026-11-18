"""Load the raw diabetes-risk CSV into SQLite without altering source values."""

from pathlib import Path
import sqlite3

import pandas as pd


DATA_PATH = Path("data/raw/diabetes_risk/diabetes_risk_prediction_dataset.csv")
DB_PATH = Path("data/processed/diabetes_risk/diabetes_risk.sqlite")
TABLE_NAME = "diabetes_risk"


def main() -> None:
    df = pd.read_csv(DATA_PATH)
    DB_PATH.parent.mkdir(parents=True, exist_ok=True)

    with sqlite3.connect(DB_PATH) as connection:
        df.to_sql(TABLE_NAME, connection, if_exists="replace", index=False)
        row_count = connection.execute(
            f"SELECT COUNT(*) FROM {TABLE_NAME}"
        ).fetchone()[0]

    print(f"Loaded {row_count:,} rows into {DB_PATH}")
    print(f"SQLite table: {TABLE_NAME}")


if __name__ == "__main__":
    main()

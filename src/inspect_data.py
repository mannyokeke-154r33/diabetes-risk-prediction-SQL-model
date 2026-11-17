from pathlib import Path

import pandas as pd


DATA_PATH = Path("data/raw/archive/diabetic_data.csv")

def main() -> None:
    df = pd.read_csv(
        DATA_PATH,
        na_values=["?"],
        dtype={"payer_code": "string"},
        low_memory=False,
    )


    print("Shape:", df.shape)

    print("\nColumns:")
    print(df.columns.tolist())

    print("\nTop 5 missing columns:")
    print(df.isna().sum().sort_values(ascending=False).head(5))

    print("\nDuplicate rows:")
    print(df.duplicated().sum())

    print("\nReadmission labels:")
    print(df["readmitted"].value_counts(dropna=False))

    print("\nData type counts:")
    print(df.dtypes.value_counts())

if __name__ == "__main__":
    main()
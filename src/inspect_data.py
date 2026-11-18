"""Inspect the newer Kaggle diabetes-risk dataset."""

from pathlib import Path

import pandas as pd


DATA_PATH = Path("data/raw/diabetes_risk/diabetes_risk_prediction_dataset.csv")


def main() -> None:
    df = pd.read_csv(DATA_PATH)

    print("Shape:", df.shape)
    print("\nColumns:")
    print(df.columns.tolist())
    print("\nData type counts:")
    print(df.dtypes.value_counts())
    print("\nDuplicate rows:", df.duplicated().sum())
    print("\nTarget distribution:")
    print(df["Diabetes_Risk"].value_counts(dropna=False))
    print("\nMissing-value counts:")
    print(df.isna().sum().sort_values(ascending=False).head(15))


if __name__ == "__main__":
    main()

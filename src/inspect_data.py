"""Stage 1 exercise: inspect the raw Kaggle encounter file."""

from pathlib import Path

import pandas as pd


DATA_PATH = Path("data/raw/diabetic_data.csv")


def main() -> None:
    # TODO 1: Load DATA_PATH into a pandas DataFrame named df.
    # Hint: pd.read_csv(DATA_PATH)
    pass

    # TODO 2: Print the number of rows and columns.
    # TODO 3: Print the column names.
    # TODO 4: Print the five columns with the most missing values.
    # TODO 5: Print the number of fully duplicated rows.


if __name__ == "__main__":
    main()

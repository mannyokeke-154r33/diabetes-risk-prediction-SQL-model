"""Train and evaluate a from-scratch classifier on the Kaggle risk dataset."""

from pathlib import Path
import sqlite3

import numpy as np
import pandas as pd


DB_PATH = Path("data/processed/diabetes_risk/diabetes_risk.sqlite")
TABLE_NAME = "diabetes_risk"

FEATURES = [
    "Age",
    "BMI",
    "Waist_Circumference_cm",
    "Blood_Glucose",
    "HbA1c",
    "Fasting_Blood_Sugar",
    "Insulin_Level",
    "Blood_Pressure_Systolic",
    "Blood_Pressure_Diastolic",
    "Total_Cholesterol",
    "HDL",
    "LDL",
    "Triglycerides",
    "Heart_Rate",
    "Exercise_Hours_Per_Week",
    "Daily_Walking_Minutes",
    "Sleep_Hours",
    "Daily_Water_Intake_L",
]


class DiabetesPredictor:
    """Binary logistic regression trained with full-batch gradient descent."""

    def __init__(self, learning_rate: float = 0.05, iterations: int = 2500, l2: float = 1e-3):
        self.learning_rate = learning_rate
        self.iterations = iterations
        self.l2 = l2
        self.weights: np.ndarray | None = None
        self.bias = 0.0
        self.mean: np.ndarray | None = None
        self.scale: np.ndarray | None = None

    @staticmethod
    def _sigmoid(values: np.ndarray) -> np.ndarray:
        return 1.0 / (1.0 + np.exp(-np.clip(values, -30, 30)))

    def _standardize(self, features: np.ndarray) -> np.ndarray:
        if self.mean is None or self.scale is None:
            raise RuntimeError("The model must be fitted before prediction.")
        return (features - self.mean) / self.scale

    def fit(self, features: np.ndarray, target: np.ndarray) -> "DiabetesPredictor":
        features = np.asarray(features, dtype=float)
        target = np.asarray(target, dtype=float).reshape(-1)

        self.mean = features.mean(axis=0)
        self.scale = features.std(axis=0) + 1e-8
        standardized = self._standardize(features)

        rows, columns = standardized.shape
        self.weights = np.zeros(columns)
        self.bias = 0.0

        for _ in range(self.iterations):
            probabilities = self._sigmoid(standardized @ self.weights + self.bias)
            error = probabilities - target
            gradient_weights = standardized.T @ error / rows + self.l2 * self.weights
            gradient_bias = error.mean()
            self.weights -= self.learning_rate * gradient_weights
            self.bias -= self.learning_rate * gradient_bias

        return self

    def predict_proba(self, features: np.ndarray) -> np.ndarray:
        if self.weights is None:
            raise RuntimeError("The model must be fitted before prediction.")
        standardized = self._standardize(np.asarray(features, dtype=float))
        return self._sigmoid(standardized @ self.weights + self.bias)

    def predict(self, features: np.ndarray, threshold: float = 0.5) -> np.ndarray:
        return (self.predict_proba(features) >= threshold).astype(int)


def load_data() -> pd.DataFrame:
    with sqlite3.connect(DB_PATH) as connection:
        data = pd.read_sql_query(f"SELECT * FROM {TABLE_NAME}", connection)

    labels = data["Diabetes_Risk"].str.strip().str.lower()
    data["target"] = labels.map({"high": 1, "low": 0, "moderate": 0})
    if data["target"].isna().any():
        unknown = sorted(labels[data["target"].isna()].unique())
        raise ValueError(f"Unexpected Diabetes_Risk labels: {unknown}")
    return data


def stratified_split(
    data: pd.DataFrame, test_fraction: float = 0.2
) -> tuple[pd.DataFrame, pd.DataFrame]:
    rng = np.random.default_rng(42)
    train_indices: list[int] = []
    test_indices: list[int] = []

    for label in sorted(data["target"].unique()):
        # Copy because pandas may return a read-only NumPy view here, while
        # the split needs to shuffle the indices in place.
        indices = data.index[data["target"] == label].to_numpy(copy=True)
        rng.shuffle(indices)
        test_size = int(len(indices) * test_fraction)
        test_indices.extend(indices[:test_size])
        train_indices.extend(indices[test_size:])

    rng.shuffle(train_indices)
    rng.shuffle(test_indices)
    return data.loc[train_indices].copy(), data.loc[test_indices].copy()


def prepare_features(
    train_data: pd.DataFrame, test_data: pd.DataFrame
) -> tuple[np.ndarray, np.ndarray, np.ndarray, np.ndarray]:
    train_features = train_data[FEATURES].apply(pd.to_numeric, errors="coerce")
    test_features = test_data[FEATURES].apply(pd.to_numeric, errors="coerce")

    for feature in FEATURES:
        median = train_features[feature].median()
        train_features[feature] = train_features[feature].fillna(median)
        test_features[feature] = test_features[feature].fillna(median)

    return (
        train_features.to_numpy(),
        train_data["target"].to_numpy(),
        test_features.to_numpy(),
        test_data["target"].to_numpy(),
    )


def classification_metrics(actual: np.ndarray, predicted: np.ndarray) -> dict[str, float]:
    true_positive = np.sum((predicted == 1) & (actual == 1))
    false_positive = np.sum((predicted == 1) & (actual == 0))
    false_negative = np.sum((predicted == 0) & (actual == 1))

    precision = true_positive / (true_positive + false_positive + 1e-9)
    recall = true_positive / (true_positive + false_negative + 1e-9)
    f1 = 2 * precision * recall / (precision + recall + 1e-9)
    accuracy = np.mean(predicted == actual)

    return {
        "accuracy": float(accuracy),
        "precision": float(precision),
        "recall": float(recall),
        "f1": float(f1),
    }


def main() -> None:
    data = load_data()
    train_data, test_data = stratified_split(data)
    x_train, y_train, x_test, y_test = prepare_features(train_data, test_data)

    model = DiabetesPredictor().fit(x_train, y_train)
    predictions = model.predict(x_test)
    metrics = classification_metrics(y_test, predictions)

    majority_class = int(round(y_train.mean()))
    baseline_accuracy = float(np.mean(y_test == majority_class))

    print("Training rows:", len(y_train))
    print("Test rows:", len(y_test))
    print("High-risk rate (test):", round(float(y_test.mean()), 3))
    print("Majority baseline accuracy:", round(baseline_accuracy, 3))
    print("Model accuracy:", round(metrics["accuracy"], 3))
    print("Precision / recall:", round(metrics["precision"], 3), "/", round(metrics["recall"], 3))
    print("F1 score:", round(metrics["f1"], 3))
    print("Beats baseline:", metrics["accuracy"] > baseline_accuracy)

    if model.weights is not None:
        print("Learned weights:")
        for feature, weight in zip(FEATURES, model.weights):
            print(f"  {feature}: {weight:.3f}")


if __name__ == "__main__":
    main()

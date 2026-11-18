import numpy as np

from src.diabetes_prediction_system import (
    DiabetesPredictor,
    classification_metrics,
)


def test_sigmoid_handles_extreme_values():
    values = np.array([-100.0, 0.0, 100.0])

    result = DiabetesPredictor._sigmoid(values)

    assert result[0] < 1e-10
    assert result[1] == 0.5
    assert result[2] > 1 - 1e-10


def test_classification_metrics():
    actual = np.array([1, 1, 0, 0])
    predicted = np.array([1, 0, 0, 1])

    metrics = classification_metrics(actual, predicted)

    assert np.isclose(metrics["precision"], 0.5)
    assert np.isclose(metrics["recall"], 0.5)
    assert np.isclose(metrics["f1"], 0.5)       


def test_model_learns_simple_pattern():
    features = np.array([[0.0], [0.1], [0.2], [1.0], [1.1], [1.2]])
    target = np.array([0, 0, 0, 1, 1, 1])

    model = DiabetesPredictor(
        learning_rate=0.1,
        iterations=1500,
    )
    model.fit(features, target)

    predictions = model.predict(features)

    assert np.array_equal(predictions, target)
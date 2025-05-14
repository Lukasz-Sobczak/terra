import json
import os
import pytest
from lambda_function import lambda_handler
from moto import mock_secretsmanager, mock_dynamodb
import boto3


@pytest.fixture
def setup_mocks(monkeypatch):
    os.environ["SECRET_ARN"] = "test-secret"
    with mock_secretsmanager(), mock_dynamodb():
        # Mock Secret
        sm_client = boto3.client("secretsmanager", region_name="us-east-1")
        sm_client.create_secret(
            Name="test-secret",
            SecretString=json.dumps({"username": "admin", "password": "SuperSecret123"})
        )

        # Mock DynamoDB
        db_client = boto3.client("dynamodb", region_name="us-east-1")
        db_client.create_table(
            TableName="SensorTerra",
            KeySchema=[{"AttributeName": "sensor_id", "KeyType": "HASH"}],
            AttributeDefinitions=[{"AttributeName": "sensor_id", "AttributeType": "N"}],
            BillingMode="PAY_PER_REQUEST"
        )

        yield


def test_valid_input(setup_mocks):
    event = {
        "body": json.dumps({"sensor_id": 1, "value": 10000})
    }
    result = lambda_handler(event, None)
    assert result["sensor_id"] == 1
    assert "temperature_C" in result
    assert result["status"] == "OK"

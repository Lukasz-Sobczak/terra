import json
import math
import boto3
import os


def get_secret():
    secret_arn = os.environ["SECRET_ARN"]
    client = boto3.client("secretsmanager")
    response = client.get_secret_value(SecretId=secret_arn)
    return json.loads(response["SecretString"])


def lambda_handler(event, context):
    a, b, c = 1.40e-3, 2.37e-4, 9.90e-8

    sns_client = boto3.client("sns")
    dynamodb = boto3.resource("dynamodb")
    table = dynamodb.Table("SensorTerra")
    topic_arn = "arn:aws:sns:us-east-1:708429773842:Sensor_mail"

    secret = get_secret()
    db_user = secret["username"]
    db_pass = secret["password"]

    try:
        data = json.loads(event["body"]) if "body" in event else event
        sensor_id = int(data["sensor_id"])
        resistance = float(data["value"])
    except (KeyError, ValueError, TypeError):
        table.put_item(Item={"sensor_id": sensor_id, "broken": True})
        return {"error": "INVALID INPUT"}

    if resistance < 1 or resistance > 20000:
        table.put_item(Item={"sensor_id": sensor_id, "broken": True})
        return {"error": "VALUE OUT OF RANGE"}

    lnR = math.log(resistance)
    T_inv = a + b * lnR + c * (lnR ** 3)
    T_kelvin = 1.0 / T_inv
    T_celsius = T_kelvin - 273.15

    if T_celsius < -273.15:
        status = {"error": "INVALID TEMPERATURE"}
        table.put_item(Item={"sensor_id": sensor_id, "broken": True})
    elif T_celsius < 20:
        status = {"status": "TEMPERATURE TOO LOW"}
    elif T_celsius < 103:
        status = {"status": "OK"}
    elif T_celsius < 254:
        status = {"status": "TEMPERATURE TOO HIGH"}
    else:
        status = {"status": "TEMPERATURE CRITICAL"}
        message = f"Sensor {sensor_id} detected CRITICAL TEMPERATURE: {round(T_celsius, 2)}°C"
        sns_client.publish(TopicArn=topic_arn, Message=message, Subject="CRITICAL TEMPERATURE ALERT")
        table.put_item(Item={"sensor_id": sensor_id, "broken": True})

    return {
        "user": db_user,
        "haslo": db_pass,
        "sensor_id": sensor_id,
        "temperature_C": round(T_celsius, 2),
        **status
    }

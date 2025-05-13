import json
import math
import boto3
import os

def lambda_handler(event, context):
    # Stałe dla równania Steinhart–Harta
    a = 1.40e-3
    b = 2.37e-4
    c = 9.90e-8
    
    # AWS Clients
    sns_client = boto3.client("sns")
    dynamodb = boto3.resource("dynamodb")
    table = dynamodb.Table("SensorTerra")
    topic_arn = "arn:aws:sns:us-east-1:708429773842:Sensor_mail"
    


    secret_arn = os.environ["SECRET_ARN"]
    client = boto3.client('secretsmanager')
    response = client.get_secret_value(SecretId=secret_arn)
    secret = json.loads(response['SecretString'])

    db_user = secret["username"]
    db_pass = secret["password"]
    # Pobranie danych z JSON
    try:
        data = json.loads(event["body"]) if "body" in event else event
        sensor_id = int(data["sensor_id"])
        resistance = float(data["value"])
    except (KeyError, ValueError, TypeError):
        table.put_item(Item={"sensor_id": sensor_id, "broken": True})
        return {"error": "INVALID INPUT"}
    
    # Sprawdzenie zakresu rezystancji
    if resistance < 1 or resistance > 20000:
        table.put_item(Item={"sensor_id": sensor_id, "broken": True})
        return {"error": "VALUE OUT OF RANGE"}
    
    # Obliczenie temperatury w kelwinach
    lnR = math.log(resistance)
    T_inv = a + b * lnR + c * (lnR ** 3)
    T_kelvin = 1.0 / T_inv
    
    # Konwersja do stopni Celsjusza
    T_celsius = T_kelvin - 273.15
    
    # Określenie statusu
    if T_celsius < -273.15:
        status = {"error": "INVALID TEMPERATURE"}
        table.put_item(Item={"sensor_id": sensor_id, "broken": True})
    elif T_celsius < 20:
        status = {"status": "TEMPERATURE TOO LOW"}
    elif T_celsius < 100:
        status = {"status": "OK"}
    elif T_celsius < 253:
        status = {"status": "TEMPERATURE TOO HIGH"}
    else:
        status = {"status": "TEMPERATURE CRITICAL"}
        message = f"Sensor {sensor_id} detected CRITICAL TEMPERATURE: {round(T_celsius, 2)}°C"
        sns_client.publish(TopicArn=topic_arn, Message=message, Subject="CRITICAL TEMPERATURE ALERT")
        table.put_item(Item={"sensor_id": sensor_id, "broken": True})
    
    # Zwrócenie wyniku
    return {
        "user": db_user,
        "haslo": db_pass,
        "sensor_id": sensor_id,
        "temperature_C": round(T_celsius, 2),
        **status
    }


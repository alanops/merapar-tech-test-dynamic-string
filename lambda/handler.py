import os
import boto3

ssm  = boto3.client("ssm")
PARAM = os.environ["STRING_PARAM_NAME"]

def handler(event, context):
    value = ssm.get_parameter(Name=PARAM, WithDecryption=True)["Parameter"]["Value"]
    return {
        "statusCode": 200,
        "headers": {"Content-Type": "text/html"},
        "body": f"<h1>The saved string is {value}</h1>"
    }

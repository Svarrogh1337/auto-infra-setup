import json
import boto3
import logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)
elb_client = boto3.client('elb')
def lambda_handler(event, context):
    message = event['Records'][0]['Sns']['Message']
    json_message = json.loads(message)
    elb_name = str(json_message['Trigger']['Dimensions'][0]['value'])
    return {
        'statusCode': 200,
        'message': event
    }
def describe_instance_health(elb_name):
	pass
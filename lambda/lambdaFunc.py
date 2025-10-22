import json
import boto3

def lambda_handler(event, context):
    awsService = boto3.resource('dynamodb', region_name='us-east-1')
    table = awsService.Table('cloudResumeViewsTable')
    # TODO implement
    response = table.get_item(Key={
        'id':'1'
    })
    views = response['Item']['views']
    views = views + 1
    print(views)
    response = table.put_item(Item={
        'id':'1',  
        'views':views
    })
    return views
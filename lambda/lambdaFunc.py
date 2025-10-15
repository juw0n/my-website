import json
import boto3

awsService = boto3.resource('dynamodb', region_name='us-east-2')
table = awsService.Table('juwon-resume')

def lambda_handler(event, context):
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
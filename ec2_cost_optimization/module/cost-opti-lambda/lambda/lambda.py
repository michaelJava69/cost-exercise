import json
import os
import boto3
import csv
import logging

from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.application import MIMEApplication

from urllib.request import Request, urlopen
from urllib.error import URLError, HTTPError


# The base-64 encoded, encrypted key (CiphertextBlob) stored in the kmsEncryptedHookUrl environment variable
ENCRYPTED_HOOK_URL = os.environ['kmsEncryptedHookUrl']
# The Slack channel to send a message to stored in the slackChannel environment variable
SLACK_CHANNEL = os.environ['slackChannel']

logger = logging.getLogger()
logger.setLevel(logging.INFO)

logger.info("Message: " + str(ENCRYPTED_HOOK_URL))
HOOK_URL = str(ENCRYPTED_HOOK_URL)




def handler(event, context):

    sourceKey = event['Records'][0]['s3']['object']['key']

    #print("I am printing this ",sourceKey)
    logger.info("Message sourceKey: " + sourceKey)    


def lambda_slack_handler(object):
    
    slack_message = {
        'channel': SLACK_CHANNEL,
        'text': "Cost Optimisation analysis has arrived in your email. Look for file named: %s" % ( object)
    }

    req = Request(HOOK_URL, json.dumps(slack_message).encode('utf-8'))
    
    logger.info("Sending Cost Optimization slack for file "+ object)
    
    try:
        response = urlopen(req)
        response.read()
        logger.info("Message posted to %s", slack_message['channel'])
    except HTTPError as e:
        logger.error("Request failed: %d %s", e.code, e.reason)
    except URLError as e:
        logger.error("Server connection failed: %s", e.reason)


def lambda_handler(event, context):
    
    
    #test
    #handler(event,handler)
    
    ses = boto3.client("ses")
    s3 = boto3.client("s3")

    sendEmail = False
    object =''

    for record in event['Records']:
        # Create some variables that make it easier to work with the data in the
        # event record.
        
        action = record ["eventName"]
        ip = record["requestParameters"]["sourceIPAddress"]
        bucket_name = record['s3']['bucket']['name']
        key = record['s3']['object']['key']
        #input_file = os.path.join(bucket,key)

        #print("The file given is ",key)
        logger.info("Message - The file given is: " + key) 
        
        if key.startswith('results_'):
            object= key
            sendEmail = True
    

    """
    for i in event["Records"]:
        action = i["eventName"]
        ip = i["requestParameters"]["sourceIPAddress"]
        bucket_name = i["s3"]["bucket"]["name"]
        object = 'my_file.csv'
    """
    
    if sendEmail:
        
        lambda_slack_handler(object)
        
        #print("Sending Cost Optimization email for file ",object)
        logger.info("Sending Cost Optimization email for file "+ object)    
    
        fileObj = s3.get_object(Bucket = bucket_name, Key = object)
        file_content = fileObj["Body"].read()
    
        sender = "naveen.mynampati@capgemini.com"
        to = "michael.ugbechie@capgemini.com"
        subject = str(action) + 'Event from ' + bucket_name
        body = """
            <br>
            This email is to notify you regarding {} event.
            The object {} is uploaded.
            Source IP: {}
        """.format(action, object, ip)
    
        msg = MIMEMultipart()
        msg["Subject"] = subject
        msg["From"] = sender
        msg["To"] = to
    
        body_txt = MIMEText(body, "html")
    
        attachment = MIMEApplication(file_content)
        attachment.add_header("Content-Disposition", "attachment", filename=object)
    
        msg.attach(body_txt)
        msg.attach(attachment)
    
        response = ses.send_raw_email(Source = sender, Destinations = [to], RawMessage = {"Data": msg.as_string()})
        
        return "Thanks"
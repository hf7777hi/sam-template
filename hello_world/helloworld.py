import logging
import json
import requests

from common import mylogger

# logger設定
logger = mylogger.set()
logger.setLevel(logging.DEBUG)

class HelloWorld:
    def __init__(self):
        logger.debug("")
    def get(self):
        try:
            ip = requests.get("http://checkip.amazonaws.com/")
            return {
                "statusCode": 200,
                "body": json.dumps({
                    "message": "hello world",
                    "location": ip.text.replace("\n", "")
                }),
            }
        except requests.RequestException as e:
            # Send some context about this error to Lambda Logs
            print(e)

            raise e
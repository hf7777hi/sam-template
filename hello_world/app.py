
from hello_world.helloworld import HelloWorld

def handler(event, context):
    return HelloWorld().get()

# https://github.com/supersaiyanmode/PyWebOSTV/

from pywebostv.discovery import *
from pywebostv.connection import *
from pywebostv.controls import *
import json

store = {} # client key after first run save here

client = WebOSClient("LG_TV_IP_HERE")
#client = WebOSClient.discover()[0] #search ip
client.connect()
for status in client.register(store):
    if status == WebOSClient.PROMPTED:
        print("Please accept the connect on the TV!")
    elif status == WebOSClient.REGISTERED:
        print("Registration successful!")

print(store)   # {'client_key': 'ACCESS_TOKEN_FROM_TV'}

app = ApplicationControl(client)

apps = app.list_apps()

applist = []

for x in apps:
    applist.append({
        "title": x["title"], 
        "id": x["id"]
    })
    
applist = json.dumps(applist)

print(applist)

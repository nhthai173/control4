# https://github.com/supersaiyanmode/PyWebOSTV/

from pywebostv.discovery import *
from pywebostv.connection import *
from pywebostv.controls import *
import json
import time

# store = {} # client key after first run save here
store = {'client_key': 'bb10ef5f6241a3fa17c5062dbb0d9828'}

client = WebOSClient("192.168.1.117")
# client = WebOSClient.discover()[0] #search ip
client.connect()
for status in client.register(store):
    if status == WebOSClient.PROMPTED:
        print("Please accept the connect on the TV!")
    elif status == WebOSClient.REGISTERED:
        print("Registration successful!")

print(store)   # {'client_key': 'ACCESS_TOKEN_FROM_TV'}

app = ApplicationControl(client)

launch_info = app.launch(
    {"id": 'com.viettel.media.tv360'},
    content_id="ch=2"
)

isOpened = True
while app.get_current() != 'com.viettel.media.tv360':
    time.sleep(1)
    isOpened = False

if isOpened == False:
    time.sleep(5)

inp = InputControl(client)
inp.connect_input()

inp.num_7()
time.sleep(1)
inp.num_4()







"""
apps = app.list_apps()
applist = []
for x in apps:
    applist.append({
        "title": x["title"], 
        "id": x["id"]
    })
    
applist = json.dumps(applist)
print(applist)
"""

# -*- coding: utf-8 -*-

import os
import json

print('Enter 1 to Forging Info\n')

print('Enter 2 to Get Sidechain Balance\n')

print('Enter 3 to Generate a block\n')

print('Enter 4 to Generate a new adress \n')

print('Enter 5 to Send coins \n')

print('Enter 0 to exit')


adress=''
z=''
while True:
    choice = int(input('Enter your choice:'))
    if (choice == 1):
        os.system('curl -X POST "http://127.0.0.1:9085/wallet/createPrivateKey25519" -H "accept: application/json"')
    
    if (choice == 2):
        os.system('curl -X POST "http://127.0.0.1:9085/wallet/balance" -H "accept: application/json" -H "Content-Type: application/json"')
    
    if (choice == 3):
        x=input('epochNumber= ')
        y=input('slotNumber= ')
        os.system('curl -X POST "http://127.0.0.1:9085/block/generate" -H "accept: application/json"  -H "Content-Type: application/json" -d "{\\"epochNumber\\":'+x+',\\"slotNumber\\":'+y+'}"')

    if (choice == 4):
        stream=os.popen('curl -X POST "http://127.0.0.1:9085/wallet/createPrivateKey25519" -H "accept: application/json"')
        adress=stream.read()
        publicKey=json.loads(adress)
        pk=publicKey["result"]["proposition"]["publicKey"]
        print(pk)
    
    if (choice == 5):
        v=input('value= ')
        u=input('fee= ')
        i=input('Your publicKey or 0 for the generated one= ')
        if i==0:
            os.system('curl -X POST "http://127.0.0.1:9085/transaction/sendCoinsToAddress" -H "accept: application/json" -H "Content-Type: application/json" -d "{\\"outputs\\":[{\\"publicKey\\":\\"'+pk+'\\",\\"value\\":'+v+'}],\\"fee\\":'+u+'}"')
        else:
            os.system('curl -X POST "http://127.0.0.1:9085/transaction/sendCoinsToAddress" -H "accept: application/json" -H "Content-Type: application/json" -d "{\\"outputs\\":[{\\"publicKey\\":\\"'+i+'\\",\\"value\\":'+v+'}],\\"fee\\":'+u+'}"')

    if (choice == 0):
        break

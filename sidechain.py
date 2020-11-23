# -*- coding: utf-8 -*-

import os

print('Enter 1 to Get the mainchain balance \n')

print('Enter 2 to Get Sidechain Balance \n')

print('Enter 3 to Generate a new sidechain adress \n')

print('Enter 4 to Forging Info \n')

print('Enter 5 to Send coins from mainchain to sidechain \n')

print('Enter 6 to Check mainchain transaction info \n')

print('Enter 7 to Send coins interchain \n')

print('Enter 8 to Generate a block \n')

print('Enter 9 to Check pending transactions \n')

print('Enter 10 to Check all sidechain boxes \n')

print('Enter 0 to exit')


adress=''
i=''
pk=''
x=''
y=''
v=''
u=''
tf=''
ma=''
sa=''
ti=''
vm=''
while True:
    choice = int(input('Enter your choice:'))
    if (choice == 1):
        os.system('zen-cli getbalance')
    
    if (choice == 2):
        os.system('curl -X POST "http://127.0.0.1:9085/wallet/balance" -H "accept: application/json" -H "Content-Type: application/json"')
        
    if (choice == 3):
        os.system('curl -X POST "http://127.0.0.1:9085/wallet/createPrivateKey25519" -H "accept: application/json"')
    
    if (choice == 4):
        os.system('curl -X POST "http://127.0.0.1:9085/block/forgingInfo" -H "accept: application/json" -H "Content-Type: application/json"')
        
    if (choice == 5):
        ma=input('Mainchain Adress= ')
        sa=input('Sidechain Adress= ')
        vm=input('Value= ')
        os.system('zen-cli sc_send "'+ma+'" '+vm+' "'+sa+'"')
        
    if (choice == 6):
        ti=input('Transaction ID= ')
        os.system('zen-cli gettransaction "'+ti+'"')
  
    if (choice == 7):
        v=input('value= ')
        u=input('fee= ')
        i=input('Public Key= ')
        os.system('curl -X POST "http://127.0.0.1:9085/transaction/sendCoinsToAddress" -H "accept: application/json" -H "Content-Type: application/json" -d "{\\"outputs\\":[{\\"publicKey\\":\\"'+i+'\\",\\"value\\":'+v+'}],\\"fee\\":'+u+'}"')
 
    if (choice == 8):
        x=input('epochNumber= ')
        y=input('slotNumber= ')
        os.system('curl -X POST "http://127.0.0.1:9085/block/generate" -H "accept: application/json"  -H "Content-Type: application/json" -d "{\\"epochNumber\\":'+x+',\\"slotNumber\\":'+y+'}"')   
 
    if (choice == 9):
         tf=input('format= ')
         os.system('curl -X POST "http://127.0.0.1:9085/transaction/allTransactions" -H "accept: application/json" -H "Content-Type: application/json" -d "{\\"format\\":'+tf+'}"')
   
    if (choice == 10):
        os.system('curl -X POST "http://127.0.0.1:9085/wallet/allBoxes" -H "accept: application/json" -H "Content-Type: application/json"')
   
    if (choice == 0):
        break

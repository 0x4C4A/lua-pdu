require("luapdu")

smsObj = luapdu.newTx()
smsObj.recipient.num = "1237123"
smsObj.msg.content = "DESAS"
smsObj.smsc = {num = "1233919123"}
print(smsObj:encode())

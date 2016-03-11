require("json")
require("luapdu")
require("luapdu.tests.utils")

local smsObj = luapdu.newRx()
smsObj.sender.num = "1237123"
smsObj.msg.content = "DESAS"
local decodedSmsObj = luapdu.decode(smsObj:encode())
deepCompare(smsObj, decodedSmsObj)

smsObj = luapdu.newTx()
smsObj.recipient.num = "1237123"
smsObj.msg.content = "DESAS"
local decodedSmsObj = luapdu.decode(smsObj:encode())
deepCompare(smsObj, decodedSmsObj)

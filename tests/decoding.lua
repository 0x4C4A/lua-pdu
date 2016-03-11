require("json")
require("luapdu")
require("luapdu.tests.utils")

local pduMSG = "0011000A9160214365870008AA1C00640061007400610066006100740061007800610073006400610073"
local decoded = luapdu.decode(pduMSG)
local expected = {
    recipient={
        len=10,
        ["type"]=0x91,
        num="+0612345678"
    },
    ["type"]=17,
    msgReference=0,
    validPeriod=170,
    decoding=8,
    protocol=0,
    msg={
        content="datafataxasdas",
        length=28
    }
}
deepCompare(expected, decoded)

--print(json.encode(pduMSG:decodePDU()))
--print(encodePayload(x,7))
--print(encodePayload(x,7):decode7bitPayload(x:len()))

--local sms = pduTranscoder.newTxSmsObject()
--print(json.encode(sms))
--print(json.encode())
--print(sms:encode())
require("json")
require("luapdu")

function deepCompare(obj1, obj2, path, failedtags)
    local root = false
    if failedtags == nil then
        root = true
        path = ""
        failedtags = {}
    end
    if obj1 == nil or obj2 == nil then
        failedtags[#failedtags+1] = path.."###"
        return
    end

    for i,v in pairs(obj1) do
        local currPath = path.."."..i
        if type(v) == "table" then
            deepCompare(obj1[i], obj2[i], currPath, failedtags)
        else
            if v ~= obj2[i] then
                failedtags[#failedtags+1] = currPath.." obj1: <"..(v or nil)..">"
                                                    .." obj2: <"..(obj2[i] or nil)..">"
            end
        end
    end
    for i,v in pairs(obj2) do
        local currPath = path.."."..i
        if type(v) == "table" then
            deepCompare(obj1[i], obj2[i], currPath, failedtags)
        else
            if v ~= obj1[i] then
                failedtags[#failedtags+1] = currPath.." obj1: <"..(obj1[i] or "nil")..">"
                                                    .." obj2: <"..(v or "nil")..">"
            end
        end
    end
    if root and #failedtags > 0 then
        error("Erronous keypairs:\n"..table.concat(failedtags,"\n"))
    end
end

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
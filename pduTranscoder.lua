require("json") -- luarocks install luajson
require("bit")  -- luarocks install luabitop

-- Valuable addresses
-- http://www.sendsms.cn/download/SMS_PDU-mode.PDF
-- http://www.smartposition.nl/resources/sms_pdu.html
local decodeTable7bit = {[0]="@",[1]="£",[2]="$",[3]="¥",[4]="è",[5]="é",[6]="ù",[7]="ì",[8]="ò",[9]="Ç",[10]=" ",[11]="Ø",[12]="ø",[13]=" ",[14]="Å",[15]="å",[16]="Δ",[17]="_",[18]="Φ",[19]="Γ",[20]="Λ",[21]="Ω",[22]="Π",[23]="Ψ",[24]="Σ",[25]="Θ",[26]="Ξ",[27]="€",[28]="Æ",[29]="æ",[30]="ß",[31]="É",[32]=" ",[33]="!",[34]="\"",[35]="#",[36]="¤",[37]="%",[38]="&",[39]="'",[40]="(",[41]=")",[42]="*",[43]="+",[44]=",",[45]="-",[46]=".",[47]="/",[48]="0",[49]="1",[50]="2",[51]="3",[52]="4",[53]="5",[54]="6",[55]="7",[56]="8",[57]="9",[58]=":",[59]=";",[60]="<",[61]="=",[62]=">",[63]="?",[64]="¡",[65]="A",[66]="B",[67]="C",[68]="D",[69]="E",[70]="F",[71]="G",[72]="H",[73]="I",[74]="J",[75]="K",[76]="L",[77]="M",[78]="N",[79]="O",[80]="P",[81]="Q",[82]="R",[83]="S",[84]="T",[85]="U",[86]="V",[87]="W",[88]="X",[89]="Y",[90]="Z",[91]="Ä",[92]="Ö",[93]="Ñ",[94]="Ü",[95]="§",[96]="¿",[97]="a",[98]="b",[99]="c",[100]="d",[101]="e",[102]="f",[103]="g",[104]="h",[105]="i",[106]="j",[107]="k",[108]="l",[109]="m",[110]="n",[111]="o",[112]="p",[113]="q",[114]="r",[115]="s",[116]="t",[117]="u",[118]="v",[119]="w",[120]="x",[121]="y",[122]="z",[123]="ä",[124]="ö",[125]="ñ",[126]="ü",[127]="à"}
local encodeTable7bit = {["@"]=0,["£"]=1,["$"]=2,["¥"]=3,["è"]=4,["é"]=5,["ù"]=6,["ì"]=7,["ò"]=8,["Ç"]=9,[" "]=10,["Ø"]=11,["ø"]=12,[" "]=13,["Å"]=14,["å"]=15,["Δ"]=16,["_"]=17,["Φ"]=18,["Γ"]=19,["Λ"]=20,["Ω"]=21,["Π"]=22,["Ψ"]=23,["Σ"]=24,["Θ"]=25,["Ξ"]=26,["€"]=27,["Æ"]=28,["æ"]=29,["ß"]=30,["É"]=31,[" "]=32,["!"]=33,["\""]=34,["#"]=35,["¤"]=36,["%"]=37,["&"]=38,["'"]=39,["("]=40,[")"]=41,["*"]=42,["+"]=43,[","]=44,["-"]=45,["."]=46,["/"]=47,["0"]=48,["1"]=49,["2"]=50,["3"]=51,["4"]=52,["5"]=53,["6"]=54,["7"]=55,["8"]=56,["9"]=57,[":"]=58,[";"]=59,["<"]=60,["="]=61,[">"]=62,["?"]=63,["¡"]=64,["A"]=65,["B"]=66,["C"]=67,["D"]=68,["E"]=69,["F"]=70,["G"]=71,["H"]=72,["I"]=73,["J"]=74,["K"]=75,["L"]=76,["M"]=77,["N"]=78,["O"]=79,["P"]=80,["Q"]=81,["R"]=82,["S"]=83,["T"]=84,["U"]=85,["V"]=86,["W"]=87,["X"]=88,["Y"]=89,["Z"]=90,["Ä"]=91,["Ö"]=92,["Ñ"]=93,["Ü"]=94,["§"]=95,["¿"]=96,["a"]=97,["b"]=98,["c"]=99,["d"]=100,["e"]=101,["f"]=102,["g"]=103,["h"]=104,["i"]=105,["j"]=106,["k"]=107,["l"]=108,["m"]=109,["n"]=110,["o"]=111,["p"]=112,["q"]=113,["r"]=114,["s"]=115,["t"]=116,["u"]=117,["v"]=118,["w"]=119,["x"]=120,["y"]=121,["z"]=122,["ä"]=123,["ö"]=124,["ñ"]=125,["ü"]=126,["à"]=127}

function string:decodeOctet()
    if self:len() < 2 then error("Too short, can't get octet!") end
    return tonumber("0x"..self:sub(1,2)), self:sub(3)
end

function string:decodeDecOctets(count)
    if self:len() < count*2 then error("String too short!") end
    -- Flip the octets
    local result = ""
    local var = self:sub(1,count*2)
    while var:len() ~= 0 do
        result = result .. var:sub(1,2):reverse()
        var = var:sub(3)
    end
    -- Strip "F", if padded
    if result:sub(-1) == "F" then result = result:sub(1,-2) end
    return result, self:sub(count*2+1)
end

function octet(val)
    if val > 255 then error("Can't convert to octet - value too large!") end
    return bit.tohex(val,2):upper()
end

function decOctets(val)
    local response = {}
    if val:len() % 2 ~= 0 then val = val .. "F" end
    while val:len() ~= 0 do
        response[#response+1] = val:sub(2,2)
        response[#response+1] = val:sub(1,1)
        val = val:sub(3)
    end
    return table.concat(response)
end

function string:decOctets(count)
    return self:sub(1,count*2), self:sub(count*2+1)
end

function string:decodePayload(decoding, length)
    decodingBits = bit.band(decoding, 12)
    if     decodingBits == 0  then return self:decode7bitPayload(length)
    elseif decodingBits == 4  then return self:decode8bitPayload(length)
    elseif decodingBits == 8  then return self:decode16bitPayload(length)
    elseif decodingBits == 12 then error("Invalid alphabet size!") end
end

function string:decode7bitPayload(length)
    local data = {}
    local prevoctet = 0
    local state = 0
    local octet
    local val
    while self:len() ~= 0 and length ~= 0 do
        octet, self = self:decodeOctet()
        val = bit.band(bit.lshift(octet,state),0x7F) + prevoctet
        prevoctet = bit.band(bit.rshift(octet, 7-state),0x7F)
        data[#data+1] = decodeTable7bit[val]
        if state == 6 then
            data[#data+1] = decodeTable7bit[prevoctet]
            prevoctet = 0
            state = 0
            length = length - 2
        else
            length = length - 1
            state = state + 1
        end
    end
    if     length     ~= 0 then
        print("Content shorter than expected!")
    elseif self:len() ~= 0 then
        print("Content longer than expected!<"..self..">")
    end    return table.concat(data)
end

function string:decode8bitPayload(length)
    local data = {}
    local octet = 0
    while self ~= "" and length ~=0 do
        octet,self = self:decodeOctet()
        data[#data+1] = string.char(octet)
        length = length - 1
    end
    if     length     ~= 0 then
        print("Content shorter than expected!")
    elseif self:len() ~= 0 then
        print("Content longer than expected!<"..self..">")
    end
    return table.concat(data)
end

function string:decode16bitPayload(length)
    local data = {}
    local octe1, octet2
    while self ~= "" and length ~=0 do
        octet1,self = self:decodeOctet()
        octet2,self = self:decodeOctet()
        val = bit.lshift(octet1, 8) + octet2
        -- http://lua-users.org/wiki/LuaUnicode
        -- X - octet1, Y - octet2
        if val < 0x7F then       -- 8bit
            data[#data+1] = string.char(val)    -- 0b0XXXXXXX
        elseif val < 0x7FF then  -- 11bit
            data[#data+1] = string.char(0xC0 + bit.rshift(val,8))   -- 0b110XXXYY
            data[#data+1] = string.char(0x80 + bit.band(val, 0x3F)) -- 0b10YYYYYY
        elseif val < 0xFFFF then -- 16bit
            data[#data+1] = string.char(0xE0 + bit.band(bit.rshift(val,12), 0x1F))  -- 0b1110XXXX
            data[#data+1] = string.char(0x80 + bit.band(bit.rshift(val,6), 0x3F))   -- 0b10XXXXYY
            data[#data+1] = string.char(0x80 + bit.band(val, 0x3F))                 -- 0b10YYYYYY
        end
        length = length - 2
    end
    if     length     ~= 0 then
        print("Content shorter than expected!")
    elseif self:len() ~= 0 then
        print("Content longer than expected!<"..self..">")
    end
    return table.concat(data)
end


function string:decodeTXmsg(response)
    response.msgReference, self = self:decodeOctet()
    response.recipient = {}
    response.recipient.len,  self = self:decodeOctet()
    response.recipient.type, self = self:decodeOctet()
    if response.recipient.len > 0 then
        response.recipient.num, self = self:decodeDecOctets(math.ceil(response.recipient.len/2))
        if response.recipient.type == 0x91 then -- International format
            response.recipient.num = "+"..response.recipient.num
        end
    end
    response.protocol,    self = self:decodeOctet()
    response.decoding,    self = self:decodeOctet()
    response.validPeriod, self = self:decodeOctet()
    response.msg.length,  self = self:decodeOctet()
    response.msg.content       = self:decodePayload(response.decoding, response.msg.length)

    return response
end

function string:decodeRXmsg(response)
    response.sender = {}
    response.sender.len,  self = self:decodeOctet()
    response.sender.type, self = self:decodeOctet()
    if response.sender.len > 0 then
        response.sender.num, self = self:decodeDecOctets(math.ceil(response.sender.len/2))
        if response.sender.type == 0x91 then -- International format
            response.sender.num = "+"..response.sender.num
        end
    end
    response.protocol,   self = self:decodeOctet()
    response.decoding,   self = self:decodeOctet()
    response.timestamp,  self = self:decodeDecOctets(7)
    response.msg.length, self = self:decodeOctet()

    response.msg.content      = self:decodePayload(response.decoding, response.msg.length)

    return response
end

function string:decodePDU()
    local response = {smsc={}, msg = {}}
    response.smsc.len,   self = self:decodeOctet()
    if response.smsc.len > 0 then
        response.smsc.type,  self = self:decodeOctet()
        response.smsc.num,   self = self:decodeDecOctets(response.smsc.len - 1)
        if response.smsc.type == 0x91 then -- International format
            response.smsc.num = "+"..response.smsc.num
        end
    else
        response.smsc = nil
    end
    response.type, self = self:decodeOctet()
    typeBits = bit.band(response.type, 0x03)
    if     typeBits == 0 then
        return self:decodeRXmsg(response)
    elseif typeBits == 1 then
        return self:decodeTXmsg(response)
    else
        error("Unknown message type!")
    end
end

function encode16bitPayload(content)
    local response = {}
    while content:len() ~= 0 do
        -- http://lua-users.org/wiki/LuaUnicode
        local byte = content:byte(1)
        if     byte <= 0x8F then
            response[#response+1] = "00"
            response[#response+1] = octet(byte)
            content = content:sub(2)
        elseif byte <= 0xDF then
            local byte2 = content:byte(2)
            content = content:sub(3)
            local val = bit.lshift(bit.band(byte,0x3F),6) +
                        bit.band(byte2,0x3F)
            response[#response+1] = octet(bit.rshift(val,8))
            response[#response+1] = octet(bit.band(val,0xFF))
        elseif byte <= 0xEF then
            local byte2 = content:byte(2)
            local byte3 = content:byte(3)
            content = content:sub(4)
            local val = bit.lshift(bit.band(byte,  0x0F),12) +
                        bit.lshift(bit.band(byte2, 0x3F),6)  +
                                   bit.band(byte3, 0x3F)
            response[#response+1] = octet(bit.rshift(val,8))
            response[#response+1] = octet(bit.band(val,0xFF))
        else
            return error("Can't fit payload char into 16bit unicode!")
        end
    end
    return response
end

function encode7bitPayload(content)
    local response = {}
    local state = 0
    local carryover = 0

    while content:len() ~= 0 or carryover ~= 0 do
        local charval = encodeTable7bit[content:sub(1,1)]
        content = content:sub(2)
        if charval == nil then charval = encodeTable7bit["?"] end
        local val = bit.lshift(charval, state) + carryover
        if state~= 0 or content:len() == 0 then
            response[#response+1] = octet(bit.band(val, 0xFF))
            carryover = bit.rshift(val, 8)
        else
            carryover = val
        end
        if state == 0 then state = 7 else state = state - 1 end
    end
    return response
end

function encodePayload(content, alphabetOverride)
    if alphabetOverride == nil then
        alphabetOverride = 16
    elseif alphabetOverride ~= 16 and
           alphabetOverride ~=  8 and
           alphabetOverride ~=  7 then
        error("Invalid alphabet override!")
    end
    local response = {}
    if alphabetOverride == 8 then
        while content:len() ~= 0 do
            response[#response+1] = octet(content:byte(1))
            content = content:sub(2)
        end
    elseif alphabetOverride == 16 then
        response = encode16bitPayload(content)
    elseif alphabetOverride == 7 then
        response = encode7bitPayload(content)
    else
        error("Unimplemented payload encoding alphabet!")
    end
    return table.concat(response)
end

function encodePDU(smsObject)
    local response = {}
    if smsObject.smsc and smsObject.smsc.num then
        local rawSmscNumber = smsObject.smsc.num:gsub("+","")
        smsObject.smsc.len = rawSmscNumber:len() + 1
        response[#response+1] = octet(smsObject.smsc.len)
        smsObject.smsc.type = (smsObject.smsc.num:sub(1,1) == "+") and 0x91 or 0x81
        response[#response+1] = octet(smsObject.smsc.type)
        response[#response+1] = decOctets(rawSmscNumber)
    else
        response[#response+1] = octet(0x00)
    end
    if smsObject.sender then
        response[#response+1] = octet(0x00)
        -- Sender block
        local rawSenderNumber = smsObject.sender.num:gsub("+","")
        response[#response+1] = rawSenderNumber:len()
        smsObject.sender.type = (smsObject.sender.num:sub(1,1) == "+") and 0x91 or 0x81
        response[#response+1] = octet(smsObject.sender.type)
        response[#response+1] = decOctets(smsObject.sender.num)
        -- Protocol

        -- Decoding

        -- Validity period

        -- Payload
    elseif smsObject.recipient then
        response[#response+1] = octet(0x01)
        -- Recipient block
        local rawRecipientrNumber = smsObject.recipient.num:gsub("+","")
        response[#response+1] = rawrecipientNumber:len()
        smsObject.recipient.type = (smsObject.recipient.num:sub(1,1) == "+") and 0x91 or 0x81
        response[#response+1] = octet(smsObject.recipient.type)
        response[#response+1] = decOctets(smsObject.recipient.num)
        -- Protocol
        response[#response+1] = octet(0x00)
        -- Decoding

        response[#response+1] = octet()
        -- Timestamp

        -- Payload

    else
        error("No valid content!")
    end
end

function encodePDUsimple(recipientNumber, content)

end

local pduMSG = "0011000A9160214365870008AA1C00640061007400610066006100740061007800610073006400610073"
x = "12345678ABSAD9"
print(encodePayload(x,7))
print(encodePayload(x,7):decode7bitPayload(x:len()))
--print(json.encode(pduMSG:decodePDU()))
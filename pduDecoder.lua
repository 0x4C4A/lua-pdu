require("json") -- luarocks install luajson
require("bit")  -- luarocks install luabitop

-- Valuable addresses
-- http://www.sendsms.cn/download/SMS_PDU-mode.PDF
-- http://www.smartposition.nl/resources/sms_pdu.html
local decodeTable7bit = {[0]="@",[1]="£",[2]="$",[3]="¥",[4]="è",[5]="é",[6]="ù",[7]="ì",[8]="ò",[9]="Ç",[10]=" ",[11]="Ø",[12]="ø",[13]=" ",[14]="Å",[15]="å",[16]="Δ",[17]="_",[18]="Φ",[19]="Γ",[20]="Λ",[21]="Ω",[22]="Π",[23]="Ψ",[24]="Σ",[25]="Θ",[26]="Ξ",[27]="€",[28]="Æ",[29]="æ",[30]="ß",[31]="É",[32]=" ",[33]="!",[34]="\"",[35]="#",[36]="¤",[37]="%",[38]="&",[39]="'",[40]="(",[41]=")",[42]="*",[43]="+",[44]=",",[45]="-",[46]=".",[47]="/",[48]="0",[49]="1",[50]="2",[51]="3",[52]="4",[53]="5",[54]="6",[55]="7",[56]="8",[57]="9",[58]=":",[59]=";",[60]="<",[61]="=",[62]=">",[63]="?",[64]="¡",[65]="A",[66]="B",[67]="C",[68]="D",[69]="E",[70]="F",[71]="G",[72]="H",[73]="I",[74]="J",[75]="K",[76]="L",[77]="M",[78]="N",[79]="O",[80]="P",[81]="Q",[82]="R",[83]="S",[84]="T",[85]="U",[86]="V",[87]="W",[88]="X",[89]="Y",[90]="Z",[91]="Ä",[92]="Ö",[93]="Ñ",[94]="Ü",[95]="§",[96]="¿",[97]="a",[98]="b",[99]="c",[100]="d",[101]="e",[102]="f",[103]="g",[104]="h",[105]="i",[106]="j",[107]="k",[108]="l",[109]="m",[110]="n",[111]="o",[112]="p",[113]="q",[114]="r",[115]="s",[116]="t",[117]="u",[118]="v",[119]="w",[120]="x",[121]="y",[122]="z",[123]="ä",[124]="ö",[125]="ñ",[126]="ü",[127]="à"}

function string:decodeOctet()
    if self:len() < 2 then error("Too short, can't get octet!") end
    return tonumber("0x"..self:sub(1,2)), self:sub(3)
end

function string:decodeDecOctets(count)
    if self:len() < count*2 then error("String too short!") end
    -- Flip the octets
    local result = ""
    local var = self:sub(1,count*2)
    while var ~= "" do
        result = result .. var:sub(1,2):reverse()
        var = var:sub(3)
    end
    -- Strip "F", if padded
    if result:sub(-1) == "F" then result = result:sub(1,-2) end
    return result, self:sub(count*2+1)
end

function string:octet()
    return self:sub(1,2), self:sub(3)
end

function string:octets(count)
    return self:sub(1,count*2), self:sub(count*2+1)
end

function string:decode7bitPayload(length)
    local data = {}
    local prevoctet = 0
    local state = 0
    local octet
    local val
    while self ~= "" and length ~= 0 do
        octet, self = self:decodeOctet()
        val = bit.band(bit.lshift(octet,state),0x7F) + prevoctet
        print(val, state, bit.tohex(octet))
        prevoctet = bit.band(bit.rshift(octet, 7-state),0x7F)
        data[#data+1] = decodeTable7bit[val]
        if state == 7 then
            print(prevoctet)
            data[#data+1] = decodeTable7bit[prevoctet]
            prevoctet = 0
            state = 0
            length = length - 2
        else
            length = length - 1
            state = state + 1
        end
        print("<"..table.concat(data)..">")
        --print(decodeTable7bit[val])
    end
    print("datalen: "..#data)
    return table.concat(data)
end

function string:decodeTXmsg(response)
    response.msgReference, self = self:decodeOctet()
    response.sender.len,   self = self:decodeOctet()
    response.sender.type,  self = self:decodeOctet()
    if response.sender.len > 0 then
        response.sender.num, self = self:decodeDecOctets(math.ceil(response.sender.len/2))
    end
    response.PID, self         = self:decodeOctet()
    response.DCS, self         = self:decodeOctet()
    response.validPeriod, self = self:decodeOctet()
    response.msg.length, self  = self:decodeOctet()
    response.msg.content       = self:decode7bitPayload(response.msg.length)

    return response
end

function string:decodePDU()
    local response = {smsc={}, sender={}, msg = {}}
    response.smsc.len,   self = self:decodeOctet()
    response.smsc.type,  self = self:decodeOctet()
    if response.smsc.len > 0 then
        response.smsc.num,   self = self:decodeDecOctets(response.smsc.len - 1)
    end
    response.type, self = self:decodeOctet()
    if bit.band(response.type,0x03) == 1 then
        return self:decodeTXmsg(response)
    elseif bit.band(response.type,0x03) == 0 then
        print("RX MSG")
    else
        error("Unknown message type!")
    end

    response.sender.len, self = self:decodeOctet()
    response.sender.type,self = self:decodeOctet()
    if response.sender.len > 0 then
        response.sender.num, self = self:decodeDecOctets(response.sender.len/2+0.5)
    end
    response.protocol,  self = self:decodeOctet()
    response.encoding,  self = self:decodeOctet()
    response.timestamp, self = self:decodeDecOctets(7)

    response.msg.length, self = self:decodeOctet()


    return response
end

local pduMSG = "07917321292020F011000891623092820000AA0CC8F71D14969741F977FD07"

print(json.encode(pduMSG:decodePDU()))
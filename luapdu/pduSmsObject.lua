local pduSmsObject = {}
pduSmsObject.__index = pduSmsObject

function pduSmsObject.newTx()
    local self = {
            msgReference=0,
            recipient={
                num  = "",
                ["type"] = 0x81
            },
            protocol = 0,
            decoding = 0,
            validPeriod = 11, -- 5 + 5*11 = 60 minutes (https://en.wikipedia.org/wiki/GSM_03.40)
            msg={content = ""}
        }
    setmetatable(self, pduSmsObject)
    return self
end

function pduSmsObject:encode16bitPayload()
    local response = {}
    local length = 0
    local content = self.msg.content
    while content:len() ~= 0 do
        -- http://lua-users.org/wiki/LuaUnicode
        local byte = content:byte(1)
        if     byte <= 0x8F then
            response[#response+1] = "00"
            response[#response+1] = pduString.octet(byte)
            content = content:sub(2)
        elseif byte <= 0xDF then
            local byte2 = content:byte(2)
            content = content:sub(3)
            local val = bit.lshift(bit.band(byte,0x3F),6) +
                        bit.band(byte2,0x3F)
            response[#response+1] = pduString.octet(bit.rshift(val,8))
            response[#response+1] = pduString.octet(bit.band(val,0xFF))
        elseif byte <= 0xEF then
            local byte2 = content:byte(2)
            local byte3 = content:byte(3)
            content = content:sub(4)
            local val = bit.lshift(bit.band(byte,  0x0F),12) +
                        bit.lshift(bit.band(byte2, 0x3F),6)  +
                                   bit.band(byte3, 0x3F)
            response[#response+1] = pduString.octet(bit.rshift(val,8))
            response[#response+1] = pduString.octet(bit.band(val,0xFF))
        else
            return error("Can't fit payload char into 16bit unicode!")
        end
        length = length + 1
    end
    return response, length
end

function pduSmsObject:encode7bitPayload()
    local response = {}
    local state = 0
    local carryover = 0
    local length = 0
    local content = self.msg.content

    while content:len() ~= 0 or carryover ~= 0 do
        local charval = encodeTable7bit[content:sub(1,1)]
        content = content:sub(2)
        if charval == nil then charval = encodeTable7bit["?"] end
        local val = bit.lshift(charval, state) + carryover
        if state~= 0 or content:len() == 0 then
            response[#response+1] = pduString.octet(bit.band(val, 0xFF))
            carryover = bit.rshift(val, 8)
            length = length + 1
        else
            carryover = val
        end
        if state == 0 then state = 7 else state = state - 1 end
    end
    return response, length
end

function pduSmsObject:encodePayload(alphabetOverride)
    local content = self.msg.content
    local length  = 0
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
            response[#response+1] = pduString.octet(content:byte(1))
            content = content:sub(2)
            length = length + 1
        end
    elseif alphabetOverride == 16 then
        response, length = self:encode16bitPayload(content)
    elseif alphabetOverride == 7 then
        response, length = self:encode7bitPayload(content)
    else
        error("Unimplemented payload encoding alphabet!")
    end
    return table.concat(response), length
end

function pduSmsObject:encode()
    local response = {}
    local function numberType(number)
        return (number:sub(1,1) == "+") and 0x91 or 0x81
    end
    if self.smsc and self.smsc.num then
        local rawSmscNumber = self.smsc.num:gsub("+","")
        self.smsc.len = rawSmscNumber:len() + 1
        response[#response+1] = pduString.octet(self.smsc.len)
        self.smsc.type   = numberType(self.smsc.num)
        response[#response+1] = pduString.octet(self.smsc.type)
        response[#response+1] = pduString.decOctets(rawSmscNumber)
    else
        response[#response+1] = pduString.octet(0x00)
    end

    local payload = ""
    if self.sender then
        response[#response+1] = pduString.octet(0x00)
        -- Sender block
        local rawSenderNumber = self.sender.num:gsub("+","")
        response[#response+1] = rawSenderNumber:len()
        self.sender.type = numberType(self.sender.num)
        response[#response+1] = pduString.octet(self.sender.type)
        response[#response+1] = pduString.decOctets(self.sender.num)
        -- Protocol
        response[#response+1] = pduString.octet(0x00)
        -- Data Coding Scheme https://en.wikipedia.org/wiki/Data_Coding_Scheme
        response[#response+1] = pduString.octet(0x00)
        -- Validity period
        response[#response+1] = pduString.octet(self.validPeriod)
        -- Payload
        payload, self.msg.len = pduString.encodePayload(self.msg.content)
        response[#response+1] = pduString.octet(self.msg.len)
        response[#response+1] = content

    elseif self.recipient then
        response[#response+1] = pduString.octet(0x01)
        -- Recipient block
        local rawRecipientrNumber = self.recipient.num:gsub("+","")
        response[#response+1] = rawrecipientNumber:len()
        self.recipient.type = numberType(self.recipient.num)
        response[#response+1] = pduString.octet(self.recipient.type)
        response[#response+1] = pduString.decOctets(self.recipient.num)
        -- Protocol
        response[#response+1] = pduString.octet(0x00)
        -- Decoding

        response[#response+1] = pduString.octet()
        -- Timestamp

        -- Payload

    else
        error("No valid content!")
    end
    return table.concat(response, "")
end

return pduSmsObject
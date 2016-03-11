require("json")
require("luapdu")

function decodeAndPrint(pduString)
    local decoded = luapdu.decode(pduString)
    print(json.encode(decoded))
end

pduStrs = {}
pduStrs[#pduStrs+1] = "0011000A9160214365870008AA1C00640061007400610066006100740061007800610073006400610073"
pduStrs[#pduStrs+1] = "07914400000000F001000B811000000000F0000030C834888E2ECBCB2E97CB284F8362313A1AD40CCB413258CC0682D574B598AB3603C1DB20D4B1495DC552"

for i,v in ipairs(pduStrs) do
    local decodedSMS = luapdu.decode(v)
    print("\n---SMS #"..i)
    print(v)
    print(json.encode(decodedSMS).."\n")
end

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
                failedtags[#failedtags+1] = currPath.." obj1: <"..(v or "nil")..">"
                                                    .." obj2: <"..(obj2[i] or "nil")..">"
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
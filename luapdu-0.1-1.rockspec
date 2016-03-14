package = "Lua-PDU"
 version = "0.1-1"
 source = {
    url = "https://github.com/0x4c4a/lua-pdu.git"
    source.tag = "v0.1-1"
 }
 description = {
    summary = "An example for the LuaRocks tutorial.",
    detailed = [[
      This is a module for decoding and encoding
      PDU SMS which is used for GSM communication.
    ]],
    homepage = "https://github.com/0x4c4a/lua-pdu.git",
    maintainer = "Linards.Jukmanis@0x4c4a.com",
    license = "MIT/X11"
 }
 dependencies = {
    "lua ~> 5.1",
    "json4lua",
    "luabitop"
 }
 build = {
    copy_directories = { "luapdu" }
    -- We'll start here.
 }
 build = {
  type = "builtin",
  modules = {
    ["luapdu"] = "luapdu.lua",
    ["luapdu.string"] = "luapdu/string.lua",
    ["luapdu.smsobject"] = "luapdu/smsobject.lua",
  }
}
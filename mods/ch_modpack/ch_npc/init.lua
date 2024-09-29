print("[MOD BEGIN] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")

-- local S = minetest.get_translator("ch_npc")

local modpath = minetest.get_modpath(minetest.get_current_modname())
local internal = {
	clothes_inv_size = 12,
}

-- API OBJECT
ch_npc = {}

local lua_files = {
	"privs",
	"registrations",
	"entities",
	"formspecs",
	"api",
	"nodes",
	"skins",
}

local function mydofile(filename)
	local f = loadfile(modpath.."/"..filename..".lua")
	if not f then
		error("File "..modpath.."/"..filename..".lua is missing!")
	end
	assert(f)
	return f(internal)
end

for _, filename in ipairs(lua_files) do
	mydofile(filename)
end

print("[MOD END] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")


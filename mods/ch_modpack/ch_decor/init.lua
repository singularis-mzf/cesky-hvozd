print("[MOD BEGIN] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")
local modpath = minetest.get_modpath(minetest.get_current_modname())

local mods = {
	"bbq",
	"cutepie",
	"digistuff",
}

for _, mod in ipairs(mods) do
	dofile(modpath .. "/" .. mod .. ".lua")
end

print("[MOD END] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")

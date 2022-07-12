print("[MOD BEGIN] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")

local modpath = minetest.get_modpath("ch_overrides")

for _, modname in ipairs({"homedecor_kitchen"}) do
	if minetest.get_modpath(modname) then
		dofile(modpath .. "/"..modname..".lua")
	end
end

print("[MOD END] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")

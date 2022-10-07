sausages = {
	S = minetest.get_translator(minetest.get_current_modname()),
	log = function(lvl,msg)
		if not msg then
			msg = lvl
			lvl = "action"
		end
		minetest.log(lvl,"[sausages] " .. msg)
	end,
}

local MP = minetest.get_modpath(minetest.get_current_modname())

local function require(name)
	return dofile(MP .. "/src/" .. name .. ".lua")
end

require("sausages")
require("crafting")

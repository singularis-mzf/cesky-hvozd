print("[MOD BEGIN] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")
local modpath = minetest.get_modpath("bbq_smoke")

dofile(modpath.."/bbq.lua")

local def = table.copy(minetest.registered_nodes["bbq_smoke:chimney_smoke"])
local smoking_items = {
	["bbq_smoke:chimney_smoke"] = 1,
	["bbq_smoke:chimney_smoke_automatic"] = 1,
	["building_blocks:Fireplace"] = 1,
	["default:furnace_active"] = 1,
	["fire:basic_flame"] = 1,
	["fire:permanent_flame"] = 1,
	["technic:coal_alloy_furnace_active"] = 1,
	["technic:lv_generator_active"] = 1,
	["technic:mv_generator_active"] = 1,
	["technic:hv_generator_active"] = 1,
}

def.description = "Kouř (dočasný)"
def.on_construct = function(pos)
	minetest.get_node_timer(pos):start(3)
end
def.on_timer = function(pos)
	local node = minetest.get_node(pos)
	if node.name == "bbq_smoke:chimney_smoke_automatic" then
		node = minetest.get_node(vector.new(pos.x, pos.y - 1, pos.z))
		if smoking_items[node.name] then
			minetest.get_node_timer(pos):start(3) -- wait again
		else
			minetest.remove_node(pos)
		end
	end
end
def.drop = {}
minetest.register_node("bbq_smoke:chimney_smoke_automatic", def)
print("[MOD END] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")

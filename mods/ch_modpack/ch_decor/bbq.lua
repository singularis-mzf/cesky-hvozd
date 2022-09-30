-- Code cut from Your Dad's BBQ Mod
-- (c) Grizzly Adam
-- (c) Singularis — slight modifications and additions
-- LGPLv2.1+

-- Chimeny Smoke
local def = {
	description = "permantentní kouř",
	inventory_image = "bbq_chimney_smoke.png",
	wield_image = "bbq_chimney_smoke.png",
	drawtype = "plantlike",
	paramtype = "light",
	paramtype2 = "facedir",
	buildable_to = true,
	floodable = true,
	sunlight_propagates = true,
	tiles = {
		{
			image = "bbq_chimney_smoke_animation.png",
			backface_culling = false,
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 1.5
			},
		},
	},
	groups = {dig_immediate = 3,
              --attached_node = 1
	},
}
minetest.register_node(":bbq:chimney_smoke", table.copy(def))

--Chimeny Smoke Craft Recipe
minetest.register_craft( {
	output = "bbq:chimney_smoke",
	recipe = {
		{"", "group:wood", ""},
		{"", "group:wood", ""},
		{"", "default:torch", ""}
	}
})

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

def.description = "kouř (dočasný)"
def.on_construct = function(pos)
	minetest.get_node_timer(pos):start(3)
end
def.on_timer = function(pos)
	local node = minetest.get_node(pos)
	if node.name == "bbq:chimney_smoke_automatic" then
		node = minetest.get_node(vector.new(pos.x, pos.y - 1, pos.z))
		if smoking_items[node.name] then
			minetest.get_node_timer(pos):start(3) -- wait again
		else
			minetest.remove_node(pos)
		end
	end
end
def.drop = ""
minetest.register_node(":bbq:chimney_smoke_automatic", def)

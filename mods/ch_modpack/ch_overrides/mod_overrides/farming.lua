local def = {
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5, 0.5, 0.5 - 2 / 32, 0.5},
	},
	paramtype = "light",
	paramtype2 = "facedir",
}

if minetest.get_modpath("screwdriver") then
	def.on_rotate = screwdriver.rotate_simple
end

for _, name in ipairs({"dry_soil", "soil"}) do
	minetest.override_item("farming:"..name, def)
end

def.node_box = {
	type = "fixed",
	fixed = {-0.5, -0.5, -0.5, 0.5, 0.5 - 3 / 32, 0.5},
}
for _, name in ipairs({"dry_soil_wet", "soil_wet"}) do
	minetest.override_item("farming:"..name, def)
end


if minetest.get_modpath("technic_cnc") then
	local old_on_place = {
		["farming:melon_8"] = minetest.registered_nodes["farming:melon_8"].on_place or minetest.item_place,
		["farming:pumpkin_8"] = minetest.registered_nodes["farming:pumpkin_8"].on_place or minetest.item_place,
	}
	local overrides = {
		drawtype = "mesh",
		mesh = "technic_cnc_oblate_spheroid.obj",
		tiles = {{name = "farming_melon_side.png", backface_culling = true}},
		use_texture_alpha = "oblique",
		paramtype2 = "colorfacedir",
		palette = "ch_overrides_melon_palette.png",
		on_growth = function(pos, node, elapsed)
			local facedir = node.param2 % 32
			local new_color = math.random(1, 8) - 1
			node.param2 = 32 * new_color + facedir
			minetest.swap_node(pos, node)
		end,
		on_place = function(itemstack, placer, pointed_thing)
			local name = itemstack:get_name()
			local on_place = old_on_place[name] or minetest.item_place
			local result = on_place(itemstack, placer, table.copy(pointed_thing))
			if pointed_thing.type == "node" then
				local node = minetest.get_node(pointed_thing.above)
				if node.name == name then
					local facedir = node.param2 % 32
					local new_color = math.random(1, 8) - 1
					node.param2 = 32 * new_color + facedir
					minetest.swap_node(pointed_thing.above, node)
				end
			end
			return result
		end,
	}
	minetest.override_item("farming:melon_8", table.copy(overrides))
	overrides.tiles = {{name = "farming_pumpkin_side.png", backface_culling = true}}
	minetest.override_item("farming:pumpkin_8", overrides)
end

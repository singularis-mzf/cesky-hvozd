-- Dirt drop

local dirt_drop = minetest.registered_nodes["default:dirt"].drop

if type(dirt_drop) == "table" then
	local drop_items = dirt_drop.items
	if type(drop_items) ~= "table" then
			error("Table expected as default:dirt drop.drop_items!")
	end
	drop_items = table.copy(drop_items)
	local n = #drop_items
	local empty_table = {}
	local last_dirt_i
	for i, v in ipairs(drop_items) do
		if (v.items or empty_table)[1] == "default:dirt" then
			last_dirt_i = i
		end
	end
	if last_dirt_i ~= nil then
		for i = last_dirt_i, n do
			drop_items[i] = drop_items[i + 1]
		end
		n = n - 1
	end
	for i = n + 1, n + 3 do
		drop_items[i] = {items = {"default:dirt"}, rarity = 2}
	end
	n = n + 3
	if minetest.get_modpath("ch_extras") then
		drop_items[n] = {items = {"ch_extras:clean_dirt"}, rarity = 5}
		-- n = n + 1
	end
	minetest.override_item("default:dirt", {drop = dirt_drop})
else
	minetest.log("warning", "Drop of default:dirt not overriden, because it's not a table!")
end

-- Snow
local box = {
	type = "fixed",
	fixed = {
		{-0.5, -0.5, -0.5, 0.5, -0.375, 0.5},
	},
}
minetest.override_item("default:snow", {
	tiles = {{name = "default_snow.png", backface_culling = true}},
	drawtype = "mesh",
	mesh = "ch_overrides_snow.obj",
	collision_box = box,
	selection_box = box,
})

-- Mese Crystals
minetest.override_item("default:stone_with_mese", {
	drawtype = "mesh",
	mesh = "underch_crystal.obj",
	tiles = {{name = "dfcaverns_glow_mese.png^[brighten", backface_culling = true}},
	use_texture_alpha = "blend",
	paramtype = "light",
	paramtype2 = "facedir",
	light_source = 2,
	sunlight_propagates = true,
	-- TODO: selection_box and collision_box
})
minetest.override_item("default:mese_crystal", {
	on_place = function(itemstack, placer, pointed_thing)
		local shadow_stack = ItemStack(itemstack)
		shadow_stack:set_name("default:stone_with_mese")
		local result = minetest.item_place(shadow_stack, placer, pointed_thing)
		if result:get_count() ~= itemstack:get_count() then
			itemstack:set_count(result:get_count())
		end
		if pointed_thing.type == "node" then
			local node = minetest.get_node(pointed_thing.under)
			if node.name == "default:stone_with_mese" and node.param2 == 0 then
				local meta = minetest.get_meta(pointed_thing.under)
				meta:set_int("node_version", 1)
			end
		end
		return itemstack
	end,
})
minetest.register_lbm({
	label = "Set mese crystals facedir",
	name = "ch_overrides:mese_crystal_facedir_1",
	nodenames = {"default:stone_with_mese"},
	run_at_every_load = true,
	action = function(pos, node, dtime_s)
		if node.param2 == 0 then
			local meta = minetest.get_meta(pos)
			if meta:get_int("node_version") == 0 then
				local new_param2 = math.random(0, 23)
				node.param2 = new_param2
				meta:set_int("node_version", 1)
				minetest.swap_node(pos, node)
			end
		end
	end,
})

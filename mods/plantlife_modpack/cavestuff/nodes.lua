-- support for i18n
local S = minetest.get_translator("cavestuff")

--Rocks

local cbox = {
	type = "fixed",
	fixed = {-4/16, -8/16, -3/16, 4/16, -2/16, 3/16},
}

local function degrotate_after_place_node(pos, placer, itemstack, pointed_thing)
	local node = minetest.get_node(pos)
	local ndef = minetest.registered_nodes[node.name]
	if ndef and ndef.paramtype2 == "degrotate" then
		node.param2 = math.random(0, 239)
		minetest.swap_node(pos, node)
	end
end

local function degrotate_on_rotate(pos, node, user, mode, new_param2)
	if mode == screwdriver.ROTATE_FACE then
		if node.param2 == 239 then
			node.param2 = 0
		else
			node.param2 = node.param2 + 1
		end
	else
		if node.param2 == 0 then
			node.param2 = 239
		else
			node.param2 = node.param2 - 1
		end
	end
	minetest.swap_node(pos, node)
	return true
end

minetest.register_node("cavestuff:pebble_1",{
	description = S("Pebble"),
	drawtype = "mesh",
	mesh = "cavestuff_pebble.obj",
	tiles = {"undergrowth_pebble.png"},
	paramtype = "light",
	paramtype2 = "degrotate",
	groups = {cracky=3, stone=1, attached_node=1, oddly_breakable_by_hand=2},
	selection_box = cbox,
	collision_box = cbox,
	on_place = function(itemstack, placer, pointed_thing)
		-- place a random pebble node
		local stack = ItemStack("cavestuff:pebble_"..math.random(1,2))
		local ret = minetest.item_place(stack, placer, pointed_thing)
		return ItemStack("cavestuff:pebble_1 "..itemstack:get_count()-(1-ret:get_count()))
	end,
	on_rotate = degrotate_on_rotate,
	after_place_node = degrotate_after_place_node,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("cavestuff:pebble_2",{
	drawtype = "mesh",
	mesh = "cavestuff_pebble.obj",
	tiles = {"undergrowth_pebble.png"},
	drop = "cavestuff:pebble_1",
	paramtype = "light",
	paramtype2 = "degrotate",
	groups = {cracky=3, stone=1, attached_node=1, oddly_breakable_by_hand=2, not_in_creative_inventory=1},
	selection_box = cbox,
	collision_box = cbox,
	on_rotate = degrotate_on_rotate,
	after_place_node = degrotate_after_place_node,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("cavestuff:desert_pebble_1",{
	description = S("Desert Pebble"),
	drawtype = "mesh",
	mesh = "cavestuff_pebble.obj",
	tiles = {"default_desert_stone.png"},
	paramtype = "light",
	paramtype2 = "degrotate",
	groups = {cracky=3, stone=1, attached_node=1,oddly_breakable_by_hand=2},
	selection_box = cbox,
	collision_box = cbox,
	on_place = function(itemstack, placer, pointed_thing)
		-- place a random pebble node
		local stack = ItemStack("cavestuff:desert_pebble_"..math.random(1,2))
		local ret = minetest.item_place(stack, placer, pointed_thing)
		return ItemStack("cavestuff:desert_pebble_1 "..itemstack:get_count()-(1-ret:get_count()))
	end,
	on_rotate = degrotate_on_rotate,
	after_place_node = degrotate_after_place_node,
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("cavestuff:desert_pebble_2",{
	drawtype = "mesh",
	mesh = "cavestuff_pebble.obj",
	drop = "cavestuff:desert_pebble_1",
	tiles = {"default_desert_stone.png"},
	paramtype = "light",
	paramtype2 = "degrotate",
	groups = {cracky=3, stone=1, attached_node=1, not_in_creative_inventory=1,oddly_breakable_by_hand=2},
	selection_box = cbox,
	collision_box = cbox,
	on_rotate = degrotate_on_rotate,
	after_place_node = degrotate_after_place_node,
	sounds = default.node_sound_stone_defaults(),
})

local two_pebbels = {"cavestuff:pebble_1", "cavestuff:pebble_1"}
minetest.register_craft({
	output = "default:cobble",
	recipe = {
		two_pebbels,
		two_pebbels,
	},
})
local two_desert_pebbles = {"cavestuff:desert_pebble_1"}
minetest.register_craft({
	output = "default:desert_cobble",
	recipe = {
		two_desert_pebbles,
		two_desert_pebbles,
	},
})



--Staclactites

minetest.register_node("cavestuff:stalactite_1",{
	drawtype="nodebox",
	tiles = {"undergrowth_pebble.png"},
	groups = {cracky=3,attached_node=1},
	description = S("Stalactite"),
	paramtype = "light",
	paramtype2 = "wallmounted",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.187500,-0.425000,-0.150003,0.162500,-0.500000,0.162500},
			{-0.112500,-0.162500,-0.100000,0.087500,-0.475000,0.087500},
			{-0.062500,0.275000,-0.062500,0.062500,-0.500000,0.062500},
			{-0.037500,0.837500,0.037500,0.037500,-0.500000,-0.025000},
		}
	},
	on_place = function(itemstack, placer, pointed_thing)
		local dir = vector.subtract(pointed_thing.above, pointed_thing.under)
		local base = pointed_thing.under
		local place = vector.add(base, dir)
		local above = vector.add(place, dir)

		if not placer then return end
		local playername = placer:get_player_name()
		if minetest.is_protected(place, playername)
		or minetest.is_protected(above, playername) then 
			minetest.record_protection_violation(place, playername)
			return
		end

		if minetest.get_node(base).name == "default:stone"
		and minetest.get_node(place).name == "air"
		and minetest.get_node(above).name == "air"
		then
			minetest.swap_node(place, {
				name = "cavestuff:stalactite_"..math.random(1,3),
				param2 = minetest.dir_to_wallmounted(vector.multiply(dir, -1))
			})
			if not minetest.settings:get_bool("creative_mode", false) then
				itemstack:take_item()
			end
		end
		return itemstack
	end,
})

minetest.register_node("cavestuff:stalactite_2",{
	drawtype="nodebox",
	tiles = {"undergrowth_pebble.png"},
	groups = {cracky=3,attached_node=1,not_in_creative_inventory=1},
	drop = "cavestuff:stalactite_1",
	paramtype = "light",
	paramtype2 = "wallmounted",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.187500,-0.387500,-0.150003,0.162500,-0.500000,0.162500},
			{-0.112500,-0.112500,-0.100000,0.087500,-0.475000,0.087500},
			{-0.062500,0.675000,-0.062500,0.062500,-0.500000,0.062500},
			{-0.037500,0.975000,0.037500,0.037500,-0.500000,-0.025000},
		}
	},
})

minetest.register_node("cavestuff:stalactite_3",{
	drawtype="nodebox",
	tiles = {"undergrowth_pebble.png"},
	groups = {cracky=3,attached_node=1,not_in_creative_inventory=1},
	drop = "cavestuff:stalactite_1",
	paramtype = "light",
	paramtype2 = "wallmounted",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.187500,-0.387500,-0.150003,0.162500,-0.500000,0.162500},
			{-0.112500,-0.037500,-0.100000,0.087500,-0.475000,0.087500},
			{-0.062500,0.437500,-0.062500,0.062500,-0.500000,0.062500},
			{-0.037500,1.237500,0.037500,0.037500,-0.500000,-0.025000},
		}
	},
})

--Stalagmites

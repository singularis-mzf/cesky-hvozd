local S = minetest.get_translator("more_boats")
local modpath = minetest.get_modpath("more_boats")
dofile(modpath .."/aspen.lua")
dofile(modpath .."/acacia.lua")
dofile(modpath .."/jungle.lua")
dofile(modpath .."/pine.lua")
minetest.register_craft({
	output = "boats:boat",
	recipe = {
		{"", "", ""},
		{"default:wood", "", "default:wood"},
		{"default:wood", "default:wood", "default:wood"},
	},
})

local function is_water(pos)
	local nn = minetest.get_node(pos).name
	return minetest.get_item_group(nn, "water") ~= 0
end

-- aspen boat
minetest.register_entity("more_boats:aspen_boat", aspen_boat)
minetest.register_craftitem("more_boats:aspen_boat", {
	description = S("Aspen Boat"),
	inventory_image = "more_boats_aspen_inv.png",
	wield_image = "more_boats_aspen_wield.png",
	wield_scale = {x = 2, y = 2, z = 1},
	liquids_pointable = true,
	groups = {flammable = 2},
	on_place = function(itemstack, placer, pointed_thing)
		local under = pointed_thing.under
		local node = minetest.get_node(under)
		local udef = minetest.registered_nodes[node.name]
		if udef and udef.on_rightclick and
				not (placer and placer:is_player() and
				placer:get_player_control().sneak) then
			return udef.on_rightclick(under, node, placer, itemstack,
				pointed_thing) or itemstack
		end

		if pointed_thing.type ~= "node" then
			return itemstack
		end
		if not is_water(pointed_thing.under) then
			return itemstack
		end
		pointed_thing.under.y = pointed_thing.under.y + 0.5
		boat = minetest.add_entity(pointed_thing.under, "more_boats:aspen_boat")
		if boat then
			if placer then
				boat:set_yaw(placer:get_look_horizontal())
			end
			local player_name = placer and placer:get_player_name() or ""
			if not minetest.is_creative_enabled(player_name) then
				itemstack:take_item()
			end
		end
		return itemstack
	end,
})
minetest.register_craft({
	output = "more_boats:aspen_boat",
	recipe = {
		{"", "", ""},
		{"default:aspen_wood", "", "default:aspen_wood"},
		{"default:aspen_wood", "default:aspen_wood", "default:aspen_wood"},
	},
})
minetest.register_craft({
	type = "fuel",
	recipe = "more_boats:aspen_boat",
	burntime = 20,
})

-- acacia boat
minetest.register_entity("more_boats:acacia_boat", acacia_boat)
minetest.register_craftitem("more_boats:acacia_boat", {
	description = S("Acacia Boat"),
	inventory_image = "more_boats_acacia_inv.png",
	wield_image = "more_boats_acacia_wield.png",
	wield_scale = {x = 2, y = 2, z = 1},
	liquids_pointable = true,
	groups = {flammable = 2},
	on_place = function(itemstack, placer, pointed_thing)
		local under = pointed_thing.under
		local node = minetest.get_node(under)
		local udef = minetest.registered_nodes[node.name]
		if udef and udef.on_rightclick and
				not (placer and placer:is_player() and
				placer:get_player_control().sneak) then
			return udef.on_rightclick(under, node, placer, itemstack,
				pointed_thing) or itemstack
		end

		if pointed_thing.type ~= "node" then
			return itemstack
		end
		if not is_water(pointed_thing.under) then
			return itemstack
		end
		pointed_thing.under.y = pointed_thing.under.y + 0.5
		boat = minetest.add_entity(pointed_thing.under, "more_boats:acacia_boat")
		if boat then
			if placer then
				boat:set_yaw(placer:get_look_horizontal())
			end
			local player_name = placer and placer:get_player_name() or ""
			if not minetest.is_creative_enabled(player_name) then
				itemstack:take_item()
			end
		end
		return itemstack
	end,
})
minetest.register_craft({
	output = "more_boats:acacia_boat",
	recipe = {
		{"", "", ""},
		{"default:acacia_wood", "", "default:acacia_wood"},
		{"default:acacia_wood", "default:acacia_wood", "default:acacia_wood"},
	},
})
minetest.register_craft({
	type = "fuel",
	recipe = "more_boats:acacia_boat",
	burntime = 20,
})

-- jungle boat
minetest.register_entity("more_boats:jungle_boat", jungle_boat)
minetest.register_craftitem("more_boats:jungle_boat", {
	description = S("Jungle Wood Boat"),
	inventory_image = "more_boats_jungle_inv.png",
	wield_image = "more_boats_jungle_wield.png",
	wield_scale = {x = 2, y = 2, z = 1},
	liquids_pointable = true,
	groups = {flammable = 2},
	on_place = function(itemstack, placer, pointed_thing)
		local under = pointed_thing.under
		local node = minetest.get_node(under)
		local udef = minetest.registered_nodes[node.name]
		if udef and udef.on_rightclick and
				not (placer and placer:is_player() and
				placer:get_player_control().sneak) then
			return udef.on_rightclick(under, node, placer, itemstack,
				pointed_thing) or itemstack
		end

		if pointed_thing.type ~= "node" then
			return itemstack
		end
		if not is_water(pointed_thing.under) then
			return itemstack
		end
		pointed_thing.under.y = pointed_thing.under.y + 0.5
		boat = minetest.add_entity(pointed_thing.under, "more_boats:jungle_boat")
		if boat then
			if placer then
				boat:set_yaw(placer:get_look_horizontal())
			end
			local player_name = placer and placer:get_player_name() or ""
			if not minetest.is_creative_enabled(player_name) then
				itemstack:take_item()
			end
		end
		return itemstack
	end,
})
minetest.register_craft({
	output = "more_boats:jungle_boat",
	recipe = {
		{"", "", ""},
		{"default:junglewood", "", "default:junglewood"},
		{"default:junglewood", "default:junglewood", "default:junglewood"},
	},
})
minetest.register_craft({
	type = "fuel",
	recipe = "more_boats:jungle_boat",
	burntime = 20,
})

-- pine boat
minetest.register_entity("more_boats:pine_boat", pine_boat)
minetest.register_craftitem("more_boats:pine_boat", {
	description = S("Pine Boat"),
	inventory_image = "more_boats_pine_inv.png",
	wield_image = "more_boats_pine_wield.png",
	wield_scale = {x = 2, y = 2, z = 1},
	liquids_pointable = true,
	groups = {flammable = 2},
	on_place = function(itemstack, placer, pointed_thing)
		local under = pointed_thing.under
		local node = minetest.get_node(under)
		local udef = minetest.registered_nodes[node.name]
		if udef and udef.on_rightclick and
				not (placer and placer:is_player() and
				placer:get_player_control().sneak) then
			return udef.on_rightclick(under, node, placer, itemstack,
				pointed_thing) or itemstack
		end

		if pointed_thing.type ~= "node" then
			return itemstack
		end
		if not is_water(pointed_thing.under) then
			return itemstack
		end
		pointed_thing.under.y = pointed_thing.under.y + 0.5
		boat = minetest.add_entity(pointed_thing.under, "more_boats:pine_boat")
		if boat then
			if placer then
				boat:set_yaw(placer:get_look_horizontal())
			end
			local player_name = placer and placer:get_player_name() or ""
			if not minetest.is_creative_enabled(player_name) then
				itemstack:take_item()
			end
		end
		return itemstack
	end,
})
minetest.register_craft({
	output = "more_boats:pine_boat",
	recipe = {
		{"", "", ""},
		{"default:pine_wood", "", "default:pine_wood"},
		{"default:pine_wood", "default:pine_wood", "default:pine_wood"},
	},
})
minetest.register_craft({
	type = "fuel",
	recipe = "more_boats:pine_boat",
	burntime = 20,
})

local function register_seed (name, inv_img, tile, displayname, description, max_growtime, place_group, grow_func)
	awg: register_node('seed_' .. name, {
		displayname = displayname,
		description = description,
		inventory_image = inv_img,
		wield_image = inv_img,
		tiles = {tile},
		groups = {seed = 1, snappy = 3, attached_node = 1, crop = 1, plant = 1},
		sunlight_propagates = true,
		walkable = false,
		drawtype = 'plantlike',
		paramtype = 'light',
		paramtype2 = 'meshoptions',
		floodadable = true,
		buildable_to = true,
		place_param2 = 41,
		drop = '',
		node_placement_prediction = '',
		sounds = default.node_sound_leaves_defaults(),
		selection_box = {
			type = 'fixed',
			fixed = {-0.25, -0.5, -0.25, 0.25, -0.25, 0.25}
		},
		on_construct = function (pos)
			minetest.get_node_timer(pos): start(math.random(max_growtime*0.3, max_growtime))
		end,
		on_place = function (itemstack, placer, pointed_thing)
			local stack, pos = minetest.item_place_node(itemstack, placer, pointed_thing)
			
			local node = minetest.get_node(pos - vector.new(0, 1, 0))
			if minetest.get_item_group(node.name, place_group) > 0 then
				return stack
			else
				minetest.set_node(pos, {name = 'air'})
				return nil
			end
		end,
		on_timer = grow_func
	})
end

local function register_seed_rooted (place_node, name, inv_img, tile, displayname, description, max_growtime, min_height, max_height, grow_func)
	awg: register_node('seed_' .. name, {
		displayname = displayname,
		description = description,
		inventory_image = inv_img,
		wield_image = inv_img,
		tiles = {minetest.registered_nodes[place_node].tiles[1]},
		special_tiles = {tile},
		groups = {seed = 1, snappy = 3, crop = 1, plant = 1},
		sunlight_propagates = true,
		drawtype = 'plantlike_rooted',
		paramtype = 'light',
		paramtype2 = 'meshoptions',
		drop = '',
		node_placement_prediction = '',
		node_dig_prediction = place_node,
		sounds = default.node_sound_leaves_defaults(),
		selection_box = {
			type = 'fixed',
			fixed = {
					{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
					{-2/16, 0.5, -2/16, 2/16, 1.25, 2/16},
			},
		},
		on_construct = function (pos)
			minetest.get_node_timer(pos): start(math.random(max_growtime*0.3, max_growtime))
		end,
		on_timer = grow_func,
		on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type == 'node' and not (placer and placer:is_player()
				and placer:get_player_control().sneak) then
			local node_ptu = minetest.get_node(pointed_thing.under)
			local def_ptu = minetest.registered_nodes[node_ptu.name]
			if def_ptu and def_ptu.on_rightclick then
				return def_ptu.on_rightclick(pointed_thing.under, node_ptu, placer,
					itemstack, pointed_thing)
			end
		end

		local pos = pointed_thing.under
		if minetest.get_node(pos).name ~= place_node then
			return itemstack
		end

		local height = math.random(min_height, max_height)
		local pos_top = {x = pos.x, y = pos.y + height, z = pos.z}
		local node_top = minetest.get_node(pos_top)
		local def_top = minetest.registered_nodes[node_top.name]
		local player_name = placer:get_player_name()

		if def_top and def_top.liquidtype == 'source' and
				minetest.get_item_group(node_top.name, "water") > 0 then
			if not minetest.is_protected(pos, player_name) and not minetest.is_protected(pos_top, player_name) then
				minetest.set_node(pos, {name = 'always_greener:seed_' .. name, param2 = 41})
				local meta = minetest.get_meta(pos)
				meta: set_int('height', height * 16)
				if not minetest.is_creative_enabled(player_name) then
					itemstack:take_item()
				end
			end
		end

		return itemstack
	end,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		minetest.set_node(pos, {name = place_node})
	end
	})
end

register_seed(
	'mushroom_brown',
	'awg_mushroom_spores_brown_inv.png',
	'awg_mushroom_spores_brown.png',
	'Brown Mushroom Spores',
	'Grows into brown mushrooms. Plant on soil.',
	500,
	'soil',
	function (pos)
		minetest.set_node(pos, {name = 'flowers:mushroom_brown_'..math.random(1,3)})
	end
)

minetest.register_craft {
	type = 'shapeless',
	output = 'awg:seed_mushroom_brown 3',
	recipe = {'flowers:mushroom_brown'}
}

register_seed(
	'mushroom_red',
	'awg_mushroom_spores_red_inv.png',
	'awg_mushroom_spores_red.png',
	'Red Mushroom Spores',
	'Grows into red mushrooms. Plant on soil.',
	300,
	'soil',
	function (pos)
		minetest.set_node(pos, {name = 'flowers:mushroom_red_'..math.random(1,3)})
	end
)

minetest.register_craft {
	type = 'shapeless',
	output = 'awg:seed_mushroom_red 3',
	recipe = {'flowers:mushroom_red'}
}

if minetest.settings: get_bool('awg.load_module_grassland', true) then
	register_seed(
		'mushroom_field',
		'awg_mushroom_spores_field_inv.png',
		'awg_mushroom_spores_field.png',
		'Field Mushroom Spores',
		'Grows into field mushrooms. Plant on soil.',
		300,
		'soil',
		function (pos)
			minetest.set_node(pos, {name = 'always_greener:field_mushroom_'..math.random(1,3)})
		end
	)

	minetest.register_craft {
		type = 'shapeless',
		output = 'awg:seed_mushroom_field 3',
		recipe = {'always_greener:field_mushroom_1'}
	}
	
	register_seed(
		'cane',
		'awg_seed_cane.png',
		'awg_seed_cane.png',
		'Giant Cane Shoot',
		'Grows into giant cane. Plant on soil.',
		900,
		'soil',
		function (pos)
			local height = math.random(1, 3)
			local rotation = math.random(0, 239)
			local has_top = math.random(1,2) == 1
			
			minetest.set_node(pos, {name = 'always_greener:cane_bottom', param2 = rotation})
			
			for i = 1, height do
				local node_up = minetest.get_node(pos + vector.new(0,i,0))
				if node_up.name == 'air' then
					minetest.set_node(pos + vector.new(0,i,0), {name = 'always_greener:cane_middle', param2 = rotation})
				else
					has_top = false
					break
				end
			end
			
			local node_top = minetest.get_node(pos + vector.new(0,height+1,0))
			if has_top and node_top.name == 'air' then
				minetest.set_node(pos + vector.new(0,height+1,0), {name = 'always_greener:cane_top', param2 = rotation})
			end
		end
	)

	minetest.register_craft {
		type = 'shapeless',
		output = 'awg:seed_cane 3',
		recipe = {'awg:cane_top'}
	}
end

register_seed_rooted(
	'default:sand',
	'kelp',
	'awg_seed_kelp.png',
	'awg_seed_kelp.png',
	'Kelp Sporophyte',
	'Grows into kelp. Plant on sand under deep water.',
	400,
	4,
	6,
	function (pos)
		local meta = minetest.get_meta(pos)
		local height = meta: get_int 'height'
		minetest.set_node(pos, {name = 'default:sand_with_kelp', param2 = height})
	end
)

minetest.register_craft {
	type = 'shapeless',
	output = 'awg:seed_kelp 5',
	recipe = {'default:sand_with_kelp'}
}

register_seed_rooted(
	'default:coral_skeleton',
	'coral_green',
	'awg_seed_coral_green_inv.png',
	'awg_seed_coral_green.png',
	'Green Coral Polyp',
	'Grows into green coral. Plant on coral skeleton underwater.',
	800,
	1,
	1,
	function (pos)
		minetest.set_node(pos, {name = 'default:coral_green'})
	end
)

minetest.register_craft {
	type = 'shapeless',
	output = 'awg:seed_coral_green 6',
	recipe = {'default:coral_green'}
}

register_seed_rooted(
	'default:coral_skeleton',
	'coral_pink',
	'awg_seed_coral_pink_inv.png',
	'awg_seed_coral_pink.png',
	'Pink Coral Polyp',
	'Grows into pink coral. Plant on coral skeleton underwater.',
	800,
	1,
	1,
	function (pos)
		minetest.set_node(pos, {name = 'default:coral_pink'})
	end
)

minetest.register_craft {
	type = 'shapeless',
	output = 'awg:seed_coral_pink 6',
	recipe = {'default:coral_pink'}
}

register_seed_rooted(
	'default:coral_skeleton',
	'coral_cyan',
	'awg_seed_coral_cyan_inv.png',
	'awg_seed_coral_cyan.png',
	'Cyan Coral Polyp',
	'Grows into cyan coral. Plant on coral skeleton underwater.',
	800,
	1,
	1,
	function (pos)
		minetest.set_node(pos, {name = 'default:coral_cyan'})
	end
)

minetest.register_craft {
	type = 'shapeless',
	output = 'awg:seed_coral_cyan 6',
	recipe = {'default:coral_cyan'}
}

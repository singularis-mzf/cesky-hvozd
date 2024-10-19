
local cuttable = {}

local uses = minetest.settings: get 'awg.secateurs_num_uses' or 300

awg: register_tool('secateurs', {
	displayname = 'Secateurs',
	description = 'Used to take cuttings of plants in order to reproduce them.',
	stats = '<LMB> on a plant to take a cutting',
	inventory_image = 'awg_secateurs.png',
	wield_image = 'awg_secateurs.png^[transformFX',
	on_use = function (itemstack, user, pointed_thing)
		local pos = pointed_thing.under
		
		if not pos then return itemstack end
		
		if minetest.is_protected(pos, user: get_player_name()) then
			return itemstack
		end
		
		local node = minetest.get_node(pos)
		
		if node and cuttable[node.name] then
			local meta = minetest.get_meta(pos)
			
			if meta: get_int 'awg:cuttings' == cuttable[node.name][1] - 1 then
				minetest.set_node(pos, {name = 'air'})
			end
			
			meta: set_int('awg:cuttings', meta: get_int 'awg:cuttings' + 1)
			etc.give_or_drop(user, pos, ItemStack(cuttable[node.name][2]))
			
			minetest.sound_play('awg_snip', {pos = pos, gain = 0.5, max_hear_distance = 10, pitch = 0.9 + (math.random() * 0.2)}, true)
			
			local wear = itemstack: get_wear()
			wear = wear + 65536/uses
			if wear >= 65535 then
				minetest.sound_play('default_tool_breaks', {to_player = user: get_player_name(), gain = 1}, true)
				return ItemStack()
			end
			itemstack: set_wear(wear)
			return itemstack
		end
	end
})

minetest.register_craft {
	output = 'awg:secateurs',
	recipe = {
		{'', 'default:tin_ingot', 'etcetera:sandpaper_0'},
		{'default:stick', '', 'default:tin_ingot'},
		{'', 'default:stick', ''}
	}
}

local function cutting_on_construct (pos)
	minetest.get_node_timer(pos): start(math.random(90, 600))
end

local function cutting_on_timer (nodename)
	return function(pos)
		local def = minetest.registered_nodes[nodename]
		minetest.set_node(pos, {name = nodename, param2 = def.place_param2})
	end
end

local function cutting_on_place (itemstack, placer, pointed_thing)
	local stack, pos = minetest.item_place_node(itemstack, placer, pointed_thing)
	
	local node = minetest.get_node(pos - vector.new(0, 1, 0))
	if minetest.get_item_group(node.name, 'dirt') + minetest.get_item_group(node.name, 'soil') > 0 then
		return stack
	else
		minetest.set_node(pos, {name = 'air'})
		return nil
	end
end

local inv = minetest.settings: get_bool('awg.cuttings_list', false)

local function register_cutting (nodename, can_grow, nomask)
	local itemname = 'always_greener:cutting_' .. string.split(nodename, ':')[2]
	local node = minetest.registered_nodes[nodename]
	if can_grow then
		minetest.register_node(itemname, {
			description = node.description .. ' ' .. awg.gettext('Cuttings', 'normal'),
			inventory_image = (not nomask) and ('awg_cutting.png^(' .. node.inventory_image .. '^[mask:awg_cutting_mask.png)') or 'awg_cutting.png',
			color = node.color,
			groups = {not_in_creative_inventory = inv and 0 or 1, snappy = 3, attached_node = 1, crop = 1},
			tiles = {(not nomask) and (node.inventory_image .. '^[mask:awg_cutting_planted_mask.png^awg_cutting_planted_overlay.png') or 'awg_cutting_planted.png'},
			sunlight_propagates = true,
			walkable = false,
			drawtype = 'plantlike',
			paramtype = 'light',
			paramtype2 = 'meshoptions',
			floodadable = true,
			buildable_to = true,
			place_param2 = 41,
			sounds = default.node_sound_leaves_defaults(),
			selection_box = {
				type = 'fixed',
				fixed = {-0.15, -0.5, -0.15, 0.15, -0.25, 0.15}
			},
			on_construct = cutting_on_construct,
			on_timer = cutting_on_timer(nodename),
			on_place = cutting_on_place
		})
	else
		minetest.register_craftitem(itemname, {
			description = node.description .. ' ' .. awg.gettext('Cuttings', 'normal'),
			inventory_image = (not nomask) and ('awg_cutting.png^(' .. node.inventory_image .. '^[mask:awg_cutting_mask.png)') or 'awg_cutting.png',
			color = node.color,
			groups = {not_in_creative_inventory = inv and 0 or 1}
		})
	end
	
	return itemname
end

local function register_cuttable (nodename, can_grow, hp, cutting, nomask)
	minetest.override_item(nodename, {
		on_dig = function(pos, node, digger)
			local meta = minetest.get_meta(pos)
			if meta: get_int 'awg:cuttings' > 0 then
				minetest.set_node(pos, {name = 'air'})
				return false
			else
				return minetest.node_dig(pos, node, digger)
			end
		end
	})
	
	if cutting then
		cuttable[nodename] = {hp, cutting}
	else
		cutting = register_cutting(nodename, can_grow, nomask)
		cuttable[nodename] = {hp, cutting}
		
		if etc.modules.farming_tweaks then
			etc.farming_tweaks.plants[cutting] = nodename
		end
	end
end

register_cuttable('default:grass_1', false, 1, nil, true)
register_cuttable('default:grass_2', nil, 2, 'always_greener:cutting_grass_1')
register_cuttable('default:grass_3', nil, 2, 'always_greener:cutting_grass_1')
register_cuttable('default:grass_4', nil, 2, 'always_greener:cutting_grass_1')
register_cuttable('default:grass_5', nil, 3, 'always_greener:cutting_grass_1')
register_cuttable('always_greener:grass_6', nil, 4, 'always_greener:cutting_grass_1')
register_cuttable('always_greener:grass_7', nil, 5, 'always_greener:cutting_grass_1')

register_cuttable('default:dry_grass_1', false, 1, nil, true)
register_cuttable('default:dry_grass_2', nil, 2, 'always_greener:cutting_dry_grass_1')
register_cuttable('default:dry_grass_3', nil, 2, 'always_greener:cutting_dry_grass_1')
register_cuttable('default:dry_grass_4', nil, 2, 'always_greener:cutting_dry_grass_1')
register_cuttable('default:dry_grass_5', nil, 3, 'always_greener:cutting_dry_grass_1')
register_cuttable('always_greener:dry_grass_6', nil, 4, 'always_greener:cutting_dry_grass_1')
register_cuttable('always_greener:dry_grass_7', nil, 5, 'always_greener:cutting_dry_grass_1')

if minetest.settings: get_bool('awg.craft_grass_blocks', true) then
	minetest.register_craft {
		type = 'shapeless',
		output = 'default:dirt_with_grass',
		recipe = {
			'always_greener:cutting_grass_1', 'always_greener:cutting_grass_1', 'always_greener:cutting_grass_1',
			'always_greener:cutting_grass_1', 'default:dirt', 'always_greener:cutting_grass_1',
			'always_greener:cutting_grass_1', 'always_greener:cutting_grass_1', 'always_greener:cutting_grass_1'
		}
	}

	minetest.register_craft {
		type = 'shapeless',
		output = 'always_greener:dry_dirt_with_grass',
		recipe = {
			'always_greener:cutting_dry_grass_1', 'always_greener:cutting_dry_grass_1', 'always_greener:cutting_dry_grass_1',
			'always_greener:cutting_dry_grass_1', 'default:dry_dirt', 'always_greener:cutting_dry_grass_1',
			'always_greener:cutting_dry_grass_1', 'always_greener:cutting_dry_grass_1', 'always_greener:cutting_dry_grass_1'
		}
	}
end

register_cuttable('flowers:chrysanthemum_green', true, 2, nil, false)
register_cuttable('flowers:dandelion_white', true, 2, nil, false)
register_cuttable('flowers:dandelion_yellow', true, 2, nil, false)
register_cuttable('flowers:geranium', true, 2, nil, false)
register_cuttable('flowers:rose', true, 2, nil, false)
register_cuttable('flowers:tulip', true, 2, nil, false)
register_cuttable('flowers:tulip_black', true, 2, nil, false)
register_cuttable('flowers:viola', true, 2, nil, false)

register_cuttable('default:fern_1', true, 2, nil, false)
register_cuttable('default:fern_2', false, 3, 'always_greener:cutting_fern_1')
register_cuttable('default:fern_3', false, 5, 'always_greener:cutting_fern_1')

register_cuttable('default:junglegrass', true, 4, nil, false)
register_cuttable('always_greener:jungle_grass_flowering', true, 4, nil, false)
register_cuttable('always_greener:jungle_grass_short', true, 2, nil, false)

register_cuttable('default:papyrus', true, 3, nil, false)

register_cuttable('farming:cotton_wild', true, 3, nil, false)

if minetest.settings: get_bool('awg.load_module_tundra', true) then
	register_cuttable('always_greener:tundra_shrub', true, 2, nil, false)
	register_cuttable('always_greener:tundra_shrub_2', true, 2, nil, false)
	register_cuttable('always_greener:tundra_shrub_3', true, 4, nil, false)
end

if minetest.settings: get_bool('awg.load_module_grassland', true) then
	register_cuttable('always_greener:sage', true, 4, nil, false)
	register_cuttable('always_greener:clover', true, 2, nil, false)
	register_cuttable('always_greener:clover_flower', true, 2, nil, false)
	
	register_cuttable('always_greener:bulrush_1', true, 3, nil, false)
	register_cuttable('always_greener:bulrush_2', false, 3, 'always_greener:cutting_bulrush_1')
	
	register_cuttable('always_greener:marshgrass_1', true, 2, nil, false)
	register_cuttable('always_greener:marshgrass_2', false, 3, 'always_greener:cutting_marshgrass_1')
	register_cuttable('always_greener:marshgrass_3', false, 4, 'always_greener:cutting_marshgrass_1')
end

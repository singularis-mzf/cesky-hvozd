ch_base.open_mod(minetest.get_current_modname())
-- Translation support
local S = minetest.get_translator("new_campfire")

local ch_help = "Ohniště vhodně umístěte (ne do blízkosti hořlavých předmětů).\n"..
	"Pravým klikem křesadlem je zapálíte. Pak můžete přikládat tyčky.\n"..
	"Nakonec nechte ohniště vyhasnout a vychladnout. Prázdné ohniště budete moci vysbírat\n"..
	"nebo naplnit novými tyčkami. Kdykoliv můžete přidat (pravým klikem) gril. Gril odeberete\n"..
	"levým klikem, když ohniště zrovna nehoří."

local ch_help_group = "ncfire"

-- VARIABLES

new_campfire = {}

new_campfire.cooking = 1        -- nil - not cooked, 1 - cooked
new_campfire.limited = 1        -- nil - unlimited campfire, 1 - limited
new_campfire.flames_ttl = 30    -- Time in seconds until a fire burns down into embers
new_campfire.embers_ttl = 60    -- seconds until embers burn out completely leaving ash and an empty fireplace.
new_campfire.flare_up = 2       -- seconds from adding a stick to embers before it flares into a fire again
new_campfire.stick_time = new_campfire.flames_ttl/2;   -- How long does the stick increase. In sec.

-- FUNCTIONS
local function fire_particles_on(pos) -- 3 layers of fire
	local meta = minetest.get_meta(pos)
	local id = minetest.add_particlespawner({ -- 1 layer big particles fire
		amount = 9,
		time = 1.3,
		minpos = {x = pos.x - 0.2, y = pos.y - 0.4, z = pos.z - 0.2},
		maxpos = {x = pos.x + 0.2, y = pos.y - 0.1, z = pos.z + 0.2},
		minvel = {x= 0, y= 0, z= 0},
		maxvel = {x= 0, y= 0.1, z= 0},
		minacc = {x= 0, y= 0, z= 0},
		maxacc = {x= 0, y= 0.7, z= 0},
		minexptime = 0.5,
		maxexptime = 0.7,
		minsize = 2,
		maxsize = 5,
		collisiondetection = false,
		vertical = true,
		texture = "new_campfire_anim_fire.png",
		animation = {type="vertical_frames", aspect_w=16, aspect_h=16, length = 0.8,},
--      playername = "singleplayer"
	})
	meta:set_int("layer_1", id)

	local id = minetest.add_particlespawner({ -- 2 layer smol particles fire
		amount = 1,
		time = 1.3,
		minpos = {x = pos.x - 0.1, y = pos.y, z = pos.z - 0.1},
		maxpos = {x = pos.x + 0.1, y = pos.y + 0.4, z = pos.z + 0.1},
		minvel = {x= 0, y= 0, z= 0},
		maxvel = {x= 0, y= 0.1, z= 0},
		minacc = {x= 0, y= 0, z= 0},
		maxacc = {x= 0, y= 1, z= 0},
		minexptime = 0.4,
		maxexptime = 0.6,
		minsize = 0.5,
		maxsize = 0.7,
		collisiondetection = false,
		vertical = true,
		texture = "new_campfire_anim_fire.png",
		animation = {type="vertical_frames", aspect_w=16, aspect_h=16, length = 0.7,},
	 -- playername = "singleplayer"
	})
	meta:set_int("layer_2", id)

	local id = minetest.add_particlespawner({ --3 layer smoke
		amount = 1,
		time = 1.3,
		minpos = {x = pos.x - 0.1, y = pos.y - 0.2, z = pos.z - 0.1},
		maxpos = {x = pos.x + 0.2, y = pos.y + 0.4, z = pos.z + 0.2},
		minvel = {x= 0, y= 0, z= 0},
		maxvel = {x= 0, y= 0.1, z= 0},
		minacc = {x= 0, y= 0, z= 0},
		maxacc = {x= 0, y= 1, z= 0},
		minexptime = 0.6,
		maxexptime = 0.8,
		minsize = 2,
		maxsize = 4,
		collisiondetection = true,
		vertical = true,
		texture = "new_campfire_anim_smoke.png",
		animation = {type="vertical_frames", aspect_w=16, aspect_h=16, length = 0.9,},
		-- playername = "singleplayer"
	})
	meta:set_int("layer_3", id)
end

local function fire_particles_off(pos)
	local meta = minetest.get_meta(pos)
	local id_1 = meta:get_int("layer_1");
	local id_2 = meta:get_int("layer_2");
	local id_3 = meta:get_int("layer_3");
	minetest.delete_particlespawner(id_1)
	minetest.delete_particlespawner(id_2)
	minetest.delete_particlespawner(id_3)
end

-- we do this to determine the number of bytes each block symbol takes in the
-- user's current encoding (they're 3-byte UTF8 on my box, but that may not be
-- the case elsewhere)

local utf8_len_1=string.find("▓X", "X")-1
local utf8_len_2=string.find("▒X", "X")-1

local function indicator(maxVal, curVal)
	local percent_val = math.floor(curVal / maxVal * 100)
	local v = math.min(math.ceil(percent_val / 10), 10)

	return "\n"
	       ..string.sub("▓▓▓▓▓▓▓▓▓▓", 1, v*utf8_len_1)
	       ..string.sub("▒▒▒▒▒▒▒▒▒▒", 1, (10-v)*utf8_len_2)
	       .." "..percent_val.."%"
end

local function effect(pos, texture, vlc, acc, time, size)
	local id = minetest.add_particle({
		pos = pos,
		velocity = vlc,
		acceleration = acc,
		expirationtime = time,
		size = size,
		collisiondetection = true,
		vertical = true,
		texture = texture,
	})
end

local function infotext_edit(meta)
	local infotext = S("Active campfire")

	if new_campfire.limited and new_campfire.flames_ttl > 0 then
		local it_val = meta:get_int("it_val");
		infotext = infotext..indicator(new_campfire.flames_ttl, it_val)
	end

	local cooked_time = meta:get_int('cooked_time');
	if new_campfire.cooking and cooked_time ~= 0 then
		local cooked_cur_time = meta:get_int('cooked_cur_time');
		infotext = infotext.."\n"..S("Cooking")..indicator(cooked_time, cooked_cur_time)
	end

	meta:set_string('infotext', infotext)
end

local function cooking(pos, itemstack, is_creative)
	local meta = minetest.get_meta(pos)
	local cooked, _ = minetest.get_craft_result({method = "cooking", width = 1, items = {itemstack}})
	local cookable = cooked.time ~= 0

	if cookable and new_campfire.cooking then
		local result_stack = ItemStack(cooked.item:to_table().name)
		local result_name = result_stack:get_name()
		local eat_y = result_stack:get_definition().on_use
		if
			(minetest.get_item_group(result_name, "ch_food") ~= 0 or
			minetest.get_item_group(result_name, "drink") ~= 0 or
			minetest.get_item_group(result_name, "ch_poison") ~= 0 or
			string.find(minetest.serialize(eat_y), "do_item_eat")) and
			meta:get_int("cooked_time") == 0
		then
			meta:set_int('cooked_time', cooked.time);
			meta:set_int('cooked_cur_time', 0);
			local name = itemstack:get_name()
			local texture = itemstack:get_definition().inventory_image

			infotext_edit(meta)

			effect(
				{x = pos.x, y = pos.y+0.2, z = pos.z},
				texture,
				{x=0, y=0, z=0},
				{x=0, y=0, z=0},
				cooked.time,
				4
			)

			minetest.after(cooked.time/2, function()
				if meta:get_int("it_val") > 0 then

					local item = cooked.item:to_table().name
					minetest.after(cooked.time/2, function(item)
						if meta:get_int("it_val") > 0 then
							minetest.add_item({x=pos.x, y=pos.y+0.2, z=pos.z}, item)
							meta:set_int('cooked_time', 0);
							meta:set_int('cooked_cur_time', 0);
						else
							minetest.add_item({x=pos.x, y=pos.y+0.2, z=pos.z}, name)
						end
					end, item)
				else
					minetest.add_item({x=pos.x, y=pos.y+0.2, z=pos.z}, name)
				end
			end)

			print("cooking() is_creative = "..(is_creative and "true" or "false"))

			if not is_creative then
				itemstack:take_item()
				return itemstack
			end
		end
	end
end

local function add_stick(pos, itemstack, is_creative)
	local meta = minetest.get_meta(pos)
	local name = itemstack:get_name()
	if itemstack:get_definition().groups.stick == 1 then
		local it_val = meta:get_int("it_val") + (new_campfire.flames_ttl);
		meta:set_int('it_val', it_val);
		effect(
			pos,
			"default_stick.png",
			{x=0, y=-1, z=0},
			{x=0, y=0, z=0},
			1,
			6
		)
		infotext_edit(meta)
		if not is_creative then
			itemstack:take_item()
			return itemstack
		end
		return true
	end
end

local function burn_out(pos, node)
	if string.find(node.name, "embers") then
		node.name = string.gsub(node.name, "_with_embers", "")
		minetest.set_node(pos, node)
		minetest.add_item(pos, "new_campfire:ash")
	else
		fire_particles_off(pos)
		node.name = string.gsub(node.name, "campfire_active", "fireplace_with_embers")
		minetest.set_node(pos, node)
	end
end

-- NODES

local sbox = {
	type = 'fixed',
	fixed = { -8/16, -8/16, -8/16, 8/16, -6/16, 8/16},
}

local grille_sbox = {
	type = "fixed",
	fixed = { -8/16, -8/16, -8/16, 8/16, 2/16, 8/16 },
}

local grille_cbox = {
	type = "fixed",
	fixed = {
		{ -8/16,  1/16, -8/16,  8/16, 2/16,  8/16 },
		{ -8/16, -8/16, -8/16, -7/16, 1/16, -7/16 },
		{  8/16, -8/16,  8/16,  7/16, 1/16,  7/16 },
		{  8/16, -8/16, -8/16,  7/16, 1/16, -7/16 },
		{ -8/16, -8/16,  8/16, -7/16, 1/16,  7/16 }
	}
}

minetest.register_node('new_campfire:fireplace', {
	description = S("Fireplace"),
	drawtype = 'mesh',
	mesh = 'contained_campfire.obj',
	tiles = {
		"default_stone.png",
		"new_campfire_empty_tile.png",
		"new_campfire_empty_tile.png",
		"new_campfire_empty_tile.png"
	},
	use_texture_alpha = "clip",
	paramtype2 = "facedir",
	walkable = false,
	buildable_to = false,
	sunlight_propagates = false,
	paramtype = 'light',
	groups = {crumbly=3, oddly_breakable_by_hand=1},
	selection_box = sbox,
	sounds = default.node_sound_stone_defaults(),
	--drop = {max_items = 3, items = {{items = {"stairs:slab_cobble 3"}}}},
	_ch_help = "Tip: Prázdné ohniště bez grilu je otáčitelné klíčem (můžete ho použít k dekoračním účelům).\n"..
		"Přidáním tyček, když leží na zemi, z něj učiníte normální ohniště.",

	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		if node.param2 > 4 then
			minetest.get_meta(pos):set_string("infotext", "")
			return
		end
		local name = itemstack:get_name()
		local a=add_stick(pos, itemstack, minetest.is_creative_enabled(player:get_player_name()))
		if a then
			node.name = "new_campfire:campfire"
			node.param2 = 0
			minetest.set_node(pos, node)
		elseif name == "new_campfire:grille" then
			itemstack:take_item()
			node.name = "new_campfire:fireplace_with_grille"
			node.param2 = 0
			minetest.swap_node(pos, node)
		end
	end,

	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string('infotext', S("Fireplace"));
		meta:set_int("it_val", 0)
		meta:set_int("em_val", 0)
	end,
})

minetest.register_node('new_campfire:campfire', {
	description = S("Campfire"),
	drawtype = 'mesh',
	mesh = 'contained_campfire.obj',
	tiles = {
		"default_stone.png",
		"default_wood.png",
		"new_campfire_empty_tile.png",
		"new_campfire_empty_tile.png"
	},
	use_texture_alpha = "clip",
	inventory_image = "new_campfire_campfire.png",
	walkable = false,
	buildable_to = false,
	sunlight_propagates = true,
	groups = {crumbly=2, flammable=0},
	paramtype = 'light',
	paramtype2 = "degrotate",
	selection_box = sbox,
	sounds = default.node_sound_stone_defaults(),
	_ch_help = ch_help,
	_ch_help_group = ch_help_group,

	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_int("it_val", 0)
		meta:set_int("em_val", 0)
		meta:set_string('infotext', S("Campfire"));
	end,

	on_place = function(itemstack, placer, pointed_thing)
		return core.item_place(itemstack, placer, pointed_thing, math.random(0, 239))
	end,

	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		local itemname = itemstack:get_name()
		if itemname == "fire:flint_and_steel" then
			minetest.sound_play("fire_flint_and_steel",{pos = pos, gain = 0.5, max_hear_distance = 8})
			node.name = 'new_campfire:campfire_active'
			minetest.set_node(pos, node)
			local id = minetest.add_particle({
				pos = {x = pos.x, y = pos.y, z = pos.z},
				velocity = {x=0, y=0.1, z=0},
				acceleration = {x=0, y=0, z=0},
				expirationtime = 2,
				size = 4,
				collisiondetection = true,
				vertical = true,
				texture = "new_campfire_anim_smoke.png",
				animation = {type="vertical_frames", aspect_w=16, aspect_h=16, length = 2.5,},
--               playername = "singleplayer"
			})
		elseif itemname == "new_campfire:grille" then
			itemstack:take_item()
			node.name = "new_campfire:campfire_with_grille"
			minetest.swap_node(pos, node)
		end
	end,
})

minetest.register_node('new_campfire:campfire_active', {
	description = S("Active campfire"),
	drawtype = 'mesh',
	mesh = 'contained_campfire.obj',
	tiles = {
		"default_stone.png",
		"default_wood.png",
		"new_campfire_empty_tile.png",
		"new_campfire_empty_tile.png"
	},
	use_texture_alpha = "clip",
	inventory_image = "new_campfire_campfire.png",
	walkable = false,
	buildable_to = false,
	sunlight_propagates = true,
	groups = {oddly_breakable_by_hand=3, flammable=0, not_in_creative_inventory=1, igniter=1},
	paramtype = 'light',
	paramtype2 = "degrotate",
	light_source = 13,
	damage_per_second = 3,
	drop = "new_campfire:campfire",
	sounds = default.node_sound_stone_defaults(),
	selection_box = sbox,
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		local name = itemstack:get_name()
		local a=add_stick(pos, itemstack, minetest.is_creative_enabled(player:get_player_name()))
		if not a then
			if name == "new_campfire:grille" then
				itemstack:take_item()
				node.name = "new_campfire:campfire_active_with_grille"
				minetest.swap_node(pos, node)
			end
		end
	end,

	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_int('it_val', new_campfire.flames_ttl)
		meta:set_int("em_val", 0)
		infotext_edit(meta)
		minetest.get_node_timer(pos):start(2)
	end,

	on_destruct = function(pos, oldnode, oldmetadata, digger)
		fire_particles_off(pos)
		local meta = minetest.get_meta(pos)
		local handle = meta:get_int("handle")
		minetest.sound_stop(handle)
	end,
})

minetest.register_node('new_campfire:fireplace_with_embers', {
	description = S("Fireplace with embers"),
	drawtype = 'mesh',
	mesh = 'contained_campfire.obj',
	tiles = {
		"default_stone.png",
		"new_campfire_empty_tile.png",
		"new_campfire_empty_tile.png",
		{
			name = "new_campfire_anim_embers.png",
			animation = {
				type="vertical_frames",
				aspect_w=16,
				aspect_h=16,
				length=2
			}
		}
	},
	use_texture_alpha = "clip",
	walkable = false,
	buildable_to = false,
	sunlight_propagates = false,
	paramtype = 'light',
	paramtype2 = "degrotate",
	light_source = 5,
	groups = {crumbly=2, not_in_creative_inventory=1},
	selection_box = sbox,
	sounds = default.node_sound_stone_defaults(),
	drop = {max_items = 3, items = {{items = {"stairs:slab_cobble 3"}}}},

	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		local name = itemstack:get_name()
		local a=add_stick(pos, itemstack, minetest.is_creative_enabled(player:get_player_name()))
		if a then
			node.name = "new_campfire:campfire"
			minetest.swap_node(pos, node)
			minetest.after(new_campfire.flare_up, function()
				if minetest.get_meta(pos):get_int("it_val") > 0 then
					node.name = "new_campfire:campfire_active"
					minetest.swap_node(pos, node)
				end
			end)
		elseif name == "new_campfire:grille" then
			itemstack:take_item()
			node.name = "new_campfire:fireplace_with_embers_with_grille"
			minetest.swap_node(pos, node)
		end
	end,

	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_int("it_val", 0)
		meta:set_int("em_val", new_campfire.embers_ttl)
		meta:set_string('infotext', S("Fireplace with embers"));
	end,
})

minetest.register_node('new_campfire:fireplace_with_embers_with_grille', {
	description = S("Fireplace with embers and grille"),
	drawtype = 'mesh',
	mesh = 'contained_campfire.obj',
	tiles = {
		"default_stone.png",
		"new_campfire_empty_tile.png",
		"default_steel_block.png",
		{
			name = "new_campfire_anim_embers.png",
			animation = {
				type="vertical_frames",
				aspect_w=16,
				aspect_h=16,
				length=2
			}
		}
	},
	use_texture_alpha = "clip",
	walkable = false,
	buildable_to = false,
	sunlight_propagates = false,
	paramtype = 'light',
	paramtype2 = "degrotate",
	light_source = 5,
	groups = {crumbly=2, not_in_creative_inventory=1},
	selection_box = grille_sbox,
	node_box = grille_cbox,
	sounds = default.node_sound_stone_defaults(),
	drop = {
		max_items = 4,
		items = {
			{
				items = {"stairs:slab_cobble 3"},
				items = {"new_campfire:grille 1"}
			}
		}
	},

	on_punch = function(pos, node, puncher, pointed_thing)
		if puncher ~= nil then
			local player_name = puncher:get_player_name()
			if core.is_protected(pos, player_name) then
				core.record_protection_violation(pos, player_name)
				return
			end
			puncher:get_inventory():add_item("main", ItemStack("new_campfire:grille"))
			node.name = "new_campfire:fireplace_with_embers"
			core.set_node(pos, node)
			core.sound_play({name = "default_dig_metal", gain = 0.5}, {pos = pos, max_hear_distance = 32}, true)
		end
	end,

	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		local name = itemstack:get_name()
		local a=add_stick(pos, itemstack, minetest.is_creative_enabled(player:get_player_name()))
		if a then
			node.name = "new_campfire:campfire_with_grille"
			minetest.swap_node(pos, node)
			minetest.after(new_campfire.flare_up, function()
				if minetest.get_meta(pos):get_int("it_val") > 0 then
					node.name = "new_campfire:campfire_active_with_grille"
					minetest.swap_node(pos, node)
				end
			end)
		end
	end,

	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_int("it_val", 0)
		meta:set_int("em_val", new_campfire.embers_ttl)
		meta:set_string('infotext', S("Fireplace with embers"));
	end,
})

minetest.register_node('new_campfire:fireplace_with_grille', {
	description = S("Fireplace with grille"),
	drawtype = 'mesh',
	mesh = 'contained_campfire.obj',
	tiles = {
		"default_stone.png",
		"new_campfire_empty_tile.png",
		"default_steel_block.png",
		"new_campfire_empty_tile.png"
	},
	use_texture_alpha = "clip",
	buildable_to = false,
	sunlight_propagates = false,
	paramtype = 'light',
	paramtype2 = "degrotate",
	groups = {crumbly = 2, not_in_creative_inventory=1},
	selection_box = grille_sbox,
	node_box = grille_cbox,
	sounds = default.node_sound_stone_defaults(),
	drop = {
		max_items = 4,
		items = {
			{
				items = {"stairs:slab_cobble 3"},
				items = {"new_campfire:grille 1"}
			}
		}
	},
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_int("it_val", 0)
		meta:set_int("em_val", 0)
		meta:set_string('infotext', S("Fireplace"));
	end,
	on_punch = function(pos, node, puncher, pointed_thing)
		if puncher ~= nil then
			local player_name = puncher:get_player_name()
			if core.is_protected(pos, player_name) then
				core.record_protection_violation(pos, player_name)
				return
			end
			puncher:get_inventory():add_item("main", ItemStack("new_campfire:grille"))
			node.name = "new_campfire:fireplace"
			node.param2 = 0
			core.set_node(pos, node)
			core.sound_play({name = "default_dig_metal", gain = 0.5}, {pos = pos, max_hear_distance = 32}, true)
		end
	end,
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		local name = itemstack:get_name()
		local a=add_stick(pos, itemstack, minetest.is_creative_enabled(player:get_player_name()))
		if a then
			node.name = "new_campfire:campfire_with_grille"
			minetest.set_node(pos, node)
		end
	end,
})

minetest.register_node('new_campfire:campfire_with_grille', {
	description = S("Campfire with grille"),
	drawtype = 'mesh',
	mesh = 'contained_campfire.obj',
	tiles = {
		"default_stone.png",
		"default_wood.png",
		"default_steel_block.png",
		"new_campfire_empty_tile.png"
	},
	use_texture_alpha = "clip",
	inventory_image = "new_campfire_campfire.png",
	buildable_to = false,
	sunlight_propagates = true,
	groups = {crumbly=2, flammable=0, not_in_creative_inventory=1},
	paramtype = 'light',
	paramtype2 = 'degrotate',
	selection_box = grille_sbox,
	node_box = grille_cbox,
	sounds = default.node_sound_stone_defaults(),

	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_int("it_val", 0)
		meta:set_int("em_val", 0)
		meta:set_string('infotext', S("Campfire"));
	end,

	on_punch = function(pos, node, puncher, pointed_thing)
		if puncher ~= nil then
			local player_name = puncher:get_player_name()
			if core.is_protected(pos, player_name) then
				core.record_protection_violation(pos, player_name)
				return
			end
			puncher:get_inventory():add_item("main", ItemStack("new_campfire:grille"))
			node.name = "new_campfire:campfire"
			core.set_node(pos, node)
			core.sound_play({name = "default_dig_metal", gain = 0.5}, {pos = pos, max_hear_distance = 32}, true)
		end
	end,

	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		if itemstack:get_name() == "fire:flint_and_steel" then
			minetest.sound_play("fire_flint_and_steel",{pos = pos, gain = 0.5, max_hear_distance = 8})
			node.name = 'new_campfire:campfire_active_with_grille'
			minetest.set_node(pos, node)
			local id = minetest.add_particle({
				pos = {x = pos.x, y = pos.y, z = pos.z},
				velocity = {x=0, y=0.1, z=0},
				acceleration = {x=0, y=0, z=0},
				expirationtime = 2,
				size = 4,
				collisiondetection = true,
				vertical = true,
				texture = "new_campfire_anim_smoke.png",
				animation = {type="vertical_frames", aspect_w=16, aspect_h=16, length = 2.5,},
--               playername = "singleplayer"
			})
		end
	end,
	drop = {
		max_items = 4,
		items = {
			{
				items = {"new_campfire:campfire 1"},
				items = {"new_campfire:grille 1"}
			}
		}
	},
})

minetest.register_node('new_campfire:campfire_active_with_grille', {
	description = S("Active campfire with grille"),
	drawtype = 'mesh',
	mesh = 'contained_campfire.obj',
	tiles = {
		"default_stone.png",
		"default_wood.png",
		"default_steel_block.png",
		"new_campfire_empty_tile.png"
	},
	use_texture_alpha = "clip",
	inventory_image = "new_campfire_campfire.png",
	buildable_to = false,
	sunlight_propagates = true,
	groups = {not_in_creative_inventory=1, igniter=1},
	paramtype = 'light',
	paramtype2 = "degrotate",
	light_source = 13,
	damage_per_second = 3,
	drop = {
		max_items = 4,
		items = {
			{
				items = {"new_campfire:campfire 1"},
				items = {"new_campfire:grille 1"}
			}
		}
	},
	sounds = default.node_sound_stone_defaults(),
	selection_box = grille_sbox,
	node_box = grille_cbox,

	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		local name = itemstack:get_name()
		local is_creative = minetest.is_creative_enabled(player:get_player_name())
		local a=add_stick(pos, itemstack, is_creative)
		if not a then
			return cooking(pos, itemstack, is_creative)
		end
	end,

	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_int('it_val', new_campfire.flames_ttl);
		meta:set_int("em_val", 0)
		infotext_edit(meta)
		minetest.get_node_timer(pos):start(2)
	end,

	on_destruct = function(pos, oldnode, oldmetadata, digger)
		fire_particles_off(pos)
		local meta = minetest.get_meta(pos)
		local handle = meta:get_int("handle")
		minetest.sound_stop(handle)
	end,

	on_timer = function(pos) -- Every 6 seconds play sound fire_small
		local meta = minetest.get_meta(pos)
		local handle = minetest.sound_play("fire_small",{pos=pos, max_hear_distance = 18, loop=false, gain=0.1})
		meta:set_int("handle", handle)
		minetest.get_node_timer(pos):start(6)
	end,
})

-- ABMs

minetest.register_abm({
	nodenames = {
		"new_campfire:fireplace_with_embers",
		"new_campfire:fireplace_with_embers_with_grille"
	},
	interval = 1.0, -- Run every second
	chance = 1, -- Select every node
	catch_up = false,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local meta = minetest.get_meta(pos)
		local em_val = meta:get_int("em_val")
		meta:set_int("em_val", em_val - 1)
		if em_val <= 0 then
			burn_out(pos, node)
		end
	end
})


minetest.register_abm({
	nodenames = {
		"new_campfire:campfire_active",
		"new_campfire:campfire_active_with_grille"
	},
	interval = 1.0, -- Run every second
	chance = 1, -- Select every node
	catch_up = false,

	action = function(pos, node, active_object_count, active_object_count_wider)
		local fpos, num = minetest.find_nodes_in_area(
			{x=pos.x-1, y=pos.y, z=pos.z-1},
			{x=pos.x+1, y=pos.y+1, z=pos.z+1},
			{"group:water"}
		)
		if #fpos > 0 then
			if string.find(node.name, "embers") then
				burn_out(pos, node)
			else
				node.name = string.gsub(node.name, "_active", "")
				minetest.set_node(pos, node)
			end
			minetest.sound_play("fire_extinguish_flame",{pos = pos, max_hear_distance = 16, gain = 0.15})
		else
			local meta = minetest.get_meta(pos)
			local it_val = meta:get_int("it_val") - 1;

			if new_campfire.limited and new_campfire.flames_ttl > 0 then
				if it_val <= 0 then
					burn_out(pos, node)
					return
				end
				meta:set_int('it_val', it_val);
			end

			if new_campfire.cooking then
				if meta:get_int('cooked_cur_time') <= meta:get_int('cooked_time') then
					meta:set_int('cooked_cur_time', meta:get_int('cooked_cur_time') + 1);
				else
					meta:set_int('cooked_time', 0);
					meta:set_int('cooked_cur_time', 0);
				end
			end

			infotext_edit(meta)
			fire_particles_on(pos)
		end
	end
})

-- CRAFTS

minetest.register_craft({
    output = "new_campfire:grille",
	recipe = {
		{ "basic_materials:steel_bar", "",                           "basic_materials:steel_bar" },
		{ "",                          "basic_materials:steel_wire", "" },
		{ "basic_materials:steel_bar", "",                           "basic_materials:steel_bar" },
	}
})

minetest.register_craft({
	output = "new_campfire:campfire",
	recipe = {
		{'', 'group:stick', ''},
		{'stairs:slab_cobble','group:stick', 'stairs:slab_cobble'},
		{'', 'stairs:slab_cobble', ''},
	}
})

minetest.register_craft({
	output = "new_campfire:campfire",
	recipe = {
		{'group:stick', '', ''},
		{'group:stick', '', ''},
		{'new_campfire:fireplace', '', ''},
	}
})

minetest.register_craft({
	output = "new_campfire:fireplace",
	recipe = {{"stairs:slab_cobble", "", "stairs:slab_cobble"}, {"", "stairs:slab_cobble", ""}, {"", "", ""}},
})

minetest.register_craft({
	output = "stairs:slab_cobble 3",
	recipe = {{"new_campfire:fireplace"}},
})

-- ITEMS

minetest.register_craftitem("new_campfire:grille", {
	description = S("Metal Grille"),
	inventory_image = "new_campfire_grille.png"
})

minetest.register_craftitem("new_campfire:ash", {
	description = S("Ash"),
	inventory_image = "new_campfire_ash.png"
})

-- EXTRA

if not minetest.get_modpath("campfire") then
	minetest.register_alias("campfire:campfire", "new_campfire:campfire")
	minetest.register_alias("campfire:campfire_active", "new_campfire:campfire")
end
ch_base.close_mod(minetest.get_current_modname())

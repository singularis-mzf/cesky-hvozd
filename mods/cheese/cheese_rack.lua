local F = minetest.formspec_escape
local S = cheese.S
local ifthenelse = ch_core.ifthenelse

local rack_types = { --moslty redundant data, but i dont feel like changing it..
	--craft material				tiles				rack name			name	 aging time (MIN 3!)
	{"default:wood", 				"wood", 			"wooden",	"Wooden",	55.0},
	{"default:stone", 			"stone", 			"stone",	"Stone", 	45.0},
	{"default:mossycobble", "mossycobble","mossy",	"Mossy",	30.0},
}

local slab = "stairs:slab_"
if minetest.get_modpath("moreblocks") then
	slab = "moreblocks:slab_"
end
local producable = { --remember, only cow milk
	["wooden"] 	= {"parmesan",		"fontal",			"gruyere",	"emmental"}, 	--long time, hard
	["stone"] 	= {"asiago",		"monteray_jack",	"toma",		"gouda"}, 		-- medium time, semi soft or medium
	["mossy"] 	= {"gorgonzola",	"stilton",			"brie", 	"stracchino"}, 	-- short time, soft and creamy
}

local formspec_states = {} -- player_name => custom_state

-- sheep cheese (cant make them): feta, pecorino, queso?
-- also cheese + nuts, chilly, herbs, olives ??

-- the process is called cheese ripening, maturation of affinage (or simplified, aging)
--local aged_cheeses = {"parmesan", "gorgonzola", "asiago", "emmental"}

--[[
local function get_cheese(rack_type)

	if cheese.astral then
		local event, event_name = astral.get_astral_event()
		if not ( event == nil or event == "none" or  event == "normal" ) then

			if event_name == "Blue Moon" then
				return "cheese:".. producable["mossy"][math.random(1,2)].." "..math.random(3,5) -- only gorgo and stilton

			elseif event_name == "Super Moon" then
				return "cheese:".. producable[rack_type][math.random(#producable[rack_type])].." "..math.random(4,7) -- more of it ;)

			elseif event_name == "Rainbow Sun" then
				return "cheese:".. producable[rack_type][1].." "..math.random(3,5) -- the first in the lists is an italian one

			elseif event_name == "Ring Sun"  or event_name == "Crescent Sun" then -- ring_sun = sun eclipse
				return "cheese:".. producable[rack_type][4].." "..math.random(3,5)
			end
		end
	end
	return "cheese:".. producable[rack_type][math.random(#producable[rack_type])].." "..math.random(2,4)

end
]]

local function get_formspec(custom_state)
	local pos = custom_state.pos
	local _cheese = custom_state._cheese
	local node = minetest.get_node(pos)
	local nodemetainv = "nodemeta:"..pos.x.."\\,"..pos.y.."\\,"..pos.z
	local ndef = minetest.registered_nodes[node.name]
	if ndef == nil or ndef._cheese == nil then
		error("Invalid node detected by get_formspec()!")
	end
	local node_desc = ndef.description or "neznámý blok"
	local producables = _cheese.producables
	local meta = minetest.get_meta(pos)
	local current_cheese = meta:get_string("current_cheese")

	local result = {
		ch_core.formspec_header{
			formspec_version = 4,
			size = {10.25, 9.5},
			auto_background = true,
		},
		"item_image[0.25,0.25;1,1;",
		F(node.name), "]"..
		"label[1.5,0.75;", F(node_desc), "]"..
		"list[", nodemetainv, ";input;0.25,2.75;1,1;]"..
		"label[1.5,3.25;=>]"..
		"list[", nodemetainv, ";output;2.25,2.75;4,1;]"..
		"list[current_player;main;0.25,4.25;8,4;]"..
		"button_exit[9.25,0.25;0.75,0.75;zavrit;x]",
		"listring[current_player;main]"..
		"listring[", nodemetainv, ";input]"..
		"listring[current_player;main]"..
		"listring[", nodemetainv, ";output]",
		"style[cheese_", current_cheese, ";bgcolor=#00ff00]",
	}
	for i, n in ipairs(producables) do
		table.insert(result, "item_image_button["..(1.25 * i - 1.0)..",1.5;1,1;cheese:"..n..";cheese_"..n..";]")
	end
	return table.concat(result)
end

-- Update node name, formspec, infotext and timer state
local function update_state(pos, node, _cheese)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	-- local update_formspec = false
	local new_name
	local curd_item = ItemStack("cheese:curd")
	local timer = minetest.get_node_timer(pos)
	local current_cheese = meta:get_string("current_cheese")
	local target_time = meta:get_int("target_time") -- DEBUG
	print("DEBUG: update_state(): target_time = "..target_time)

	local has_current_cheese = minetest.registered_items["cheese:"..current_cheese]
	local has_input = inv:contains_item("input", curd_item)
	local has_output = not inv:is_empty("output")
	local is_started = target_time ~= 0

	if target_time ~= 0 then
		new_name = _cheese.rack_with_aging_cheese
	elseif has_current_cheese and has_input then
		local now = ch_core.aktualni_cas().znamka32
		target_time = now + _cheese.aging_time + math.random(-3, 3)
		meta:set_int("target_time", target_time)
		timer:start(4)
		new_name = _cheese.rack_with_aging_cheese
	else
		new_name = ifthenelse(has_output, _cheese.rack_with_cheese, _cheese.rack_empty)
	end

	if new_name ~= nil and new_name ~= node.name then
		node.name = new_name
		minetest.swap_node(pos, node)
		for player_name, custom_state in pairs(formspec_states) do
			if vector.equals(custom_state.pos, pos) then
				local player = assert(minetest.get_player_by_name(player_name))
				ch_core.update_formspec(player, "cheese:rack", get_formspec(custom_state))
			end
		end
	end

	local node_description = minetest.registered_nodes[node.name].description or "???"

	if node.name == _cheese.rack_with_aging_cheese then
		local cheese = minetest.registered_items["cheese:"..current_cheese]
		if cheese == nil then
			cheese = "žádný"
		else
			cheese = cheese.description
		end
		meta:set_string("infotext", node_description.."\nna stojanu zraje sýr:\n"..cheese)
	elseif node.name == _cheese.rack_with_cheese then
		meta:set_string("infotext", node_description.."\nsýr je hotov")
	else
		meta:set_string("infotext", node_description.."\nstojan je prázdný")
	end
end

local function formspec_callback(custom_state, player, formname, fields)
	local player_name = player:get_player_name()
	if fields.quit then
		formspec_states[player_name] = nil
	end
	local pos = custom_state.pos
	local node = minetest.get_node(pos)
	local meta = minetest.get_meta(pos)
	local timer = minetest.get_node_timer(pos)
	local will_run
	local ndef = minetest.registered_nodes[node.name]
	if ndef == nil or ndef._cheese == nil then
		error("Invalid node detected by get_formspec()!")
	end
	local _cheese = custom_state._cheese
	local current_cheese = meta:get_string("current_cheese")

	for i, n in ipairs(_cheese.producables) do
		if fields["cheese_"..n] then
			if n ~= current_cheese then
				-- switch cheese
				meta:set_string("current_cheese", n)
			else
				-- disable
				meta:set_string("current_cheese", "")
			end
			meta:set_int("target_time", 0)
			update_state(pos, node, _cheese)
			return get_formspec(custom_state)
		end
	end
end

local function on_construct(pos)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	inv:set_size("input", 1)
	inv:set_size("output", 4)
end

local function on_timer_inner(pos, meta, _cheese, target_time, current_cheese)
	-- 2. check the light
	local node_light = minetest.get_node_light(pos)
	if node_light > 11 then
		-- too much light
		local timer = minetest.get_node_timer(pos)
		timer:start(4)
		meta:set_int("target_time", target_time + 4)
		return
	end

	-- 3. check, if the target_time has been reached
	local now = ch_core.aktualni_cas().znamka32
	if now < target_time then
		return true -- try again
	end

	local curd_item = ItemStack("cheese:curd")
	local inv = meta:get_inventory()
	while target_time <= now do

		local cheese_item = ItemStack("cheese:"..current_cheese.." "..math.random(2, 3))

		-- Check, if output has room for cheese
		if not inv:room_for_item("output", cheese_item) then
			minetest.log("warning", "Cheese Rack output at "..minetest.pos_to_string(pos).." is full. Will stop.")
			return false
		end
		-- remove curd from input
		if inv:remove_item("input", curd_item):is_empty() then
			return false -- no more input
		end
		-- add the cheese to the output:
		inv:add_item("output", ItemStack("cheese:"..current_cheese))

		-- play sound:
		minetest.sound_play("cheese_ftspw", {pos = pos, max_hear_distance = 8, gain = 0.5})

		-- check the input
		if not inv:contains_item("input", curd_item) then
			return false
		end

		target_time = target_time + _cheese.aging_time + math.random(-15, 15)
		meta:set_int("target_time", target_time)
	end
	return true
end

local function on_timer(pos, elapsed)
	local result

	-- 1. check, if the node is valid and has target_time and current_cheese set up
	local node = minetest.get_node(pos)
	local _cheese = ch_core.safe_get_3(minetest.registered_nodes, node.name, "_cheese")
	if _cheese == nil then
		return
	end
	local meta = minetest.get_meta(pos)
	local target_time = meta:get_int("target_time")
	local current_cheese = meta:get_string("current_cheese")
	if target_time == 0 or current_cheese == "" or not minetest.registered_items["cheese:"..current_cheese] then
		result = false
	else
		result = on_timer_inner(pos, meta, _cheese, target_time, current_cheese)
	end
	if result == true then
		update_state(pos, minetest.get_node(pos), _cheese)
		return true
	elseif result == false then
		meta:set_int("target_time", 0)
	end
	update_state(pos, minetest.get_node(pos), _cheese)
end

local function allow_player_access(player)
	player = ch_core.normalize_player(player)
	return player.role ~= "new" and player.role ~= "none"
end

local function can_dig(pos, player)
	if not allow_player_access(player) then
		return false
	end
	local inv = minetest.get_meta(pos):get_inventory()
	return inv:is_empty("input") and inv:is_empty("output")
end

local function allow_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
	return ifthenelse(allow_player_access(player) and from_list == to_list, count, 0)
end

local function allow_metadata_inventory_put(pos, listname, index, stack, player)
	return ifthenelse(allow_player_access(player), stack:get_count(), 0)
end

local function allow_metadata_inventory_take(pos, listname, index, stack, player)
	return ifthenelse(allow_player_access(player), stack:get_count(), 0)
end

--[[
local function on_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
end
]]

local function on_metadata_inventory_put(pos, listname, index, stack, player)
	local node = minetest.get_node(pos)
	local _cheese = minetest.registered_nodes[node.name]._cheese
	update_state(pos, node, _cheese)
end

local function on_metadata_inventory_take(pos, listname, index, stack, player)
	local node = minetest.get_node(pos)
	local _cheese = minetest.registered_nodes[node.name]._cheese
	update_state(pos, node, _cheese)
end

local function on_rightclick(pos, node, clicker, itemstack, pointed_thing)
	local playerinfo = ch_core.normalize_player(clicker)
	if playerinfo.role ~= "new" and playerinfo.role ~= "none" then
		local custom_state = {
			pos = pos,
			_cheese = assert(minetest.registered_nodes[node.name]._cheese),
		}
		formspec_states[playerinfo.player_name] = custom_state
		ch_core.show_formspec(clicker, "cheese:rack", get_formspec(custom_state), formspec_callback, custom_state, {})
	end
end

local selection_box = {
	type = "fixed",
	fixed = {
		{-0.5, -0.5, -0.4375, 0.5, 0.5, 0.5}, -- selection
	}
}

local empty_node_box = {
	type = "fixed",
	fixed = {
		{-0.5, -0.5, -0.4375, 0.5, -0.375, 0.375}, -- base
		{-0.5, 0.375, -0.4375, 0.5, 0.5, 0.375}, -- top
		{-0.5, -0.5, 0.375, 0.5, 0.5, 0.5}, -- back
		{0.375, -0.375, -0.375, 0.5, 0.375, 0.375}, -- right
		{-0.5, -0.375, -0.375, -0.375, 0.375, 0.375}, -- left
		{-0.4375, -0.0625, -0.4375, 0.4375, 0.0625, 0.375}, -- middle
	}
}

local with_cheese_node_box = {
	type = "fixed",
	fixed = {
		{-0.5, -0.5, -0.4375, 0.5, -0.375, 0.375}, -- base
		{-0.5, 0.375, -0.4375, 0.5, 0.5, 0.375}, -- top
		{-0.5, -0.5, 0.375, 0.5, 0.5, 0.5}, -- back
		{0.375, -0.375, -0.375, 0.5, 0.375, 0.375}, -- right
		{-0.5, -0.375, -0.375, -0.375, 0.375, 0.375}, -- left
		{-0.4375, -0.0625, -0.4375, 0.4375, 0.0625, 0.375}, -- middle
		{-0.375, -0.375, -0.3125, 0.375, 0.375, 0.375}, -- cheese1
	}
}

for k, v in pairs(rack_types) do
	local _cheese = {
		aging_time = v[5],
		producables = assert(producable[v[3]]),
		rack_type = v[3],
		rack_empty = "cheese:"..v[3].."_cheese_rack_empty",
		rack_with_aging_cheese = "cheese:"..v[3].."_cheese_rack_with_aging_cheese",
		rack_with_cheese = "cheese:"..v[3].."_cheese_rack_with_cheese",
	}
	local groups, sounds
	if k == "wooden" then
		groups = {choppy = 2, cheese_rack = 1}
		sounds = default.node_sound_wood_defaults()
	else
		groups = {cracky = 2, cheese_rack = 1}
		sounds = default.node_sound_stone_defaults()
	end

	-- rack_empty:
	local def = {
		description = S(v[4] .." Cheese Rack"),
		drawtype = "nodebox",
		tiles = {"default_"..v[2]..".png"},
		paramtype = "light",
		paramtype2 = "4dir",
		node_box = empty_node_box,
		selection_box = selection_box,
		collision_box = selection_box,
		groups = table.copy(groups),
		sounds = sounds,
		_cheese = _cheese,

		on_construct = on_construct,
		on_rightclick = on_rightclick,
		on_timer = on_timer,
		allow_metadata_inventory_move = allow_metadata_inventory_move,
		allow_metadata_inventory_put = allow_metadata_inventory_put,
		allow_metadata_inventory_take = allow_metadata_inventory_take,
		on_metadata_inventory_put = on_metadata_inventory_put,
		on_metadata_inventory_take = on_metadata_inventory_take,
		can_dig = can_dig,
	}
	minetest.register_node(_cheese.rack_empty, def)

	groups.not_in_creative_inventory = 1

	-- rack_with_aging_cheese
	def = {
		description = S(v[4] .." Cheese Rack with Aging Cheese"),
		drawtype = "nodebox",
		tiles = {
			"default_"..v[2]..".png",
			"default_"..v[2]..".png",
			"default_"..v[2]..".png",
			"default_"..v[2]..".png",
			"default_"..v[2]..".png",
			"default_"..v[2]..".png^fresh_cheese_front.png"
		},
		paramtype = "light",
		paramtype2 = "4dir",
		node_box = with_cheese_node_box,
		selection_box = selection_box,
		collision_box = selection_box,
		groups = table.copy(groups),
		sounds = sounds,
		drop = _cheese.rack_empty,
		_cheese = _cheese,

		on_rightclick = on_rightclick,
		on_timer = on_timer,
		allow_metadata_inventory_move = allow_metadata_inventory_move,
		allow_metadata_inventory_put = allow_metadata_inventory_put,
		allow_metadata_inventory_take = allow_metadata_inventory_take,
		on_metadata_inventory_put = on_metadata_inventory_put,
		on_metadata_inventory_take = on_metadata_inventory_take,
		can_dig = can_dig,
	}
	minetest.register_node(_cheese.rack_with_aging_cheese, def)

	-- rack_with_cheese
	def = {
		description = S(v[4] .." Cheese Rack with Cheese"),
		drawtype = "nodebox",
		tiles = {
			"default_"..v[2]..".png",
			"default_"..v[2]..".png",
			"default_"..v[2]..".png",
			"default_"..v[2]..".png",
			"default_"..v[2]..".png",
			"default_"..v[2]..".png^cheese_front.png"
		},
		paramtype = "light",
		paramtype2 = "facedir",
		node_box = with_cheese_node_box,
		selection_box = selection_box,
		collision_box = selection_box,
		groups = groups,
		sounds = sounds,
		drop = _cheese.rack_empty,
		_cheese = _cheese,

		on_rightclick = on_rightclick,
		on_timer = on_timer,
		allow_metadata_inventory_move = allow_metadata_inventory_move,
		allow_metadata_inventory_put = allow_metadata_inventory_put,
		allow_metadata_inventory_take = allow_metadata_inventory_take,
		on_metadata_inventory_put = on_metadata_inventory_put,
		on_metadata_inventory_take = on_metadata_inventory_take,
		can_dig = can_dig,
	}
	minetest.register_node(_cheese.rack_with_cheese, def)

	local slab_item
	if v[1] ~= "default:mossycobble" then
		slab_item = slab..v[2]
	else
		slab_item = "moreblocks:slab_stone"
	end
	minetest.register_craft({
		output = _cheese.rack_empty,
		recipe = {
			{""..v[1], slab_item, ""..v[1]},
			{""..v[1], slab_item, ""..v[1]},
			{""..v[1], slab_item, ""..v[1]},
		}
	})
end

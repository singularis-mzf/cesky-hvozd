--[[
More Blocks: circular saw

Copyright © 2011-2023 Hugo Locurcio, Sokomine and contributors.
Licensed under the zlib license. See LICENSE.md for more information.
--]]

local S = moreblocks.S
local F = minetest.formspec_escape

local output_inv_size = (8 + 2) * 8
local separator = {}

circular_saw = {}

circular_saw.known_stairs = setmetatable({}, {
	__newindex = function(k, v)
		local modname = minetest.get_current_modname()
		print(("WARNING: mod %s tried to add node %s to the circular saw manually."):format(modname, v))
	end,
})

-- This is populated by stairsplus:register_all:
circular_saw.known_nodes = {}

circular_saw.names = {
	{"micro", "_1", 1},
	{"micro", "_2", 1},
	{"micro", "_4", 1},
	{"micro", "", 1},
	{"micro", "_12", 2},
	{"micro", "_15", 2},
	{"panel", "_special", 1},
	{"panel", "_l", 1},

	-- {"micro", "_14", 2},
	-- {"panel", "_14", 4},

	{"panel", "_1", 1},
	{"panel", "_2", 1},
	{"panel", "_4", 1},
	{"panel", "", 2},
	{"panel", "_12", 3},
	{"panel", "_15", 4},
	{"panel", "_wide_1", 1},
	{"panel", "_wide", 4},

	{"slab", "_1", 1},
	{"slab", "_2", 1},
	{"slab", "_quarter", 2},
	{"slab", "", 4},
	{"slab", "_three_quarter", 6},
	{"slab", "_14", 7},
	{"slab", "_15", 8},
	separator,

	{"stair", "", 6},
	{"stair", "_triple", 6},
	{"stair", "_outer", 5},
	{"stair", "_inner", 7},
	{"stair", "_alt_1", 1},
	{"stair", "_alt_2", 1},
	{"stair", "_alt_4", 2},
	{"stair", "_alt", 4},

	{"slope", "", 4},
	{"slope", "_inner", 7},
	{"slope", "_outer", 3},
	{"slope", "_cut", 4},
	{"slope", "_inner_cut", 7},
	{"slope", "_outer_cut", 2},
	{"stair", "_chimney", 8},
	{"stair", "_wchimney", 8},

	{"slope", "_half", 2},
	{"slope", "_half_raised", 6},
	{"slope", "_inner_half", 3},
	{"slope", "_inner_half_raised", 7},
	{"slope", "_inner_cut_half", 4},
	{"slope", "_inner_cut_half_raised", 8},
	{"slope", "_outer_half", 2},
	{"slope", "_outer_half_raised", 6},

	{"slope", "_outer_cut_half", 1},
	{"slab", "_two_sides", 1},
	{"slab", "_two_sides_half", 1},
	{"slab", "_three_sides", 2},
	{"slab", "_three_sides_half", 2},
	{"slab", "_three_sides_u", 2},
	{"slope", "_slab", 1},
	{"panel", "_l1", 2},

	-- {"slab", "_pit", 3},
	-- {"slab", "_pit_half", 2},
	{"slope", "_cut2", 4},
	{"slope", "_roof22", 2},
	{"slope", "_roof22_raised", 2},
	{"slope", "_roof45", 2},
	{"slab", "_cube", 4},
	separator,
	separator,
	separator,

	{"slope", "_roof22_3", 6},
	{"slope", "_roof22_raised_3", 6},

	{"slope", "_roof45_3", 6},
	{"slope", "_tripleslope", 12},

	{"slab", "_rcover", 2},
	{"slab", "_triplet", 3},

	-- {"slope", "_outer_cut_half_raised", 3},
	-- {"slope", "_slab_half", 2},
	-- {"slope", "_slab_half_raised", 6},
}

local function extract_cost_in_microblocks(names)
	local result = {}
	for i, v in ipairs(names) do
		result[i] = v[3] or 0
		v[3] = nil
	end
	return result
end

-- How many microblocks does this shape at the output inventory cost:
-- It may cause slight loss, but no gain.
circular_saw.cost_in_microblocks = extract_cost_in_microblocks(circular_saw.names)

function circular_saw:get_cost(inv, stackname)
	-- returns: cost, craftitem
	-- or:      nil, nil
	local name = minetest.registered_aliases[stackname] or stackname
	local craftitem, category, alternate = stairsplus:analyze_shape(name)
	-- print("TEST: analyze_shape("..name..") => "..(craftitem or "nil")..", "..(category or "nil")..", "..(alternate or "nil"))
	if craftitem ~= nil then
		for i, item in ipairs(circular_saw.names) do
			if item[1] == category and item[2] == alternate then
				return circular_saw.cost_in_microblocks[i], craftitem
			end
		end
	end
end

function circular_saw:get_output_inv(modname, material, amount, max)
	if (not max or max < 1 or max > 100) then max = 100 end

	local list = {}
	local pos = #list

	-- If there is nothing inside, display empty inventory:
	if amount < 1 then
		return list
	end

	for i = 1, #circular_saw.names do
		local t = circular_saw.names[i]
		if t[1] ~= nil then
			local nodename = modname .. ":" .. t[1] .. "_" .. material .. t[2]
			local cost, balance
			if minetest.registered_nodes[nodename] then
				cost = circular_saw.cost_in_microblocks[i]
				balance = math.min(math.floor(amount/cost), max)
			else
				balance = 0
			end
			pos = pos + 1
			list[pos] = nodename .. " " .. balance
		else
			pos = pos + 1
			list[pos] = ""
		end
	end
	return list
end

local function update_infotext(meta, item_description)
	local owner, owner_viewname, infotext
	owner = meta:get_string("owner") or ""
	if owner == "" then
		owner = nil
	else
		if minetest.get_modpath("ch_core") then
			owner_viewname = ch_core.prihlasovaci_na_zobrazovaci(owner)
		else
			owner_viewname = owner
		end
	end
	if owner ~= nil then
		if item_description ~= nil then
			infotext = S("Circular Saw that was placed by @1 is working on @2", owner_viewname, item_description)
		else
			infotext = S("Circular Saw that was placed by @1 is empty", owner_viewname)
		end
	elseif item_description ~= nil then
		infotext = S("Circular Saw is working on @1", item_description)
	else
		infotext = S("Circular Saw is empty")
	end
	meta:set_string("infotext", infotext)
end

-- Reset empty circular_saw after last full block has been taken out
-- (or the circular_saw has been placed the first time)
-- Note: max_offered is not reset:
function circular_saw:reset(pos)
	local meta = minetest.get_meta(pos)
	local inv  = meta:get_inventory()

	inv:set_list("input",  {})
	inv:set_list("micro",  {})
	inv:set_list("output", {})

	meta:set_int("anz", 0)
	update_infotext(meta)
end

function circular_saw:get_input(pos)
	-- returns craftitem, amount (in microblocks)
	-- or:     "", 0
	local meta = minetest.get_meta(pos)
	local inv  = meta:get_inventory()
	local stack = inv:get_stack("input", 1)
	local craftitem = ""
	if not stack:is_empty() then
		-- print("TEST 31: <"..stack:get_name()..">")
		craftitem = stack:get_name()
	else
		stack = inv:get_stack("micro", 1)
		if not stack:is_empty() then
			local stackname = stack:get_name()
			-- print("TEST 32: <"..stackname..">")
			local amount, craftitem2 = self:get_cost(inv, stackname)
			-- print("TEST 33: "..(amount or "nil").." "..(craftitem2 or "nil"))
			if craftitem2 ~= nil then
				-- print("TEST 34")
				craftitem = craftitem2
			end
		end
	end
	-- print("TEST35: "..craftitem..", "..meta:get_int("anz"))
	return craftitem, meta:get_int("anz")
end

-- Player has taken something out of the box or placed something inside
-- that amounts to count microblocks:
function circular_saw:update_inventory(pos, amount, craftitem_hint)
	local meta          = minetest.get_meta(pos)
	local inv           = meta:get_inventory()
	local craftitem, current_amount = self:get_input(pos)

	-- print("TEST: update_inventory(*, "..amount..", "..(craftitem_hint and ("\""..craftitem_hint.."\"") or "nil").."): "..current_amount.." => "..(current_amount + amount))
	-- print("TEST - current_state = <"..craftitem.."> "..current_amount)
	amount = current_amount + amount

	-- The material is recycled automatically.
	inv:set_list("recycle",  {})

	-- print("TEST 21")
	if craftitem == "" then
		if craftitem_hint ~= nil then
			-- print("TEST 22")
			craftitem = craftitem_hint
		else
			-- print("TEST 23")
			amount = 0 -- material not known
		end
	end
	if amount < 1 then -- If the last block is taken out.
		-- print("TEST 24: "..amount)
		self:reset(pos)
		return
	end
	-- print("TEST 25: "..amount)
	local name_parts = circular_saw.known_nodes[craftitem] or ""
	local modname  = name_parts[1] or ""
	local material = name_parts[2] or ""

	inv:set_list("input", { -- Display as many full blocks as possible:
		craftitem.. " " .. math.floor(amount / 8)
	})

	-- print("circular_saw set to " .. modname .. " : "
	--	.. material .. " with " .. (amount) .. " microblocks.")

	-- 0-7 microblocks (slab_*_1) may remain left-over:
	inv:set_list("micro", {
		modname .. ":slab_" .. material .. "_1 " .. (amount % 8)
	})
	-- Display:
	inv:set_list("output",
		self:get_output_inv(modname, material, amount,
				meta:get_int("max_offered")))
	-- Store how many microblocks are available:
	meta:set_int("anz", amount)

	local node_def = minetest.registered_nodes[craftitem]
	update_infotext(meta, node_def and node_def.description or material)
end


-- The amount of items offered per shape can be configured:
function circular_saw.on_receive_fields(pos, formname, fields, sender)
	local meta = minetest.get_meta(pos)
	if fields.Set then
		local max = tonumber(fields.max_offered)
		if max and max > 0 then
			meta:set_string("max_offered",  max)
			-- Update to show the correct number of items:
			circular_saw:update_inventory(pos, 0)
		end
	elseif fields.Clear then
		local inv = meta:get_inventory()
		local no_content = inv:is_empty("input") and inv:is_empty("micro")
		circular_saw:reset(pos)
		if not no_content and sender ~= nil and minetest.get_modpath("unified_inventory") ~= nil then
			minetest.sound_play("trash_all", { to_player = sender:get_player_name(), gain = 0.8 })
		end
	end
end


-- Moving the inventory of the circular_saw around is not allowed because it
-- is a fictional inventory. Moving inventory around would be rather
-- impractical and make things more difficult to calculate:
function circular_saw.allow_metadata_inventory_move(
		pos, from_list, from_index, to_list, to_index, count, player)
	return 0
end


-- Only input- and recycle-slot are intended as input slots:
function circular_saw.allow_metadata_inventory_put(
		pos, listname, index, stack, player)
	-- The player is not allowed to put something in there:
	if listname == "output" or listname == "micro" then
		return 0
	end
	if listname == "trash" then
		return stack:get_count()
	end

	local meta = minetest.get_meta(pos)
	local inv  = meta:get_inventory()
	local stackname = stack:get_name()
	local count = stack:get_count()

	if listname == "recycle" then
		local craftitem, amount = circular_saw:get_input(pos) -- items currently in the saw (may be "", 0)
		local rcost, rcraftitem = circular_saw:get_cost(inv, stackname) -- items to be recycled
		-- print("TEST 1")
		if rcraftitem == nil then
			-- print("TEST 2")
			return 0 -- item not recyclable
		end
		if craftitem == "" then
			craftitem = rcraftitem
		elseif rcraftitem ~= craftitem then
			-- print("TEST 3 (craftitem == <"..craftitem..">, rcraftitem == <"..rcraftitem..">)")
			return 0 -- cannot recycle different material
		end
		local rcost_max = ItemStack(craftitem):get_stack_max() * 8 + 7 - amount
		-- print("TEST 4: "..rcost_max..", "..rcost)
		if rcost > rcost_max then
			-- print("TEST 5")
			return 0 -- overflow
		end
		-- print("TEST 6: "..count)
		return count
		--[[
		if amount + rcost > ItemStack(craftitem):get_stack_max() * 8 then
			return 0 -- too many items
		end
		local stackmax = stack:get_stack_max()
		local instack = inv:get_stack("input", 1)
		local microstack = inv:get_stack("micro", 1)
		local incount = instack:get_count()
		local incost = (incount * 8) + microstack:get_count()
		local maxcost = (stackmax * 8) + 7
		local cost = circular_saw:get_cost(inv, stackname)
		if (incost + cost) > maxcost then
			return math.max((maxcost - incost) / cost, 0)
		end
		return count
		]]
	end

	-- Only accept certain blocks as input which are known to be craftable into stairs:
	if listname == "input" then
		if not inv:is_empty("input") then
			if inv:get_stack("input", index):get_name() ~= stackname then
				return 0
			end
		end
		if not inv:is_empty("micro") then
			local microstackname = inv:get_stack("micro", 1):get_name():gsub("^.+:slab_", "", 1):gsub("_1$", "", 1)
			local cutstackname = stackname:gsub("^.+:", "", 1)
			if microstackname ~= cutstackname then
				return 0
			end
		end
		for name, t in pairs(circular_saw.known_nodes) do
			if name == stackname and inv:room_for_item("input", stack) then
				return count
			end
		end
		return 0
	end
end

-- Taking is allowed from all slots (even the internal microblock slot).
-- Putting something in is slightly more complicated than taking anything
-- because we have to make sure it is of a suitable material:
function circular_saw.on_metadata_inventory_put(
		pos, listname, index, stack, player)
	-- We need to find out if the circular_saw is already set to a
	-- specific material or not:
	local meta = minetest.get_meta(pos)
	local inv  = meta:get_inventory()
	local stackname = stack:get_name()
	local count = stack:get_count()

	-- Putting something into the input slot is only possible if that had
	-- been empty before or did contain something of the same material:
	if listname == "input" then
		-- Each new block is worth 8 microblocks:
		circular_saw:update_inventory(pos, 8 * count)
	elseif listname == "recycle" then
		local craftitem, amount = circular_saw:get_input(pos) -- items currently in the saw (may be nil)
		local rcost, rcraftitem = circular_saw:get_cost(inv, stackname) -- items to be recycled
		-- print("TEST 10")
		if rcraftitem == nil then
			-- print("TEST 11")
			return -- item not recyclable
		end
		if craftitem == "" then
			craftitem = rcraftitem
		elseif rcraftitem ~= craftitem then
			return -- cannot recycle different material
		end
		local rcost_max = ItemStack(craftitem):get_stack_max() * 8 + 7 - amount
		-- print("TEST 12: "..rcost..", "..rcost_max)
		if rcost > rcost_max then
			return -- overflow
		end
		-- print("TEST 13: "..rcost..", "..count)
		if rcost > 0 and count > 0 then
			if rcost > 1 then
				rcost = rcost - 1
			end
			circular_saw:update_inventory(pos, rcost * count, craftitem)
		end
	elseif listname == "trash" then
		ch_core.vyhodit_inventar(player and player:get_player_name(), inv, "trash", "circular saw")
		--[[
		inv:set_stack("trash", 1, ItemStack())
		local player_name = player and player:get_player_name()
		if player_name ~= nil then
			minetest.log("action", "Player "..player_name.." trashed in the circular saw: "..stack:to_string():sub(1, 1024))
			if minetest.get_modpath("unified_inventory") ~= nil then
				minetest.sound_play("trash_all", { to_player = player_name, gain = 0.8 })
			end
		end
		]]
	end
end

function circular_saw.allow_metadata_inventory_take(pos, listname, index, stack, player)
	local meta          = minetest.get_meta(pos)
	local inv           = meta:get_inventory()
	local input_stack = inv:get_stack(listname,  index)
	local player_inv = player:get_inventory()
	if not player_inv:room_for_item("main", input_stack) then
		return 0
	else
		return stack:get_count()
	end
end

function circular_saw.on_metadata_inventory_take(
		pos, listname, index, stack, player)

	-- Prevent (inbuilt) swapping between inventories with different blocks
	-- corrupting player inventory or Saw with 'unknown' items.
	local meta          = minetest.get_meta(pos)
	local inv           = meta:get_inventory()
	local input_stack = inv:get_stack(listname,  index)
	if not input_stack:is_empty() and input_stack:get_name()~=stack:get_name() then
		local player_inv = player:get_inventory()

		-- Prevent arbitrary item duplication.
		inv:remove_item(listname, input_stack)

		if player_inv:room_for_item("main", input_stack) then
			player_inv:add_item("main", input_stack)
		end

		circular_saw:reset(pos)
		return
	end

	-- If it is one of the offered stairs: find out how many
	-- microblocks have to be subtracted:
	if listname == "output" then
		-- We do know how much each block at each position costs:
		local cost = circular_saw.cost_in_microblocks[index]
				* stack:get_count()

		circular_saw:update_inventory(pos, -cost)
	elseif listname == "micro" then
		-- Each microblock costs 1 microblock:
		circular_saw:update_inventory(pos, -stack:get_count())
	elseif listname == "input" then
		-- Each normal (= full) block taken costs 8 microblocks:
		circular_saw:update_inventory(pos, 8 * -stack:get_count())
	end
	-- The recycle field plays no role here since it is processed immediately.
end

local has_default_mod = minetest.get_modpath("default")

local function get_formspec()
	local fancy_inv = ""
	if has_default_mod then
		-- prepend background and slot styles from default if available
		fancy_inv = default.gui_bg..default.gui_bg_img..default.gui_slots
	end
		--FIXME Not work with @n in this part bug in minetest/minetest#7450.
	return "size[13,12]"..fancy_inv..
		"label[0,0;" ..S("Input material").. "]" ..
		"list[current_name;input;1.7,0;1,1;]" ..
		"label[0,1;" ..F(S("Left-over")).. "]" ..
		"list[current_name;micro;1.7,1;1,1;]" ..
		"label[0,2;" ..F(S("Recycle output")).. "]" ..
		"list[current_name;recycle;1.7,2;1,1;]" ..
		"field[0.3,3.5;1,1;max_offered;" ..F(S("Max")).. ":;${max_offered}]" ..
		"button[1,3.2;1.7,1;Set;" ..F(S("Set")).. "]" ..
		"button[0.5,3.75;2,2;Clear;" .. F(S("Discard All")) .. "]" ..
		"label[0,7;" .. F(S("Trash")).. "]" ..
		"list[current_name;trash;1.5,7;1,1;]" ..
		"list[current_name;output;2.8,0;8,8;]" ..
		"list[current_name;output;11,0;2,8;64]" ..
		"list[current_player;main;1.5,8.25;8,4;]" ..
		"listring[current_name;output]" ..
		"listring[current_player;main]" ..
		"listring[current_name;input]" ..
		"listring[current_player;main]" ..
		"listring[current_name;micro]" ..
		"listring[current_player;main]" ..
		"listring[current_name;recycle]" ..
		"listring[current_player;main]"
end

local circular_saw_formspec = get_formspec()

function circular_saw.on_construct(pos)
	local meta = minetest.get_meta(pos)
	meta:set_string("formspec", circular_saw_formspec)

	meta:set_int("anz", 0) -- No microblocks inside yet.
	meta:set_string("max_offered", 10) -- How many items of this kind are offered by default?
	-- meta:set_string("infotext", S("Circular Saw is empty"))

	local inv = meta:get_inventory()
	inv:set_size("input", 1)    -- Input slot for full blocks of material x.
	inv:set_size("micro", 1)    -- Storage for 1-7 surplus microblocks.
	inv:set_size("recycle", 1)  -- Surplus partial blocks can be placed here.
	inv:set_size("output", output_inv_size)
	inv:set_size("trash", 1)    -- Trash list

	circular_saw:reset(pos)
end

minetest.register_lbm({
	label = "Update circular saw formspec",
	name = "moreblocks:update_circular_saw_formspec",
	nodenames = {"moreblocks:circular_saw"},
	run_at_every_load = true,
	action = function(pos, node, dtime_s)
		local meta = minetest.get_meta(pos)
		if meta:get_string("formspec") ~= circular_saw_formspec then
			meta:set_string("formspec", circular_saw_formspec)
			local inv = meta:get_inventory()
			inv:set_size("output", output_inv_size)
			inv:set_size("trash", 1)
			minetest.log("action", "Circular Saw formspec updated at "..minetest.pos_to_string(pos))
		end
	end
})

function circular_saw.can_dig(pos,player)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	if not inv:is_empty("input") or
	   not inv:is_empty("micro") or
	   not inv:is_empty("recycle") then
		return false
	end
	-- Can be dug by anyone when empty, not only by the owner:
	return true
end

minetest.register_node("moreblocks:circular_saw",  {
	description = S("Circular Saw"),
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.4, -0.5, -0.4, -0.25, 0.25, -0.25}, -- Leg
			{0.25, -0.5, 0.25, 0.4, 0.25, 0.4}, -- Leg
			{-0.4, -0.5, 0.25, -0.25, 0.25, 0.4}, -- Leg
			{0.25, -0.5, -0.4, 0.4, 0.25, -0.25}, -- Leg
			{-0.5, 0.25, -0.5, 0.5, 0.375, 0.5}, -- Tabletop
			{-0.01, 0.4375, -0.125, 0.01, 0.5, 0.125}, -- Saw blade (top)
			{-0.01, 0.375, -0.1875, 0.01, 0.4375, 0.1875}, -- Saw blade (bottom)
			{-0.25, -0.0625, -0.25, 0.25, 0.25, 0.25}, -- Motor case
		},
	},
	tiles = {"moreblocks_circular_saw_top.png",
		"moreblocks_circular_saw_bottom.png",
		"moreblocks_circular_saw_side.png"},
	paramtype = "light",
	sunlight_propagates = true,
	paramtype2 = "facedir",
	groups = {choppy = 2,oddly_breakable_by_hand = 2},
	sounds = moreblocks.node_sound_wood_defaults(),
	on_construct = circular_saw.on_construct,
	can_dig = circular_saw.can_dig,
	-- Set the owner of this circular saw.
	after_place_node = function(pos, placer)
		local meta = minetest.get_meta(pos)
		local owner = placer and placer:get_player_name() or ""
		local owned_by = owner

		if owner ~= "" then
			owned_by = (" (%s)"):format(S("owned by @1", owner))
		end

		meta:set_string("owner",  owner)
		meta:set_string("infotext", S("Circular Saw is empty") .. owned_by)
	end,

	-- The amount of items offered per shape can be configured:
	on_receive_fields = circular_saw.on_receive_fields,
	allow_metadata_inventory_move = circular_saw.allow_metadata_inventory_move,
	-- Only input- and recycle-slot are intended as input slots:
	allow_metadata_inventory_put = circular_saw.allow_metadata_inventory_put,
	allow_metadata_inventory_take = circular_saw.allow_metadata_inventory_take,
	-- Taking is allowed from all slots (even the internal microblock slot). Moving is forbidden.
	-- Putting something in is slightly more complicated than taking anything because we have to make sure it is of a suitable material:
	on_metadata_inventory_put = circular_saw.on_metadata_inventory_put,
	on_metadata_inventory_take = circular_saw.on_metadata_inventory_take,
})

-- From technic_plus (license LGPLv2+)

-- Configuration

local chainsaw1_max_charge      = 30000
local chainsaw2_max_charge      = 375000
local chainsaw3_max_charge      = 1000000
local chainsaw_charge_per_node = 12 -- Gives 2500 nodes on a single charge (about 50 complete normal trees)

local chainsaw_leaves = true -- Cut down tree leaves.
-- Leaf decay may cause slowness on large trees if this is disabled.

local chainsaw_vines = true -- Cut down vines

local timber_nodenames = {} -- Cuttable nodes

local max_saw_radius = 12 -- max x/z distance away from starting position to allow cutting
-- Prevents forest destruction, increase for extra wide trees

-- Support for nodes not in any supported node groups (tree, leaves, leafdecay, leafdecay_drop)
timber_nodenames["default:papyrus"] = true
timber_nodenames["default:cactus"] = true
timber_nodenames["default:bush_stem"] = true
timber_nodenames["default:acacia_bush_stem"] = true
timber_nodenames["default:pine_bush_stem"] = true

if minetest.get_modpath("growing_trees") then
	timber_nodenames["growing_trees:branch_sprout"] = true
	if chainsaw_leaves then
		timber_nodenames["growing_trees:leaves"] = true
	end
end

if minetest.get_modpath("snow") then
	if chainsaw_leaves then
		timber_nodenames["snow:needles"] = true
		timber_nodenames["snow:needles_decorated"] = true
		timber_nodenames["snow:star"] = true
	end
end

if minetest.get_modpath("trunks") then
	if chainsaw_leaves then
		timber_nodenames["trunks:moss"] = true
		timber_nodenames["trunks:moss_fungus"] = true
		timber_nodenames["trunks:treeroot"] = true
	end
end

local S = technic.getter

-- Table for saving what was sawed down
local produced = {}

-- Save the items sawed down so that we can drop them in a nice single stack
local function handle_drops(drops)
	for _, item in ipairs(drops) do
		local stack = ItemStack(item)
		local name = stack:get_name()
		local p = produced[name]
		if not p then
			produced[name] = stack
		else
			p:set_count(p:get_count() + stack:get_count())
		end
	end
end

-- This function does all the hard work. Recursively we dig the node at hand
-- if it is in the table and then search the surroundings for more stuff to dig.
local function recursive_dig(origin, remaining_charge)
	local x_min = origin.x - max_saw_radius
	local y_min = origin.y
	local z_min = origin.z - max_saw_radius
	local x_max = origin.x + max_saw_radius
	local y_max = origin.y + 100
	local z_max = origin.z + max_saw_radius

	local queue = {origin}
	local queue_begin = 1
	local queue_end = 2

	local hash_node_position = minetest.hash_node_position
	local hashset = {[hash_node_position(origin)] = origin}

	local dig_count = 0
	local dig_count_max = math.floor(remaining_charge / chainsaw_charge_per_node)

	while queue_begin < queue_end and dig_count < dig_count_max do
		-- dequeue a node
		local pos = queue[queue_begin]
		-- queue[queue_begin] = nil -- keep the queue short
		queue_begin = queue_begin + 1

		local node_name = minetest.get_node(pos).name
		if timber_nodenames[node_name] then

			-- Wood found - cut it
			handle_drops(minetest.get_node_drops(node_name, ""))
			minetest.remove_node(pos)
			dig_count = dig_count + 1

			-- Check for snow on pine trees, sand/gravel on leaves, etc
			minetest.check_for_falling(pos)

			-- Enqueue surroundings
			local z, new_pos, hash
			z = pos.z
			for y = pos.y - 1, pos.y + 1 do
				if y_min <= y and y <= y_max then
					for x = pos.x - 1, pos.x + 1 do
						if x_min <= x and x <= x_max then

							new_pos = vector.new(x, y, z - 1)

							hash = hash_node_position(new_pos)
							if z_min <= z - 1 and not hashset[hash] then
								hashset[hash] = hashset
								queue[queue_end] = new_pos
								queue_end = queue_end + 1
								new_pos = vector.new(x, y, z)
							else
								new_pos.z = z -- recycle the vector
							end

							hash = hash_node_position(new_pos)
							if not hashset[hash] then
								hashset[hash] = hashset
								queue[queue_end] = new_pos
								queue_end = queue_end + 1
								new_pos = vector.new(x, y, z + 1)
							else
								new_pos.z = z + 1 -- recycle the vector
							end

							hash = hash_node_position(new_pos)
							if z + 1 <= z_max and not hashset[hash] then
								hashset[hash] = hashset
								queue[queue_end] = new_pos
								queue_end = queue_end + 1
							end
						end
					end
				end
			end
		end
	end

	local remaining_charge_original = remaining_charge
	remaining_charge = remaining_charge - dig_count * chainsaw_charge_per_node

	print("Chainsaw dig at "..origin.x..","..origin.y..","..origin.z..": queue="..queue_end..", dig_count="..dig_count..", remaining_charge: "..remaining_charge_original.." => "..remaining_charge)
	return math.max(0, remaining_charge)
end

-- Function to randomize positions for new node drops
local function get_drop_pos(pos)
	local drop_pos = {}

	for i = 0, 8 do
		-- Randomize position for a new drop
		drop_pos.x = pos.x + math.random(-3, 3)
		drop_pos.y = pos.y - 1
		drop_pos.z = pos.z + math.random(-3, 3)

		-- Move the randomized position upwards until
		-- the node is air or unloaded.
		for y = drop_pos.y, drop_pos.y + 5 do
			drop_pos.y = y
			local node = minetest.get_node_or_nil(drop_pos)

			if not node then
				-- If the node is not loaded yet simply drop
				-- the item at the original digging position.
				return pos
			elseif node.name == "air" then
				-- Add variation to the entity drop position,
				-- but don't let drops get too close to the edge
				drop_pos.x = drop_pos.x + (math.random() * 0.8) - 0.5
				drop_pos.z = drop_pos.z + (math.random() * 0.8) - 0.5
				return drop_pos
			end
		end
	end

	-- Return the original position if this takes too long
	return pos
end

-- Chainsaw entry point
local function chainsaw_dig(pos, current_charge)
	-- Play the sound before the tree is chopped
	if current_charge >= chainsaw_charge_per_node then
		minetest.sound_play("chainsaw", {pos = pos, gain = 1.0, max_hear_distance = 10}, true)
	end
	-- Start sawing things down
	local remaining_charge = recursive_dig(pos, current_charge)

	-- Now drop items for the player
	for name, stack in pairs(produced) do
		-- Drop stacks of stack max or less
		local count, max = stack:get_count(), stack:get_stack_max()
		stack:set_count(max)
		while count > max do
			minetest.add_item(get_drop_pos(pos), stack)
			count = count - max
		end
		stack:set_count(count)
		minetest.add_item(get_drop_pos(pos), stack)
	end

	-- Clean up
	produced = {}

	return remaining_charge
end

technic.register_power_tool("technic:chainsaw_mk1", chainsaw1_max_charge)
technic.register_power_tool("technic:chainsaw_mk2", chainsaw2_max_charge)
technic.register_power_tool("technic:chainsaw_mk3", chainsaw3_max_charge)

local function chainsaw_onuse(max_charge, itemstack, user, pointed_thing)
	if pointed_thing.type ~= "node" then
		return itemstack
	end

	local meta = minetest.deserialize(itemstack:get_meta():get_string(""))
	if not meta or not meta.charge or
			meta.charge < chainsaw_charge_per_node then
		return
	end

	local name = user:get_player_name()
	if minetest.is_protected(pointed_thing.under, name) then
		minetest.record_protection_violation(pointed_thing.under, name)
		return
	end

	-- Send current charge to digging function so that the
	-- chainsaw will stop after digging a number of nodes
	meta.charge = chainsaw_dig(pointed_thing.under, meta.charge)
	if not minetest.is_creative_enabled(name) then
		technic.set_RE_wear(itemstack, meta.charge, max_charge)
		itemstack:get_meta():set_string("", minetest.serialize(meta))
	end
	return itemstack
end

local ch_help = "Slouží k rychlému kácení stromů.\nLevý klik na blok kmene nebo listí skácí celou výše položenou část stromu, někdy i okolních stromů.\nElektrický nástroj — před použitím nutno nabít."
local ch_help_group = "chainsaw"

minetest.register_tool("technic:chainsaw_mk1", {
	description = S("Chainsaw Mk1"),
	_ch_help = ch_help,
	_ch_help_group = ch_help_group,
	inventory_image = "technic_chainsaw_mk1.png",
	stack_max = 1,
	wear_represents = "technic_RE_charge",
	on_refill = technic.refill_RE_charge,
	on_use = function(itemstack, user, pointed_thing)
		return chainsaw_onuse(chainsaw1_max_charge, itemstack, user, pointed_thing)
	end,
})

minetest.register_tool("technic:chainsaw_mk2", {
	description = S("Chainsaw Mk2"),
	_ch_help = ch_help,
	_ch_help_group = ch_help_group,
	inventory_image = "technic_chainsaw_mk2.png",
	stack_max = 1,
	wear_represents = "technic_RE_charge",
	on_refill = technic.refill_RE_charge,
	on_use = function(itemstack, user, pointed_thing)
		return chainsaw_onuse(chainsaw2_max_charge, itemstack, user, pointed_thing)
	end,
})

minetest.register_tool("technic:chainsaw_mk3", {
	description = S("Chainsaw Mk3"),
	_ch_help = ch_help,
	_ch_help_group = ch_help_group,
	inventory_image = "technic_chainsaw_mk3.png",
	stack_max = 1,
	wear_represents = "technic_RE_charge",
	on_refill = technic.refill_RE_charge,
	on_use = function(itemstack, user, pointed_thing)
		return chainsaw_onuse(chainsaw3_max_charge, itemstack, user, pointed_thing)
	end,
})

local trigger = minetest.get_modpath("mesecons_button") and "mesecons_button:button_off" or "default:mese_crystal_fragment"

minetest.register_craft({
	output = "technic:chainsaw_mk1",
	recipe = {
		{"technic:stainless_steel_ingot", trigger,                      "technic:battery"},
		{"basic_materials:copper_wire",      "basic_materials:motor",              "technic:battery"},
		{"",                              "",                           "technic:stainless_steel_ingot"},
	},
	replacements = { {"basic_materials:copper_wire", "basic_materials:empty_spool"}, },
})
minetest.register_craft({
	output = "technic:chainsaw_mk2",
	recipe = {
		{"technic:battery", "technic:stainless_steel_ingot", "technic:battery"},
		{"technic:stainless_steel_ingot", "technic:chainsaw_mk1", "technic:battery"},
		{"", "technic:green_energy_crystal", ""},
	},
})
minetest.register_craft({
	output = "technic:chainsaw_mk3",
	recipe = {
		{"technic:battery", "technic:stainless_steel_ingot", "technic:battery"},
		{"technic:stainless_steel_ingot", "technic:chainsaw_mk1", "technic:battery"},
		{"", "technic:blue_energy_crystal", ""},
	},
})

-- Add cuttable nodes after all mods loaded
minetest.after(0, function ()
	for k, v in pairs(minetest.registered_nodes) do
		if v.groups.tree then
			timber_nodenames[k] = true
		elseif chainsaw_leaves and (v.groups.leaves or v.groups.leafdecay or v.groups.leafdecay_drop) then
			timber_nodenames[k] = true
		elseif chainsaw_vines and v.groups.vines then
			timber_nodenames[k] = true
		end
	end
end)

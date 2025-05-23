
local S = technic.getter

local fs_helpers = pipeworks.fs_helpers
local tube_entry = "^pipeworks_tube_connection_metallic.png"

function technic.default_can_insert(pos, node, stack, direction)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	if meta:get_int("splitstacks") == 1 then
		stack = stack:peek_item(1)
	end
	return inv:room_for_item("src", stack)
end

function technic.new_default_tube()
	return {
		insert_object = function(pos, node, stack, direction)
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			return inv:add_item("src", stack)
		end,
		can_insert = technic.default_can_insert,
		connect_sides = {left = 1, right = 1, back = 1, top = 1, bottom = 1},
	}
end

local connect_default = {"top", "bottom", "back", "left", "right"}

local function round(v)
	return math.floor(v + 0.5)
end

local function compress_input(list)
	local result = {}
	local index = {}
	for i, stack in ipairs(list) do
		local count = stack:get_count()
		if count > 0 then
			local name = stack:get_name()
			if core.registered_items[name] ~= nil then
				local ind = index[name]
				if ind == nil then
					ind = #result + 1
					index[name] = ind
					local rstack = ItemStack(name)
					rstack:set_count(count)
					result[ind] = rstack
				else
					local oldstack = result[ind]
					local free_space = oldstack:get_free_space()
					if free_space > 0 then
						oldstack:set_count(oldstack:get_count() + math.min(count, free_space))
					end
				end
			end
		end
	end
	if result[1] == nil then
		result[1] = ItemStack()
	end
	return result
end

function technic.register_base_machine(data)
	local typename = data.typename
	local input_size = data.input_size or technic.recipes[typename].input_size
	local machine_name = data.machine_name
	local machine_desc = data.machine_desc
	local tier = data.tier
	local ltier = string.lower(tier)

	data.modname = data.modname or minetest.get_current_modname()

	local groups = {cracky = 2, technic_machine = 1, technic_all_tiers = 1}
	if data.tube then
		groups.tubedevice = 1
		groups.tubedevice_receiver = 1
	end
	local active_groups = table.copy(groups)
	active_groups.not_in_creative_inventory = 1

	local formspec =
		"size[8,9;]"..
		"list[current_name;src;"..(4-input_size)..",1;"..input_size..",1;]"..
		"list[current_name;dst;5,1;2,2;]"..
		"list[current_player;main;0,5;8,4;]"..
		"label[0,0;"..machine_desc:format(S(tier)).."]"..
		"listring[current_name;dst]"..
		"listring[current_player;main]"..
		"listring[current_name;src]"..
		"listring[current_player;main]"
	if data.upgrade then
		formspec = formspec..
			"list[current_name;upgrade1;1,3;1,1;]"..
			"list[current_name;upgrade2;2,3;1,1;]"..
			"label[1,4;"..S("Upgrade Slots").."]"..
			"listring[current_name;upgrade1]"..
			"listring[current_player;main]"..
			"listring[current_name;upgrade2]"..
			"listring[current_player;main]"
	end

	local tube = technic.new_default_tube()
	if data.can_insert then
		tube.can_insert = data.can_insert
	end
	if data.insert_object then
		tube.insert_object = data.insert_object
	end
	if tube.input_inventory == nil then
		tube.input_inventory = "dst"
	end

	local run = function(pos, node)
		local meta     = minetest.get_meta(pos)
		local inv      = meta:get_inventory()
		local eu_input = 100000 -- meta:get_int(tier.."_EU_input")

		local machine_desc_tier = machine_desc:format(S(tier))
		local machine_node      = data.modname..":"..ltier.."_"..machine_name
		local machine_demand    = data.demand

		-- Setup meta data if it does not exist.
		if not eu_input then
			meta:set_int(tier.."_EU_demand", machine_demand[1])
			meta:set_int(tier.."_EU_input", 0)
			return
		end

		local EU_upgrade, tube_upgrade = 0, 0
		if data.upgrade then
			EU_upgrade, tube_upgrade = technic.handle_machine_upgrades(meta)
		end
		if data.tube then
			technic.handle_machine_pipeworks(pos, tube_upgrade)
		end

		local powered = eu_input >= machine_demand[EU_upgrade+1]
		if powered then
			meta:set_int("src_time", meta:get_int("src_time") + round(data.speed*5))
		end
		while true do
			-- compress input:
			local src_size = inv:get_size("src") or 0
			if src_size ~= input_size then
				local node_def = minetest.registered_nodes[node.name]
				node_def.on_construct(pos)
				src_size = inv:get_size("src") or 0
				assert(src_size == input_size)
			end
			local src_list = inv:get_list("src")
			local use_compress_input = typename ~= "alloy" and typename ~= "separating"
			if use_compress_input then
				src_list = compress_input(src_list)
			end

			local result, src_i
			if use_compress_input then
				for i, stack in ipairs(src_list) do
					if not stack:is_empty() then
						result = technic.get_recipe(typename, {stack})
						if result then
							src_i = i
							break
						end
					end
				end
				if not result or src_i == nil then
					technic.swap_node(pos, machine_node)
					meta:set_string("infotext", S("@1 Idle", machine_desc_tier))
					meta:set_int(tier.."_EU_demand", 0)
					meta:set_int("src_time", 0)
					return
				end
			else
				result = technic.get_recipe(typename, src_list)
				if not result then
					technic.swap_node(pos, machine_node)
					meta:set_string("infotext", S("@1 Idle", machine_desc_tier))
					meta:set_int(tier.."_EU_demand", 0)
					meta:set_int("src_time", 0)
					return
				end
			end
			meta:set_int(tier.."_EU_demand", machine_demand[EU_upgrade+1])
			technic.swap_node(pos, machine_node.."_active")
			meta:set_string("infotext", S("@1 Active", machine_desc_tier))
			if meta:get_int("src_time") < round(result.time*10) then
				if not powered then
					technic.swap_node(pos, machine_node)
					meta:set_string("infotext", S("@1 Unpowered", machine_desc_tier))
				end
				return
			end
			local output = result.output
			if type(output) ~= "table" then output = { output } end
			local output_stacks = {}
			for _, o in ipairs(output) do
				table.insert(output_stacks, ItemStack(o))
			end
			local room_for_output = true
			inv:set_size("dst_tmp", inv:get_size("dst"))
			inv:set_list("dst_tmp", inv:get_list("dst"))
			for _, o in ipairs(output_stacks) do
				if not inv:room_for_item("dst_tmp", o) then
					room_for_output = false
					break
				end
				inv:add_item("dst_tmp", o)
			end
			if output_stacks[1] ~= nil then
				if machine_name == "electric_furnace" or machine_name == "alloy_furnace" then
					minetest.sound_play("default_cool_lava", {pos = pos, max_hear_distance = 16, gain = 0.1}, true)
				elseif machine_name == "oven_white" or machine_name == "oven_steel" or machine_name == "microwave_oven" then
					minetest.sound_play("default_cool_lava", {pos = pos, max_hear_distance = 8, gain = 0.05}, true)
				end
			end
			if not room_for_output then
				technic.swap_node(pos, machine_node)
				meta:set_string("infotext", S("@1 Idle", machine_desc_tier))
				meta:set_int(tier.."_EU_demand", 0)
				meta:set_int("src_time", round(result.time*10))
				return
			end
			meta:set_int("src_time", meta:get_int("src_time") - round(result.time*10))
			if src_i ~= nil then
				src_list[src_i] = ItemStack()
				inv:set_list("src", src_list) -- update src
				for _, stack in ipairs(result.new_input) do
					if not stack:is_empty() then
						inv:add_item("src", stack)
					end
				end
			else
				inv:set_list("src", result.new_input)
			end
			inv:set_list("dst", inv:get_list("dst_tmp"))
		end
	end

	local tentry = tube_entry
	if ltier == "lv" then
		tentry = ""
	end

	local def = {
		description = machine_desc:format(S(tier)),
		tiles = {
			data.modname.."_"..ltier.."_"..machine_name.."_top.png",
			data.modname.."_"..ltier.."_"..machine_name.."_bottom.png"..tentry,
			data.modname.."_"..ltier.."_"..machine_name.."_side.png"..tentry,
			data.modname.."_"..ltier.."_"..machine_name.."_side.png"..tentry,
			data.modname.."_"..ltier.."_"..machine_name.."_side.png"..tentry,
			data.modname.."_"..ltier.."_"..machine_name.."_front.png"
		},
		paramtype2 = "facedir",
		groups = groups,
		tube = data.tube and tube or nil,
		connect_sides = data.connect_sides or connect_default,
		legacy_facedir_simple = true,
		sounds = default.node_sound_wood_defaults(),
		on_construct = function(pos)
			local node = minetest.get_node(pos)
			local meta = minetest.get_meta(pos)

			local form_buttons = ""
			if not string.find(node.name, ":lv_") then
				form_buttons = fs_helpers.cycling_button(
					meta,
					pipeworks.button_base,
					"splitstacks",
					{
						pipeworks.button_off,
						pipeworks.button_on
					}
				)..pipeworks.button_label
			end

			meta:set_string("infotext", machine_desc:format(S(tier)))
			meta:set_int("tube_time",  0)
			meta:set_string("formspec", formspec..form_buttons)
			local inv = meta:get_inventory()
			inv:set_size("src", input_size)
			inv:set_size("dst", 4)
			inv:set_size("upgrade1", 1)
			inv:set_size("upgrade2", 1)
		end,
		can_dig = technic.machine_can_dig,
		allow_metadata_inventory_put = technic.machine_inventory_put,
		allow_metadata_inventory_take = technic.machine_inventory_take,
		allow_metadata_inventory_move = technic.machine_inventory_move,
		technic_run = run,
		after_place_node = data.tube and pipeworks.after_place,
		after_dig_node = technic.machine_after_dig_node,
		on_receive_fields = function(pos, formname, fields, sender)
			if fields.quit then return end
			if not pipeworks.may_configure(pos, sender) then return end
			fs_helpers.on_receive_fields(pos, fields)
			local node = minetest.get_node(pos)
			local meta = minetest.get_meta(pos)
			local form_buttons = ""
			if not string.find(node.name, ":lv_") then
				form_buttons = fs_helpers.cycling_button(
					meta,
					pipeworks.button_base,
					"splitstacks",
					{
						pipeworks.button_off,
						pipeworks.button_on
					}
				)..pipeworks.button_label
			end
			meta:set_string("formspec", formspec..form_buttons)
		end,
	}
	local override = data.def_override
	if override then
		for k, v in pairs(override) do
			def[k] = v
		end
	end
	minetest.register_node(data.modname..":"..ltier.."_"..machine_name, def)

	def = {
		description = machine_desc:format(tier),
		tiles = {
			data.modname.."_"..ltier.."_"..machine_name.."_top.png",
			data.modname.."_"..ltier.."_"..machine_name.."_bottom.png"..tentry,
			data.modname.."_"..ltier.."_"..machine_name.."_side.png"..tentry,
			data.modname.."_"..ltier.."_"..machine_name.."_side.png"..tentry,
			data.modname.."_"..ltier.."_"..machine_name.."_side.png"..tentry,
			data.modname.."_"..ltier.."_"..machine_name.."_front_active.png"
		},
		paramtype2 = "facedir",
		drop = data.modname..":"..ltier.."_"..machine_name,
		groups = active_groups,
		connect_sides = data.connect_sides or connect_default,
		legacy_facedir_simple = true,
		sounds = default.node_sound_wood_defaults(),
		tube = data.tube and tube or nil,
		can_dig = technic.machine_can_dig,
		allow_metadata_inventory_put = technic.machine_inventory_put,
		allow_metadata_inventory_take = technic.machine_inventory_take,
		allow_metadata_inventory_move = technic.machine_inventory_move,
		technic_run = run,
		technic_disabled_machine_name = data.modname..":"..ltier.."_"..machine_name,
		on_receive_fields = function(pos, formname, fields, sender)
			if fields.quit then return end
			if not pipeworks.may_configure(pos, sender) then return end
			fs_helpers.on_receive_fields(pos, fields)
			local node = minetest.get_node(pos)
			local meta = minetest.get_meta(pos)
			local form_buttons = ""
			if not string.find(node.name, ":lv_") then
				form_buttons = fs_helpers.cycling_button(
					meta,
					pipeworks.button_base,
					"splitstacks",
					{
						pipeworks.button_off,
						pipeworks.button_on
					}
				)..pipeworks.button_label
			end
			meta:set_string("formspec", formspec..form_buttons)
		end,
	}
	override = data.def_override_active
	if override then
		for k, v in pairs(override) do
			def[k] = v
		end
	end
	minetest.register_node(data.modname..":"..ltier.."_"..machine_name.."_active", def)

	technic.register_machine(tier, data.modname..":"..ltier.."_"..machine_name,            technic.receiver)
	technic.register_machine(tier, data.modname..":"..ltier.."_"..machine_name.."_active", technic.receiver)

end -- End registration


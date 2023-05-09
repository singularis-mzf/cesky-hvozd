print("[MOD BEGIN] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")

-- local S = minetest.get_translator("ch_3dprint")

ch_3dprint = {
	recipes = {},
}

-- CONFIGURATION:
local printers = {
	"home_workshop_machines:3dprinter_bedflinger",
	"home_workshop_machines:3dprinter_corexy",
}
local computers = {
	"computers:admiral128",
	"computers:specter",
	"computers:admiral64",
	"computers:wee",
	"computers:monitor_on",
	"computers:piepad",
	"computers:shefriendSOO",
	"computers:vanio",
	"computers:server_on",
	"computers:router",
}
local points_per_dye = 10
local default_output_max = 1
local page_width, page_height, pages = 10, 5, 8
local default_item = {
	input = "technic:wrought_iron_dust",

	cyan = "dye:cyan",
	magenta = "dye:magenta",
	yellow = "dye:yellow",
	black = "dye:black",
}

-- DATA:
local dye_colors = {"cyan", "magenta", "yellow", "black"}

unified_inventory.register_craft_type("3dprint", {
	description = "3D tisk",
	icon = "home_workshop_machines_3dprinter_bedflinger_inv.png",
	width = 2,
	height = 3,
})

local function get_page_max()
	local recipes = ch_3dprint.recipes
	local result = math.ceil(#recipes / (page_width * page_height))
	if result < 1 then
		return 1
	elseif result > pages then
		return pages
	else
		return result
	end
end

local function get_formspec(pos, meta, inv, player, page)
	if meta == nil then
		meta = minetest.get_meta(pos)
	end
	inv = nil -- not used
	local node = minetest.get_node(pos)
	local context = "nodemeta:"..pos.x..","..pos.y..","..pos.z
	local formspec = {
		"formspec_version[4]",
		"size[14.75,16]",
		"item_image[0.25,0.25;1,1;", node.name, "]",
		"label[1.5,0.75;3D tiskárna]",
		"label[2.5,1.25;prach]",
		"list[", context, ";input;1.25,1.5;3,1;]",
		"label[5.3,1.25;tyrkysová]",
		"list[", context, ";cyan;5.5,1.5;1,1;]",
		"label[6.8,1.25;purpurová]",
		"list[", context, ";magenta;7.0,1.5;1,1;]",
		"label[8.6,1.25;žlutá]",
		"list[", context, ";yellow;8.5,1.5;1,1;]",
		"label[10.1,1.25;černá]",
		"list[", context, ";black;10.0,1.5;1,1;]",
		"label[5.6,0.75;+0,", meta:get_int("cyan"), "]",
		"label[7.1,0.75;+0,", meta:get_int("magenta"), "]",
		"label[8.6,0.75;+0,", meta:get_int("yellow"), "]",
		"label[10.0,0.75;+0,", meta:get_int("black"), "]",
		"field[11.5,1.45;2,0.5;stackmax;max. výst.;", meta:get_int("output_max"), "]",
		"button[11.75,2;1.5,0.5;setmax;nastavit]",
		"label[1.25,3;vyrobitelné předměty:]",
	}

	local s = "list["..context..";output;1.25,3.5;10,5;"
	local page_max = get_page_max()
	if page ~= 1 then
		s = s..(page_width * page_height * (page - 1))
	end
	table.insert(formspec, s.."]")
	if page ~= 1 then
		table.insert(formspec, "button[4.0,9.75;2,0.75;prevpage;< předchozí]")
	end
	if page ~= page_max then
		table.insert(formspec, "button[9.0,9.75;2,0.75;nextpage;další >]")
	end
	if page_max ~= 1 then
		table.insert(formspec, "label[6.5,10.1;stránka "..page.." z "..page_max.."]")
	end
	table.insert(formspec, "list[current_player;main;2.5,11.0;8,4;]")
	table.insert(formspec, "listring["..context..";output]")
	table.insert(formspec, "listring[current_player;main]")
	table.insert(formspec, "listring["..context..";input]")
	return table.concat(formspec)
end

local function is_input_item(item_name)
	return item_name == default_item.input or item_name == "technic:tin_dust" or item_name == "technic:silver_dust"
end

local function dye_points_to_ceil(points)
	return math.ceil(points / points_per_dye)
end

function ch_3dprint.register_recipe(recipe)
	if type(recipe) ~= "table" or not recipe.output then
		error("Invalid 3D printer recipe!")
	end
	local new_recipe = {}
	if type(recipe.output) == "string" then
		new_recipe.output = ItemStack(recipe.output)
	else
		new_recipe.output = recipe.output
	end
	new_recipe.cyan = recipe.cyan or 0
	new_recipe.magenta = recipe.magenta or 0
	new_recipe.yellow = recipe.yellow or 0
	new_recipe.black = recipe.black or 0
	new_recipe.input = recipe.input or 0
	table.insert(ch_3dprint.recipes, new_recipe)

	local items = {
		default_item.cyan.." "..math.ceil(new_recipe.cyan / points_per_dye),
		default_item.magenta.." "..math.ceil(new_recipe.magenta / points_per_dye),
		default_item.yellow.." "..math.ceil(new_recipe.yellow / points_per_dye),
		default_item.black.." "..math.ceil(new_recipe.black / points_per_dye),
		default_item.input.." "..new_recipe.input,
	}
	unified_inventory.register_craft({type = "3dprint", output = new_recipe.output:to_string(), items = items})

	if new_recipe.input > 1 and not recipe.no_grinder then
		technic.register_grinder_recipe({
			input = {new_recipe.output:get_name()},
			output = default_item.input.." "..(new_recipe.input - 1),
		})
	end
end

local function get_current_state(pos, meta, inv)
	if meta == nil then
		meta = minetest.get_meta(pos)
	end
	if inv == nil then
		inv = meta:get_inventory()
	end
	local input = 0
	for i = 1, inv:get_size("input") do
		input = input + inv:get_stack("input", i):get_count()
	end
	return {
		cyan = meta:get_int("cyan") + inv:get_stack("cyan", 1):get_count() * points_per_dye,
		magenta = meta:get_int("magenta") + inv:get_stack("magenta", 1):get_count() * points_per_dye,
		yellow = meta:get_int("yellow") + inv:get_stack("yellow", 1):get_count() * points_per_dye,
		black = meta:get_int("black") + inv:get_stack("black", 1):get_count() * points_per_dye,
		input = input,
	}
end

local function set_current_state(pos, meta, inv, state)
	if meta == nil then
		meta = minetest.get_meta(pos)
	end
	if inv == nil then
		inv = meta:get_inventory()
	end
	local input = 0
	for i = 1, inv:get_size("input") do
		local stack = inv:get_stack("input", i)
		if not stack:is_empty() then
			local stack_count = stack:get_count()
			input = input + stack_count
			if input > state.input then
				stack:set_count(stack_count - (input - state.input))
				inv:set_stack("input", i, stack)
				input = state.input
			end
		end
	end
	if state.input > input then
		inv:add_item("input", ItemStack(default_item.input.." "..(state.input - input)))
	end
	for _, color in ipairs(dye_colors) do
		local new_count = math.floor(state[color] / points_per_dye)
		local new_points = state[color] - new_count * points_per_dye
		inv:set_stack(color, 1, ItemStack(default_item[color].." "..new_count))
		meta:set_int(color, new_points)
	end
	return true
end

-- get_output_inventory() => invlist, max_pages
local function get_output_inventory(pos, meta, inv)
	if meta == nil then
		meta = minetest.get_meta(pos)
	end
	if inv == nil then
		inv = meta:get_inventory()
	end
	local output_size = inv:get_size("output")
	local output_max = meta:get_int("output_max")
	local current_state = get_current_state(pos, meta, inv)
	local empty_stack = ItemStack()
	local result = {}

	-- print("DEBUG: cyan = "..current_state.cyan..", magenta = "..current_state.magenta..", yellow = "..current_state.yellow..", black = "..current_state.black..", input = "..current_state.input)

	for i, recipe in ipairs(ch_3dprint.recipes) do
		if i > output_size then
			minetest.log("warning", "Too many recipes for 3d printer at "..minetest.pos_to_string(pos).." with output_size == "..output_size.."!")
			break
		end
		local stack = recipe.output
		if not stack:is_empty() then
			local stack_max = math.min(output_max, stack:get_stack_max())
			for _, color in ipairs(dye_colors) do
				if recipe[color] > 0 then
					stack_max = math.min(stack_max, current_state[color] / recipe[color])
				end
			end
			if recipe.input > 0 then
				stack_max = math.min(stack_max, current_state.input / recipe.input)
			end
			stack_max = math.floor(stack_max)
			if stack_max > 0 then
				stack:set_count(stack_max)
			else
				stack = empty_stack
			end
		end
		result[i] = stack
	end

	for i = #result + 1, output_size do
		result[i] = empty_stack
	end

	return result
end

local function update_output_inventory(pos, meta, inv)
	if meta == nil then
		meta = minetest.get_meta(pos)
	end
	if inv == nil then
		inv = meta:get_inventory()
	end
	local output_inv = get_output_inventory(pos, meta, inv)
	inv:set_list("output", output_inv)
	return output_inv
end

-- returns a new state and a correct count
local function simulate_crafting(pos, meta, inv, recipe, count)
	if meta == nil then
		meta = minetest.get_meta(pos)
	end
	if inv == nil then
		inv = meta:get_inventory()
	end
	local state = get_current_state(pos, meta, inv)
	for _, color in ipairs(dye_colors) do
		if recipe[color] > 0 then
			local new_value = state[color] - recipe[color] * count
			if new_value < 0 then
				count = math.floor(state[color] / recipe[color])
				new_value = state[color] - recipe[color] * count
			end
			state[color] = new_value
		end
	end
	if recipe.input > 0 then
		local new_input_count = state.input - recipe.input * count
		if new_input_count < 0 then
			count = math.floor(state.input / recipe.input)
			new_input_count = state.input - recipe.input * count
		end
		state.input = new_input_count
	end
	return state, count
end

local function allow_metadata_inventory_put(pos, listname, index, stack, player)
	local player_name = player and player:get_player_name()
	if not player_name or not minetest.check_player_privs(player_name, "ch_registered_player") then
		return 0
	end

	local allow
	local name = stack:get_name()
	if listname == "input" then
		allow = is_input_item(name)
	elseif default_item[listname] ~= nil then
		allow = name == default_item[listname]
	end

	if allow then
		return stack:get_count()
	else
		return 0
	end
end

local function allow_metadata_inventory_take(pos, listname, index, stack, player)
	local player_name = player and player:get_player_name()
	if not player_name or not minetest.check_player_privs(player_name, "ch_registered_player") then
		return 0
	end
	if listname == "output" then
		local wanted_count = stack:get_count()
		local recipe = ch_3dprint.recipes[index]
		local new_state, allowed_count = simulate_crafting(pos, nil, nil, recipe, wanted_count)
		if allowed_count ~= wanted_count then
			minetest.log("error", "3D printer crafting of "..recipe.output:to_string().." at "..minetest.pos_to_string(pos).." failed! Can craft only "..count.." items instead of "..orig_count.."!")
		end
		set_current_state(pos, nil, nil, new_state)
		return allowed_count
	else
		return stack:get_count()
	end
end

local function allow_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
	if from_list == "input" and to_list == "input" then
		return count
	else
		return 0
	end
end

local function on_dig(pos, node, digger, old_on_dig)
	local player_name = digger and digger:get_player_name()
	if not player_name or not minetest.check_player_privs(player_name, "ch_registered_player") then
		return false
	end
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local allow = inv:is_empty("input") and inv:is_empty("cyan") and inv:is_empty("magenta") and inv:is_empty("yellow") and inv:is_empty("black")
	if not allow then
		return false
	end

	return old_on_dig(pos, node, digger)
end

local function on_construct(pos)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	inv:set_size("input", 3)
	inv:set_size("cyan", 1)
	inv:set_size("magenta", 1)
	inv:set_size("yellow", 1)
	inv:set_size("black", 1)
	inv:set_size("output", page_width * page_height * pages)
	meta:set_int("output_max", default_output_max)
end

local function on_metadata_inventory_put(pos, listname, index, stack, player)
	update_output_inventory(pos)
end

local printers_counters = {}

local function on_metadata_inventory_take(pos, listname, index, stack, player)
	if listname == "output" then
		-- some output taken!
		local player_name = player and player:get_player_name()
		minetest.log("action", "3D printer at "..minetest.pos_to_string(pos).." crafted "..stack:to_string().." for "..(player_name or "???"))
		if player_name ~= nil then
			ch_core.update_shown_formspec(player_name, "ch_3dprint:formspec", function(custom_state)
					return get_formspec(custom_state.pos, nil, nil, minetest.get_player_by_name(player_name), custom_state.page)
				end)
		end
		local hash = minetest.hash_node_position(pos)
		local timer = minetest.get_node_timer(pos)
		if (printers_counters[hash] or 0) < 2 then
			timer:set(0.5, 0.4)
		end
		printers_counters[hash] = 10
	end
	if default_item[listname] ~= nil or listname == "output" then
		update_output_inventory(pos)
	end
end

local function formspec_callback(custom_state, player, formname, fields)
	if fields.prevpage and custom_state.page ~= 1 then
		custom_state.page = custom_state.page - 1
		return get_formspec(custom_state.pos, nil, nil, player, custom_state.page)
	elseif fields.nextpage and custom_state.page < custom_state.page_max then
		custom_state.page = custom_state.page + 1
		return get_formspec(custom_state.pos, nil, nil, player, custom_state.page)
	elseif fields.setmax and minetest.check_player_privs(player, "ch_registered_player") then
		local meta = minetest.get_meta(custom_state.pos)
		local n = tonumber(fields.stackmax)
		if n ~= nil and n >= 1 and n <= 65535 then
			meta:set_int("output_max", n)
			update_output_inventory(custom_state.pos, meta)
		end
		return get_formspec(custom_state.pos, nil, nil, player, custom_state.page)
	end
end

local function on_rightclick(pos, node, clicker, itemstack, pointed_thing)
	if clicker and clicker:is_player() then
		local computer = minetest.find_node_near(pos, 10, computers)
		if computer then
			ch_core.show_formspec(clicker, "ch_3dprint:formspec", get_formspec(pos, nil, nil, clicker, 1), formspec_callback, {pos = pos, page = 1, page_max = get_page_max(pos)}, {})
		else
			ch_core.systemovy_kanal(clicker:get_player_name(), "K použití 3D tiskárny musí být v blízkosti (do 10 metrů) zapnutý počítač!")
		end
	end
end

local function on_timer(pos, elapsed)
	local hash = minetest.hash_node_position(pos)
	local node = minetest.get_node(pos)
	local ndef = minetest.registered_nodes[node.name]
	local color = minetest.strip_param2_color(node.param2, ndef.paramtype2)
	if ndef.paramtype2 == "colorwallmounted" then
		local new_color = math.random(0, 31)
		node.param2 = node.param2 - color + 8 * new_color
		minetest.swap_node(pos, node)

		local counter = printers_counters[hash]
		if counter ~= nil and counter > 1 then
			printers_counters[hash] = counter - 1
			return true
		else
			printers_counters[hash] = nil
		end
	end
end

local function preserve_metadata(pos, oldnode, oldmeta, drops)
	for i, stack in ipairs(drops) do
		if not stack:is_empty() then
			stack:get_meta():set_int("palette_index", 0)
		end
	end
end

local default_override = {
	allow_metadata_inventory_move = allow_metadata_inventory_move,
	allow_metadata_inventory_put = allow_metadata_inventory_put,
	allow_metadata_inventory_take = allow_metadata_inventory_take,
	on_construct = on_construct,
	-- on_metadata_inventory_move = on_metadata_inventory_move,
	on_metadata_inventory_put = on_metadata_inventory_put,
	on_metadata_inventory_take = on_metadata_inventory_take,
	on_rightclick = on_rightclick,
	on_timer = on_timer,
	preserve_metadata = preserve_metadata,
}

for _, name in ipairs(printers) do
	local ndef = minetest.registered_nodes[name]
	if ndef ~= nil then
		local old_on_dig = ndef.on_dig or minetest.node_dig
		local override = table.copy(default_override)
		override.on_dig = function(pos, node, digger)
			return on_dig(pos, node, digger, old_on_dig)
		end
		override.groups = ch_core.override_groups(ndef.groups, {ud_param2_colorable = 0})
		minetest.override_item(name, override)
	else
		minetest.log("warning", "Expected 3D printer node "..name.." does not exist!")
	end
end

if minetest.get_modpath("streets") then
	local input_default, cyan_default, magenta_default, yellow_default, black_default = 3, 2, 2, 2, 2
	local function rr(name, input, cyan, magenta, yellow, black)
		local ndef = minetest.registered_nodes[name]
		if ndef ~= nil then
			ch_3dprint.register_recipe({output = name, input = input or input_default, cyan = cyan or cyan_default, magenta = magenta or magenta_default, yellow = yellow or yellow_default, black = black or black_default})
		end
	end

	rr("streets:sign_curve_chevron_left", 4, 0, 2, 2, 3)
	rr("streets:sign_curve_chevron_right", 4, 0, 2, 2, 3)
	rr("streets:sign_eu_curveright")
	rr("streets:sign_eu_curveleft")
	rr("streets:sign_eu_trafficlightahead")
	rr("streets:sign_eu_pedestrians")
	rr("streets:sign_eu_children")
	rr("streets:sign_eu_farmanimals")
	rr("streets:sign_eu_deercrossing")
	rr("streets:sign_eu_roadworks")
	rr("streets:sign_eu_bikes")
	rr("streets:sign_eu_doublecurveright")
	rr("streets:sign_eu_doublecurveleft")
	rr("streets:sign_eu_danger")
	rr("streets:sign_eu_jam")
	rr("streets:sign_eu_intersectionrightofwayright")
	rr("streets:sign_eu_cross1", 2, 0, 2, 2, 0)
	rr("streets:sign_eu_cross2", 3, 0, 3, 3, 0)
	rr("streets:sign_eu_downhillgrade", 3, 2, 2, 2, 3)
	rr("streets:sign_eu_uphillgrade", 3, 2, 2, 2, 3)
	rr("streets:sign_eu_roadnarrowsboth")
	rr("streets:sign_eu_roadnarrowsleft")
	rr("streets:sign_eu_roadnarrowsright")
	rr("streets:sign_eu_bumpyroad")
	rr("streets:sign_eu_slipdanger")
	rr("streets:sign_eu_twowaytraffic")
	rr("streets:sign_eu_novehicles", 3, 2, 2, 2, 0)
	rr("streets:sign_eu_nomotorvehicles")
	rr("streets:sign_eu_noentry", 3, 2, 4, 4, 0)
	rr("streets:sign_eu_10")
	rr("streets:sign_eu_100")
	rr("streets:sign_eu_120")
	rr("streets:sign_eu_30")
	rr("streets:sign_eu_50")
	rr("streets:sign_eu_70")
	rr("streets:sign_eu_noovertaking")
	rr("streets:sign_eu_endnoovertaking")
	rr("streets:sign_eu_nouturns")
	rr("streets:sign_eu_end")
	rr("streets:sign_eu_nostopping")
	rr("streets:sign_eu_noparking")
	rr("streets:sign_eu_nomotorcars")
	rr("streets:sign_eu_nopedestrians")
	rr("streets:sign_eu_nohorsebackriding")
	rr("streets:sign_eu_notrucks")
	rr("streets:sign_eu_nobikes")
	cyan_default = 3
	rr("streets:sign_eu_roundabout")
	rr("streets:sign_eu_seperatedpedestriansbicyclists")
	rr("streets:sign_eu_bridlepath")
	rr("streets:sign_eu_straightonly")
	rr("streets:sign_eu_rightonly")
	rr("streets:sign_eu_leftonly")
	rr("streets:sign_eu_straightrightonly")
	rr("streets:sign_eu_straightleftonly")
	rr("streets:sign_eu_rightonly_")
	rr("streets:sign_eu_leftonly_")
	rr("streets:sign_eu_passingright")
	rr("streets:sign_eu_passingleft")
	rr("streets:sign_eu_walkway")
	rr("streets:sign_eu_cyclepath")
	rr("streets:sign_eu_sharedpedestriansbicyclists")
	cyan_default = 2
	rr("streets:sign_eu_turningprioroad4")
	rr("streets:sign_eu_turningprioroad3-1")
	rr("streets:sign_eu_turningprioroad3-2")
	rr("streets:sign_eu_arrowleft", 2, 2, 2, 2, 2)
	rr("streets:sign_eu_arrowright", 2, 2, 2, 2, 2)
	rr("streets:sign_eu_wc")
	rr("streets:sign_eu_firstaid")
	rr("streets:sign_eu_info")
	rr("streets:sign_eu_deadendstreet")
	rr("streets:sign_eu_parkingsite")
	rr("streets:sign_eu_highway")
	rr("streets:sign_eu_highwayend")
	rr("streets:sign_eu_motorroad")
	rr("streets:sign_eu_motorroadend")
	rr("streets:sign_eu_trafficcalmingarea")
	rr("streets:sign_eu_trafficcalmingareaend")
	rr("streets:sign_eu_onewayleft", 2, 2, 2, 2, 0)
	rr("streets:sign_eu_onewayright", 2, 2, 2, 2, 0)
	rr("streets:sign_eu_oneway")
	rr("streets:sign_eu_pedestriancrossing")
	rr("streets:sign_eu_breakdownbay")
	rr("streets:sign_eu_laneshift")
	rr("streets:sign_eu_transfertoothercarriageway1")
	rr("streets:sign_eu_transfertoothercarriageway2")
	rr("streets:sign_eu_tunnel", 3, 2, 2, 2, 3)
	rr("streets:sign_eu_pedestrianszone", 4, 2, 2, 2, 2)
	rr("streets:sign_eu_pedestrianszoneend", 4, 2, 2, 2, 2)
	rr("streets:sign_eu_30zone", 4, 2, 2, 2, 2)
	rr("streets:sign_eu_30zoneend", 4, 2, 2, 2, 2)
	rr("streets:sign_grass")
	rr("streets:sign_eu_rightofway")
	rr("streets:sign_eu_majorroad", 3, 2, 2, 4, 1)
	rr("streets:sign_eu_endmajorroad", 3, 2, 2, 4, 2)
	rr("streets:sign_eu_yield")
	rr("streets:sign_eu_stop", 3, 2, 4, 2, 2)
	rr("streets:sign_eu_givewayoncoming")
	rr("streets:sign_eu_priooveroncoming", 3, 3, 2, 2, 0)
	rr("streets:sign_eu_arrowturnleft", 2, 2, 2, 2, 3)
	rr("streets:sign_eu_arrowturnright", 2, 2, 2, 2, 3)
	rr("streets:sign_eu_arrowsvertical", 2, 2, 2, 2, 3)
	rr("streets:sign_eu_arrowshorizontal", 2, 2, 2, 2, 3)
	rr("streets:sign_eu_greenarrow", 3, 3, 2, 3, 3)
	rr("streets:sign_eu_bendleft")
	rr("streets:sign_eu_bendright")
	rr("streets:sign_eu_guideboard_right")
	rr("streets:sign_eu_guideboard_left")
end

print("[MOD END] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")

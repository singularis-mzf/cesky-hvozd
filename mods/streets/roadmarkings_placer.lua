--[[
	## StreetsMod 2.0 ##
]]

local S = minetest.get_translator("streets")

local facedir_group_to_shift = {
	[0] = vector.new(0, 1, 0),
	[1] = vector.new(0, 0, 1),
	[2] = vector.new(0, 0, -1),
	[3] = vector.new(1, 0, 0),
	[4] = vector.new(-1, 0, 0),
	[5] = vector.new(0, -1, 0),
}

local colors = {
	"white",
	"yellow",
	"black",
	"red",
	"green",
	"violet",
	"brown",
	"blue",
}

local function formspec_callback(custom_state, player, formname, fields)
	for field_name, field_value in pairs(fields) do
		if field_value and field_name:match("^tool_") then

			local target_color_index = minetest.get_item_group("streets:"..field_name, "streets_tool")
			if target_color_index == 0 then
				minetest.log("error", "Invalid item name in the "..formname.." callback: streets:"..field_name.."!")
				return
			end
			if target_color_index ~= custom_state.color_index then
				minetest.log("warning", "Invalid item color in the "..formname.."!")
				return
			end
			local inv = player:get_inventory()
			local wlist = player:get_wield_list()
			local windex = player:get_wield_index()
			local witem = inv:get_stack(wlist, windex)
			if witem:is_empty() or minetest.get_item_group(witem:get_name(), "streets_tool") ~= target_color_index then
				minetest.log("error", "Unexpected item in the inventory for rm_callback: "..witem:get_name().."!")
				return
			end
			witem:set_name("streets:"..field_name)
			inv:set_stack(wlist, windex, witem)

			-- Close the formspec
			fields.quit = "true"
			minetest.close_formspec(player:get_player_name(), formname)
			return
		end
	end
	if not fields.quit then
		minetest.log("warning", "Unexpected formspec callback for "..formname..", fields = "..dump2(fields))
	end
end

local function on_place(itemstack, placer, pointed_thing, name, r)

	local empty_table = {}
	local player_name = placer and placer:is_player() and placer:get_player_name()

	if not player_name then
		return itemstack -- only works when used by a player
	end

	local itemstack_name = itemstack:get_name()
	local color_index = minetest.get_item_group(itemstack_name, "streets_tool")

	if color_index < 1 or color_index > #colors then
		minetest.debug("invalid color_index "..color_index)
		return itemstack
	end

	local control = placer:get_player_control()
	if control.aux1 then
		-- SETUP
		local colorname = colors[color_index]

		local formspec = {
			"formspec_version[4]",
			"size[9,7.5]",
			"label[0.375,0.5;Změna tvaru]",
			"button_exit[1,6.3;7,0.75;zavrit;Zavřít ovládací panel]",
		}
		local name, desc
		local tools = {}

		for _, w in ipairs(streets.labels.labeltypes_in_order) do
			local base_name = "streets:tool_" .. w.name:gsub("{color}", colorname)
			name = base_name:gsub("^streets:tool_", "")
			desc = w.friendlyname
			if minetest.registered_tools[base_name] then
				table.insert(tools, name)
			else
				minetest.log("warning", "Expected tool "..base_name.." does not exist!")
			end
			if w.basic then
				for r, _ in pairs(w.basic_rotation or empty_table) do
					if minetest.registered_tools[base_name.."_"..r] then
						table.insert(tools, base_name:gsub("^streets:tool_", "").."_"..r)
					else
						minetest.log("warning", "Expected tool "..base_name.."_"..r.." does not exist!")
					end
				end
			end
		end

		local i = 0
		local tool
		local x_scale, y_scale = 1, 1
		local x_shift, y_shift = -0.5, 0
		local button_size = 0.9
		for y = 1, 5 do
			for x = 1, 8 do
				i = i + 1
				tool = tools[i]
				if not tool then break end
				table.insert(formspec, "item_image_button["..(x * x_scale + x_shift)..","..(y * y_scale + y_shift)..";"..button_size..","..button_size..";streets:tool_"..tool..";tool_"..tool..";]")
			end
			if not tool then break end
		end

		ch_core.show_formspec(player_name, "streets:toolmenu", table.concat(formspec), formspec_callback, {color_index = color_index}, {})
		return itemstack

	else

		if pointed_thing.type ~= "node" then
			return itemstack -- only works on nodes
		end

		-- PLACE
		local pos_above = pointed_thing.above
		local pos_under = pointed_thing.under
		local node_above = minetest.get_node(pos_above)
		local node_under = minetest.get_node(pos_under)
		local ndef_under = minetest.registered_nodes[node_under.name]
		if node_above.name ~= "air" then
			return -- can only place to the air
		end
		if not ndef_under or ndef_under.walkable == false or minetest.get_item_group(node_under.name, "attached_node") ~= 0 then
			return -- can only place on walkable non-attached nodes
		end
		local groups_under = ndef_under.groups or {}
		local extra_facedir

		if pos_above.y < pos_under.y then
			extra_facedir = 20
		elseif pos_above.x < pos_under.x then
			extra_facedir = 16
		elseif pos_above.x > pos_under.x then
			extra_facedir = 12
		elseif pos_above.z < pos_under.z then
			extra_facedir = 8
		elseif pos_above.z > pos_under.z then
			extra_facedir = 4
		else
			extra_facedir = 0
		end

		local variant, pos_multiplier = "", 1
		local craftitem, category, alternate = stairsplus:analyze_shape(node_under.name)

		if craftitem ~= nil and (category == "slope" or category == "bank_slope") then
			if alternate == "_half" then
				variant = "slope_lower"
			elseif alternate == "_half_raised" then
				variant = "slope_upper"
			elseif alternate == "_tripleslope" then
				variant = "slope_triple"
			end
			if category == "bank_slope" then
				pos_multiplier = 2
			end
		end

		local pos
		if variant == "" then
			pos = pos_above
		else
			local pos_shift
			if ndef_under.paramtype2 == "facedir" or ndef_under.paramtype2 == "colorfacedir" then
				pos_shift = facedir_group_to_shift[math.floor(node_under.param2 / 4 % 6)]
				pos_shift = vector.multiply(pos_shift, pos_multiplier)
			else
				pos_shift = vector.new(0, pos_multiplier, 0)
			end
			pos = vector.add(pos_under, pos_shift)
		end

		if minetest.is_protected(pos, player_name) then
			minetest.record_protection_violation(pos, name)
			return
		end

		local new_node
		if variant == "" then
			new_node = {
				name = "streets:mark_" .. name:gsub("{color}", "white") .. r,
				param2 = minetest.dir_to_facedir(placer:get_look_dir()) + extra_facedir + 32 * (color_index - 1),
			}
		else
			new_node = {
				name = "streets:mark_" .. name:gsub("{color}", "white") .. "_" .. variant .. r,
				param2 = (node_under.param2 % 32) + 32 * (color_index - 1),
			}
		end

		minetest.set_node(pos, new_node)

		if not minetest.is_creative_enabled(player_name) then
			itemstack:add_wear(65535 / 75)
		end
		return itemstack
	end
end

return on_place

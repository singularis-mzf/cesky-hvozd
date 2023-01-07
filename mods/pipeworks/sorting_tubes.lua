local S = minetest.get_translator("pipeworks")
local fs_helpers = pipeworks.fs_helpers

local lines = 6
local inv_width, inv_height = 12, 1

if pipeworks.enable_mese_tube then

	local output_names = {
		S("White"),
		S("Black"),
		S("Green"),
		S("Yellow"),
		S("Blue"),
		S("Red"),
	}

	local function update_formspec(pos)
		local meta = minetest.get_meta(pos)
		local old_formspec = meta:get_string("formspec")
		if string.find(old_formspec, "button1") then -- Old version
			local inv = meta:get_inventory()
			for i = 1, lines do
				for _, stack in ipairs(inv:get_list("line"..i)) do
					minetest.add_item(pos, stack)
				end
			end
		end
		local buttons_formspec = ""
		for i = 0, 5 do
			buttons_formspec = buttons_formspec .. fs_helpers.cycling_button(meta,
				"image_button[1.4,"..(i+(i*0.25)+0.5)..";1,0.6", "l"..(i+1).."s",
				{
					pipeworks.button_off,
					pipeworks.button_on
				}
			)
		end
		local list_backgrounds = ""
		if minetest.get_modpath("i3") then
			list_backgrounds = "style_type[box;colors=#666]"
			for i=0, 5 do
				for j=0, 5 do
					list_backgrounds = list_backgrounds .. "box[".. 1.5+(i*1.25) ..",".. 0.25+(j*1.25) ..";1,1;]"
				end
			end
		end
		local size = "17.5,13"
		meta:set_string("formspec",
			"formspec_version[2]"..
			"size["..size.."]"..
			pipeworks.fs_helpers.get_prepends(size)..
			"list[context;line1;2.5,0.25;"..inv_width..","..inv_height..";]"..
			"list[context;line2;2.5,1.50;"..inv_width..","..inv_height..";]"..
			"list[context;line3;2.5,2.75;"..inv_width..","..inv_height..";]"..
			"list[context;line4;2.5,4.00;"..inv_width..","..inv_height..";]"..
			"list[context;line5;2.5,5.25;"..inv_width..","..inv_height..";]"..
			"list[context;line6;2.5,6.50;"..inv_width..","..inv_height..";]"..
			list_backgrounds..
			"image[0.22,0.25;1,1;pipeworks_white.png]"..
			"image[0.22,1.50;1,1;pipeworks_black.png]"..
			"image[0.22,2.75;1,1;pipeworks_green.png]"..
			"image[0.22,4.00;1,1;pipeworks_yellow.png]"..
			"image[0.22,5.25;1,1;pipeworks_blue.png]"..
			"image[0.22,6.50;1,1;pipeworks_red.png]"..
			buttons_formspec..
			--"list[current_player;main;0,8;8,4;]" ..
			pipeworks.fs_helpers.get_inv(8, 3.75)..
			"listring[current_player;main]" ..
			"listring[current_player;main]" ..
			"listring[context;line1]" ..
			"listring[current_player;main]" ..
			"listring[context;line2]" ..
			"listring[current_player;main]" ..
			"listring[context;line3]" ..
			"listring[current_player;main]" ..
			"listring[context;line4]" ..
			"listring[current_player;main]" ..
			"listring[context;line5]" ..
			"listring[current_player;main]" ..
			"listring[context;line6]"
			)
	end

	local function update_infotext(pos)
		local meta = minetest.get_meta(pos)
		-- meta:set_string("infotext", S("Sorting pneumatic tube"))
		local infotext = {}
		for i = 1, lines do
			if meta:get_int("l"..i.."s") ~= 0 then
				local last, count = meta:get_int("last"..i), meta:get_int("count"..i)
				if infotext[1] ~= nil then
					table.insert(infotext, "\n")
				end
				table.insert(infotext, output_names[i])
				table.insert(infotext, " [")
				if last ~= 0 then
					table.insert(infotext, tostring(last))
				else
					table.insert(infotext, S("Other"))
				end
				table.insert(infotext, "]: ")
				table.insert(infotext, S("Count"))
				table.insert(infotext, " = ")
				table.insert(infotext, tostring(count))
			end
		end
		meta:set_string("infotext", table.concat(infotext))
		meta:set_float("liut", minetest.get_us_time() / 1000000)
	end

	local function update_infotext_after_second_inner(pos, node)
		local current_node = minetest.get_node(pos)
		if current_node.name ~= node.name or current_node.param2 ~= node.param2 then
			return
		end
		local meta = minetest.get_meta(pos)
		local liut = meta:get_float("liut")
		local liut_new = minetest.get_us_time() / 1000000
		if liut_new - 1.0 <= liut and liut <= liut_new then
			return
		end
		return update_infotext(pos)
	end

	local function update_infotext_after_second(pos)
		minetest.after(1, update_infotext_after_second_inner, pos, minetest.get_node(pos))
	end

	local function take_inv_item(meta, inv, list_index, stack_index)
		local listname = "line"..tostring(list_index)
		local stack = inv:get_stack(listname, stack_index)
		if stack:is_empty() then
			return stack
		end
		local last = meta:get_int("last"..tostring(list_index))
		if stack_index ~= last then
			for i = stack_index, last - 1 do
				inv:set_stack(listname, i, inv:get_stack(listname, i + 1))
			end
		end
		inv:set_stack(listname, last, ItemStack())
		meta:set_int("last"..tostring(list_index), last - 1)
		return stack
	end

	local function update_inv_meta(pos, meta, inv, i)
		local result = 0
		local listname = "line"..tostring(i)
		local list = inv:get_list(listname)
		for i = 1, #list do
			if not list[i]:is_empty() then
				result = i
			end
		end
		meta:set_int("last"..tostring(i), result)
		update_infotext(pos)
		return i
	end

	local function after_leave(pos, new_pos, stack)
		local i
		if new_pos.z > pos.z then
			i = 1
		elseif new_pos.z < pos.z then
			i = 2
		elseif new_pos.y > pos.y then
			i = 3
		elseif new_pos.y < pos.y then
			i = 4
		elseif new_pos.x > pos.x then
			i = 5
		elseif new_pos.x < pos.x then
			i = 6
		else
			return
		end
		local meta = minetest.get_meta(pos)
		local count = meta:get_int("count"..i) + 1
		meta:set_int("count"..i, count)
		update_infotext_after_second(pos)
	end

	local function tube_can_go(pos, node, velocity, stack)
		local tbl, tbln = {}, 0
		local found, foundn = {}, 0
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		local name = stack:get_name()
		for i, vect in ipairs(pipeworks.meseadjlist) do
			local npos = vector.add(pos, vect)
			local node = minetest.get_node(npos)
			local reg_node = minetest.registered_nodes[node.name]
			if meta:get_int("l"..i.."s") == 1 and reg_node then
				local tube_def = reg_node.tube
				if not tube_def or not tube_def.can_insert or tube_def.can_insert(npos, node, stack, vect) then
					local invname = "line"..i
					local is_empty = true
					local last_stack = meta:get_int("last"..i)
					for j = 1, last_stack do
						local st = inv:get_stack(invname, j)
						if not st:is_empty() then
							is_empty = false
							if st:get_name() == name then
								foundn = foundn + 1
								found[foundn] = vect
							end
						end
					end
					if is_empty then
						tbln = tbln + 1
						tbl[tbln] = vect
					end
				end
			end
		end
		return (foundn > 0) and found or tbl
	end

	pipeworks.register_tube("pipeworks:mese_tube", {
			description = S("Sorting Pneumatic Tube Segment"),
			inventory_image = "pipeworks_mese_tube_inv.png",
			noctr = {"pipeworks_mese_tube_noctr_1.png", "pipeworks_mese_tube_noctr_2.png", "pipeworks_mese_tube_noctr_3.png",
				"pipeworks_mese_tube_noctr_4.png", "pipeworks_mese_tube_noctr_5.png", "pipeworks_mese_tube_noctr_6.png"},
			plain = {"pipeworks_mese_tube_plain_1.png", "pipeworks_mese_tube_plain_2.png", "pipeworks_mese_tube_plain_3.png",
				"pipeworks_mese_tube_plain_4.png", "pipeworks_mese_tube_plain_5.png", "pipeworks_mese_tube_plain_6.png"},
			ends = { "pipeworks_mese_tube_end.png" },
			short = "pipeworks_mese_tube_short.png",
			no_facedir = true,  -- Must use old tubes, since the textures are rotated with 6d ones
			node_def = {
				tube = {
					after_leave = after_leave,
					can_go = tube_can_go,
				},
				on_construct = function(pos)
					local meta = minetest.get_meta(pos)
					local inv = meta:get_inventory()
					for i = 1, lines do
						meta:set_int("l"..tostring(i).."s", 0)
						inv:set_size("line"..tostring(i), inv_width * inv_height)
						meta:set_int("last"..tostring(i), 0)
						meta:set_int("count"..tostring(i), 0)
					end
					meta:set_float("liut", 0) -- liut == last infotext update timestamp in seconds
					update_formspec(pos)
					update_infotext(pos)
				end,
				after_place_node = function(pos, placer, itemstack, pointed_thing)
					if placer and placer:is_player() and placer:get_player_control().aux1 then
						local meta = minetest.get_meta(pos)
						for i = 1, lines do
							meta:set_int("l"..tostring(i).."s", 0)
						end
						update_formspec(pos)
						update_infotext(pos)
					end
					return pipeworks.after_place(pos, placer, itemstack, pointed_thing)
				end,
				on_punch = function(pos, node, puncher, pointed_thing)
					update_formspec(pos)
					update_infotext(pos)
				end,
				on_receive_fields = function(pos, formname, fields, sender)
					if (fields.quit and not fields.key_enter_field)
							or not pipeworks.may_configure(pos, sender) then
						return
					end
					fs_helpers.on_receive_fields(pos, fields)
					update_formspec(pos)
					update_infotext(pos)
				end,
				--[[
				can_dig = function(pos, player)
					update_formspec(pos) -- so non-virtual items would be dropped for old tubes
					return true
				end, ]]
				allow_metadata_inventory_put = function(pos, listname, index, stack, player)
					if not pipeworks.may_configure(pos, player) then return 0 end
					-- update_formspec(pos) -- For old tubes
					local meta = minetest.get_meta(pos)
					local inv = meta:get_inventory()
					local stack_copy = ItemStack(stack:get_name())
					-- stack_copy:set_count(1)
					if not inv:contains_item(listname, stack_copy) then
						inv:add_item(listname, stack_copy)
						update_inv_meta(pos, meta, inv, listname:sub(5, -1))
					end
					return 0
				end,
				allow_metadata_inventory_take = function(pos, listname, index, stack, player)
					if not pipeworks.may_configure(pos, player) then return 0 end
					-- update_formspec(pos) -- For old tubes
					local meta = minetest.get_meta(pos)
					local inv = meta:get_inventory()
					take_inv_item(meta, inv, tonumber(listname:sub(5, -1)), index)
					update_infotext(pos)
					return 0
				end,
				allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
					if not pipeworks.may_configure(pos, player) then return 0 end
					-- update_formspec(pos) -- For old tubes
					local meta = minetest.get_meta(pos)
					local inv = meta:get_inventory()

					if from_list:match("line%d") and to_list:match("line%d") then
						local item = take_inv_item(meta, inv, tonumber(from_list:sub(5, -1)), from_index)
						if not inv:contains_item(to_list, item) then
							inv:add_item(to_list, item)
						end
						update_inv_meta(pos, meta, inv, tonumber(from_list:sub(5, -1)))
						update_inv_meta(pos, meta, inv, tonumber(to_list:sub(5, -1)))
						return 0
					else
						inv:set_stack(from_list, from_index, ItemStack(""))
						return 0
					end
				end,
			},
	})

	local lbm = {
		label = "Update sorting tubes",
		name = "pipeworks:update_mesetubes",
		nodenames = {"group:tube"},
		action = function(pos, node, dtime_s)
			if node.name:match("^pipeworks:mese_tube_") then
				local meta = minetest.get_meta(pos)
				local inv = meta:get_inventory()
				if inv:get_size("line1") ~= inv_width * inv_height then
					for i = 1, lines do
						inv:set_size("line"..i, inv_width * inv_height)
					end
					update_formspec(pos)
					update_infotext(pos)
					minetest.log("action", "Sorting tube at "..minetest.pos_to_string(pos).." upgraded.")
				end
			end
		end
	}
	minetest.register_lbm(lbm)
end

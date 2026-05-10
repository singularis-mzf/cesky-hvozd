local S = core.get_translator("pipeworks")
local fs_helpers = pipeworks.fs_helpers

if not pipeworks.enable_item_tags or not pipeworks.enable_tag_tube then return end

local help_text = core.formspec_escape(
	S("Separate multiple tags using commas.").."\n"..
	S("Use \"<bez>\" to match items without tags.")
)

local output_names = {
	S("White"),
	S("Black"),
	S("Green"),
	S("Yellow"),
	S("Blue"),
	S("Red"),
}

local update_formspec = function(pos)
	local meta = core.get_meta(pos)
	local buttons_formspec = ""
	for i = 0, 5 do
		buttons_formspec = buttons_formspec .. fs_helpers.cycling_button(meta,
			"image_button[9," .. (i + (i * 0.25) + 0.5) .. ";1,0.6", "l" .. (i + 1) .. "s",
			{
				pipeworks.button_off,
				pipeworks.button_on
			}
		)
	end
	local size = "10.2,9"
	meta:set_string("formspec",
		"formspec_version[2]" ..
		"size[" .. size .. "]" ..
		pipeworks.fs_helpers.get_prepends(size) ..
		"field[1.5,0.25;7.25,1;tags1;;${tags1}]" ..
		"field[1.5,1.5;7.25,1;tags2;;${tags2}]" ..
		"field[1.5,2.75;7.25,1;tags3;;${tags3}]" ..
		"field[1.5,4.0;7.25,1;tags4;;${tags4}]" ..
		"field[1.5,5.25;7.25,1;tags5;;${tags5}]" ..
		"field[1.5,6.5;7.25,1;tags6;;${tags6}]" ..

		"image[0.22,0.25;1,1;pipeworks_white.png]" ..
		"image[0.22,1.50;1,1;pipeworks_black.png]" ..
		"image[0.22,2.75;1,1;pipeworks_green.png]" ..
		"image[0.22,4.00;1,1;pipeworks_yellow.png]" ..
		"image[0.22,5.25;1,1;pipeworks_blue.png]" ..
		"image[0.22,6.50;1,1;pipeworks_red.png]" ..
		buttons_formspec ..
		"label[0.22,7.9;"..help_text.."]"..
		"button[7.25,7.8;1.5,0.8;set_item_tags;" .. S("Set") .. "]"
	)
end

	local function update_infotext(pos)
		local meta = minetest.get_meta(pos)
		-- meta:set_string("infotext", S("Sorting pneumatic tube"))
		local infotext = {}
		for i = 1, 6 do
			if meta:get_int("l"..i.."s") ~= 0 then
				local last, count = meta:get_int("last"..i), meta:get_int("count"..i)
				if infotext[1] ~= nil then
					table.insert(infotext, "\n")
				end
				table.insert(infotext, output_names[i])
				table.insert(infotext, " [")
				table.insert(infotext, meta:get_string("tags"..i))
				table.insert(infotext, "]: ")
				table.insert(infotext, S("Count"))
				table.insert(infotext, " = ")
				table.insert(infotext, tostring(count))
			end
		end
		meta:set_string("infotext", table.concat(infotext))
		meta:set_float("liut", core.get_us_time() / 1000000)
	end

	local function update_infotext_after_second_inner(pos, node)
		local current_node = core.get_node(pos)
		if current_node.name ~= node.name or current_node.param2 ~= node.param2 then
			return
		end
		local meta = core.get_meta(pos)
		local liut = meta:get_float("liut")
		local liut_new = core.get_us_time() / 1000000
		if liut_new - 1.0 <= liut and liut <= liut_new then
			return
		end
		return update_infotext(pos)
	end

	local function update_infotext_after_second(pos)
		core.after(1, update_infotext_after_second_inner, pos, core.get_node(pos))
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
		local meta = core.get_meta(pos)
		local count = meta:get_int("count"..i) + 1
		meta:set_int("count"..i, count)
		update_infotext_after_second(pos)
	end

pipeworks.register_tube("pipeworks:tag_tube", {
	description = S("Tag Sorting Pneumatic Tube Segment (priority @1)", 50),
	inventory_image = "pipeworks_tag_tube_inv.png",
	noctr = { "pipeworks_tag_tube_noctr_1.png", "pipeworks_tag_tube_noctr_2.png", "pipeworks_tag_tube_noctr_3.png",
		"pipeworks_tag_tube_noctr_4.png", "pipeworks_tag_tube_noctr_5.png", "pipeworks_tag_tube_noctr_6.png" },
	plain = { "pipeworks_tag_tube_plain_1.png", "pipeworks_tag_tube_plain_2.png", "pipeworks_tag_tube_plain_3.png",
		"pipeworks_tag_tube_plain_4.png", "pipeworks_tag_tube_plain_5.png", "pipeworks_tag_tube_plain_6.png" },
	ends = { "pipeworks_tag_tube_end.png" },
	short = "pipeworks_tag_tube_short.png",
	no_facedir = true, -- Must use old tubes, since the textures are rotated with 6d ones
	node_def = {
		tube = {
			after_leave = after_leave,
			can_go = function(pos, node, velocity, stack, tags)
				local tbl, tbln = {}, 0
				local found, foundn = {}, 0
				local meta = core.get_meta(pos)
				local tag_hash = {}
				if #tags > 0 then
					for _,tag in ipairs(tags) do
						tag_hash[tag] = true
					end
				else
					tag_hash["<bez>"] = true  -- Matches items without tags
				end
				for i, vect in ipairs(pipeworks.meseadjlist) do
					local npos = vector.add(pos, vect)
					local node = core.get_node(npos)
					local reg_node = core.registered_nodes[node.name]
					if meta:get_int("l" .. i .. "s") == 1 and reg_node then
						local tube_def = reg_node.tube
						if not tube_def or not tube_def.can_insert or
							tube_def.can_insert(npos, node, stack, vect) then
							local side_tags = meta:get_string("tags" .. i)
							if side_tags ~= "" then
								side_tags = pipeworks.sanitize_tags(side_tags)
								for _,tag in ipairs(side_tags) do
									if tag_hash[tag] then
										foundn = foundn + 1
										found[foundn] = vect
										break
									end
								end
							else
								tbln = tbln + 1
								tbl[tbln] = vect
							end
						end
					end
				end
				return (foundn > 0) and found or tbl
			end
		},
		on_construct = function(pos)
			--[[
			local meta = core.get_meta(pos)
			for i = 1, 6 do
				meta:set_int("l" .. tostring(i) .. "s", 1)
			end
			]]
			update_formspec(pos)
			update_infotext(pos)
		end,
		after_place_node = function(pos, placer, itemstack, pointed_thing)
			if placer and placer:is_player() and placer:get_player_control().aux1 then
				local meta = core.get_meta(pos)
				for i = 1, 6 do
					meta:set_int("l" .. tostring(i) .. "s", 0)
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

			local meta = core.get_meta(pos)
			for i = 1, 6 do
				local field_name = "tags" .. tostring(i)
				if fields[field_name] then
					local tags = pipeworks.sanitize_tags(fields[field_name])
					meta:set_string(field_name, table.concat(tags, ","))
				end
			end

			fs_helpers.on_receive_fields(pos, fields)
			update_formspec(pos)
			update_infotext(pos)
		end,
		--[[
		can_dig = function(pos, player)
			return true
		end,
		]]
	},
})

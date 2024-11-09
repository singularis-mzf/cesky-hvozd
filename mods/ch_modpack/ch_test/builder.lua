-- :ch_extras:builder
---------------------------------------------------------------
local xyz = {"x", "y", "z"}
local function builder_callback(custom_state, player, formname, fields)
	local pos = custom_state.pos
	local node = minetest.get_node(pos)
	if node.name ~= "ch_extras:builder" or not fields.save then
		return
	end
	local meta = minetest.get_meta(pos)
	for _, coord in ipairs(xyz) do
		local n = fields["shift_"..coord]
		if n ~= nil then
			n = tonumber(n)
			if n ~= nil then
				n = math.floor(n)
				if -2 <= n and n <= 2 then
					meta:set_int("shift_"..coord, n)
				end
			end
		end
		n = fields["hl_"..coord]
		if n ~= nil then
			n = tonumber(n)
			if n ~= nil then
				n = math.floor(n)
				if -2 <= n and n <= 2 then
					meta:set_int("hl_"..coord, n)
				end
			end
		end
	end
end

local function builder_on_rightclick(pos, node, clicker, itemstack, pointed_thing)
	local player_name = clicker and clicker:get_player_name()
	if player_name == nil then
		minetest.log("warning", "null clicker right-clicked to the builder "..node.name.." at "..minetest.pos_to_string(pos).."!")
		return
	end
	if minetest.is_protected(pos, player_name) then
		minetest.record_protection_violation(pos, player_name)
		return
	end
	local meta = minetest.get_meta(pos)
	if clicker:get_player_control().aux1 then
		-- show the formspec
		local formspec = {
			"formspec_version[4]",
			"size[6,6]",
			"label[0.5,0.5;Univerzální stavební modul]",
			"label[0.5,1.0;Posun po stavbě:]",
			"field[0.5,1.5;0.9,0.5;shift_x;X;",
			tostring(meta:get_int("shift_x")),
			"]",
			"field[1.5,1.5;0.9,0.5;shift_y;Y;",
			tostring(meta:get_int("shift_y")),
			"]",
			"field[2.5,1.5;0.9,0.5;shift_z;Z;",
			tostring(meta:get_int("shift_z")),
			"]",
			"label[0.5,2.5;Umístění stavební hlavice vůči modulu:]",
			"field[0.5,3.0;0.9,0.5;hl_x;X;",
			tostring(meta:get_int("hl_x")),
			"]",
			"field[1.5,3.0;0.9,0.5;hl_y;Y;",
			tostring(meta:get_int("hl_y")),
			"]",
			"field[2.5,3.0;0.9,0.5;hl_z;Z;",
			tostring(meta:get_int("hl_z")),
			"]",
			"button_exit[1.5,4.5;2.25,0.75;save;Uložit]",
		}
		formspec = table.concat(formspec)
		ch_core.show_formspec(clicker, "ch_extras:builder_settings", formspec, builder_callback, {pos = pos}, {})
	else
		-- build
		local hlavice_under = vector.offset(pos, meta:get_int("hl_x"), meta:get_int("hl_y"), meta:get_int("hl_z"))
		local hlavice_above = vector.copy(hlavice_under)
		for _, coord in ipairs({"y", "x", "z", ""}) do
			if coord == "" then
				hlavice_above.y = hlavice_above.y + 1
				break
			elseif hlavice_under[coord] < pos[coord] then
				hlavice_above[coord] = hlavice_above[coord] + 1
				break
			elseif hlavice_under[coord] > pos[coord] then
				hlavice_above[coord] = hlavice_above[coord] - 1
				break
			end
		end
		print("LADĚNÍ: "..dump2({
			pos = pos,
			hlavice_under = minetest.pos_to_string(hlavice_under),
			hlavice_above = minetest.pos_to_string(hlavice_above),
			}))
		local ndef = minetest.registered_items[itemstack:get_name()]
		if not ndef then
			minetest.log("warning", "Builder module used with unknown item '"..itemstack:get_name().."'!")
			return
		end
		local place_result = (ndef.on_place or minetest.item_place)(itemstack, clicker, {
			type = "node", above = hlavice_above, under = hlavice_under})
		print("LADĚNÍ: place_result = "..dump2(place_result))
		-- [ ] TODO: ...
	end
end

def = {
	description = "univerzální stavební modul (experimentální)",
	tiles = {"ch_core_white_pixel.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {dig_immediate = 2},
	sounds = default.node_sound_stone_defaults(),
	after_place_node = function(pos, placer, itemstack, pointed_thing)
		local player_name = placer and placer:get_player_name()
		local meta = minetest.get_meta(pos)
		if player_name ~= nil then
			meta:set_string("owner", player_name)
		end
		meta:set_int("hl_y", -1)
	end,
	-- on_rightclick = builder_on_rightclick,
}

-- minetest.register_node(":ch_extras:builder", def)

-- TODO: Možnost zamykání.
-- TODO: Možnost duplikace a slučování.

-- CACHED FUNCTIONS
local F = minetest.formspec_escape
local S = minetest.get_translator("orienteering")
local get_item_group = minetest.get_item_group

-- CONSTANT DATA
local barvy = {
	{ description = "bílá", color = 0xffffff },
	{ description = "červená", color = 0xdd0000 },
	{ description = "modrá", color = 0x2c4df1 },
	{ description = "zelená", color = 0x2cf136 },
	{ description = "žlutá", color = 0xf1d32c },
}
local barvy_text
local barvy_color_to_index
local cisla = {1, 2, 3, 4, 5, 6, 7, 8, 9}
local xy_00 = {x = 0, y = 0}
local default_player_form = {name = "", number = 1, color_index = 1}
local item_description = "Builder Compass (unset)"
local item_description_N = "Builder Compass @1"
local ch_help = "Je-li na výběrové liště, ukazuje směr do jednoho nebo více uložených cílů.\nLevým kliknutím vyvoláte formulář pro změnu názvu či pozice cíle."
local ch_help_group = "o:bc"

barvy_text = {}
barvy_color_to_index = {}
for i, d in ipairs(barvy) do
	barvy_text[i] = F(d.description)
	-- print("DEBUG: will set barvy_color_to_index["..d.color.."] = "..i)
	barvy_color_to_index[d.color] = i
end
barvy_text = table.concat(barvy_text, ",")

-- VARIABLE DATA
local player_huds = {} -- player_name = {compass_hash = {hud_id, ...}}
local player_forms = {} -- player_name = {name = string, number = 1..9, color_index = 1..N}

-- JOIN/LEAVE PLAYER
minetest.register_on_joinplayer(function(player, last_login)
	player_huds[player:get_player_name()] = {}
end)

minetest.register_on_leaveplayer(function(player, timed_out)
	local player_name = player:get_player_name()
	-- local huds_to_remove_by_hash = player_huds[player_name]
	player_huds[player_name] = nil
	--[[ for hash, huds_to_remove in pairs(huds_to_remove_by_hash) do
		for _, hud_id in ipairs(huds_to_remove) do
			player:hud_remove(hud_id)
		end
	end ]]
end)

-- LOCAL FUNCTIONS
local function get_current_pos(player)
	local result = player:get_pos()
	-- result.y = result.y + 1
	return vector.round(result)
end

local function new_target(name, color_index, pos)
	-- print("new_target("..name..", "..color_index.." (=> "..barvy[color_index].color.."),"..minetest.pos_to_string(pos)..")")
	return {name = name, color = barvy[color_index].color, pos = pos}
end

-- number = compass number (1..9)
-- data = list of compass targets
local function serialize_compass(number, targets)
	if number < 1 or number > 9 or number ~= math.floor(number) or type(targets) ~= "table" then
		minetest.log("error", "serialize_compass() called with invalid arguments: "..dump2({number, targets}))
		return ItemStack()
	end
	local result = ItemStack("orienteering:builder_compass_"..number)
	local meta = result:get_meta()
	-- print("DEBUG: Will serialize compass with these targets: "..dump2(targets))
	local bc_data = minetest.serialize(targets)
	local bc_data_hash = minetest.sha1(bc_data, true)
	local bc_data_hash_int = string.byte(bc_data_hash, 1)
	bc_data_hash_int = 256 * bc_data_hash_int + string.byte(bc_data_hash, 2)
	bc_data_hash_int = 256 * bc_data_hash_int + string.byte(bc_data_hash, 3)
	bc_data_hash_int = 128 * bc_data_hash_int + math.floor(string.byte(bc_data_hash, 4) / 2)
	meta:set_string("bc_data", bc_data)
	meta:set_int("bc_hash", bc_data_hash_int)

	-- description
	local target_names = {}
	for i, position in ipairs(targets) do
		if targets[i].name ~= "" then
			table.insert(target_names, targets[i].name)
		end
	end
	if #target_names == 0 then
		-- no targets
		meta:set_string("description", S(item_description_N, tostring(number)))
	else
		local new_description = ch_core.utf8_truncate_right(table.concat(target_names, ", "), 80).." ["..S(item_description_N, tostring(number)).."]"
		meta:set_string("description", new_description)
	end

	minetest.log("info", "Builder compass targets serialized with hash "..bc_data_hash_int)
	-- print("Builder compass targets serialized with hash "..bc_data_hash_int)
	return result
end

local function deserialize_compass(itemstack)
	-- => 0, nil or number, {{name, color, pos}...}
	if not itemstack or itemstack:is_empty() then
		return 0, nil
	end
	local number = get_item_group(itemstack:get_name(), "builder_compass")
	if number == 0 then
		return 0, nil
	end
	local meta = itemstack:get_meta()
	local data = meta:get_string("bc_data")
	if data ~= "" then
		return number, minetest.deserialize(data)
	else
		return number, {}
	end
end

local function show_bc_formspec(player_name, options)
	local form_data = player_forms[player_name] or default_player_form
	local formspec = {
		"formspec_version[4]",
		"size[8,7]",
		"label[0.375,0.5;", F("Stavitelský kompas"), "]",
		"field[0.375,1.5;7.0,0.5;name;", F("Titulek:"), ";", F(form_data.name), "]",
		"label[0.375,2.35;", F("Číslo:"), "]",
		"dropdown[0.375,2.5;1.0,0.5;number;1,2,3,4,5,6,7,8,9;", form_data.number, "]",
		"label[1.5,2.35;", F("Barva:"), "]",
		"dropdown[1.5,2.5;3.0,0.5;color;", barvy_text, ";", form_data.color_index, ";true]",
		"button_exit[0.375,4.9;3.5,0.75;save;Uložit nastavení]",
		"button_exit[4.125,4.9;3.5,0.75;close;Zavřít]",
		"button[0.375,5.9;3.5,0.75;sethere;Nastavit cíl sem]",
		"button[4.125,5.9;3.5,0.75;coords;Souřadnice do titulku]",
	}

	if options then
		if options.has_more_targets then
			table.insert(formspec, "label[0.375,3.5;")
			table.insert(formspec, F("Varování: tento kompas je nastaven na více cílů;"))
			table.insert(formspec, "]")
			table.insert(formspec, "label[0.375,3.9;")
			table.insert(formspec, F("pokud nyní uložíte nastavení, bude zachován"))
			table.insert(formspec, "]")
			table.insert(formspec, "label[0.375,4.3;")
			table.insert(formspec, F("jen první z nich!"))
			table.insert(formspec, "]")
		elseif options.target_set then
			table.insert(formspec, "label[0.375,3.5;")
			table.insert(formspec, F("Cíl nastaven na:"))
			table.insert(formspec, "]")
			table.insert(formspec, "label[0.375,3.9;")
			table.insert(formspec, F(minetest.pos_to_string(options.target_set)))
			table.insert(formspec, "]")
		end
	end
	return minetest.show_formspec(player_name, "orienteering:builder_compass", table.concat(formspec))
end

local function bc_on_use(itemstack, player, pointed_thing)
	local player_name = player and player:get_player_name()
	if not player_name then
		return
	end
	local inv = player:get_inventory()
	if not inv then
		return
	end
	local witem = inv:get_stack("main", player:get_wield_index()) or ItemStack()
	local number, targets = deserialize_compass(witem)
	if number == 0 then
		minetest.log("warning", "bc_on_use() called on itemstack of "..(witem:get_name()))
		return
	end
	if not targets[1] then
		targets[1] = new_target("", 1, get_current_pos(player))
	end
	player_forms[player_name] = {
		name = targets[1].name,
		number = number,
		color_index = barvy_color_to_index[tonumber(targets[1].color) or ""] or 1,
	}
	show_bc_formspec(player_name, { has_more_targets = targets[2] })
end

local function on_player_receive_fields(player, formname, fields)
	if formname ~= "orienteering:builder_compass" then
		return false
	end
	local player_name = player:get_player_name()
	if fields.close then
		player_forms[player_name] = nil
	end
	if fields.close or not (fields.coords or fields.sethere or fields.save) then
		return true
	end
	-- print("DEBUG: on_player_receive_fields(): "..dump2(fields))

	local current_form = player_forms[player_name]
	if not current_form then
		current_form = table.copy(default_player_form)
		player_forms[player_name] = current_form
	end

	-- update current_form from fields
	if fields.name then
		current_form.name = ch_core.utf8_truncate_right(fields.name, 40)
	end

	if fields.number then
		local new_number = tonumber(fields.number)
		if new_number then
			new_number = math.floor(new_number)
			if 1 <= new_number and new_number <= 9 then
				current_form.number = new_number
			end
		end
	end

	if fields.color then
		local new_color_index = tonumber(fields.color)
		if new_color_index then
			new_color_index = math.floor(new_color_index)
			if 1 <= new_color_index and new_color_index <= #barvy then
				current_form.color_index = new_color_index
			end
		end
	end

	-- find and deserialize the compass
	local inv = player:get_inventory()
	if not inv then
		return false
	end
	local windex = player:get_wield_index()
	local witem = inv:get_stack("main", windex) or ItemStack()
	local number, targets = deserialize_compass(witem)
	if number == 0 then
		minetest.log("warning", "on_player_receive_fields for orienteering:bcompass called on itemstack of "..witem:get_name().." for player "..player_name)
		return true
	end

	-- serve the buttons (except for "close")
	if fields.coords then
		local pos_string = minetest.pos_to_string((targets[1] and targets[1].pos) or get_current_pos(player))
		if current_form.name == "" then
			current_form.name = pos_string
		else
			current_form.name = current_form.name.." "..pos_string
		end
		show_bc_formspec(player_name, { has_more_targets = targets[2] })
	elseif fields.sethere then
		if targets[1] then
			targets[1].pos = get_current_pos(player)
			if targets[2] then
				targets = {targets[1]}
			end
		else
			targets[1] = new_target("", 1, get_current_pos(player))
		end
		inv:set_stack("main", windex, serialize_compass(number, targets))
		show_bc_formspec(player_name, { target_set = targets[1].pos })
	elseif fields.save then
		-- print("DEBUG: "..dump(current_form))
		targets[1] = new_target(current_form.name, current_form.color_index, (targets[1] and targets[1].pos) or get_current_pos(player))
		if targets[2] then
			targets = {targets[1]}
		end
		inv:set_stack("main", windex, serialize_compass(current_form.number, targets))
	end
	return true
end
minetest.register_on_player_receive_fields(on_player_receive_fields)

-- PUBLIC FUNCTIONS
local function update_bc_player_huds(player)
	local player_name = player:get_player_name()
	local current_huds_by_hash = player_huds[player_name]
	if not current_huds_by_hash then
		return false -- player probably not online
	end

	local inv = player:get_inventory()
	local hotbar = inv and inv:get_list("main")
	if not hotbar then
		return result
	end
	local hotbar_length = player:hud_get_hotbar_itemcount()

	if not hotbar_length then
		hotbar_length = 8
	elseif hotbar_length > 32 then
		hotbar_length = 32
	elseif hotbar_length < 1 then
		hotbar_length = 1
	end

	local huds_to_remove_by_hash = table.copy(current_huds_by_hash)
	local huds_to_add_by_hash

	-- scan for builder compasses in the hotbar
	for i = 1, hotbar_length, 1 do
		local name = hotbar[i]:get_name()
		if get_item_group(name, "builder_compass") > 0 then
			local meta = hotbar[i]:get_meta()
			local hash = meta:get_int("bc_hash")
			if hash ~= 0 then
				if hash < 0 then
					minetest.log("warning", "Negative hash: "..hash)
				end
				if current_huds_by_hash[hash] then
					huds_to_remove_by_hash[hash] = nil -- HUDs for this compass still exist
				else
					local huds_to_add = {}
					local number, data = deserialize_compass(hotbar[i])
					minetest.log("verbose", "deserialize_compass() results: "..number..", "..type(data))
					if number > 0 then
						for _, position in ipairs(data) do
							local hud_def = {
								-- constant fields:
								hud_elem_type = "waypoint",
								alignment = xy_00,
								z_index = -300,
								text = " m",
								-- precision = 1,
								-- variable fields:
								name = position.name,
								world_pos = position.pos,
								number = position.color,
							}
							table.insert(huds_to_add, hud_def)
						end
					end
					-- insert the list of new HUDs to huds_to_add_by_hash
					if #huds_to_add > 0 then
						if not huds_to_add_by_hash then
							huds_to_add_by_hash = {}
						end
						huds_to_add_by_hash[hash] = huds_to_add
						minetest.log("verbose", "insert hash "..hash.." to huds_to_add_by_hash")
					end
				end
			end -- if hash > 0
		end
	end -- for each item on hotbar

	-- remove HUDs that should no longer exit
	for hash, huds_to_remove in pairs(huds_to_remove_by_hash) do
		-- print("will remove "..#huds_to_remove.." HUDs for hash "..hash)
		minetest.log("info", "will remove "..#huds_to_remove.." HUDs for hash "..hash)
		for _, hud_id in ipairs(huds_to_remove) do
			player:hud_remove(hud_id)
		end
		current_huds_by_hash[hash] = nil
	end

	-- create new HUDs
	if huds_to_add_by_hash then -- huds_to_add_by_hash is nil if there are no HUDs to add
		for hash, hud_defs in pairs(huds_to_add_by_hash) do
			local new_hud_ids = {}
			current_huds_by_hash[hash] = new_hud_ids
			-- print("will create "..#hud_defs.." HUDs for hash"..hash)
			minetest.log("info", "will create "..#hud_defs.." HUDs for hash"..hash)
			for i, hud_def in ipairs(hud_defs) do
				new_hud_ids[i] = player:hud_add(hud_def)
			end
		end
	end

	return true
end

-- ITEMS REGISTRATION

for i = 1, 9 do
	local groups = {builder_compass = i}
	if i > 1 then
		groups.not_in_creative_inventory = 1
	end
	minetest.register_tool("orienteering:builder_compass_"..i, {
		description = S(item_description),
		_ch_help = ch_help,
		_ch_help_group = ch_help_group,
		wield_image = "orienteering_compass_wield.png^ch_core_"..i..".png",
		inventory_image = "orienteering_compass_inv.png^ch_core_"..i..".png",
		stack_max = 1,
		on_use = bc_on_use,
		groups = groups,
	})
end

-- CRAFT

minetest.register_craft({
	output = "orienteering:builder_compass_1",
	recipe = {
		{"orienteering:compass","default:mese_crystal_fragment"},
		{"default:mese_crystal_fragment", "default:mese_crystal_fragment"},
	},
})

return update_bc_player_huds

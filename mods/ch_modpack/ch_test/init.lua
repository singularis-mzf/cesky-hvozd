print("[MOD BEGIN] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")

local ui = unified_inventory
local F = minetest.formspec_escape

--[[
local function apply_filter(player, formname, fields, menu_def)
	ui.apply_filter(player, menu_def.filter_group, "nochange")
	minetest.sound_play("paperflip2", {to_player = player:get_player_name(), gain = 1.0})
end

local menu_items = {
	{
		id = "na_kp",
		title = "na kotoučovou pilu",
		label = "KP",
		item_for_icon = "moreblocks:circular_saw",
		func = apply_filter,
		filter_group = "group:na_kp",
	},
	{
		id = "na_kp2",
		title = "jen test",
		label = "",
		item_for_icon = "moreblocks:circular_saw",
		func = apply_filter,
		filter_group = "group:seed",
	},
}

ui.register_button("test_form", {
	type = "image",
	image = "ui_craft_icon.png",
	tooltip = "Test Form"
})

local function get_test_form_formspec(player, perplayer_formspec)
	local player_name = player:get_player_name()
	local button_size = perplayer_formspec.btn_size
	local formspec = {
	"label["..perplayer_formspec.form_header_x..","..perplayer_formspec.form_header_y..";"..F("Testovací volby").."]",
		ui.style_full.standard_inv_bg,
	}

	local x_base = perplayer_formspec.form_header_x
	local y_base = perplayer_formspec.form_header_y + 0.5
	local x = 0
	local y = 0
	local scale = button_size * 1.1
	for _, item_def in ipairs(menu_items) do
		if minetest.registered_items[item_def.item_for_icon] then
			table.insert(formspec, string.format("item_image_button[%f,%f;%f,%f;%s;%s;%s]tooltip[%s;%s]",
				x_base + x * scale, y_base + y * scale, button_size, button_size,
				item_def.item_for_icon, "test_form_"..item_def.id, item_def.label or "", "test_form_"..item_def.id, F(item_def.title)))
			x = x + 1
		end
	end
	return {formspec = table.concat(formspec)}
end

ui.register_page("test_form", {get_formspec = get_test_form_formspec})

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "" then
		return
	end

	for k, v in pairs(fields) do
		print("Will "..k.." match ^test_form_? ")
		if k:match("^test_form_") then
			local player_name = player:get_player_name()
			for _, item_def in ipairs(menu_items) do
				if k == "test_form_" .. item_def.id then
					if item_def.func then
						item_def.func(player, formname, fields, item_def)
					end
				end
			end
			-- ui.activefilter[player_name] = "group:na_kp"
			-- ui.apply_filter(player, "group:na_kp", "nochange")
			-- ui.set_inventory_formspec(player, ui.current_page[player_name])
			-- return
		else
			print("No match.")
		end
	end
end)
]]





















-- ARRAY STATS

local function array_stats(name, table)
	if not table then
		return name..":nil"
	end

	local count = 0
	local longest = ""
	local count_per_mod = {}
	local i, m, k2

	for k, _ in pairs(table) do
		i = string.find(k, ":")
		if i then
			m = k:sub(1, i - 1)
		else
			m = ""
		end
		count = count + 1
		count_per_mod[m] = (count_per_mod[m] or 0) + 1
		k2 = k..""
		if #k2 > #longest then
			longest = k2
		end
	end

	local mods_count = 0
	local mod_with_most_name = ""
	local mod_with_most_count = 0
	for mod, count in pairs(count_per_mod) do
		mods_count = mods_count + 1
		if count > mod_with_most_count then
			mod_with_most_name = mod
			mod_with_most_count = count
		end
	end

	return name..": "..count.." items of "..mods_count.." mods (most "..mod_with_most_count.." from mod "..mod_with_most_name.."), longest = "..longest
end

local function on_mods_loaded()
	print("Will do registered stats...")
	print(array_stats("registered_nodes", minetest.registered_nodes))
	print("----")
	print(array_stats("registered_items", minetest.registered_items))
	print(array_stats("registered_craftitems", minetest.registered_craftitems))
	print(array_stats("registered_tools", minetest.registered_tools))
	print(array_stats("registered_aliases", minetest.registered_aliases))
	print(array_stats("registered_entities", minetest.registered_entities))
	print(array_stats("registered_abms", minetest.registered_abms))
	print(array_stats("registered_lbms", minetest.registered_lbms))
	print(array_stats("registered_ores", minetest.registered_ores))
	print(array_stats("registered_decorations", minetest.registered_decorations))
end

minetest.register_on_mods_loaded(on_mods_loaded)

print("[MOD END] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")


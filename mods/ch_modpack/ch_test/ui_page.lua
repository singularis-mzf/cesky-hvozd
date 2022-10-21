local ui = unified_inventory
local F = minetest.formspec_escape

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

--[[
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

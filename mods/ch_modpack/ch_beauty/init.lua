ch_base.open_mod(minetest.get_current_modname())

local groups_clothing = {clothing = 1}

local hair_colors = {
	{"blond", "D7C58C", "blond dlouhé vlasy"},
	{"cerne", "16120D", "černé dlouhé vlasy"},
	{"hnede", "2F1002", "hnědé dlouhé vlasy"},
	{"plave", "DAD2B7", "plavé dlouhé vlasy"},
	{"rysave", "9A3A1F", "ryšavé dlouhé vlasy"},
	{"sede", "EAEAEA", "šedé dlouhé vlasy"},
	{"svhnede", "B48655", "světle hnědé dlouhé vlasy"},
}

for _, hcolor in ipairs(hair_colors) do
	minetest.register_craftitem("ch_beauty:dlvlasy_"..hcolor[1], {
		description = hcolor[3],
		inventory_image = "ch_beauty_dlvlasy_inv.png^[multiply:#"..hcolor[2],
		uv_image = "(ch_beauty_dlvlasy.png^[multiply:#"..hcolor[2]..")",
		stack_max = 1,
		groups = groups_clothing,
		_hair_color = "#"..hcolor[2],
	})
end

local function get_player_hair_color(player)
	if player == nil then return end
	local skin = skins.get_player_skin(player)
	if skin == nil then return end
	skin = skin:get_key()
	local result, count = string.gsub(skin, "^character_[^_][^_]_[^_]+_([^_]+)_.*$", "%1")
	if count == 1 then
		return result
	end
end

local function get_clothing_inventory(player_name)
	return minetest.get_inventory{
		type = "detached",
		name = player_name.."_clothing",
	}
end

local function add_hair(player_name, hair_color, is_simulation)
	if not minetest.registered_items["ch_beauty:dlvlasy_"..hair_color] then
		minetest.log("error", "Long hair not available (ch_beauty:dlvlasy_"..hair_color..")")
		return false, "vnitřní chyba: dlouhé vlasy této barvy nejsou implementovány"
	end
	local player = minetest.get_player_by_name(player_name)
	if player == nil then
		return false, "postava není ve hře"
	end
	local inv = minetest.get_inventory{
		type = "detached",
		name = player_name.."_clothing",
	}
	if inv == nil then
		return false, "vnitřní chyba: nenalezen inventář oblečení"
	end
	local list = inv:get_list("clothing")
	for _, stack in ipairs(list) do
		if not stack:is_empty() and stack:get_name():sub(1, 10) == "ch_beauty:" then
			return false, "vaše postava už má dlouhé vlasy; pokud chcete další, musíte si ty stávající nejdřív sundat"
		end
	end
	local hair_stack = ItemStack("ch_beauty:dlvlasy_"..hair_color)
	local success
	if is_simulation then
		success = inv:room_for_item("clothing", hair_stack)
	else
		success = clothing:add_clothing(player, hair_stack):is_empty()
	end
	if success then
		return true
	else
		return false, "v inventáři oblečení na dlouhé vlasy není dost místa!"
	end
end

local function f(xmin, xmax, ymin, ymax, zmin, zmax)
	return {xmin, ymin, zmin, xmax, ymax, zmax}
end

local function get_finish_func(player_name)
	return function()
		local player = minetest.get_player_by_name(player_name)
		if player == nil then
			return
		end
		local hair_color = get_player_hair_color(player)
		if hair_color == nil then
			ch_core.systemovy_kanal(player_name, "CHYBA: váš nastavený vzhled postavy nemá systémovou barvu vlasů; dlouhé vlasy pro tyto postavy nejsou podporovány; zkuste nejprve změnit vzhled postavy (a nezapomeňte mít na sobě nějaké oblečení)")
			return
		end
		local success, message = add_hair(player_name, hair_color, false)
		if success then
			ch_core.systemovy_kanal(player_name, "Vaše dlouhé vlasy jsou hotové! Vyzkoušejte si, jak s nimi vypadáte.")
		elseif message ~= nil then
			ch_core.systemovy_kanal(player_name, "CHYBA: "..message)
		end
	end
end

local function step_3(player_name, pos)
	local player = minetest.get_player_by_name(player_name)
	local online_charinfo = ch_data.online_charinfo[player_name]
	if player == nil or online_charinfo == nil or not ch_core.is_ch_timer_running(online_charinfo, "ch_beauty") then return end
	local player_pos = player:get_pos()

	if
		math.abs(player_pos.x - pos.x) > 0.5 or
		math.abs(player_pos.y - pos.y) > 0.5 or
		math.abs(player_pos.z - pos.z) > 0.5
	then
		ch_core.cancel_ch_timer(online_charinfo, "ch_beauty")
		ch_core.systemovy_kanal(player_name, "Úprava vlasů přerušena.")
	else
		minetest.after(1, step_3, player_name, pos)
	end
end

local function step_2(player_name, pos, pos_below, hair_item)
	local hair_def = minetest.registered_items[hair_item]
	if hair_def == nil then
		return
	end
	local player = minetest.get_player_by_name(player_name)
	local online_charinfo = ch_data.online_charinfo[player_name]
	if player == nil or online_charinfo == nil then return end
	local player_pos = player:get_pos()
	if
		math.abs(player_pos.x - pos_below.x) > 0.5 or
		math.abs(player_pos.y - pos_below.y) > 0.5 or
		math.abs(player_pos.z - pos_below.z) > 0.5
	then
		minetest.log("warning", "ch_beauty:nastavec failed at "..minetest.pos_to_string(pos)..", because the player "..player_name.." is not on expected position "..minetest.pos_to_string(pos_below)..", but at "..minetest.pos_to_string(player_pos).."! node_below is "..dump2(minetest.get_node(pos_below)))
		ch_core.systemovy_kanal(player_name, "CHYBA: selhalo sedání na židli či komunikace s kadeřnickým nástavcem; informujte prosím Administraci, ať to opraví")
		return
	end

	ch_core.start_ch_timer(online_charinfo, "ch_beauty", 180, {
		label = "úprava vlasů",
		func = get_finish_func(player_name),
		hudbar_icon = hair_def.inventory_image,
		hudbar_bar = "hudbars_bar_timer.png^[multiply:"..hair_def._hair_color,
	})
	minetest.after(1, step_3, player_name, player_pos)
end

local function on_rightclick(pos, node, clicker, itemstack, pointed_thing)
	local player_name = clicker and clicker:get_player_name()
	if player_name == nil or player_name == "" then return end
	local pos_below = vector.offset(pos, 0, -1, 0)
	local node_below = minetest.get_node(pos_below)
	local ndef = minetest.registered_nodes[node_below.name]
	if node_below.name == "ignore" or ndef == nil or ndef.on_rightclick == nil then
		ch_core.systemovy_kanal(player_name, "CHYBA: pod nástavcem chybí místo k sezení!")
		return
	end
	local hair_color = get_player_hair_color(clicker)
	if hair_color == nil then
		ch_core.systemovy_kanal(player_name, "CHYBA: váš nastavený vzhled postavy nemá systémovou barvu vlasů; dlouhé vlasy pro tyto postavy nejsou podporovány; zkuste nejprve změnit vzhled postavy (a nezapomeňte mít na sobě nějaké oblečení)")
		return
	end
	local success, message = add_hair(player_name, hair_color, true)
	if not success then
		if message ~= nil then
			ch_core.systemovy_kanal(player_name, "CHYBA: "..message)
		end
		return
	end
	local result = ndef.on_rightclick(table.copy(pos_below), node_below, clicker, itemstack, pointed_thing)
	minetest.after(0.5, step_2, player_name, pos, pos_below, "ch_beauty:dlvlasy_"..hair_color)
	return result
end

local function on_construct(pos)
	minetest.get_meta(pos):set_string("infotext", "kadeřnický nástavec na hlavu\npravý klik + 3 minuty sezení vklidu = nové dlouhé vlasy")
end

local x_min, x_max = -5/16, 5/16
local y_min, y_max = -5/16, 5/16
local z_min, z_max = -3/16, 5/16

local def = {
	description = "kadeřnický nástavec",
	drawtype = "nodebox",
	tiles = {{name = "default_pine_wood.png", align_style = "world", backface_culling = true}},
	paramtype = "light",
	paramtype2 = "color4dir",
	palette = "unifieddyes_palette_color4dir.png",
	node_box = {
		type = "fixed",
		fixed = {
			f(x_min + 1/16, x_max - 1/16,	y_min, y_max - 1/16,	z_max - 1/16, z_max),  -- zadní stěna
			f(x_min, x_min + 1/16,			y_min, y_max - 1/16,	z_min, z_max - 1/16), -- levá stěna
			f(x_max - 1/16, x_max,			y_min, y_max - 1/16,	z_min, z_max - 1/16), -- pravá stěna
			f(x_min + 1/16, x_max - 1/16,	y_max - 1/16, y_max,	z_min, z_max - 1/16), -- horní stěna
			f(x_min + 1/16, x_max - 1/16,	-1.5, y_max - 1/16,		z_max, z_max + 1/32),  -- zadní stěna (zadní část)
		},
	},
	groups = {choppy = 2, ud_param2_colorable = 1},
	sounds = default.node_sound_wood_defaults(),

	on_construct = on_construct,
	on_rightclick = on_rightclick,
}

minetest.register_node("ch_beauty:nastavec", def)
minetest.register_craft{
	output = "ch_beauty:nastavec",
	recipe = {
		{"moreblocks:slab_pine_wood_three_sides", "", ""},
		{"moreblocks:slab_pine_wood_1", "", ""},
		{"moreblocks:slab_pine_wood_1", "", ""},
	},
}

ch_base.close_mod(minetest.get_current_modname())

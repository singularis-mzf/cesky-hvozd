-- SADA NA ROZBOR OTISKŮ PRSTŮ

local F = minetest.formspec_escape

local function otisky(player, pos, range, seconds, limit)
	local node = minetest.get_node(pos)
	local records = {}

	for _, record in ipairs(minetest.rollback_get_node_actions(pos, range, seconds, limit)) do
		if record.newnode.name ~= record.oldnode.name or record.newnode.param2 ~= record.newnode.param2 then
			local actor = record.actor
			if actor:sub(1,7) == "player:" then
				actor = ch_core.prihlasovaci_na_zobrazovaci(actor:sub(8,-1))
			end
			local cas = ch_time.cas_na_strukturu(record.time + ch_time.get_time_shift())
			local oldnode, newnode = record.oldnode, record.newnode
			table.insert(records, string.format("#aaaaaa,%04d-%02d-%02d,#ffff00,%02d:%02d:%02d,%s,#00ff00,%s,#ffffff,%s/%s => %s/%s,%s",
				cas.rok, cas.mesic, cas.den, cas.hodina, cas.minuta, cas.sekunda, cas:posun_text(),
				F(actor), F(oldnode.name), oldnode.param2, F(newnode.name), newnode.param2, F(minetest.pos_to_string(pos))))
		end
	end
	local formspec = {
		"formspec_version[4]"..
		"size[20,11]"..
		"label[0.5,0.75;Otisky prstů na pozici ",
		F(minetest.pos_to_string(pos).." ("..node.name.."/"..node.param2..")"),
		"]"..
		"button_exit[19,0.25;0.75,0.75;zavrit;x]"..
		"label[0.5,10;Poznámka: Administrace má k dispozici výkonnější nástroje pro sledování zásahů do herního světa, než je tento.]",
		"tablecolumns[color;text,tooltip=datum;color,span=1;text,tooltip=čas;text;color,span=1;text,tooltip=postava;color,span=1;text,tooltip=původní blok => nový blok;text,tooltip=pozice]"..
		"table[0.5,1.25;19,8;tabulka;",
		table.concat(records, ","),
		";]",
	}
	minetest.show_formspec(player:get_player_name(), "ch_extras:otisky", table.concat(formspec))
end

local function otisky_finished(pos, player_name)
	local player = minetest.get_player_by_name(player_name)
	if player == nil then return end
	local stack = player:get_wielded_item()
	if stack:get_name() ~= "ch_extras:otisky" then return end
	if not minetest.is_creative_enabled(player_name) then
		stack:take_item()
		player:set_wielded_item(stack)
	end
	otisky(player, pos, 0, 31557600, 64)
end

local function otisky_on_use(pos, player)
	local pinfo = ch_core.normalize_player(player)
	local player_name = pinfo.player_name
	if pinfo.role == "none" or pinfo.role == "new" then
		ch_core.systemovy_kanal(player_name, "Jen přijaté postavy mohou používat sadu na rozbor otisků prstů!")
		return
	end
	local online_charinfo = ch_core.online_charinfo[player_name or ""]
	if online_charinfo ~= nil then
		ch_core.start_ch_timer(online_charinfo, "ch_extras_otisky", 8, {
			label = "rozbor otisků prstů",
			func = function() otisky_finished(pos, player_name) end,
			hudbar_icon = "ch_extras_otisky.png^[resize:20x20",
			hudbar_bar = "hudbars_bar_timer.png^[multiply:#b31536",
		})
	end
end

local def = {
	description = "sada na rozbor otisků prstů",
	inventory_image = "ch_extras_otisky.png",
	wield_image = "ch_extras_otisky.png",
	groups = {tool = 1},
	_ch_help = "Sada na jedno použití. Levý klik prozkoumá otisky na bloku, na který jste klikl/a;\npravý klik prozkoumá otisky \"nad\" kliknutým povrchem.",
	on_use = function(itemstack, user, pointed_thing)
		if minetest.is_player(user) and pointed_thing.type == "node" then
			otisky_on_use(pointed_thing.under, user)
		end
	end,
	on_place = function(itemstack, placer, pointed_thing)
		if minetest.is_player(placer) and pointed_thing.type == "node" then
			otisky_on_use(pointed_thing.above, placer)
		end
	end,
}
minetest.register_craftitem("ch_extras:otisky", def)

minetest.register_craft{
	output = "ch_extras:otisky 3",
	recipe = {
		{"", "ch_extras:lupa", ""},
		{"darkage:chalk_powder", "darkage:chalk_powder", "darkage:chalk_powder"},
		{"darkage:chalk_powder", "darkage:chalk_powder", "darkage:chalk_powder"},
	},
}

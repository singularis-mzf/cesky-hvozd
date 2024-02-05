local F = minetest.formspec_escape
local ifthenelse = ch_core.ifthenelse
local ui = unified_inventory
local white, light_gray, light_green = ch_core.colors.white, ch_core.colors.light_gray, ch_core.colors.light_green
-- minetest.get_color_escape_sequence("#CCCCCC")

local has_ch_bank = minetest.get_modpath("ch_bank")
local has_woodcutting = minetest.get_modpath("woodcutting")
--
-- fsgen_class
-- -------------------------------------------------------------------------
local fsgen_class = {}

function fsgen_class:field_with_button(id, label, value, tooltip)
	local a = "field[0,"..(self.y + 0.4)..";4.75,0.5;chs_"..id..";"..light_gray..F(label or "")..";"..F(value or "").."]"
	local b = ""
	if tooltip ~= nil then
		b = "tooltip[chs_"..id..";"..F(tooltip).."]"
	end
	local c = "button[4.9,"..(self.y + 0.2)..";1.5,0.75;chs_"..id.."_set;nastavit]"
	self.y = self.y + 1
	return a..b..c
end

function fsgen_class:button(id, label, text, tooltip)
	local a, b, c
	if label ~= nil then
		a = "label[0,"..(self.y + 0.25)..";"..light_gray..F(label).."]"
		self.y = self.y + 0.25
	else
		a = ""
	end
	b = "button[0,"..(self.y + 0.2)..";6.4,0.75;chs_"..id.."_set;"..F(text or "nastavit").."]"
	if tooltip ~= nil then
		c = "tooltip[chs_"..id.."_set;"..F(tooltip).."]"
	else
		c = ""
	end
	self.y = self.y + 1
	return a..b..c
end

function fsgen_class:checkbox(id, label, value, tooltip)
	local a = "checkbox[0,"..(self.y + 0.25)..";chs_"..id..";"..light_gray..F(label or "")..";"
	local b = "false]"
	local c = ""
	if value == true or value == "true" or value == 1 then
		b = "true]"
	end
	if tooltip ~= nil then
		c = "tooltip[chs_"..id..";"..F(tooltip).."]"
	end
	self.y = self.y + 0.5
	return a..b..c
end

function fsgen_class:dropdown(id, label, fs_options, current_index, tooltip)
	local a, c = "", ""
	if label ~= nil then
		a = "label[0,"..(self.y + 0.25)..";"..light_gray..F(label).."]"
		self.y = self.y + 0.25
	end
	local b = "dropdown[0.5,"..(self.y + 0.15)..";5.9,0.5;chs_"..id..";"..assert(fs_options)..";"..(current_index or "1")..";true]"
	if tooltip ~= nil then
		c = "tooltip[chs_"..id..";"..F(tooltip).."]"
	end
	self.y = self.y + 0.75
	return a..b..c
end

function fsgen_class:table(id, label, fs_options, current_index, height, tooltip)
	local a, c = "", ""
	if height == nil then
		height = 2
	end
	if label ~= nil then
		a = "label[0,"..(self.y + 0.25)..";"..light_gray..F(label).."]"
		self.y = self.y + 0.25
	end
	local b = "table[0.5,"..(self.y + 0.15)..";5.9,"..height..";chs_"..id..";"..assert(fs_options)..";"..(current_index or "1").."]"
	if tooltip ~= nil then
		c = "tooltip[chs_"..id..";"..F(tooltip).."]"
	end
	self.y = self.y + 0.25 + height
	return a..b..c
end

function fsgen_class:new()
	local result = setmetatable({y = 0}, {__index = fsgen_class})
	return result
end

--
-- Admin Targets and dropdown
-- -------------------------------------------------------------------------
local admin_dropdowns = {}
local admin_targets = {}

local function player_info_less_than(a, b)
	-- 1. Online players first
	local oc = ch_core.online_charinfo
	if a.is_online and not b.is_online then
		return true
	elseif not a.is_online and b.is_online then
		return false
	end
	-- 2. Registered players first
	if a.privs.ch_registered_player and not b.privs.ch_registered_player then
		return true
	elseif not a.privs.ch_registered_player and b.privs.ch_registered_player then
		return false
	end
	-- 3. Otherwise by viewname:
	return a.index < b.index
end

local function clear_admin_dropdown(admin_name)
	admin_dropdowns[admin_name] = nil
end

local function get_admin_dropdown(admin_name)
	local result = admin_dropdowns[admin_name]
	if result ~= nil then
		return result
	end
	local all_players = ch_core.get_all_players(false, true) --> {prihlasovaci, zobrazovaci, privs}
	local index_to_name = {}
	local formspec_options = {}
	for i = 1, #all_players do
		all_players[i].index = i
		all_players[i].is_online = ch_core.online_charinfo[all_players[i].prihlasovaci]
	end
	table.sort(all_players, player_info_less_than)
	for i = 1, #all_players do
		index_to_name[i] = all_players[i].prihlasovaci
		formspec_options[i] = F(all_players[i].zobrazovaci)
	end
	result = {
		formspec_options = table.concat(formspec_options, ","),
		index_to_name = index_to_name,
		name_to_index = table.key_value_swap(index_to_name),
	}
	admin_dropdowns[admin_name] = result
	return result
end

--[[
ocal ddi_to_pi_data, pn_to_ddi, dd_fstext

local function init_dropdown_info()
	if ddi_to_pi_data == nil or pn_to_ddi == nil or dd_fstext == nil then
		ddi_to_pi_data, pn_to_ddi, dd_fstext = {}, {}, {}
		for i, info in ipairs(ch_core.get_all_players(false, false)) do
			ddi_to_pi_data[i] = info
			pn_to_ddi[info.prihlasovaci] = i
			dd_fstext[i] =  F(info.zobrazovaci)
		end
		dd_fstext = table.concat(dd_fstext, ",")
	end
end

local function dropdown_index_to_player_info(index)
	init_dropdown_info()
	return ddi_to_pi_data[index]
end

local function player_name_to_dropdown_index(player_name)
	init_dropdown_info()
	return pn_to_ddi[player_name] or 1
end

local function get_dropdown_fstext()
	init_dropdown_info()
	return assert(dd_fstext)
end
]]

--
-- Helper functions
-- -------------------------------------------------------------------------
local function clip(min, max, n)
	if n < min then
		return min
	elseif n > max then
		return max
	else
		return n
	end
end

local function first(a, b)
	return a
end

--[[
local function second(a, b)
	return b
end ]]

local function semiround_vector(v)
	v = vector.multiply(v, 100.0)
	v = vector.round(v)
	v = vector.multiply(v, 0.01)
	return v
end

--
-- Choice extractors
-- -------------------------------------------------------------------------
local function get_tplayer_index_and_name(player_name, player_role)
	if player_role == "admin" and admin_targets[player_name] ~= nil then
		local admin_dropdown = get_admin_dropdown(player_name)
		player_name = admin_targets[player_name]
		return admin_dropdown.name_to_index[player_name] or 1, player_name
	else
		-- not admin
		return 1, player_name
	end
end

local function get_zacatek_kam(toffline_charinfo)
	return clip(1, 3, tonumber(toffline_charinfo.zacatek_kam) or 1)
end

local function get_dennoc_choice_and_ratio(tplayer)
	if tplayer == nil then
		return 1, nil
	end
	local ratio = tplayer:get_day_night_ratio()
	local current_choice
	if ratio == nil then
		current_choice = 1
	else
		current_choice = clip(0, 10, math.round(ratio * 10))
		if current_choice == 10 then
			current_choice = 2
		elseif current_choice == 0 then
			current_choice = 3
		else
			current_choice = 3 + current_choice -- 4..12
		end
	end
	assert(1 <= current_choice and current_choice <= 12)
	return current_choice, ratio
end

local function get_woodcutting_mode(tplayer_name)
	return ifthenelse(has_woodcutting and woodcutting.is_disabled_by_player(tplayer_name), 2, 1)
end

local function get_rezim_plateb(tplayer_name, toffline_charinfo)
	if has_ch_bank and ch_bank.zustatek(tplayer_name) ~= nil then
		return clip(1, 5, toffline_charinfo.rezim_plateb + 1)
	else
		return nil
	end
end

-- local x = fsgen_class:new()

local function get_formspec(player, perplayer_formspec)
	local player_info = ch_core.normalize_player(player)
	local player_name = assert(player_info.player_name) -- (who is the formspec for)
	local player_viewname = ch_core.prihlasovaci_na_zobrazovaci(player_name)
	local player_role = assert(player_info.role)
	local online_charinfo = ch_core.online_charinfo[player_name] or {}

	-- target player (who is the formspec about)
	local tplayer_role, tplayer_privs, tplayer
	local tplayer_index, tplayer_name = get_tplayer_index_and_name(player_name, player_role)
	if tplayer_name == player_name then
		tplayer_role = player_role
		tplayer_privs = player_info.privs
		tplayer = player
	else
		local tplayer_info = ch_core.normalize_player(tplayer_name)
		tplayer_role = tplayer_info.role
		tplayer_privs = tplayer_info.privs
		tplayer = tplayer_info.player
	end
	local toffline_charinfo = ch_core.offline_charinfo[tplayer_name] or {}
	local fs = perplayer_formspec
	local left_form = {
		x = fs.std_inv_x,
		y = fs.form_header_y + 0.5,
		w = 10.0,
		h = fs.std_inv_y - fs.form_header_y - 1.25,
	}
	local right_form = {
		x = fs.page_x - 0.25,
		y = fs.page_y + 0.5,
		w = fs.pagecols - 1,
		h = fs.pagerows - 1,
	}
	local sbar_width = 0.5
	local tooltip

	local formspec = {
		fs.standard_inv_bg,
		"label["..(left_form.x + 0.05)..","..(left_form.y - 0.3)..";"..light_green..ch_core.prihlasovaci_na_zobrazovaci(player_name, true)..white.." — nastavení]",
		--[[
		"tableoptions[background=#00000000;highlight=#00000000;border=false]",
		"tablecolumns[color;text;color;text]",
		"table["..(left_form.x - 0.1)..","..(left_form.y - 0.5)..";"..left_form.w..",0.5;;#00ff00,"..F(player_viewname)..",#ffffff,— nastavení]", ]]
	}

	-- LEFT FORM:
	table.insert(formspec, "scroll_container["..left_form.x..","..left_form.y..";"..left_form.w..","..left_form.h..";chs_left;vertical]")
	--
	tooltip = "V pravém panelu jsou nastavení Vaší postavy. Kde je tlačítko, "..
		"nastavení se uplatní po kliknutí na něj. Ostatní typy nastavení "..
		"(rozbalovací seznamy, zaškrtávací podle apod.) se uplatní okamžitě "..
		"po provedení volby. Kde není uvedena značka (*), nastavení se ukládá "..
		"a přetrvá i po Vašem příštím připojení do hry. Nastavení se značkou (*) "..
		"budou platit, jen dokud se neodpojíte. Podrobnější vysvětlení "..
		"k jednotlivým volbám se zobrazí po najetí kurzoru myši nad ovládací prvek."
	table.insert(formspec,
		"textarea[0,0;"..left_form.w..","..left_form.h..";;;"..F(tooltip).."]")
	--
	table.insert(formspec, "scroll_container_end[]")
	local sbar_left_max = 0 -- math.max(0, math.ceil(10 * (fsgen.y - left_form.h + 0.5)))

	if sbar_left_max > 0 then
		table.insert(formspec,
			"scrollbaroptions[max="..sbar_left_max..";arrows=show]"..
			"scrollbar["..(left_form.x + left_form.w - sbar_width)..","..left_form.y..";"..sbar_width..","..left_form.h..";vertical;chs_left;]")
	else
		table.insert(formspec,
			"scrollbar[1000,0;0,0;vertical;chs_left;0]")
	end

	-- RIGHT FORM:
	table.insert(formspec, "scroll_container["..right_form.x..","..right_form.y..";"..right_form.w..","..right_form.h..";chs_right;vertical]")
	--
	local fsgen = fsgen_class:new()

	-- Target player selection [admin only]
	if player_role == "admin" then
		local dropdown = get_admin_dropdown(player_name)
		--[[ table.insert(formspec,
			fsgen:dropdown("tplayer", "postava", dropdown.formspec_options, tplayer_index)) ]]
		table.insert(formspec,
			fsgen:table("tplayer", "postava", dropdown.formspec_options, tplayer_index, 3.0))
	end

	-- Režim usnadnění hry [creative players and players with ch_switchable_creative priv]
	if tplayer_role == "creative" or tplayer_privs.ch_switchable_creative or tplayer_privs.privs then
		tooltip =
			"Režim usnadnění hry je dostupný pouze kouzelnickým postavám.\n"..
			"Činí hru rychlejší a snazší odstraněním některých požadavků a omezení.\n"..
			"Lze jej snadno zapínat použitím kouzelnické hůlky."
		table.insert(formspec,
			fsgen:checkbox("creative", "režim usnadnění hry (*)", ifthenelse(tplayer_privs.creative, "true", "false"), tooltip))
	end

	-- Neshýbat [all players]
	tooltip =
		"Nastaví, zda se má postava při držení klávesy Shift sehnout tak,\n"..
		"že bude trochu nižší."
	table.insert(formspec,
		fsgen:checkbox("shybat", "shýbat postavu při držení Shift (sneak)", (toffline_charinfo.neshybat or 0) == 0, tooltip))

	-- Skrýt body [not for new players]
	if tplayer_role ~= "new" and tplayer_role ~= "none" then
		tooltip =
			"Ve spodní části obrazovky se přijatým postavám zobrazuje ukazatel\n"..
			"úrovní a bodů potřebných k jejich získání. Tyto body a úrovně vyjadřují\n"..
			"vaši aktivitu ve hře. Tímto nastavením můžete tento ukazatel zobrazit\n"..
			"či skrýt."
		table.insert(formspec,
			fsgen:checkbox("zobrazitbody", "zobrazit ukazatel úrovní a bodů", (toffline_charinfo.skryt_body or 0) == 0, tooltip))
	end

	-- Krásná obloha [all players]
	tooltip =
		"Zobrazí texturovanou oblohu namísto výchozí minetestovské. Pokud máte problémy\n"..
		"s výkonem grafiky, můžete toto nastavení zkusit vypnout."
	table.insert(formspec,
		fsgen:checkbox("krasna_obloha", "krásná obloha", (toffline_charinfo.no_ch_sky or 0) == 0, tooltip))

	if tplayer ~= nil then
		-- Osobní osvětlení světa [all players in game]
		tooltip =
			"Osobní osvětlení světa mění denní osvětlení herního světa pouze pro vašeho\n"..
			"klienta na určitou úroveň mezi dnem a nocí, která se pak nemění podle toho,\n"..
			"zda je v herním světě ve skutečnosti den nebo noc. Je to jeden ze způsobů,\n"..
			"jak vyřešit noční stavby."
		table.insert(formspec,
			fsgen:dropdown("dennoc", "osobní osvětlení světa (*):", "vypnout,den (100%),noc (0%),spíše noc (10%),spíše noc (20%),spíše noc (30%),spíše noc (40%),půl napůl (50%),spíše den (60%),spíše den (70%),spíše den (80%),spíše den (90%)", first(get_dennoc_choice_and_ratio(tplayer)), tooltip))
	end

	-- Začátek [not for new players]
	if tplayer_role ~= "new" and tplayer_role ~= "none" then
		tooltip =
			"Přijaté postavy si mohou vybírat jeden z nabízených cílů, kam je zdarma přenese\n"..
			"příkaz /začátek."
		table.insert(formspec,
			fsgen:dropdown("zacatek", "cíl pro /začátek:", "Začátek,Masarykovo náměstí,Hlavní nádraží", get_zacatek_kam(toffline_charinfo), tooltip))
	end

	-- Režim dřevorubectví [not for new players]
	if has_woodcutting and tplayer_role ~= "new" and tplayer_role ~= "none" then
		tooltip =
			"Dřevorubectví je herní systém, který postupně automaticky pokácí celý\n"..
			"strom, když ho začnete kácet sekyrou. Tato volba ovlivňuje, jak se bude\n"..
			"dřevorubectví aktivovat."
		table.insert(formspec,
			fsgen:dropdown("drevorubectvi", "režim dřevorubectví:", "zapnuto,vypnuto",
				get_woodcutting_mode(tplayer_name), tooltip))
	end

	-- Režim bezhotovostních plateb [for players with bank accounts]
	if has_ch_bank and ch_bank.zustatek(tplayer_name) ~= nil then
		tooltip =
			"Toto nastavení ovlivňuje, kdy bude systém upřednostňovat hotovostní\n"..
			"a kdy bezhotovostní platbu v případech, kdy bude mít na výběr."
		table.insert(formspec,
			fsgen:dropdown("rezim_plateb", "režim bezhotovostních plateb:",
			"upřednostňovat platby z/na účet,přijímat v hotovosti\\, platit z účtu,přijímat na účet\\, platit hotově,upřednostňovat hotovost,zakázat platby z účtu",
			get_rezim_plateb(tplayer_name, toffline_charinfo), tooltip))
	end

	-- Domov [priv home]
	if tplayer_privs.home then
		tooltip = "V Českém hvozdu můžete mít jednu libovolnou uloženou pozici, na kterou se\n"..
				"budete moci kdykoliv zdarma vrátit příkazem /domů. Nemusí to být výslovně\n"..
				"domov, ale bude výhodné, pokud to bude místo, kam se často vracíte."
		local player_pos = semiround_vector(player:get_pos())
		local domov = toffline_charinfo.domov
		if domov ~= nil and domov ~= "" and domov ~= "()" then
			domov = minetest.string_to_pos(domov)
			if domov == nil then
				domov = "()"
			else
				domov = minetest.pos_to_string(semiround_vector(domov))
			end
		end
		table.insert(formspec,
			fsgen:button("domu", "pozice pro /domů: "..domov, "nastavit sem "..minetest.pos_to_string(player_pos), tooltip))
	end

	-- Skrýt čas [not for new players]
	if tplayer_role ~= "new" and tplayer_role ~= "none" then
		tooltip =
			"Do odhlášení ze hry skryje čas v pravém dolním rohu obrazu.\n"..
			"To může být užitečné při pořizování snímků obrazovky, ačkoliv skrytí\n"..
			"HUD může být ještě účinnější. Ukazatel času vrátíte zpět tím,\n"..
			"že se odhlásíte a znovu přihlásíte."
		table.insert(formspec,
			fsgen:button("skrytcas", nil, "skrýt čas (*)", tooltip))
	end

	-- Návody znovu [all players in game]
	if tplayer ~= nil then
		tooltip =
			"U některých předmětů se vám v momentě, kdy je poprvé vyberete\n"..
			"na výběrové liště, zobrazí v četu nápověda, k čemu slouží a jak je použít.\n"..
			"Po stisku tohoto tlačítka se vám tato nápověda zobrazí jednou znovu\n"..
			"i u předmětů, které už jste v minulosti vybrali."
		table.insert(formspec,
			fsgen:button("navodyznovu", nil, "zobrazovat znovu\nnápovědy k předmětům", tooltip))
	end

	-- Aktuální doslech [all players in game]
	if tplayer ~= nil then
		tooltip = "Doslech je vzdálenost v metrech kolem vaší postavy ve hře,\n"..
			"ze které se vám zobrazí zprávy z výchozího kanálu četu od ostatních postav.\n"..
			"To, zda se jim zobrazí vaše zprávy, záleží zase na jejich doslechu.\n"..
			"Nastavením velkého doslechu budete vidět čet ze všech koutů světa,\n"..
			"ale pokud zrovna vedete rozhovor s někým poblíž, mohou vás otravovat."
		local tonline_charinfo = ch_core.online_charinfo[tplayer_name] or {}
		table.insert(formspec,
			fsgen:field_with_button("adoslech", "aktuální doslech(*)(0-65535):", tostring(tonline_charinfo.doslech or "50"), tooltip))
	end

	-- Výchozí doslech [all players]
	tooltip = "Výchozí doslech je doslech, který se vám nastaví po vstupu do hry."
	table.insert(formspec,
		fsgen:field_with_button("vdoslech", "výchozí doslech (0-65535):", tostring(toffline_charinfo.doslech or "50"), tooltip))



	-- Délka lišty [all players]
	tooltip =
		"Počet polí zobrazovaných na spodním okraji obrazovky, z nichž můžete\n"..
		"vybírat aktivní předměty. Rovněž některé předměty účinkují jen tehdy,\n"..
		"jsou-li umístěny na liště. Nastavte si délku, která vám bude vyhovovat."
	local hotbar_length = dreambuilder_hotbar.get_hotbar_size(tplayer_name) or 16
	table.insert(formspec,
		fsgen:field_with_button("lista", "délka výběrové lišty (1-32):", F(hotbar_length), tooltip))

	--[[
	table.insert(formspec,
		fsgen:field_with_button("hudba", "hlasitost hudby (0-10):", "10",
			"Pro zpestření hry občas hraje v Českém hvozdu hudba na pozadí.\n"..
			"0 ji zcela vypne, 10 znamená nejvyšší hlasitost. Toto nastavení \n"..
			"neslouží k úplnému vypnutí zvuků Minetestu, k tomu slouží příslušná\n"..
			"klávesa (ve výchozím nastavení na počítači M)."))
	table.insert(formspec,
		fsgen:field_with_button("zvuky", "hlasitost zvuků okolí (0-10):", "10",
			"Ovládá hlasitost některých zvuků okolí (ne všech). 0 tyto zvuky vypne,\n"..
			"10 jim nastaví maximální hlasitost."))
	]]

	--
	table.insert(formspec, "scroll_container_end[]")
	local sbar_right_max = math.max(0, math.ceil(10 * (fsgen.y - right_form.h + 0.5)))

	if sbar_right_max > 0 then
		table.insert(formspec,
			"scrollbaroptions[max="..sbar_right_max..";arrows=show]"..
			"scrollbar["..(right_form.x + right_form.w - sbar_width)..","..right_form.y..";"..sbar_width..","..right_form.h..";vertical;chs_right;"..math.min(online_charinfo.ui_settings_rscroll or 0, sbar_right_max).."]")
	else
		table.insert(formspec,
			"scrollbaroptions[max=1]"..
			"scrollbar[1000,0;0,0;vertical;chs_right;0]")
	end

	return {
		draw_item_list = false,
		formspec = table.concat(formspec),
	}
end

ui.register_button("ch_settings", {
	type = "image",
	image = "ch_overrides_ui_settings.png",
	tooltip = "Nastavení",
	condition = function(player)
		return true -- minetest.check_player_privs(player, "server")
	end,
})

ui.register_page("ch_settings", {get_formspec = get_formspec})

local function on_player_receive_fields(player, formname, fields)
	if formname ~= "" then return end
	local player_info = ch_core.normalize_player(player)
	local player_name = assert(player_info.player_name) -- (who is the formspec for)
	local player_role = assert(player_info.role)

	if player_role == "admin" and fields.quit then
		clear_admin_dropdown(player_name)
		return
	end

	local online_charinfo = ch_core.online_charinfo[player_name] or {}
	local tplayer_index, tplayer_name = get_tplayer_index_and_name(player_name, player_role)
	local tplayer_info

	if fields.chs_right then
		local event = minetest.explode_scrollbar_event(fields.chs_right)
		if event.type == "CHG" then
			online_charinfo.ui_settings_rscroll = tonumber(event.value) or 0
			return
		end
	end

	if tplayer_name == player_name then
		tplayer_info = player_info
	else
		tplayer_info = ch_core.normalize_player(tplayer_name)
	end
	local tplayer_event = fields.chs_tplayer and minetest.explode_table_event(fields.chs_tplayer)
	if tplayer_event and player_role == "admin" and tostring(tplayer_event.row) ~= tostring(tplayer_index) then
		-- tplayer changed!
		local admin_dropdown = get_admin_dropdown(player_name)
		admin_targets[player_name] = admin_dropdown.index_to_name[assert(tonumber(tplayer_event.row))]
		online_charinfo.ui_settings_rscroll = 0
		ui.set_inventory_formspec(player, "ch_settings")
		return true
	end
	local toffline_charinfo = ch_core.offline_charinfo[tplayer_name] or {}
	local update_formspec = false

	-- Expected dropdown values:
	local expected = {
		chs_zacatek = tostring(get_zacatek_kam(toffline_charinfo)),
		chs_dennoc = tostring(first(get_dennoc_choice_and_ratio(tplayer_info.player))),
		chs_drevorubectvi = has_woodcutting and tostring(get_woodcutting_mode(tplayer_info.player_name)),
		chs_rezim_plateb = tostring(get_rezim_plateb(tplayer_info.player_name, toffline_charinfo)),
	}

	-- 1. DROPDOWNS
	if fields.chs_zacatek and tostring(fields.chs_zacatek) ~= expected.chs_zacatek then
		-- chs_zacatek
		local new_zacatek = clip(1, 3, math.round(assert(tonumber(fields.chs_zacatek))))
		toffline_charinfo.zacatek_kam = new_zacatek
		ch_core.save_offline_charinfo(tplayer_name, "zacatek_kam")
		update_formspec = true
	elseif tplayer_info.player ~= nil and fields.chs_dennoc and tostring(fields.chs_dennoc) ~= expected.chs_dennoc then
		local new_choice = clip(1, 12, math.round(assert(tonumber(fields.chs_dennoc))))
		local tplayer = tplayer_info.player
		if new_choice == 1 then
			tplayer:override_day_night_ratio(nil)
		elseif new_choice == 2 then
			tplayer:override_day_night_ratio(1.0)
		elseif new_choice == 3 then
			tplayer:override_day_night_ratio(0.0)
		else
			tplayer:override_day_night_ratio(0.1 * (new_choice - 3))
		end
		update_formspec = true
	elseif has_woodcutting and fields.chs_drevorubectvi and tostring(fields.chs_drevorubectvi) ~= expected.chs_drevorubectvi then
		if fields.chs_drevorubectvi == "1" then
			woodcutting.enable_for_player(tplayer_name)
		else
			woodcutting.disable_for_player(tplayer_name)
		end
		update_formspec = true
	elseif has_ch_bank and fields.chs_rezim_plateb and tostring(fields.chs_rezim_plateb) ~= expected.chs_rezim_plateb then
		toffline_charinfo.rezim_plateb = clip(1, 5, math.round(assert(tonumber(fields.chs_rezim_plateb)))) - 1
		ch_core.save_offline_charinfo(tplayer_name, "rezim_plateb")
		update_formspec = true

	-- 2. CHECKBOXES
	elseif fields.chs_creative and (tplayer_info.role == "creative" or tplayer_info.privs.ch_switchable_creative or tplayer_info.privs.privs) then
		tplayer_info.privs.creative = ifthenelse(fields.chs_creative == "true", true, nil)
		minetest.set_player_privs(tplayer_name, tplayer_info.privs)
		update_formspec = true
	elseif fields.chs_shybat then
		update_formspec = not ch_core.nastavit_shybani(tplayer_name, fields.chs_shybat == "true") or player_name ~= tplayer_name
	elseif fields.chs_zobrazitbody then
		update_formspec = not ch_core.showhide_ap_hud(tplayer_name, fields.chs_zobrazitbody == "true") or player_name ~= tplayer_name
	elseif fields.chs_krasna_obloha then
		if fields.chs_krasna_obloha == "true" then
			if toffline_charinfo.no_ch_sky == 1 then
				update_formspec = true
				toffline_charinfo.no_ch_sky = 0
				ch_core.save_offline_charinfo(tplayer_name, "no_ch_sky")
				local tonline_charinfo = ch_core.online_charinfo[tplayer_name]
				if tonline_charinfo ~= nil and tonline_charinfo.sky_info ~= nil then
					tonline_charinfo.sky_info.ch_sky_enabled = true
				end
			end
		else
			if toffline_charinfo.no_ch_sky ~= 1 then
				update_formspec = true
				toffline_charinfo.no_ch_sky = 1
				ch_core.save_offline_charinfo(tplayer_name, "no_ch_sky")
				local tonline_charinfo = ch_core.online_charinfo[tplayer_name]
				if tonline_charinfo ~= nil and tonline_charinfo.sky_info ~= nil then
					tonline_charinfo.sky_info.ch_sky_enabled = false
				end
			end
		end

	-- 3. FIELDS WITH BUTTONS
	elseif fields.chs_adoslech_set and tonumber(fields.chs_adoslech) ~= nil then
		local tonline_charinfo = ch_core.online_charinfo[tplayer_name]
		if tonline_charinfo ~= nil then
			local new_doslech = clip(0, 65535, math.ceil(tonumber(fields.chs_adoslech)))
			tonline_charinfo.doslech = new_doslech
			update_formspec = true
		end
	elseif fields.chs_vdoslech_set and tonumber(fields.chs_vdoslech) ~= nil then
		local new_doslech = clip(0, 65535, math.ceil(tonumber(fields.chs_vdoslech)))
		toffline_charinfo.doslech = new_doslech
		ch_core.save_offline_charinfo(tplayer_name, "doslech")
		update_formspec = true
	elseif fields.chs_lista_set and tonumber(fields.chs_lista) ~= nil then
		local new_size = clip(1, 32, math.round(tonumber(fields.chs_lista)))
		dreambuilder_hotbar.set_hotbar_size(tplayer_name, new_size)
		update_formspec = true

	-- 4. BUTTONS
	elseif fields.chs_domu_set and tplayer_info.privs.home then
		local player_pos = player:get_pos()
		local posstr = minetest.pos_to_string(player_pos)
		assert(minetest.string_to_pos(posstr))
		toffline_charinfo.domov = posstr
		update_formspec = true
	elseif fields.chs_navodyznovu_set and tplayer_info.player ~= nil then
		ch_core.clear_help(tplayer_info.player)
	elseif fields.chs_skrytcas_set and tplayer_info.player ~= nil then
		ch_core.clear_datetime_hud(tplayer_info.player)
	end

	if update_formspec then
		-- update player's own page
		ui.set_inventory_formspec(player, "ch_settings")

		-- if player is admin and tplayer is in game, update also tplayer's page
		if tplayer_info.player ~= nil and tplayer_name ~= player_name and ui.current_page[tplayer_name] == "ch_settings" then
			ui.set_inventory_formspec(tplayer_info.player, "ch_settings")
		end

		-- if the player is a target of some admin, update also admin's page
		for admin_name, target_name in pairs(admin_targets) do
			if target_name == player_name and admin_name ~= player_name and ui.current_page[admin_name] == "ch_settings" then
				local admin_player = minetest.get_player_by_name(admin_name)
				if admin_player ~= nil then
					ui.set_inventory_formspec(admin_player, "ch_settings")
				end
			end
		end
		return true
	end
end
minetest.register_on_player_receive_fields(on_player_receive_fields)

local F = minetest.formspec_escape
local FHE = ch_core.formspec_hypertext_escape
local has_areas = minetest.get_modpath("areas")
local ifthenelse = ch_core.ifthenelse
local ui = assert(unified_inventory)
-- local white, light_gray, light_green = ch_core.colors.white, ch_core.colors.light_gray, ch_core.colors.light_green

local stav_to_color = {
	rozestaveno = "#cccc00",
	hotovo = "#ffffff",
	k_schvaleni = "#80cccc",
	k_smazani = "#cc3333",
	opusteno = "#d8834e",
	k_povoleni = "#80cccc",
	rekonstrukce = "#cccc00",
}
local color_me = "#00ff00"
local color_admin = "#aa66aa"
local color_other_players = "#cccccc"

local htnadp_escape_sequence = minetest.get_color_escape_sequence("#00ff00")
local function htnadp(t)
	return "<style color=#00ff00>"..t.."</style>"
end

ch_core.register_event_type("stavba_new", {
	description = "založení stavby",
	access = "players",
	chat_access = "public",
})

ch_core.register_event_type("stavba_finished", {
	description = "dokončení stavby",
	access = "public",
	chat_access = "public",
})

ch_core.register_event_type("stavba_changed", {
	description = "úprava stavby",
	access = "admin",
	chat_access = "admin",
})

ch_core.register_event_type("stavba_povolena", {
	description = "stavba povolena",
	access = "players",
	chat_access = "players",
})


local function filter_all()
	return true
end

local function sort_by_distance(a, b, player_info)
	local player_pos = player_info.player:get_pos()
	return vector.distance(player_pos, a.pos) < vector.distance(player_pos, b.pos)
end

local function sort_by_name(a, b)
	return ch_core.utf8_radici_klic(a.nazev.."/"..a.druh, true) < ch_core.utf8_radici_klic(b.nazev.."/"..b.druh, true)
end

local filters = {
	{
		description = "10 nebližších staveb",
		filter = filter_all,
		sorter = sort_by_distance,
		limit = 10,
	}, {
		description = "moje stavby (A-Z)",
		filter = function(record, player_info) return record.spravuje == player_info.player_name end,
		sorter = sort_by_name,
	}, {
		description ="moje nehotové stavby (A-Z)",
		filter = function(record, player_info) return record.spravuje == player_info.player_name and record.stav ~= "hotovo" end,
		sorter = sort_by_name,
	}, {
		description ="moje hotové stavby (A-Z)",
		filter = function(record, player_info) return record.spravuje == player_info.player_name and record.stav == "hotovo" end,
		sorter = sort_by_name,
	}, {
		description = "všechny stavby (od nejbližší)",
		filter = filter_all,
		sorter = sort_by_distance,
	}, {
		description = "všechny stavby (A-Z)",
		filter = filter_all,
		sorter = sort_by_name,
	}
}

local function get_stavby_online_charinfo(player_name)
	local online_charinfo = ch_core.online_charinfo[player_name]
	if online_charinfo == nil then
		minetest.log("warning", "ui_stavby: Expected online_charinfo for player '"..player_name.."' not found!")
		return {}
	end
	local result = online_charinfo.ch_stavby
	if result == nil then
		result = {
			active_filter = 1,
			displayed_table = {""},
			selected_key = "",
		}
		online_charinfo.ch_stavby = result
	end
	return result
end

-- Unified Inventory page
-- ==============================================================================
local ui_help_fhtext = htnadp("Proč evidovat svoje stavby?")..
	"\n"..FHE(
	"- Jen zaevidované stavby můžete považovat za „svoje“; nezaevidované stavby jsou anonymní, takže je může kdokoliv převzít a upravit, jak bude chtít.\n"..
	"- Systém vás předem upozorní, pokud se pokusíte založit stavbu na nevhodném či zakázaném místě.\n"..
	"- Ostatní hráči/ky získají jasnou představu o tom, co stavíte, že to stavíte vy a v jaké je výstavba fázi.\n"..
	"- I v případě, že server opustíte a stavba bude předána ke správě jinému hráči/ce, zůstane tu záznam o tom, že jste stavbu založil/a a postavil/a.\n")..
	htnadp("Jaký je rozdíl mezi soukromou a veřejnou stavbou?")..
	FHE("\nSoukromá stavba má sloužit především vám a hráčům/kám, které na ni sám/a pozvete. Nedostane se vám takové pozornosti jako u veřejné stavby "..
	"a stavba vám téměř jistě zůstane, i když se delší dobu nepřipojíte do hry a nebudete se o ni starat. Může to být třeba zákoutí, které si chcete "..
	"upravit podle svého vkusu a chodit tam odpočívat, vlastní dílna nebo soukromý sklad materiálu. Nestane se však součástí infrastruktury světa "..
	"a nedostanete za ni odměnu nad rámec samotné možnosti ji v herním světě mít a využívat.\n"..
	"Oproti tomu veřejná je taková stavba, "..
	"která má sloužit především cizím hráčům/kám nebo jako součást světové infrastruktury. Může to být veřejná dílna, hřbitov, cesta, "..
	"obchod, restaurace, zoologická zahrada apod. Ačkoliv u veřejné stavby rozhodujete vy, jak má vypadat a jakou funkci má plnit, "..
	"Administrace se bude snažit dohlédnout, aby tuto funkci opravdu plnila, což znamená, že bude stavbu posuzovat a bude moci požadovat "..
	"nějaké důvodné úpravy. Pokud se o veřejnou stavbu nebudete delší dobu starat, "..
	"může být předána do správy jiné/mu hráči/ce nebo ji do správy převezme přímo Administrace. Za dokončení veřejné stavby užitečné pro herní svět "..
	" můžete dostat individuální odměnu ve formě herních peněz (jen dělnické postavy) nebo bodů aktivity (ovlivňují úroveň postavy).\n")..
	htnadp("Co znamená stav stavby?")..
	FHE("\nStav především rozlišuje stavby dokončené (hotové) od nedokončených (rozestavěných či v rekonstrukci). Pokud se o stavbu již nechcete starat "..
	"a nezáleží vám na ni, přepněte ji do stavu „opuštěná“. Takovou stavbu si bude moci vzít do správy někdo jiný a přestavět.\n")..
	htnadp("Systém mi nedovolí něco změnit. Co mám dělat?")..
	FHE("\nPro jakoukoliv změnu nad rámec toho, co vám systém dovolí, kontaktujte Administraci a domluvte se s ní. Je možná např. "..
	"změna soukromé stavby na veřejnou či naopak nebo přesunutí evidenčního bodu stavby na příhodnější místo. "..
	"Celkově platí, že jakákoliv snaha hráče/ky o oboustranně výhodnou domluvu se cení.\n")..
	htnadp("Moje stavba je rozlehlá/dlouhá. Jak ji mám zaevidovat?")..
	FHE("\nObecně platí, že veřejné liniové stavby jako železniční tratě, stezky, elektrická vedení, silnice apod. se samostatně neevidují. "..
	"Evidují se však jedinečné místní stavby na nich, jako např. nádraží, mosty, zastávky, čekárny, elektrárny apod. "..
	"Dále platí, že systém neeviduje rozsah stavby, jen přibližnou polohu. Rozsah stavby je pak určen neformálně "..
	"podle skutečně zastavěné (nebo ohrazené) plochy a logiky věci. Proto, pokud máte v plánu stavbu postupně rozšiřovat, "..
	"je dobrý nápad si předem ohradit přiměřeně velký prostor (ale zase to nepřehánějte).\n"..
	"Na přesné poloze evidenčního bodu tedy příliš nezáleží, snažte se však stavbu zaevidovat přibližně v místě jejího prostředka, "..
	"na mapě to pak bude vypadat lépe.\n")..
	htnadp("Jak evidovat město a stavby v něm, resp. panelový dům a byty v něm?")..
	FHE("\nJe-li menší stavba logickou součástí větší stavby (např. dům ve městě nebo byt v panelovém domě), záznam o větší stavbě se týká jen těch "..
	"vnořených staveb, které nemají svůj vlastní. Vnořenou stavbu je tedy třeba zaevidovat zvlášť, jen pokud se má lišit např. stavem nebo tím, "..
	"kdo ji spravuje. V ostatních případech záleží to, zda vnořené stavby zaevidujete samostatně, nebo ne, na vás.")

local function get_ui_formspec(player, perplayer_formspec)
	local player_info = ch_core.normalize_player(player)
	local player_name = assert(player_info.player_name) -- (who is the formspec for)
	local player_pos = vector.round(player:get_pos())
	local stavby_charinfo = get_stavby_online_charinfo(player_name)
	local is_admin = player_info.privs.ch_stavby_admin

    -- function ch_core.get_ui_form_template(id, player_viewname, title, scrollbars, perplayer_formspec)
    local template = ch_core.get_ui_form_template("stavby", ch_core.prihlasovaci_na_zobrazovaci(player_name), "evidence staveb",
		{top = 0, bottom = 0}, perplayer_formspec)

	local formspec = {
		template.fs_begin,
	}

	local active_filter = assert(filters[stavby_charinfo.active_filter])

    -- TOP form:
	local stavby = ch_core.stavby_get_all(active_filter.filter, active_filter.sorter, player_info)
	local selected_key = stavby_charinfo.selected_key
	local displayed_table = {""}
	local selection_index = 0
	local selected_record

	table.insert(formspec, "tablecolumns[image,"..
		"0=ch_core_empty.png,"..
		"1=ch_overrides_ui_stavby.png^\\[resize:16x16,"..
		"2=basic_materials_padlock.png\\^[resize:16x16"..
		";color,span=1;text,width=25;color,span=1;text,width=7;color,span=1;text,width=10;text]"..
		"table[0,0;17,4;ui_stavba;0,#ffffff,NÁZEV STAVBY (DRUH),#ffffff,STAV,#ffffff,SPRAVUJE,VZDÁLENOST")

	for i, record in ipairs(stavby) do
		local st_pos = assert(record.pos)
		-- ikona:
		if record.urceni == "soukroma" then
			table.insert(formspec, ",2,")
		elseif record.urceni == "verejna" then
			table.insert(formspec, ",0,")
		else
			table.insert(formspec, ",1,")
		end
		table.insert(formspec, ifthenelse(record.urceni ~= "chranena_oblast", "#ffffff,", "#aaaaff,"))
		table.insert(formspec, F(record.nazev))
		if record.druh ~= "" then
			table.insert(formspec, " ("..F(record.druh)..")")
		end
		table.insert(formspec, ","..(stav_to_color[record.stav] or "#ffffff")..",") -- barva pro stav
		table.insert(formspec, F(ch_core.stavy_staveb[record.stav] or "???"))
		if record.spravuje == player_name then
			table.insert(formspec, ","..color_me..",")
		elseif record.spravuje == "Administrace" then
			table.insert(formspec, ","..color_admin..",")
		else
			table.insert(formspec, ","..color_other_players..",")
		end
		table.insert(formspec, F(ch_core.prihlasovaci_na_zobrazovaci(record.spravuje)))
		table.insert(formspec, ","..math.round(vector.distance(player_pos, st_pos)).." m")
		if record.key == selected_key  then
			selection_index = i + 1
			selected_record = record
		end
		displayed_table[i + 1] = assert(record.key)

		-- apply limit
		if active_filter.limit ~= nil and i >= active_filter.limit then
			break
		end
	end
	stavby_charinfo.displayed_table = displayed_table
	table.insert(formspec, ";"..selection_index.."]")

	-- rozbalovací pole s volbou filtru a řazení
	table.insert(formspec, "dropdown[5.5,-0.6;7,0.5;ch_stavby_filtr;"..F(assert(filters[1].description)))
	for i = 2, #filters do
		table.insert(formspec, ","..F(filters[i].description))
	end
	table.insert(formspec, ";"..stavby_charinfo.active_filter..";true]")

	-- tlačítko „nová stavba zde“:
	if ch_core.stavby_get(player_pos) == nil then
		table.insert(formspec, "button[13,-0.7;4,0.6;ch_stavby_nova;nová stavba zde]"..
			"tooltip[ch_stavby_nova;založit novou stavbu na pozici "..player_pos.x.."\\,"..player_pos.y.."\\,"..player_pos.z.."]")
	end

    table.insert(formspec, template.fs_middle)
	-- BOTTOM form:
	-- table.insert(formspec, "textarea[0,0;7,5.5;;;")
	if selected_record ~= nil then
		local st_pos = assert(selected_record.pos)
		table.insert(formspec,
			string.format("label[0.01,0.26;%sPozice stavby:]textarea[2.5,0.09;4.5,0.5;;;%d\\,%d\\,%d]",
				htnadp_escape_sequence, st_pos.x, st_pos.y, st_pos.z)..
			"hypertext[0,0.5;7,5;;"..
			htnadp("Název:").." "..FHE(selected_record.nazev).."\n"..
			htnadp("Druh:").." "..FHE(selected_record.druh).."\n"..
			-- htnadp("Pozice:").." "..string.format("%d\\,%d\\,%d", ).."\n"..
			htnadp("Vzdálenost:").." "..string.format("%d m", math.round(vector.distance(player_pos, st_pos))).."\n"..
			htnadp("Stav:").." "..FHE(ch_core.stavy_staveb[selected_record.stav] or "???").."\n"..
			htnadp("Spravuje:").." "..FHE(ch_core.prihlasovaci_na_zobrazovaci(selected_record.spravuje)).."\n"..
			htnadp("Záměr/poznámka:"))
		if selected_record.zamer ~= "" then
			table.insert(formspec, "\n"..FHE(selected_record.zamer))
		end
		table.insert(formspec, "\n"..htnadp("Historie:"))
		for i = #selected_record.historie, 1, -1 do
			table.insert(formspec, "\n- "..FHE(selected_record.historie[i]))
		end
		table.insert(formspec, "\n]")
		if is_admin and selected_record.stav == "k_smazani" then
			table.insert(formspec, "button[0,5.5;6,0.5;ch_stavby_upravit;upravit]"..
				"button[6,5.5;1,0.5;ch_stavby_smazat;smazat]")
		elseif is_admin or selected_record.spravuje == player_name then
			table.insert(formspec, "button[0,5.5;7,0.5;ch_stavby_upravit;upravit]")
		end
	else
		table.insert(formspec, "hypertext[0,0.5;7,5;;"..ui_help_fhtext.."\n]")
	end

    ----
	table.insert(formspec, template.fs_end)

	return {
		draw_item_list = false,
		formspec = table.concat(formspec),
	}
end

ui.register_button("ch_stavby", {
	type = "image",
	image = "ch_overrides_ui_stavby.png",
	tooltip = "Stavby",
	condition = function(player)
        -- TODO: zpřístupnit seznam všech staveb i novým postavám,
		-- ideálně s možností získat kompas, který na ně bude ukazovat
		return ch_core.get_player_role(player) ~= "new"
	end,
})

ui.register_page("ch_stavby", {get_formspec = get_ui_formspec})

-- Nová stavba
-- ==============================================================================
--[[
	custom_state = {
		pos = vector, -- zaokrouhlený vektor pozice
		player = PlayerRef,
		is_admin = bool, -- je editující postava správce/yně?
		pozice = "", -- pozice, jak je zadaná ve formuláři
		nazev = "",
		druh = "",
		spravuje = "",
		stav = int, -- index do stav_list
		urceni = int, -- index do urceni_list
		zamer = <výchozí text>,
		stav_list = {string...} -- seznam ID stavů ve stejném pořadí jako v dropdown[]
		urceni_list = {string...} -- seznam ID určení ve stejném pořadí jako v dropdown[]
	}
]]

local function get_new_formspec(custom_state)
	local pinfo = ch_core.normalize_player(custom_state.player)
	local pos = custom_state.pos
	local is_admin = custom_state.is_admin
	local formspec = {
		ch_core.formspec_header({formspec_version = 4, size = {16.75, 12.25}, auto_background = true}),
		"image[0.35,0.3;1,1;ch_overrides_ui_stavby.png]"..
		"label[1.5,0.85;Nová stavba na pozici "..string.format("(%d\\,%d\\,%d)", pos.x, pos.y, pos.z).."]"
	}

	table.insert(formspec, "label[0.5,2.5;určení stavby:]"..
		"dropdown[0.5,2.75;7.5,0.5;urceni;")
	for i, id in ipairs(custom_state.urceni_list) do
		if i > 1 then table.insert(formspec, ",") end
		table.insert(formspec, F(ch_core.urceni_staveb[id]))
	end
	local function nadpis(t)
		return "<style color=#00ff00>"..t.."</style>\n"
	end
	table.insert(formspec, ";"..custom_state.urceni..";true]"..
		"field[0.5,4;7.5,0.5;nazev;název stavby;"..F(custom_state.nazev).."]"..
		"field[0.5,5;4,0.5;druh;druh stavby;"..F(custom_state.druh).."]"..
		"textarea[0.5,6;7.5,4;zamer;záměr stavby/poznámka:;"..F(custom_state.zamer).."]"..
		"hypertext[8.35,2;8,8;napoveda;"..
		nadpis("<big>Nápověda:</big>")..
		"Pozice stavby je přibližná. Její přesný rozsah bude určen víceméně tím\\, kolik toho postavíte.\n\n"..
		nadpis("Určení stavby:")..
		"- Soukromá stavba má sloužit především vám a hráčům/kám\\, které na ni sami pozvete\\; Administrace ji nebude posuzovat\\, "..
		"pokud nebudete chtít\\, a když přestanete na delší dobu hrát\\, zůstane vám a zůstane netknutá\\, "..
		"až na případné úpravy nutné ve veřejném zájmu. Administrace ji nebude cíleně prezentovat při prezentaci serveru "..
		"na internetu a nebude jí zřizovat veřejné dopravní spojení. Koho na ni pozvete, bude na vás.\n"..
		"- Veřejná stavba má sloužit především ostatním hráčům/kám a nabízet jim buď krásu\\, symboliku\\, užitečné služby nebo cokoliv\\, "..
		"díky čemuž se jim návštěva stavby vyplatí. Až ji označíte za dokončenou (ke schválení)\\, "..
		"Administrace ji posoudí a může mít připomínky a požadovat důvodné úpravy. "..
		"Pokud přestanete na delší dobu hrát nebo se o stavbu nebudete starat\\, "..
		"správa této stavby může být svěřena jinému hráči/ce\\, "..
		"popř. ji převezme přímo Administrace. Pokud se nedomluvíte s Administrací jinak\\, "..
		"této stavbě může být zřízeno veřejné dopravní spojení a po dokončení bude moci "..
		"být prezentována při prezentaci serveru na internetu.\n\n"..
		nadpis("Druh stavby")..
		"Např. rodinný dům\\, sklad\\, restaurace\\, hřbitov\\, vodopád\\, nádraží\\, výzkumná stanice apod. "..
		"Pokud druh stavby vyplývá již z jejího názvu, může toto pole zůstat nevyplněné.\n\n"..
		nadpis("Záměr stavby")..
		"Pro veřejné stavby je povinný\\, pro soukromé je jen doporučený. Má především odpovědět na otázky, "..
		"proč se do stavby pouštíte a (pokud již víte) k čemu bude daná stavba užitečná. Každá stavba má určitě nějaký důvod, "..
		"i kdyby to mělo být jen to, že vás baví takové stavby stavět. Ale lepší samozřejmě je, pokud se snažíte doplnit něco, "..
		"co podle vás v Českém hvozdu chybí.\n"..
		"Do záměru můžete rovněž zaznamenat svoje plány a další zajímavosti vztahující se ke stavbě, např.:\n"..
		"- Hlavní účel stavby (krása, funkce, odpočinek, ...)\n"..
		"- Jak má stavba vypadat? („v přírodním stylu“, „nástupiště z borového dřeva“, „inspirace Eiffelovou věží“).\n"..
		"- Zajímavosti z historie stavby\\; další hráči/ky, kteří na stavbě spolupracovali apod.\n"..
		"]"..
		"button[4,10.5;4,1;zalozit;Založit stavbu]"..
		"button_exit[8.5,10.5;4,1;zrusit;Zrušit]")
	return table.concat(formspec)
end

local function new_formspec_callback(custom_state, player, formname, fields)
	if fields.quit then
		return
	end
	if fields.nazev ~= nil then custom_state.nazev = fields.nazev end
	if fields.druh ~= nil then custom_state.druh = fields.druh end
	if fields.zamer ~= nil then custom_state.zamer = fields.zamer end
	if fields.urceni ~= nil then custom_state.urceni = assert(tonumber(fields.urceni)) end

	if fields.zalozit then
		local urceni = assert(custom_state.urceni_list[custom_state.urceni])
		local stav = assert(custom_state.stav_list[custom_state.stav])
		local player_name = player:get_player_name()
		local result = ch_core.stavby_add(custom_state.pos, urceni, stav, assert(fields.nazev), assert(fields.druh),
			player_name, assert(fields.zamer))
		if result == nil then
			ch_core.systemovy_kanal(player_name, "Pokus o vytvoření záznamu o stavbě selhal!")
			return
		end
		ch_core.stavby_save()
		ui.set_inventory_formspec(player, "ch_stavby") -- update inventory formspec
		--[[
		ch_core.systemovy_kanal("", ch_core.prihlasovaci_na_zobrazovaci(player_name).." založil/a novou stavbu „"..
			result.nazev.."“ na pozici ("..result.key..")")
			]]
		ch_core.add_event("stavba_new", "{PLAYER} založil/a novou stavbu „"..result.nazev.."“ na pozici ("..result.key..")", player_name)
		if stav == "k_povoleni" and not custom_state.is_admin then
			local area_name, area_owner, area_owner_viewname = "???", "Administrace", "Administrace"
			if has_areas then
				local area_id, area = areas:getMainAreaAtPos(custom_state.pos)
				if area_id and area.type == 7 then
					area_name = area.name
					if area.owner ~= nil and area.owner ~= "" then
						area_owner = area.owner
						area_owner_viewname = ch_core.prihlasovaci_na_zobrazovaci(area_owner)
					end
				end
			end

			if player_name ~= area_owner then
				ch_core.systemovy_kanal(player_name, "VAROVÁNÍ: Založil/a jste stavbu v rezervované oblasti „"..area_name.."“! "..
					"Před zahájením stavebních prací vyčkejte na vyjádření od „"..area_owner_viewname.."“ (mělo by dojít herní poštou). "..
					"Pokud o stavbu mezitím ztratíte zájem, nastavte jí stav „ke zrušení“.")
			end
		end

		minetest.close_formspec(player_name, formname)
		fields.quit = "true"
		return
	end
	return get_new_formspec(custom_state)
end

local function nova_stavba(player_info)
	local player = player_info.player
	local player_pos = vector.round(player:get_pos())
	if ch_core.stavby_get(player_pos) ~= nil then
		return -- na dané pozici již stavba existuje
	end
	local is_admin = ifthenelse(player_info.privs.ch_stavby_admin, true, false)
	local custom_state = {
		pos = player_pos,
		player = player,
		is_admin = is_admin,
		pozice = player_pos.x..","..player_pos.y..","..player_pos.z,
		nazev = "",
		druh = "",
		spravuje = player_info.player_name,
		zamer = "*Proč se do stavby pouštíte? Pokud víte, uveďte i jakékoliv další zajímavosti. "..
			"Obsah tohoto pole budete moci měnit, doplňovat a aktualizovat v průběhu stavby i po jejím dokončení.*",
	}
	local vyzaduje_povoleni = false
	if has_areas then
		local area_id, area = areas:getMainAreaAtPos(player_pos)
		if area_id and area.type == 7 and area.owner ~= player_info.player_name then
			vyzaduje_povoleni = true
		end
	end
	if is_admin then
		custom_state.stav_list = {
			"k_povoleni", "rozestaveno", "k_schvaleni", "hotovo", "rekonstrukce", "opusteno", "k_smazani"
		}
		custom_state.stav = ifthenelse(vyzaduje_povoleni, 1, 2)
		custom_state.urceni_list = {"soukroma", "verejna", "chranena_oblast"}
		custom_state.urceni = 1
	else
		custom_state.stav_list = {ifthenelse(vyzaduje_povoleni, "k_povoleni", "rozestaveno")}
		custom_state.stav = 1
		custom_state.urceni_list = {"soukroma", "verejna"}
		custom_state.urceni = 1
	end
	local formspec = get_new_formspec(custom_state)

	minetest.after(0.1, ch_core.show_formspec, player, "ch_overrides:ch_stavby_new", formspec, new_formspec_callback, custom_state, {})
end



-- Upravit stavbu
-- ==============================================================================
--[[
	custom_state = {
		key = string, -- původní klíč ke stavbě
		player = PlayerRef,
		is_admin = bool, -- je editující postava správce/yně?
		pozice = "", -- pozice, jak je zadaná ve formuláři
		nazev = "",
		druh = "",
		spravuje = "",
		stav = int, -- index do stav_list
		urceni = int, -- index do urceni_list
		zamer = <výchozí text>,
		stav_list = {string...} -- seznam ID stavů ve stejném pořadí jako v dropdown[]
		urceni_list = {string...} -- seznam ID určení ve stejném pořadí jako v dropdown[]
	}
]]

local function get_edit_formspec(custom_state)
	local pinfo = ch_core.normalize_player(custom_state.player)
	local is_admin = custom_state.is_admin
	local formspec = {
		ch_core.formspec_header({formspec_version = 4, size = {16.75, 12.25}, auto_background = true}),
		"image[0.35,0.3;1,1;ch_overrides_ui_stavby.png]"..
		"label[1.5,0.85;Upravit stavbu: "..F(custom_state.nazev).."]"
	}

	table.insert(formspec, string.format(ifthenelse(is_admin, "label[0.5,1.8;pozice:]field[1.75,1.55;5,0.5;pozice;;%s]", "label[0.5,1.8;pozice: %s]"),
		F(custom_state.pozice)))
	table.insert(formspec, "label[0.5,2.3;název stavby:]field[2.75,2.0;4.5,0.5;nazev;;"..F(custom_state.nazev).."]"..
		"label[0.5,2.8;druh stavby:]field[2.75,2.5;4.5,0.5;druh;;"..F(custom_state.druh).."]")
	table.insert(formspec, string.format(
		ifthenelse(is_admin, "label[0.5,3.5;stavbu spravuje:]field[3.25,3.2;4.5,0.5;spravuje;;%s]", "label[0.5,3.5;stavbu spravuje: %s]"),
		F(ch_core.prihlasovaci_na_zobrazovaci(custom_state.spravuje))))
	if #custom_state.stav_list > 1 then
		table.insert(formspec, "label[0.5,4.0;stav stavby:]"..
			"dropdown[0.5,4.25;7.5,0.5;stav;"..F(ch_core.stavy_staveb[custom_state.stav_list[1]]))
		for i = 2, #custom_state.stav_list do
			table.insert(formspec, ","..F(ch_core.stavy_staveb[custom_state.stav_list[i]]))
		end
		table.insert(formspec, ";"..custom_state.stav..";true]")
	else
		table.insert(formspec, "label[0.5,4.0;stav stavby: "..F(ch_core.stavy_staveb[custom_state.stav_list[custom_state.stav]]).."]")
	end

	if #custom_state.urceni_list > 1 then
		table.insert(formspec, "label[0.5,5.25;určení stavby:]"..
			"dropdown[2.25,5;5.75,0.5;urceni;"..F(ch_core.urceni_staveb[custom_state.urceni_list[1]]))
		for i = 2, #custom_state.urceni_list do
			table.insert(formspec, ","..F(ch_core.urceni_staveb[custom_state.urceni_list[i]]))
		end
		table.insert(formspec, ";"..custom_state.urceni..";true]")
	else
		table.insert(formspec, "label[0.5,5.25;určení stavby: "..F(ch_core.urceni_staveb[custom_state.urceni_list[custom_state.urceni]]).."]")
	end

	table.insert(formspec, "textarea[0.5,6;7.5,4;zamer;záměr stavby/poznámka:;")
	table.insert(formspec, F(custom_state.zamer))
	table.insert(formspec, "]"..
		"textarea[8.35,2;8,8;;Nápověda:;\n"..
		"Pro změnu vlastností\\, které nelze změnit zde\\, kontaktujte Administraci.\n\n"..
		"Stav:\n\n"..
		"- čeká na povolení = stavba byla založena v chráněné oblasti\\, kde je pro zahájení prací vyžadováno povolení od Administrace\\; "..
		"před zahájením prací vyčkejte na zprávu od Administrace nebo změňte stav na 'ke smazání', pokud již o stavbu nemáte zájem\n"..
		"- rozestavěná = práce na stavbě byly zahájeny\\, ale nebyly dokončeny\\; nemusí to znamenat\\, že se na stavbě aktivně pracuje\n\n"..
		"- ke schválení = (jen pro veřejné stavby) práce na stavbě byly dokončeny a jste s ní spokojen/a\\; stavbu nyní musí posoudit Administrace\n\n"..
		"- hotová = práce na stavbě byly dokončeny a stavba je schválena k použití\\, nyní může být slavnostně otevřena a používána\\, "..
		"dále bude potřeba stavbu udržovat a rovněž bude možno ji rozšiřovat a renovovat\n\n"..
		"- v rekonstrukci = stavba byla v minulosti dokončena, ale nyní ji nelze používat\\, protože probíhá její renovace/rekonstrukce\n\n"..
		"- opuštěná = opustil/a jste stavbu a již vám nezáleží na jejím osudu\\; taková stavba může být připsána jinému hráči/ce nebo i zbourána\n\n"..
		"- ke smazání = žádáte Administraci o smazání záznamu o stavbě (toto připadá v úvahu\\, především pokud stavební práce ještě nebyly "..
		"zahájeny nebo jste stavbu založili omylem\\; pokud již stavba existuje\\, použijte stav 'opuštěná')\n]")

	table.insert(formspec, "button[4,10.5;4,1;ulozit;Uložit]"..
		"button_exit[8.5,10.5;4,1;zrusit;Zrušit]")
	return table.concat(formspec)
end

local function edit_formspec_callback(custom_state, player, formname, fields)
	if fields.quit then
		return
	end

	if fields.pozice then custom_state.pozice = fields.pozice end
	if fields.nazev then custom_state.nazev = fields.nazev end
	if fields.druh then custom_state.druh = fields.druh end
	if fields.spravuje then custom_state.spravuje = fields.spravuje end
	if fields.stav then custom_state.stav = assert(tonumber(fields.stav)) end
	if fields.urceni then custom_state.urceni = assert(tonumber(fields.urceni)) end
	if fields.zamer then custom_state.zamer = fields.zamer end

	if fields.ulozit then
		local pocet_zmen = 0
		local datum = ch_core.aktualni_cas()
		datum = string.format("%04d-%02d-%02d", datum.rok, datum.mesic, datum.den)
		local urceni, stav = custom_state.urceni_list[custom_state.urceni], custom_state.stav_list[custom_state.stav]
		local player_name = player:get_player_name()
		local player_viewname = ch_core.prihlasovaci_na_zobrazovaci(player_name)
		local record = ch_core.stavby_get(custom_state.key)
		local je_dokonceni, je_povoleni = false, false
		if record == nil then
			return -- chybějící záznam (stavba byla pravděpodobně mezitím odstraněna)
		end
		-- nazev
		if record.nazev ~= custom_state.nazev then
			minetest.log("action", record.key..": will change nazev <"..record.nazev.."> => <"..custom_state.nazev..">")
			table.insert(record.historie, datum.." "..player_viewname.." změnil/a název: „"..record.nazev.."“ => „"..custom_state.nazev.."“")
			record.nazev = custom_state.nazev
			pocet_zmen = pocet_zmen + 1
		end
		-- druh
		if record.druh ~= custom_state.druh then
			minetest.log("action", record.key..": will change druh <"..record.druh.."> => <"..custom_state.druh..">")
			table.insert(record.historie, datum.." "..player_viewname.." změnil/a druh: „"..record.druh.."“ => „"..custom_state.druh.."“")
			record.druh = custom_state.druh
			pocet_zmen = pocet_zmen + 1
		end
		-- spravuje
		local new_spravuje = ch_core.jmeno_na_prihlasovaci(custom_state.spravuje)
		if record.spravuje ~= new_spravuje then
			minetest.log("action", record.key..": will change spravuje <"..record.spravuje.."> => <"..new_spravuje..">")
			table.insert(record.historie, datum.." "..player_viewname.." předal/a správu: „"..ch_core.prihlasovaci_na_zobrazovaci(record.spravuje).."“ => „"..
				ch_core.prihlasovaci_na_zobrazovaci(new_spravuje).."“")
			record.spravuje = new_spravuje
			pocet_zmen = pocet_zmen + 1
		end
		-- stav
		if record.stav ~= stav then
			minetest.log("action", record.key..": will change stav <"..record.stav.."> => <"..stav..">")
			table.insert(record.historie, datum.." "..player_viewname.." změnil/a stav: „"..(ch_core.stavy_staveb[record.stav] or "???").."“ => „"..
				(ch_core.stavy_staveb[stav] or "???").."“")
			je_povoleni = record.stav == "k_povoleni" and stav == "rozestaveno"
			record.stav = stav
			je_dokonceni = stav == "hotovo"
			pocet_zmen = pocet_zmen + 1
		end
		-- urceni
		if record.urceni ~= urceni then
			minetest.log("action", record.key..": will change urceni <"..record.urceni.."> => <"..urceni..">")
			table.insert(record.historie, datum.." "..player_viewname.." změnil/a určení: „"..(ch_core.urceni_staveb[record.urceni] or "???").."“ => „"..
				(ch_core.urceni_staveb[urceni] or "???").."“")
			record.urceni = urceni
			pocet_zmen = pocet_zmen + 1
		end
		-- zamer
		if record.zamer ~= custom_state.zamer then
			minetest.log("action", record.key..": will change zamer <"..record.zamer.."> => <"..custom_state.zamer..">")
			local message = datum.." "..player_viewname.." upravil/a záměr stavby"
			if record.historie[#record.historie] ~= message then
				table.insert(record.historie, message)
			end
			record.zamer = custom_state.zamer
			pocet_zmen = pocet_zmen + 1
		end

		-- pozice
		local parts = string.split(custom_state.pozice, ",")
		if #parts == 3 then
			local x, y, z = tonumber(parts[1]), tonumber(parts[2]), tonumber(parts[3])
			if x ~= nil and y ~= nil and z ~= nil and x == math.round(x) and y == math.round(y) and z == math.round(z) then
				local new_pos = vector.new(x, y, z)
				if new_pos.x ~= record.pos.x or new_pos.y ~= record.pos.y or new_pos.z ~= record.pos.z then
					local old_key = record.key
					minetest.log("warning", "Will move stavba: ("..record.key..") => ("..new_pos.x..","..new_pos.y..","..new_pos.z..")")
					if ch_core.stavby_move(record.key, new_pos) then
						table.insert(record.historie, datum.." "..player_viewname.." přesunul/a stavbu: "..old_key.." => "..record.key)
						pocet_zmen = pocet_zmen + 1
					else
						minetest.log("error", "stavby_move() failed!")
						ch_core.systemovy_kanal(player_name, "Přesun stavby selhal!")
					end
				end
			end
		end
		ch_core.stavby_save()
		ui.set_inventory_formspec(player, "ch_stavby") -- update inventory formspec
		minetest.close_formspec(player_name, formname)
		local word
		if pocet_zmen == 1 then
			word = "změna stavby uložena"
		elseif pocet_zmen >= 2 and pocet_zmen <= 4 then
			word = "změny stavby uloženy"
		else
			word = "změn stavby uloženo"
		end

		-- ch_core.systemovy_kanal(player_name, pocet_zmen.." "..word..".")
		if je_dokonceni then
			ch_core.add_event("stavba_finished", "{PLAYER} dokončil/a stavbu „"..assert(record.nazev)..
				"“ na pozici ("..assert(record.key)..")", assert(record.spravuje))
		elseif je_povoleni then
			ch_core.add_event("stavba_povolena", "{PLAYER} povolil/a stavbu „"..assert(record.nazev).."“ na ("..assert(record.key)..")",
				assert(player_name))
		else
			ch_core.add_event("stavba_changed", "{PLAYER} změnil/a stavbu na pozici ("..assert(record.key).."): "..pocet_zmen.." "..word,
				assert(player_name))
		end

		fields.quit = "true"
		return
	end

	local update_formspec = false

	if fields.pozice ~= nil then custom_state.pozice = fields.pozice end
	if fields.nazev ~= nil then custom_state.nazev = fields.nazev end
	if fields.druh ~= nil then custom_state.druh = fields.druh end
	if fields.zamer ~= nil then custom_state.zamer = fields.zamer end
	if fields.urceni ~= nil then
		custom_state.urceni = fields.urceni
	end
	if update_formspec then
		return get_new_formspec(custom_state)
	end
end

local function upravit_stavbu(player_info)
	local player = player_info.player
	local player_name = player_info.player_name
	local stavby_charinfo = get_stavby_online_charinfo(player_name)
	local key = stavby_charinfo.selected_key or ""
	if key == "" then
		ch_core.systemovy_kanal(player_name, "Není vybraná žádná stavba.")
		return
	end
	local stavba = ch_core.stavby_get(key)
	if stavba == nil then
		ch_core.systemovy_kanal(player_name, "Chybné ID stavby (pravděpodobně vnitřní chyba).")
		minetest.log("error", player_name..": cannot stavby_get("..key..")")
		return
	end
	local is_admin = ifthenelse(player_info.privs.ch_stavby_admin, true, false)
	if not is_admin and player_name ~= stavba.spravuje then
		-- access denied
		ch_core.systemovy_kanal(player_name, "Přístup odepřen.")
		return
	end
	local custom_state = {
	--[[
		custom_state = {
			key = string, -- původní klíč ke stavbě
			player = PlayerRef,
			is_admin = bool, -- je editující postava správce/yně?
			pozice = "", -- pozice, jak je zadaná ve formuláři
			nazev = "",
			druh = "",
			spravuje = "",
			zamer = <výchozí text>,
			stav = int, -- index do stav_list
			urceni = int, -- index do urceni_list
			stav_list = {string...} -- seznam ID stavů ve stejném pořadí jako v dropdown[]
			urceni_list = {string...} -- seznam ID určení ve stejném pořadí jako v dropdown[]
		}
	]]
		key = key,
		player = player,
		is_admin = is_admin,
		pozice = stavba.pos.x..","..stavba.pos.y..","..stavba.pos.z,
		nazev = assert(stavba.nazev),
		druh = assert(stavba.druh),
		spravuje = assert(stavba.spravuje),
		zamer = assert(stavba.zamer),
	}
	if is_admin then
		custom_state.stav_list = {
			"k_povoleni", "rozestaveno", "k_schvaleni", "hotovo", "rekonstrukce", "opusteno", "k_smazani"
		}
		local stav, urceni
		for i = 1, #custom_state.stav_list do
			if stavba.stav == custom_state.stav_list[i] then
				stav = i
				break
			end
		end
		if stav == nil then error("Stavba ma neznamy stav '"..stavba.stav.."'!") end
		custom_state.urceni_list = {"soukroma", "verejna", "chranena_oblast"}
		for i = 1, #custom_state.urceni_list do
			if stavba.urceni == custom_state.urceni_list[i] then
				urceni = i
				break
			end
		end
		if urceni == nil then error("Stavba ma nezname urceni '"..stavba.urceni.."'!") end
		custom_state.stav = stav
		custom_state.urceni = urceni
	else
		custom_state.urceni_list = {stavba.urceni}
		custom_state.urceni = 1

		if stavba.stav == "k_povoleni" then
			custom_state.stav_list = {"k_povoleni", "k_smazani"}
			custom_state.stav = 1
		elseif stavba.stav == "rozestaveno" then
			custom_state.stav_list = {"rozestaveno", ifthenelse(stavba.urceni == "verejna", "k_schvaleni", "hotovo"), "opusteno"}
			custom_state.stav = 1
		elseif stavba.stav == "k_schvaleni" then
			custom_state.stav_list = {"rozestaveno", "k_schvaleni", "opusteno"}
			custom_state.stav = 2
		elseif stavba.stav == "hotovo" then
			custom_state.stav_list = {"hotovo", "rekonstrukce", "opusteno"}
			custom_state.stav = 1
		elseif stavba.stav == "rekonstrukce" then
			custom_state.stav_list = {ifthenelse(stavba.urceni == "verejna", "k_schvaleni", "hotovo"), "rekonstrukce", "opusteno"}
			custom_state.stav = 2
		elseif stavba.stav == "opusteno" then
			custom_state.stav_list = {"opusteno"}
			custom_state.stav = 1
		elseif stavba.stav == "k_smazani" then
			custom_state.stav_list = {"k_povoleni", "k_smazani"}
			custom_state.stav = 2
		else
			minetest.log("warning", "Unsupported stav '"..stavba.stav.."'!")
			custom_state.stav_list = {stavba.stav}
			custom_state.stav = 1
		end
	end
	local formspec = get_edit_formspec(custom_state)

	minetest.after(0.1, ch_core.show_formspec, player, "ch_overrides:ch_stavby_edit", formspec, edit_formspec_callback, custom_state, {})
end


local function on_player_receive_fields(player, formname, fields)
	if formname ~= "" then return end

	local pinfo = ch_core.normalize_player(player)
	local player_name = pinfo.player_name

	if fields.ui_stavba ~= nil then
		local stavby_charinfo = get_stavby_online_charinfo(player_name)
		local event = minetest.explode_table_event(fields.ui_stavba)
		if event.type == "CHG" or event.type == "DCL" then
			-- Nastavit vybranou stavbu
			if event.row == 1 then
				-- žádná vybraná stavba
				stavby_charinfo.selected_key = ""
				ui.set_inventory_formspec(player, "ch_stavby")
			elseif stavby_charinfo.selected_key ~= stavby_charinfo.displayed_table[event.row] then
				stavby_charinfo.selected_key = stavby_charinfo.displayed_table[event.row]
				if event.type ~= "DCL" then
					ui.set_inventory_formspec(player, "ch_stavby")
				end
			end
			if event.type == "DCL" and stavby_charinfo.selected_key ~= "" then
				upravit_stavbu(pinfo)
				return
			end
		end
	elseif fields.ch_stavby_filtr ~= nil then
		local stavby_charinfo = get_stavby_online_charinfo(player_name)
		local volba = tonumber(fields.ch_stavby_filtr)
		if volba ~= nil and filters[volba] ~= nil then
			stavby_charinfo.active_filter = volba
			ui.set_inventory_formspec(player, "ch_stavby")
		end
	end

	if fields.ch_stavby_nova then
		nova_stavba(pinfo)
		return
	elseif fields.ch_stavby_upravit then
		upravit_stavbu(pinfo)
		return
	elseif fields.ch_stavby_smazat then
		if pinfo.privs.ch_stavby_admin then
			local stavby_charinfo = get_stavby_online_charinfo(player_name)
			local key = stavby_charinfo.selected_key
			if key ~= nil and ch_core.stavby_get(key) ~= nil then
				if ch_core.stavby_remove(key) then
					ch_core.stavby_save()
					ch_core.systemovy_kanal(pinfo.player_name, "Stavba "..key.." byla smazána!")
					ui.set_inventory_formspec(player, "ch_stavby")
				else
					ch_core.systemovy_kanal(pinfo.player_name, "Pokus o smazání stavby selhal!")
				end
				return
			else
				minetest.log("warning", "Internal error: attempt to remove a stavba with the key '"..(key or "nil").."'!")
			end
		end
	end
end
minetest.register_on_player_receive_fields(on_player_receive_fields)

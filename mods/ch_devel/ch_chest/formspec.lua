local internal = ...

local ifthenelse = ch_core.ifthenelse
local F = core.formspec_escape

--[[
	custom_state = {
		pos = pos,
		player_name = string,
		-- bag = int, -- 0 = hl. inventář, 1..6 = batoh 1 až 6, -1 = koš (zatím neimplementováno)
		page = string, -- "main" = inventář truhly, "set" = nastavení, "help" = nápověda
	}
]]

local function get_formspec(custom_state)
	local player_name = custom_state.player_name
	local player = core.get_player_by_name(player_name)
	if player == nil then
		return nil -- player must be in-game
	end
	local pos = custom_state.pos
	local node = core.get_node(pos)
	local meta = core.get_meta(pos)
	local function get_feature(feature)
		return internal.get_feature(node.name, meta, feature)
	end
	local player_bags = unified_inventory.get_bags_info(player)
	local chest_title = ""
	if get_feature("has_title") then
		chest_title = meta:get_string("title")
	end
	local chest_width, chest_height = get_feature("width"), get_feature("height")
	local chest_inv = "nodemeta:"..pos.x.."\\,"..pos.y.."\\,"..pos.z
	local ownership = get_feature("ownership")
	local chest_owner
	if ownership == "owner" then
		chest_owner = meta:get_string("owner")
	end
	local listrings = {}
	local formspec = {
		ch_core.formspec_header{
			formspec_version = 6,
			size = {26, 16},
			auto_background = true,
		},
		-- settings taken from Technic Chests mod:
		"style_type[list;spacing=0.2,0.2]",
		"listcolors[#7b7b7b;#909090;#000000;#6e823c;#ffffff]",
	}
	local function a(s)
		table.insert(formspec, s)
	end
	local button_x = 20.75
	local button_y = 0.25
	local button_w = 2
	local button_h = 0.75
	local button_xstep = button_w + 0.25

	a("button["..button_x..","..button_y..";"..button_w..","..button_h..";sw_help;nápověda]")
	button_x = button_x - button_xstep
	--[[ -- not implemented yet
	if player_rights.sort then
		a("button["..button_x..","..button_y..";"..button_w..","..button_h..";sort;seřadit]")
		button_x = button_x - button_xstep
	end
	]]
	if internal.can_setup(node.name, meta, player_name) then
		a("button["..button_x..","..button_y..";"..button_w..","..button_h..";sw_nastaveni;nastavení]")
		button_x = button_x - button_xstep
	end
	a("button["..button_x..","..button_y..";"..button_w..","..button_h..";sw_obsah;obsah truhly]")

	-- core.itemstring_with_palette(node.name, node.param2 - node.param2 % 4)
	a("style[titlebutton;border=false]"..
	  "item_image_button[0.25,0.25;1,1;"..F(core.itemstring_with_palette(node.name, node.param2 - node.param2 % 4))..";titlebutton;]")
	if custom_state.page == "main" then
		-- obsah truhly
		a("label[1.5,0.75;"..F(core.colorize("#00ff00", chest_title)).." — obsah truhly]")

		if chest_height > 6 then
			a("scroll_container[0.25,1.5;25,7.25;sb;vertical]")
		else
			a("container[0.25,1.5]")
		end
		--box[0,0;50,50;#ff0000]
		a("list["..chest_inv..";main;0,0;"..chest_width..","..chest_height..";0]")
		table.insert(listrings, chest_inv..";main")
		if chest_height > 6 then
			a("scroll_container_end[]"..
			  "scrollbaroptions[max=50]".. -- [ ] TODO!
			 "scrollbar[25.25,1.5;0.5,7.25;vertical;sb;0]")
		else
			a("container_end[]")
		end
		a("button[0.5,9.5;4.5,1;tochestex;Přesunout do truhly věci\\,\njaké už tam jsou]"..
		  "label[0.6,11;Přesunout konkrétní:\n(pusťte pro přesun)]"..
		  "list["..chest_inv..";qmove;3.5,10.75;1,1;0]"..
		  "button[0.5,12.0;4.5,1;tochest;Vše z inventáře do truhly ⇈]"..
		  "button[0.5,13.25;4.5,1;fromchest;Vše z truhly do inventáře ⇊]")

	elseif custom_state.page == "set" and internal.can_setup(node.name, meta, player_name) then
		-- nastavení
		a("label[1.5,0.75;"..F(chest_title).." — nastavení truhly]"..
		  "label[0.25,1.75;kapacita: "..chest_width.."x"..chest_height.."]")
		-- a("list["..chest_inv..";upgrades;0.25,2;1,"..upgrades_count..";0]")
		if ownership == "owner" then
			a("label[3,1.9;truhlu vlastní: "..ch_core.prihlasovaci_na_zobrazovaci(chest_owner).."]")
		end
		if chest_title ~= nil then
			a("field[3,2.4;4,0.5;title;název truhly:;"..F(custom_state.title).."]"..
				"button[7.25,2.3;2,0.75;set_title;nastavit]")
		end
		a("label[3,3.5;režim řazení:]"..
		  "dropdown[3,3.7;4,0.5;sort_mode;výchozí režim,jiný režim;"..(1 + custom_state.sort_mode)..";true]"..
		  "checkbox[3,4.75;autosort;automatické řazení;"..ifthenelse(meta:get_int("autosort") ~= 0, "true", "false").."]")
		if get_feature("pipeworks") then
			a("checkbox[3,5.5;splitstacks;povolit dělení dávek při vstupu z rour;"..ifthenelse(meta:get_int("splitstacks") ~= 0, "true", "false").."]")
		end

		--[[
		if player_rights.admin or player_rights.owner then
			a("box[9.75,1.25;4.5,8;#0000ff99]"..
			  "label[10,1.75;přístupová práva:]"..
			  "label[11.5,2.25;vlas.]"..
			  "label[12.25,2.25;skup.]"..
			  "label[13,2.25;ost.]"..

			  "label[10,2.75;zobrazit]"..
			  "label[10,3.25;řadit]"..
			  "label[10,3.75;vkládat]"..
			  "label[10,4.25;brát]"..
			  "label[10,4.75;vytěžit]"..
			  "label[10,5.25;nastavit]")

			local s = meta:get_string("rights")
			for x = 0, 2 do
				for y = 0, 5 do
					local i = 3 * y + x + 1
					if (i ~= 1 and i ~= 16) or player_rights.admin then
						a("checkbox["..(11.5 + x * 0.75)..","..(2.75 + y * 0.5)..";right_"..i..";;"..ifthenelse(s:sub(i, i) == "1", "true", "false").."]")
					end
				end
			end
			a("textarea[10,6;4,2.5;group_members;skupina:;")
			local agroup = meta:get_string("agroup")
			s = {}
			for pname in agroup:gmatch("[^|]+") do
				table.insert(s, ch_core.prihlasovaci_na_zobrazovaci(pname))
			end
			if #s > 0 then
				a(F(table.concat(s, "\n")))
			end
			a("]"..
			  "button[10,8.5;4,0.5;group_members_set;nastavit]")

			local given_state = meta:get_int("ch_given")
			if player_rights.admin then
				-- zobrazení pro Administraci:
				if given_state == NOT_GIVEN then
					-- nedarovaná truhla
					a("label[14.5,1.75;vlastník/ice:]"..
						"field[14.5,2.25;3,0.5;vlastnik_ice;vlastník/ice:;"..F(ch_core.prihlasovaci_na_zobrazovaci(meta:get_string("owner"))).."]"..
						"button[14.5,3.25;3,0.75;nastavit_vlastnictvi;nastavit]")
				else
					a("label[14.5,1.75;darováno ("..ifthenelse(given_state == GIVEN_ANONYMOUSLY, "anonymně", "otevřeně").."):]"..
						"field[14.5,2.25;3,0.5;vlastnik_ice;vlastník/ice:;"..F(ch_core.prihlasovaci_na_zobrazovaci(meta:get_string("ch_given_by"))..">>>"..ch_core.prihlasovaci_na_zobrazovaci(meta:get_string("ch_given_to"))).."]"..
						"button[14.5,3.25;3,0.75;nastavit_vlastnictvi;nastavit]")
				end
			elseif given_state == NOT_GIVEN then
				-- nedarovaná truhla, vlastník/ice ji může darovat
				a("label[14.5,1.75;darovat:]"..
				  "field[14.5,2.25;3,0.5;darovat_komu;komu:;"..F(custom_state.darovat_komu).."]"..
				  "checkbox[14.5,3;darovat_anonym;anonymně;"..ifthenelse(custom_state.darovat_anonym, "true", "false").."]"..
				  "tooltip[anonymne;zaškrtnete-li toto pole, vaše jméno na truhle nebude zobrazeno\\,\ntakže adresát/ka nebude vědět\\, od koho truhlu dostal/a]"..
				  "button[14.5,3.25;3,0.75;darovat;darovat]") -- /přijmout/zrušit
			elseif player_name == meta:get_string("ch_given_by") then
				-- darovaná truhla; původní vlastník/ice může darování zrušit
				a("label[14.5,1.75;darováno komu:]"..
				  "field[14.5,2.25;3,0.5;darovat_komu;komu:;"..F(ch_core.prihlasovaci_na_zobrazovaci(meta:get_string("ch_given_to"))).."]"..
				  "button[14.5,3.25;3,0.75;dar_zrusit;zrušit]")
			else
				-- darovaná truhla; adresát/ka ji může přijmout
				a("label[14.5,1.75;tato truhla vám byla darována]")
				if given_state == GIVEN_OPENLY then
					a("label[14.5,2.25;darováno od: "..F(ch_core.prihlasovaci_na_zobrazovaci(meta:get_string("ch_given_by"))).."]")
				end
				a("button[14.5,3.25;3,0.75;dar_prijmout;přijmout]")
			end
		end
		]]
	-- elseif custom_state.page == "help" then

	end

	if custom_state.bag == 0 then
		-- hlavní inventář
		a("list[current_player;main;5.5,9.5;8,4;0]")
		table.insert(listrings, "current_player;main")
	elseif custom_state.bag >= 1 and custom_state.bag <= 6 and player_bags["bag"..custom_state.bag] ~= nil then
		-- batoh
		-- local current_bag = player_bags["bag"..custom_state.bag]
		a("list[current_player;bag"..custom_state.bag.."contents;5.5,9.5;9,5;0]"..
		  "listright[current_player;bag"..custom_state.bag.."contents]")
		table.insert(listrings, "current_player;bag"..custom_state.bag.."contents")
	-- elseif custom_state.bag == -1 then
		-- koš (zatím neimplementováno)
		-- [ ] TODO
	end

	a("button[16.5,9.5;4,0.75;hlinventar;hlavní inventář]")
	for i = 1, 6 do
		local current_bag = player_bags["bag"..i]
		if current_bag ~= nil then
			local x, y
			if i < 4 then
				x = "16.5"
				y = tostring(9.5 + i)
			else
				x = "21"
				y = tostring(5.5 + i)
			end
			a("button["..x..","..y..";4,0.75;batoh"..i..";"..F(current_bag.title).."]")
		end
	end
	-- a("button[20,12.5;4,0.75;kosinv;koš]")
	a("button_exit[25,0.25;0.75,0.75;zavrit;x]")
	if #listrings >= 2 then
		listrings[1] = "listring["..listrings[1]
		listrings[#listrings] = listrings[#listrings].."]"
		a(table.concat(listrings, "]listring["))
	end
	return table.concat(formspec)
end

local function formspec_callback(custom_state, player, formname, fields)
	print("DEBUG: fields = "..dump2(fields))
	local player_name = assert(player:get_player_name())
	if fields.quit then
		return
	end

	local meta = core.get_meta(custom_state.pos)
	local node = core.get_node(custom_state.pos)
	local update_formspec = false

	-- 1. Aktualizovat custom_state:
	if fields.title ~= nil then
		custom_state.title = fields.title
	end
	--[[
	if fields.darovat_komu ~= nil then
		custom_state.darovat_komu = fields.darovat_komu
	end
	if fields.darovat_anonym ~= nil then
		custom_state.darovat_anonym = fields.darovat_anonym ~= "false"
	end
	]]

	-- 2. Ovládací prvky formuláře (nevyžadují zvláštní práva)
	if fields.sw_obsah then
		custom_state.page = "main"
		update_formspec = true
	elseif fields.sw_nastaveni then
		custom_state.page = "set"
		update_formspec = true
	elseif fields.sw_help then
		custom_state.page = "help"
		update_formspec = true
	end

	if fields.hlinventar then
		custom_state.bag = 0
		--[[
		internal.player_to_current_inventory[player_name] = {
			inv = player:get_inventory(),
			location = "current_player",
			listname = "main",
		}
		]]
		update_formspec = true
	else
		for i = 1, 6 do
			if fields["batoh"..i] then
				custom_state.bag = i
				--[[
				internal.player_to_current_inventory[player_name] = {
					inv = player:get_inventory(),
					location = "current_player",
					listname = "bag"..i.."contents",
				}
				]]
				break
			end
			update_formspec = true
		end
		-- [ ]TODO: fields.kosinv
	end

	-- 3. Základní nastavení (vyžaduje právo "set")
	if internal.can_setup(node.name, meta, player_name)  then
		if fields.set_title then
			meta:set_string("title", fields.title or "")
			update_formspec = true
		end
		if fields.sort_mode and tonumber(fields.sort_mode) - 1 ~= meta:get_int("sort_mode") then
			meta:set_int("sort_mode", tonumber(fields.sort_mode) - 1)
		end
		if fields.autosort and ((meta:get_int("autosort") ~= 0) ~= (fields.autosort ~= "false")) then
			meta:set_int("autosort", ifthenelse(fields.autosort ~= "false", 1, 0))
		end
		if fields.splitstacks and ((meta:get_int("splitstacks") ~= 0) ~= (fields.splitstacks ~= "false")) then
			meta:set_int("splitstacks", ifthenelse(fields.splitstacks ~= "false", 1, 0))
		end

		-- local is_owner_or_admin = ownership == "none" or player_name == meta:get_string("owner") or ch_core.get_player_role(player_name) == "admin"

		-- 4. Nastavení jen pro vlastníka/ici//admina/ici
		-- if is_owner_or_admin then
			--[[ Přístupová práva:

			for k, new_state in pairs(fields) do
				if k:sub(1,6) == "right_" then
					local n = tonumber(k:sub(7,-1))
					if n == nil then
						core.log("error", "Cannot parse field: '"..k.."'!")
					elseif n >= 1 and n <= 18 then
						-- TODO: only admin can set the right '1'
						local rights = meta:get_string("rights")
						local new_rights = rights:sub(1, n - 1)..ifthenelse(new_state == "true", "1", "0")..rights:sub(n + 1, -1)
						meta:set_string("rights", new_rights)
						print("DEBUG: rights changed:\nold = "..rights.."\nnew = "..new_rights)
					else
						core.log("warning", "Field "..k.." is out of range!")
					end
				end
			end
			]]
			--[[
			if fields.group_members_set then -- členství ve skupině
				internal.set_group_members(meta, fields.group_members)
				update_formspec = true
			end ]]
			-- darování:
			--[[
			if fields.darovat and meta:get_int("ch_given") == NOT_GIVEN then
				local give_to = ch_core.jmeno_na_prihlasovaci(fields.darovat_komu)
				local owner = meta:get_string("owner")
				if give_to == owner then
					ch_core.systemovy_kanal(player_name, "CHYBA: nemůžete darovat truhlu sobě!")
				elseif not core.player_exists(give_to) then
					ch_core.systemovy_kanal(player_name, "CHYBA: postava '"..fields.darovat_komu.."' neexistuje!")
				else
					meta:set_int("ch_given", ifthenelse(custom_state.darovat_anonym, GIVEN_ANONYMOUSLY, GIVEN_OPENLY))
					meta:set_string("ch_given_by", owner)
					meta:set_string("ch_given_to", give_to)
					update_formspec = true
				end
			elseif fields.dar_zrusit and meta:get_int("ch_given") ~= NOT_GIVEN then
				meta:set_int("ch_given", NOT_GIVEN)
				meta:set_string("owner", meta:get_string("ch_given_by"))
				meta:set_string("ch_given_by", "")
				meta:set_string("ch_given_to", "")
				update_formspec = true
			elseif fields.dar_prijmout  and meta:get_int("ch_given") ~= NOT_GIVEN then
				meta:set_int("ch_given", NOT_GIVEN)
				meta:set_string("owner", meta:get_string("ch_given_to"))
				meta:set_string("ch_given_by", "")
				meta:set_string("ch_given_to", "")
				update_formspec = true
			end
			]]
		-- end
	end

	--[[ 4. Ostatní funkce
	if fields.tochestex and internal.can_put(node.name, meta, player_name) then
		-- přesunout do truhly věci, jaké už tam jsou
		local ci = internal.player_to_current_inventory[player_name]
		if ci ~= nil then
			internal.move_ex(ci.inv, ci.listname, meta:get_inventory(), "main")
		end

	elseif fields.tochest and internal.can_put(node.name, meta, player_name) then
		local ci = internal.player_to_current_inventory[player_name]
		if ci ~= nil then
			internal.move_all(ci.inv, ci.listname, meta:get_inventory(), "main")
		end

	elseif fields.fromchest and internal.can_take(node.name, meta, player_name) then
		local ci = internal.player_to_current_inventory[player_name]
		if ci ~= nil then
			internal.move_all(meta:get_inventory(), "main", ci.inv, ci.listname)
		end

	-- elseif fields.sort and player_rights.sort then
--		internal.sort_inventory(meta:get_int("sort_mode"), meta:get_inventory(), "main")
	end
	]]

	if update_formspec then
		return get_formspec(custom_state)
	end
end

function internal.show_formspec(player, pos, node, meta)
	local player_name = assert(player:get_player_name())
	assert(meta)
	assert(node and node.name)
	local custom_state = {
		pos = assert(pos),
		player_name = player_name,
		bag = 0,
		page = "main",
		title = meta:get_string("title"),
		sort_mode = meta:get_int("sort_mode"),
		group_members = meta:get_string("agroup_raw"),
		darovat_komu = "",
		darovat_anonym = false,
	}
	--[[
	internal.player_to_current_inventory[player_name] = {
		inv = player:get_inventory(),
		location = "current_player",
		listname = "main",
	}
	]]
	ch_core.show_formspec(player, "ch_chest:chest", get_formspec(custom_state), formspec_callback, custom_state, {})
end

local F = core.formspec_escape
local player_to_door_pos = {}

local function ifthenelse(c, t, f)
	if c then
		return t
	else
		return f
	end
end

local function get_base_door_name(name)
	local ndef = core.registered_items[name]
	if ndef ~= nil then
		local new_name = ndef.drop
		if type(new_name) == "string" and core.registered_items[new_name] ~= nil then
			return new_name
		end
	end
	return name
end

function doors.show_control_panel(player, door_pos)
	local player_name = player:get_player_name()
	local player_is_admin = core.check_player_privs(player, "protection_bypass")
	local node = core.get_node(door_pos)
	local obj = doors.get(door_pos)
	if not obj then
		return false -- not a door
	end
	local base_door_name = node.name
	if type((core.registered_nodes[base_door_name] or {}).drop) == "string" then

	end
	local meta = core.get_meta(door_pos)
	local owner, owner_type = meta:get_string("owner"), "owner"
	if owner == "" then
		owner = meta:get_string("placer")
		owner_type = ifthenelse(owner ~= "", "placer", "none")
	end
	local hes = meta:get_int("hes")
	local vlastnik_ice = "není"
	if owner ~= "" then
		vlastnik_ice = doors.login_to_viewname(owner)
	else
		vlastnik_ice = "není"
	end
	local is_open = obj:state()
	local zachodove = meta:get_int("zachodove") > 0
	local zavirasamo = meta:get_int("zavirasamo") > 0
	local zakotsam = meta:get_int("zakotsam") > 0
	local bghighlight = "#666666"

	local formspec = {
		"formspec_version[4]"..
		"size[12,7.1]"..
		"field[11.0,0.25;0.5,0.5;ignore;;]"..
		"item_image[0.25,0.25;1,1;", F(get_base_door_name(node.name)), "]"..
		"label[1.5,0.8;Ovládací panel dveří]"..
		"container[0,1.5]"..
		"box[0,0;12,0.75;", bghighlight, "]",
	}
	local function f(...)
		table.insert_all(formspec, {...})
	end

	if owner_type == "owner" and player_is_admin then
		f("label[0.375,0.4;Vlastník/ice:]"..
			"field[2.75,0.125;5,0.5;owner;;"..F(vlastnik_ice).."]"..
			"button[8,0.125;2,0.5;set_owner;nastavit]")
	else
		f("label[0.375,0.4;", ifthenelse(owner_type == "placer", "Dveře postavil/a", "Vlastník/ice"), ": ", F(vlastnik_ice), "]")
	end

	f("checkbox[0.375,1.125;private;soukromé;", ifthenelse(owner_type == "owner", "true", "false") ,"]"..
		"tooltip[private;Soukromé dveře může otevřít jen jejich vlastník/ice (a Administrace).]",
		"checkbox[2.5,1.125;zavirasamo;zavírá samo;", ifthenelse(zavirasamo, "true", "false"), "]"..
		"tooltip[zavirasamo;Je-li zaškrtnuto\\, dveře se automaticky zavřou\\, když není žádná hráčská postav poblíž.]")
	local wc_supported
	if zachodove then
		wc_supported = true
	else
		local hidden_name = doors.get_wc_hidden_name(node.name, false)
		wc_supported = hidden_name ~= "doors:hidden" and hidden_name ~= "air"
	end
	if wc_supported then
		f(	"checkbox[5,1.125;zachodove;záchodové;", ifthenelse(zachodove, "true", "false"), "]"..
			"tooltip[zachodove;Záchodové dveře mají automatický zámek s barevnou indikací. Ta se nastaví na červenou\\,\n"..
			"jsou-li dveře zavřeny zevnitř. Je-li červená\\, jdou dveře otevřít jen zevnitř.]")
	end
	f(	"checkbox[7.5,1.125;zakotsam;zakázat „otevírá samo“;", ifthenelse(zakotsam, "true", "false"), "]"..
		"tooltip[zakotsam;Je-li zaškrtnuto\\, dveře se neotevřou samy postavám\\, které mají tuto funkci aktivovanou.]"..

		"box[0,1.5;12,0.75;", bghighlight, "]")
	if hes ~= 0 then
		f("checkbox[0.375,1.9;hotelove;hotelové (kód "..hes..");true]")
	else
		f("checkbox[0.375,1.9;hotelove;hotelové (zapnutí vyžaduje: nenastavený klíč ke dveřím);false]")
	end
	f("tooltip[hotelove;Hotelové dveře může otevřít jen postava\\, která má v inventáři odpovídající klíč.\n"..
		"Dále je může otevřít jejich vlastník/ice či Administrace.]"..

		"label[0.375,2.65;Stav: ", ifthenelse(is_open, "otevřeno", "zavřeno"), "]"..
		"button[2.6,2.4;2,0.5;", ifthenelse(is_open, "closedoor", "opendoor"), ";", ifthenelse(is_open, "zavřít", "otevřít") ," dveře]"..

		"box[0,3;12,0.75;", bghighlight, "]"..
		"label[0.375,3.4;Název dveří:]"..
		"field[2.2,3.15;5,0.5;nazevdveri;;", F(meta:get_string("nazev")), "]"..
		"button[7.5,3.15;2,0.5;ulozitnazev;uložit]"..
		"container_end[]"..

		"button_exit[1,6;10,0.75;zavrit;Zavřít ovládací panel]")

	formspec = table.concat(formspec)

	player_to_door_pos[player_name] = door_pos
	core.show_formspec(player_name, "doors:door_cpanel", formspec)
end

local function on_player_receive_fields(player, formname, fields)
	if formname ~= "doors:door_cpanel" then
		return
	end
	if not player or not player:is_player() or not core.check_player_privs(player, "ch_registered_player") then
		return false
	end
	local player_name = player:get_player_name()
	local door_pos = player_to_door_pos[player_name]
	if not door_pos then
		core.log("warning", "Door position for player "..player_name.." has not been saved!")
		return false
	end
	local door_node = core.get_node(door_pos)
	local door_obj = doors.get(door_pos)
	if not door_obj then
		core.log("warning", door_node.name.." is not a registered door!")
		return false
	end
	local player_is_admin = core.check_player_privs(player, "protection_bypass")

	if fields.quit then
		return true
	end
	local is_open = door_obj:state()
	local meta = core.get_meta(door_pos)

	if (not is_open and fields.opendoor) or (is_open and fields.closedoor) then
		door_obj:toggle(player)
		door_node = core.get_node(door_pos)
	end

	-- Check configuration rights:
	local hasConfigRights
	local owner = meta:get_string("owner")
	if owner == "" then
		owner = meta:get_string("placer")
	end
	hasConfigRights = player_name == owner or player_is_admin

	if player_is_admin and fields.set_owner then
		local n = doors.viewname_to_login(fields.owner or "") or ""
		if core.player_exists(n) then
			meta:set_string("owner", n)
			meta:set_string("placer", "")
		else
			core.chat_send_player(player_name, "Postava '"..tostring(fields.owner).."' neexistuje!")
		end
	end

	if hasConfigRights then
		-- buttons:
		if fields.ulozitnazev then
			meta:set_string("nazev", fields.nazevdveri or "")
		end
		-- private:
		local expected = ifthenelse(meta:get_string("owner") ~= "", "true", "false")
		if fields.private ~= nil and fields.private ~= expected then
			if fields.private == "true" then
				meta:set_string("owner", owner)
				meta:set_string("placer", "")
			else
				meta:set_string("placer", owner)
				meta:set_string("owner", "")
			end
		end
		-- zavirasamo:
		expected = ifthenelse(meta:get_int("zavirasamo") > 0, "true", "false")
		if fields.zavirasamo ~= nil and fields.zavirasamo ~= expected then
			meta:set_int("zavirasamo", ifthenelse(fields.zavirasamo == "true", 5, 0))
		end
		-- zachodove:
		expected = ifthenelse(meta:get_int("zachodove") > 0, "true", "false")
		if fields.zachodove ~= nil and fields.zachodove ~= expected then
			if fields.zachodove == "true" then
				-- zapnout režim záchodových dveří (je-li to možné):
				local pos_above = vector.offset(door_pos, 0, 1, 0)
				local node_above = core.get_node(pos_above)
				local hidden_variant = doors.is_hidden(node_above.name)
				if hidden_variant then
					node_above.name = doors.get_wc_hidden_name(door_node.name, hidden_variant == "red")
					node_above.param2 = door_node.param2
					if node_above.name ~= "doors:hidden" then
						meta:set_int("zachodove", 1)
						core.set_node(pos_above, node_above)
					else
						core.chat_send_player(player_name, "Tyto dveře nepodporují záchodový režim!")
					end
				else
					core.chat_send_player(player_name, "Tyto dveře nepodporují záchodový režim!")
				end
			else
				-- vypnout režim záchodových dveří:
				meta:set_int("zachodove", 0)
				local pos_above = vector.offset(door_pos, 0, 1, 0)
				local node_above = core.get_node(pos_above)
				local hidden_type = doors.is_hidden(node_above.name)
				if hidden_type ~= nil and hidden_type ~= "normal" then
					node_above.name = "doors:hidden"
					core.set_node(pos_above, node_above)
				end
			end
		end
		-- zakotsam:
		expected = ifthenelse(meta:get_int("zakotsam") > 0, "true", "false")
		if fields.zakotsam ~= nil and fields.zakotsam ~= expected then
			meta:set_int("zakotsam", ifthenelse(fields.zakotsam == "true", 1, 0))
		end
		-- hotelove:
		expected = ifthenelse(meta:get_int("hes") ~= 0, "true", "false")
		if fields.hotelove == "false" and meta:get_int("hes") > 0 then
			meta:set_int("hes", 0)
			-- TODO: oznámit hráči/ce
		end
		-- ulozitnazev:
		if fields.ulozitnazev then
			meta:set_string("nazev", fields.nazevdveri or "")
		end

		doors.update_infotext(door_pos, door_node, meta)
	elseif fields.ulozitnazev or fields.private or fields.zavirasamo or fields.zachodove or fields.zakotsam or fields.hotelove then
		core.chat_send_player(player_name, "Nemáte právo konfigurovat tyto dveře!")
	end

	doors.show_control_panel(player, door_pos)
	return true
end

core.register_on_player_receive_fields(on_player_receive_fields)

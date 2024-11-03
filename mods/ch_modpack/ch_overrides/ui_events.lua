local F = minetest.formspec_escape
local ifthenelse = ch_core.ifthenelse
local ui = assert(unified_inventory)

local text_length_limit = 60

-- local white, light_gray, light_green = ch_core.colors.white, ch_core.colors.light_gray, ch_core.colors.light_green

--[[
local color_me = "#00ff00"
local color_admin = "#aa66aa"
local color_other_players = "#cccccc"
]]

local function serialize_filter(nset)
	local nlist = {}
	for k, v in pairs(nset) do
		if v then
			table.insert(nlist, k)
		end
	end
	return table.concat(nlist, "|")
end

local function deserialize_filter(s) -- => nset
	local result = {}
	local nlist = string.split(s, "|")
	for _, n in ipairs(nlist) do
		result[n] = true
	end
	return result
end

local all_events_cache = {} -- cache tables to save memory

local function get_all_event_types_for_player(player_name)
	local list = ch_core.get_event_types_for_player(player_name)
	table.sort(list, function(et_a, et_b)
		return ch_core.utf8_mensi_nez(
			assert(ch_core.event_types[et_a].description),
			assert(ch_core.event_types[et_b].description),
			false
		)
	end)
	local key = minetest.sha1(table.concat(list, "|"), false)
	if all_events_cache[key] ~= nil then
		return all_events_cache[key]
	else
		all_events_cache[key] = list
		return list
	end
end

local function get_events_online_charinfo(player_name)
	local online_charinfo = ch_core.online_charinfo[player_name]
	if online_charinfo == nil then
		minetest.log("warning", "ui_events: Expected online_charinfo for player '"..player_name.."' not found!")
		return {}
	end
	local offline_charinfo = ch_core.offline_charinfo[player_name] or {}
	local result = online_charinfo.ch_events
	if result == nil then
		result = {
			all_event_types = get_all_event_types_for_player(player_name),
			negative_set = deserialize_filter(offline_charinfo.ui_event_filter or ""),
			-- sendable_event_types = nil,
			send_type_index = 1,
		}
		online_charinfo.ch_events = result
	end
	return result
end

ch_core.register_event_type("custom", {
	description = "vlastní oznámení hráče/ky",
	access = "players",
	chat_access = "players",
	send_access = "players",
	prepend_viewname = true,
})

ch_core.register_event_type("announcement", {
	description = "oznámení správy serveru",
	access = "players",
	chat_access = "players",
	send_access = "admin",
	color = "#98d3e1",
})

ch_core.register_event_type("public_announcement", {
	description = "veřejné oznámení správy serveru",
	access = "public",
	chat_access = "public",
	send_access = "admin",
	color = "#98d3e1",
})

-- Unified Inventory page
-- ==============================================================================

local function get_ui_formspec(player, perplayer_formspec)
	local player_info = ch_core.normalize_player(player)
	local player_name = assert(player_info.player_name) -- (who is the formspec for)
	local player_pos = vector.round(player:get_pos())
	local events_charinfo = get_events_online_charinfo(player_name)
	local is_admin = player_info.role == "admin" or player_info.privs.ch_events_admin

    -- function ch_core.get_ui_form_template(id, player_viewname, title, scrollbars, perplayer_formspec)

	local formspec = {""}
	local fs_begin_index = #formspec

    -- TOP form:
	local negative_set = assert(events_charinfo.negative_set)
	local event_types = ch_core.get_event_types_for_player(player_name, negative_set)
	local events = ch_core.get_events_for_player(player_name, event_types, 100) -- 100 nejnovějších událostí
	local sendable_event_types = ch_core.get_sendable_event_types_for_player(player_name)
	events_charinfo.sendable_event_types = sendable_event_types
	if events_charinfo.send_type_index > #sendable_event_types then
		events_charinfo.send_type_index = 1
	end

	table.insert(formspec, "tablecolumns[text;color,span=2;text;text]"..
		"style[ui_events;font_size=-1]"..
		"table[0,0;17,4;ui_events;DATUM,#ffffff,OZNÁMENÍ,DRUH")

	for i, event in ipairs(events) do
        local cas = event.time
        if not is_admin then
            cas = cas:sub(1,10)
        end
        table.insert(formspec, ","..F(cas)..","..event.color..","..F(event.text)..","..F(event.description))
	end
	table.insert(formspec, ";]")

	--[[ rozbalovací pole s volbou filtru a řazení (zatím nepoužité)
	table.insert(formspec, "dropdown[5.5,-0.6;7,0.5;ch_events_filtr;"..F(assert(filters[1].description)))
	for i = 2, #filters do
		table.insert(formspec, ","..F(filters[i].description))
	end
	table.insert(formspec, ";"..events_charinfo.active_filter..";true]")
	]]

	table.insert(formspec, "")
	local fs_middle_index = #formspec
	-- BOTTOM form:

	local y = 0.5

	if #sendable_event_types > 0 then
		table.insert(formspec, "field[0.25,"..y..";6,0.75;che_text;nové oznámení;]"..
			"dropdown[0.25,"..(y + 1)..";4,0.75;che_event_type;")
		for i, event_type in ipairs(sendable_event_types) do
			table.insert(formspec, F(ch_core.event_types[event_type].description))
			table.insert(formspec, ",")
		end
		formspec[#formspec] = ";"..events_charinfo.send_type_index..";true]"
		table.insert(formspec, "button[4.25,"..(y + 1)..";2,0.75;che_event_send;odeslat]"..
			"tooltip[che_text;Sem zadejte text události\\, kterou chcete oznámit ostatním registrovaným hráčům/kám.\n"..
			"Maximálně "..(text_length_limit - 2 - ch_core.utf8_length(player_info.viewname)).." znaků. "..
			"Událost nebude viditelná turistickým postavám.\n"..
			"Takto můžete odeslat jen jednu událost stejného typu za hodinu a odeslaný text již nebudete moci změnit.]"..
			"tooltip[che_event_send;Odešle text události s aktuálním časovým razítkem.]")
		y = y + 2.5
	end
	table.insert(formspec, "label[0.25,"..y..";Vyfiltrovat tyto druhy oznámení:]")
	y = y + 0.5
	for _, event_type in ipairs(events_charinfo.all_event_types) do
		local description = assert(ch_core.event_types[event_type].description)
		table.insert(formspec, "checkbox[0.25,"..y..";che_filter_"..event_type..";"..F(description)..";"..
			ifthenelse(negative_set[event_type], "false", "true").."]")
		y = y + 0.5
	end
    ----
	local y_max = math.ceil(10 * (y - 5.5))
	if y_max < 0 then y_max = 0 end
	local fs_end_index = #formspec + 1
	local template = ch_core.get_ui_form_template("events", ch_core.prihlasovaci_na_zobrazovaci(player_name), "oznámení a události",
		{top = 0, bottom = y_max}, perplayer_formspec, events_charinfo)
	formspec[fs_begin_index] = template.fs_begin
	formspec[fs_middle_index] = template.fs_middle
	formspec[fs_end_index] = template.fs_end

	return {
		draw_item_list = false,
		formspec = table.concat(formspec),
	}
end

ui.register_button("ch_events", {
	type = "image",
	image = "ch_overrides_ui_events.png",
	tooltip = "Události a oznámení",
	condition = function(player)
		return true
	end,
})

ui.register_page("ch_events", {get_formspec = get_ui_formspec})


local function on_player_receive_fields(player, formname, fields)
	if formname ~= "" then return end

	local pinfo = ch_core.normalize_player(player)
	local player_name = pinfo.player_name
	local events_charinfo
	local update_formspec = false

	if fields.che_event_type ~= nil then
		local n = tonumber(fields.che_event_type)
		if n ~= nil then
			if events_charinfo == nil then events_charinfo = get_events_online_charinfo(player_name) end
			events_charinfo.send_type_index = n
		end
	end
	if fields.ch_scrollbar2_events ~= nil then
		local event = minetest.explode_scrollbar_event(fields.ch_scrollbar2_events)
		if event.type == "CHG" then
			if events_charinfo == nil then events_charinfo = get_events_online_charinfo(player_name) end
			events_charinfo.ch_scrollbar2_events = assert(tonumber(event.value))
		end
	end

	if fields.che_event_send ~= nil and fields.che_text ~= nil and fields.che_text ~= "" then
		if events_charinfo == nil then events_charinfo = get_events_online_charinfo(player_name) end
		local sendable_event_types = events_charinfo.sendable_event_types or ch_core.get_sendable_event_types_for_player()
		local event_type = sendable_event_types[tonumber(fields.che_event_type)]
		if event_type ~= nil then
			-- možná by bylo správné zde znovu zkontrolovat právo k odeslání tohoto typu oznámení,
			-- ale soudím, že to nestojí za to
			local text = ch_core.utf8_truncate_right(tostring(fields.che_text), text_length_limit, "(...)")
			ch_core.add_event(event_type, text, player_name)
			update_formspec = true
		else
			minetest.log("error", "event_type is nil on sent: "..dump2({fields = fields, events_charinfo = events_charinfo, player_name = player_name}))
		end
	else
		for k, v in pairs(fields) do
			if k:match("^che_filter_") then
				-- update filter:
				local event_type = k:sub(12, -1)
				local events_charinfo = get_events_online_charinfo(player_name)
				local offline_charinfo = assert(ch_core.offline_charinfo[player_name])
				if v == "true" then
					-- remove from negative set
					if events_charinfo.negative_set[event_type] then
						events_charinfo.negative_set[event_type] = nil
						offline_charinfo.ui_event_filter = assert(serialize_filter(events_charinfo.negative_set))
						ch_core.save_offline_charinfo(player_name, "ui_event_filter")
						update_formspec = true
					end
				else
					-- add to negative set
					if not events_charinfo.negative_set[event_type] then
						events_charinfo.negative_set[event_type] = true
						offline_charinfo.ui_event_filter = assert(serialize_filter(events_charinfo.negative_set))
						ch_core.save_offline_charinfo(player_name, "ui_event_filter")
						update_formspec = true
					end
				end
			end
		end
	end

	if update_formspec then
		ui.set_inventory_formspec(player, "ch_events")
	end
end
minetest.register_on_player_receive_fields(on_player_receive_fields)


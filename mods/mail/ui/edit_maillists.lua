-- translation
local S = minetest.get_translator("mail")

local FORMNAME = "mail:editmaillist"

function mail.show_edit_maillist(playername, maillist_name, desc, players, illegal_name_hint)
	local formspec = [[
			size[6,7]
			button[4,6.25;2,0.5;back;]] .. S("Back") .. [[]
			field[0.25,0.5;4,1;name;]] .. S("Maillist name") .. [[:;%s]
			textarea[0.25,1.6;4,2;desc;]] .. S("Desc") .. [[:;%s]
			textarea[0.25,3.6;4,4.25;players;]] .. S("Players") .. [[:;%s]
			button[4,0.10;2,1;save;]] .. S("Save") .. [[]
		]]
	if illegal_name_hint == "collision" then
		formspec = formspec .. [[
			textarea[4.25,1;2.5,6;;;]] ..
			S("That name is already in your mailing lists.") .. [[]
			]]
	elseif illegal_name_hint == "empty" then
		formspec = formspec .. [[
			textarea[4.25,1;2.5,6;;;]] ..
			S("The mailing list name cannot be empty.") .. [[]
			]]
	end
	local players_txt = (mail.player_list_to_viewnames(players) or ""):gsub(",", "\n")
	formspec = formspec .. mail.theme
	formspec = string.format(formspec,
		minetest.formspec_escape(maillist_name or ""),
		minetest.formspec_escape(desc or ""),
		minetest.formspec_escape(players_txt))
	minetest.show_formspec(playername, FORMNAME, formspec)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= FORMNAME then
		return
	end

	local name = player:get_player_name()
	local maillists = mail.get_maillists(name)

	if fields.save then
		local players_parsed = fields.players:gsub("\n", ",")
		players_parsed = mail.parse_player_list(players_parsed)
		local old_maillist = maillists[mail.selected_idxs.maillists[name]] or {name = ""}
		if mail.selected_idxs.maillists[name] then
			if old_maillist.viewname ~= fields.name or fields.name == "" then
				-- name changed!
				if #fields.name == 0 then
					mail.show_edit_maillist(name, old_maillist.viewname or old_maillist.name, fields.desc, fields.players, "empty")
					return true

				elseif mail.get_maillist_by_name(name, fields.name) then
					mail.show_edit_maillist(name, old_maillist.viewname or old_maillist.name, fields.desc, fields.players, "collision")
					return true

				else
					mail.update_maillist(name, {
						owner = name,
						name = ch_core.jmeno_na_prihlasovaci(fields.name),
						viewname = fields.name,
						desc = fields.desc,
						players = players_parsed
					}, old_maillist.name)
				end
			else
				mail.update_maillist(name, {
					owner = name,
					name = ch_core.jmeno_na_prihlasovaci(fields.name),
					viewname = fields.name,
					desc = fields.desc,
					players = players_parsed
				}, old_maillist.name)
			end
		else
			mail.update_maillist(name, {
				owner = name,
				name = ch_core.jmeno_na_prihlasovaci(fields.name),
				viewname = fields.name,
				desc = fields.desc,
				players = players_parsed
			}, old_maillist.name)
		end
		mail.show_maillists(name)

	elseif fields.back then
		mail.show_maillists(name)
	end

	return true
end)

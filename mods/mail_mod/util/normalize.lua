--[[
return the field normalized (comma separated, single space)
and add individual player names to "recipients" as keys
--]]
function mail.normalize_players_and_add_recipients(field, recipients)
	local list = mail.player_list_to_login_names(field)
	for _, login_name in ipairs(list) do
		recipients[login_name] = login_name
	end
	return mail.login_names_to_player_list(list, {use_login_names = true})
end

function mail.parse_player_list(field)
	error("DEPRECATED")
end
mail.concat_player_list = mail.parse_player_list

--[[
	string login_name -- a canonical login name; the player is not required to exist
	string|table list -- player_list or a table of login names
]]
function mail.player_in_list(login_name, list)
	if not list then
		return false
	end
	if type(list) == "string" then
		list = mail.player_list_to_login_names(list)
	end
	return table.indexof(list, login_name) ~= -1
end


function mail.ensure_new_format(message, name)
    if message.to == nil then
        message.to = name
    end
end

--[[
	options:
		bool pass_not_found -- if true, not found names will be inserted both to not_found_list and to the result
		table not_found_list -- if defined, player_list names for players that does not exist will be added to the end of this table
		table skip_set -- if defined, the player names that satisfy the condition skip_set[player_name] will be skipped
]]

function mail.player_list_to_login_names(player_list, options)
	if not options then
		options = {}
	end
	local not_found_list = options.not_found_list or {}
	local skip_set = options.skip_set
	if skip_set then
		skip_set = table.copy(skip_set)
	else
		skip_set = {}
	end

	local parts = string.split(player_list, "[,;|&]", false, -1, true)
	local result = {}
	for _, part in ipairs(parts) do
		local name_in_the_list = part:trim()
		if name_in_the_list ~= "" then
			local login_name = ch_core.jmeno_na_prihlasovaci(name_in_the_list)
			if not skip_set[login_name] then
				skip_set[login_name] = 1
				if minetest.player_exists(login_name) then
					table.insert(result, login_name)
				else
					table.insert(not_found_list, name_in_the_list)
					if options.pass_not_found then
						table.insert(result, name_in_the_list)
					end
				end
			end
		end
	end
	return result
end

--[[
	options:
		table skip_set
		bool use_login_names
]]

function mail.login_names_to_player_list(login_names, options)
	if not options then
		options = {}
	end
	local skip_set = options.skip_set
	if skip_set then
		skip_set = table.copy(skip_set)
	else
		skip_set = {}
	end

	local result = {}

	for _, name in ipairs(login_names) do
		if not skip_set[name] then
			if options.use_login_names then
				table.insert(result, name)
			else
				table.insert(result, ch_core.prihlasovaci_na_zobrazovaci(name))
			end
		end
	end

	return table.concat(result, ", ")
end

function mail.login_names_to_login_list(login_names)
	return table.concat(login_names, ", ")
end

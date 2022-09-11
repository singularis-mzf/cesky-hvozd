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
	error("DEPRECATED") --[[
    if not field then
        return {}
    end

    local separator = ", "
    local pattern = "([^" .. separator .. "]+)"

    -- get individual players
    local player_set = {}
    local order = {}
    field:gsub(pattern, function(c)
        if player_set[string.lower(c)] == nil then
            player_set[string.lower(c)] = c
            order[#order+1] = c
        end
    end)

    return order ]]
end

function mail.concat_player_list(order)
	error("DEPRECATED")
    --[[ turn list of players back into normalized string
    return table.concat(order, ", ") ]]
end

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

	-- print("DEBUG: will split list: "..player_list)
	local parts = string.split(player_list, "[,;|&]", false, -1, true)
	local result = {}
	for _, part in ipairs(parts) do
		local name_in_the_list = part:trim()
		if name_in_the_list ~= "" then
			local login_name = ch_core.jmeno_na_prihlasovaci(name_in_the_list)
			if skip_set[login_name] then
				-- print("- will skip "..name_in_the_list..", because "..login_name.." is in the skip_set")
			elseif minetest.player_exists(login_name) then
				skip_set[login_name] = 1
				table.insert(result, login_name)
				-- print("- add "..login_name.." to the resulting login names (and to the skip set)")
			else
				table.insert(not_found_list, name_in_the_list)
				-- print("- add "..name_in_the_list.." to the not_found_list (and to the skip set)")
				skip_set[login_name] = 1

				if options.pass_not_found then
					table.insert(result, name_in_the_list)
				end
			end
		end
	end
	-- print("finished with "..#result.." resulting login names")
	return result
end

--[[
	options:
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
	local is_first = true

	print("mail.login_names_to_player_list() started")
	for _, name in ipairs(login_names) do
		if skip_set[name] then
			print("- will skip "..login_name..", because it is in the skip_set")
		else
			if not is_first then
				table.insert(result, ", ")
			else
				is_first = false
			end
			local name_to_add
			if options.use_login_names then
				name_to_add = name
			else
				name_to_add = ch_core.prihlasovaci_na_zobrazovaci(name)
			end
			print("- will add "..name_to_add.." from login name "..name)
			table.insert(result, name_to_add)
		end
	end

	result = table.concat(result)
	print(">> list "..result)
	return result
end

function mail.login_names_to_login_list(login_names)
	local result = {}
	local is_first = true

	for _, name in ipairs(login_names) do
		if not is_first then
			table.insert(result, ", ")
		else
			is_first = false
		end
		table.insert(result, name)
	end

	return table.concat(result)
end

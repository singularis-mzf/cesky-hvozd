local lc_cmp = futil.lc_cmp

local function sort_names(names, delim)
	local sorted_names = {}

    for name in names:gmatch("[%w_%-]+") do
        table.insert(sorted_names, name)
    end

    table.sort(sorted_names, lc_cmp)

	return table.concat(sorted_names, delim)
end

local old_get_server_status = minetest.get_server_status

function minetest.get_server_status(player_name, login)
	local status = old_get_server_status(player_name, login)
	local suffix
	local i = status:find("\n")
	if i then
		suffix = status:sub(i, -1)
		status = status:sub(1, i - 1)
	else
		suffix = ""
	end

	local a, b, c, d, names = status:match("^# Server: version: (.*) game: (.*) uptime: (.*) max lag: (.*) clients: (.*)")

	if not (a and b and c and d and names) then
		return status
	end

	return ("# Verze serveru: %s hra: %s čas od startu: %s max. lag: %s klienti: %s%s"):format(a, b, c, d, sort_names(names, ", "), suffix)
end

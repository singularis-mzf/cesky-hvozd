-- autonaming.lua
-- Automatically set names of signals (and maybe track sections) based on numbering


local function find_highest_count(prefix)
	local cnt = 0
	local pattern = "^"..prefix.."(%d+)$"
	local alltcb = advtrains.interlocking.db.get_all_tcb()
	for _,tcb in pairs(alltcb) do
		for _,tcbs in pairs(tcb) do
			if tcbs.signal_name then
				local mnum = string.match(tcbs.signal_name, pattern)
				if mnum then
					local n = tonumber(mnum)
					if n and n > cnt then
						cnt = n
					end
				end
			end
		end
	end
	return cnt
end

-- { pname = { prefix = "FOO", count = 7 } }
local player_prefix_info = {}

function advtrains.interlocking.set_autoname_prefix(pname, prefix)
	if prefix and #prefix>0 then
		-- check that it is valid
		if not string.match(prefix,"[A-Za-z_]+") then
			return false, "Illegal prefix, only letters and _ allowed"
		end
		-- scan database for this prefix to find out the highest count
		local count = find_highest_count(prefix)
		player_prefix_info[pname] = { prefix = prefix, count = count}
		return true, "Prefix set, next signal name will be: ".. advtrains.interlocking.get_next_autoname(pname, true)
	else
		player_prefix_info[pname] = nil
		return true, "Prefix unset, signals are not auto-named for you!"
	end
end

function advtrains.interlocking.get_next_autoname(pname, no_increment)
	local pi = player_prefix_info[pname]
	if pi then
		local name = pi.prefix..(pi.count+1)
		if not no_increment then pi.count = pi.count+1 end
		return name
	else
		return nil
	end
end

function advtrains.interlocking.add_autoname_to_tcbs(tcbs, pname)
	if not tcbs or not pname then return end
	if tcbs.signal_name then return end -- name already set
	
	tcbs.signal_name = advtrains.interlocking.get_next_autoname(pname)
end

minetest.register_chatcommand("at_nameprefix",
	{
		params = "<prefix>",
		description = "Sets the current prefix for automatically naming interlocking components. Example: '/at_nameprefix TEST' - signals will be named TEST1, TEST2 and so on",
		privs = {interlocking = true},
		func = advtrains.interlocking.set_autoname_prefix,
})


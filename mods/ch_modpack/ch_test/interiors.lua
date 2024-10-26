local counter = 0

local allowed_players = {}

--[[
local passable_drawtypes = {
	airlike = true,
	firelike = true,
	flowingliquid = true,
	liquid = true,
	plantlike = true,
	plantlike_rooted = true,
	signlike = true,
	torchlike = true,
}

local passable = 1
local evadable = 2

local node_types = {
	air = passable,
}

local empty_table = {}

minetest.register_on_mods_loaded(function()
	for name, ndef in pairs(minetest.registered_nodes) do
		if passable_drawtypes[ndef.drawtype or ""] then -- or ndef.sunlight_propagates == true
			node_types[name] = passable
		else
			local groups = ndef.groups or empty_table
			if groups.leaves then
				node_types[name] = passable
			elseif groups.tree then
				node_types[name] = evadable
			end
		end
	end
	local passable_count, evadable_count = 0, 0
	for _, value in pairs(node_types) do
		if value == passable then
			passable_count = passable_count + 1
		elseif value == evadable then
			evadable_count = evadable_count + 1
		end
	end
	print("[ch_test] "..passable_count.." passable and "..evadable_count.." evadable nodes found.")
end)

-- local debug_steps_counter = 0

local get_node = minetest.get_node

local function has_passable_neighbour(pos)
	pos.x = pos.x - 1 -- -x
	if node_types[get_node(pos).name] == passable then
		return true
	end
	pos.z = pos.z - 1 -- -x -z
	if node_types[get_node(pos).name] == passable then
		return true
	end
	pos.x = pos.x + 1 -- -z
	if node_types[get_node(pos).name] == passable then
		return true
	end
	pos.x = pos.x + 1 -- +x -z
	if node_types[get_node(pos).name] == passable then
		return true
	end
	pos.z = pos.z + 1 -- +x
	if node_types[get_node(pos).name] == passable then
		return true
	end
	pos.z = pos.z + 1 -- +x +z
	if node_types[get_node(pos).name] == passable then
		return true
	end
	pos.x = pos.x - 1 -- +z
	if node_types[get_node(pos).name] == passable then
		return true
	end
	pos.x = pos.x - 1 -- -x +z
	if node_types[get_node(pos).name] == passable then
		return true
	end
	return false
end

local function test_nodes_above(pos_above)
	local pos = pos_above
	local i = 1
	while i <= 20 do
		-- debug_steps_counter = debug_steps_counter + 1
		local node_type = node_types[get_node(pos).name]
		if node_type == nil then
			return false
		elseif node_type == evadable then
			local x, y, z = pos.x, pos.y, pos.z
			local pos2 = vector.new(x, y + 1, z)
			if node_types[get_node(pos2).name] ~= passable then
				return false
			end
			pos2.y = y
			i = i + 1
			if not has_passable_neighbour(pos2) then
				return false
			end
			pos.y = y + 1
		end
		pos.y = pos.y + 1
		i = i + 1
	end
	return true
end

local function step(dtime)
	for player_name, online_charinfo in pairs(ch_core.online_charinfo) do
		local player = minetest.get_player_by_name(player_name)
		local player_pos = player and player:get_pos()
		if allowed_players[player_name] and player_pos ~= nil then
			local player_pos_rounded = vector.round(player_pos)
			local player_last_pos_rounded = online_charinfo.player_last_pos_rounded
			if not player_last_pos_rounded then
				online_charinfo.player_last_pos_rounded = player_pos_rounded
			elseif not vector.equals(player_last_pos_rounded, player_pos_rounded) then
				-- detect
				online_charinfo.player_last_pos_rounded = player_pos_rounded
				local was_in_interior = online_charinfo.was_in_interior or 0 -- 0 => exterior, 1 => interior
				local is_in_interior
				local pos_above = vector.offset(player_pos_rounded, 0, 1, 0)
				local nlight = minetest.get_natural_light(pos_above, 0.5) or 0
				-- debug_steps_counter = 1
				if nlight <= 0 then
					is_in_interior = 1
				elseif nlight >= minetest.LIGHT_MAX then
					is_in_interior = 0
				elseif test_nodes_above(pos_above) then
					is_in_interior = 0
				else
					is_in_interior = 1
				end
				-- print("["..minetest.get_us_time().."] IE: "..debug_steps_counter.." steps was="..was_in_interior.." is="..is_in_interior)
				if is_in_interior == 1 and was_in_interior == 0 then
					counter = counter + 1
					online_charinfo.was_in_interior = 1
					minetest.chat_send_player(player_name, "*** ["..counter.."] Vstoupil/a jste do interiéru "..minetest.pos_to_string(player_pos)..".")
				elseif is_in_interior == 0 and was_in_interior == 1 then
					counter = counter + 1
					online_charinfo.was_in_interior = 0
					minetest.chat_send_player(player_name, "*** ["..counter.."] Opustil/a jste interiér "..minetest.pos_to_string(player_pos)..".")
				end
			end
		end
	end
end
]]

local ifthenelse = ch_core.ifthenelse

local function step(dtime)
	for player_name, online_charinfo in pairs(ch_core.online_charinfo) do
		local player = minetest.get_player_by_name(player_name)
		local player_pos = player and player:get_pos()
		if allowed_players[player_name] and player_pos ~= nil then
			local player_pos_rounded = vector.round(player_pos)
			local player_last_pos_rounded = online_charinfo.player_last_pos_rounded
			if not player_last_pos_rounded then
				online_charinfo.player_last_pos_rounded = player_pos_rounded
			elseif not vector.equals(player_last_pos_rounded, player_pos_rounded) then
				-- detect
				online_charinfo.player_last_pos_rounded = player_pos_rounded
				local was_in_interior = online_charinfo.was_in_interior or 0 -- 0 => exterior, 1 => interior
				local is_in_interior = ifthenelse(ch_core.is_in_interior(vector.offset(player_pos_rounded, 0, 1, 0)), 1, 0)
				print("was_in_interior = "..was_in_interior.." is_in_interior = "..is_in_interior)
				if is_in_interior == 1 and was_in_interior == 0 then
					counter = counter + 1
					online_charinfo.was_in_interior = 1
					minetest.chat_send_player(player_name, "*** ["..counter.."] Vstoupil/a jste do interiéru "..minetest.pos_to_string(player_pos)..".")
				elseif is_in_interior == 0 and was_in_interior == 1 then
					counter = counter + 1
					online_charinfo.was_in_interior = 0
					minetest.chat_send_player(player_name, "*** ["..counter.."] Opustil/a jste interiér "..minetest.pos_to_string(player_pos)..".")
				end
			end
		end
	end
end

minetest.register_globalstep(step)

local def = {
	params = "<ano|ne>",
	description = "Zapne nebo vypne experimentální detekci interiérů a exteriérů.",
	func = function(player_name, param)
		if param == "ano" then
			allowed_players[player_name] = true
			return true, "Test interiérů zapnut."
		elseif param == "ne" then
			allowed_players[player_name] = false
			return true, "Test interiérů vypnut."
		else
			return false, "Neplatné zadání. Použijte „/testinteriérů ano“ nebo „/testinteriérů ne“."
		end
	end,
}
minetest.register_chatcommand("testinteriérů", def)
minetest.register_chatcommand("testinterieru", def)

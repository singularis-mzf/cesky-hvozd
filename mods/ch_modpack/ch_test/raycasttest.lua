local function func(player_name, param)
	local player = minetest.get_player_by_name(player_name)
	local pos = player:get_pos()
	local cast = Raycast(pos, vector.offset(pos, 0, -5, 0), false, true)
	local result = {}

	local thing = cast:next()
	while thing ~= nil do
		table.insert(result, dump2(thing))
		thing = cast:next()
	end
	print("DEBUG: "..table.concat(result, "\n"))
	return true
end

local def = {
	privs = {server = true},
	func = func,
}

minetest.register_chatcommand("test", def)

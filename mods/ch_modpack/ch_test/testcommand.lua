local def

local process_enabled = false
local f
local total = 0
-- = io.open(core.get_worldpath().."/unknowns-to-delete.txt")

local function runner()
	if f ~= nil then
		for i = 1, 1000 do
			local next_line = f:read("*l")
			if next_line == nil then
				f:close()
				f = nil
				process_enabled = false
				total = total + i - 1
				core.log("action", "[TEST] test process finished (total="..total..")")
				core.log("action", "Test process finished at "..os.time())
				return
			end
			local name, x, y, z = next_line:match("^([^;]*);([^;]*);([^;]*);([^;]*);.*")
			local pos = vector.new(tonumber(x), tonumber(y), tonumber(z))
			if not core.compare_block_status(pos, "loaded") then
				core.load_area(pos)
			end
			local node = core.get_node(pos)
			if node.name == name then
				core.remove_node(pos)
			else
				core.log("warning", "Expected "..name.." not found at "..core.pos_to_string(pos)..", "..node.name.." found instead.")
			end
		end
		total = total + 1000
		core.log("action", "[TEST] test process will continue (total="..total..")")
		core.after(0.25, runner)
	end
end

local function command(player_name, param)
	if process_enabled then
		process_enabled = false
		return true, "Proces zrušen"
	end
	process_enabled = true
	core.log("action", "Test process started at "..os.time())
	f = io.open(core.get_worldpath().."/unknowns-to-delete.txt")
	if f == nil then
		core.log("error", "Cannot open "..core.get_worldpath().."/unknowns-to-delete.txt")
		return false, "Nemohu otevřít soubor."
	end
	core.after(0.25, runner)
	return true
end








def = {
	params = "[text]",
	description = "spustí právě testovanou akci pro účely vývoje serveru (jen pro Administraci)",
	privs = {server = true},
	func = command,
}
minetest.register_chatcommand("test", def)

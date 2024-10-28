--[[
TODO:
[ ] implementovat podporu tvarů vysokých dva bloky a jejich osamostatněných polovin
[ ] pod vodou používat výhradně pobřežní tvary, pokud existují
[ ] vyladit chování se stromy, květinami apod.
]]
print("[MOD BEGIN] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")

local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local dofile = ch_core.dofile

local ch_smooth = {
	rollback_log = {},
}

dofile({name = "data.lua"}, ch_smooth)
dofile({name = "lib.lua"}, ch_smooth)
dofile({name = "precompute.lua"}, ch_smooth)
dofile({name = "analyze.lua"}, ch_smooth)
dofile({name = "compute.lua"}, ch_smooth)

local vyhladit = ch_smooth.vyhladit

local function on_use(itemstack, user, pointed_thing)
	local player_name = user and user:get_player_name()
	if not player_name then
		return
	end
	if not minetest.check_player_privs(player_name, "server") then
		ch_core.systemovy_kanal(player_name, "Chyba: tuto hůlku smí používat jen Administrace.")
		return
	end
	if pointed_thing.type ~= "node" then
		ch_core.systemovy_kanal(player_name, "Nutno kliknout na blok.")
		return
	end
	local operation_id = math.random(1, 9999)
	local result = vyhladit(pointed_thing.under, operation_id)
	if result == nil then
		ch_core.systemovy_kanal(player_name, "Nemám co vyhlazovat.")
		return
	end
	if result[1] == nil then
		ch_core.systemovy_kanal(player_name, "Operace proběhla, ale nebyly nahrazeny žádné bloky.")
		return
	end
	local count = 0
	local positions = {}
	minetest.log("action", "[VYHLAZENI "..operation_id.."] Started")
	for i, action in ipairs(result) do
		local hash = minetest.hash_node_position(action.pos)
		if vyhladit_rollback_log[hash] == nil then
			vyhladit_rollback_log[hash] = action.old
		end
		count = count + 1
		minetest.log("action", "[VYHLAZENI "..operation_id.."]["..count.."] at "..minetest.pos_to_string(action.pos)..": "..action.old.name.."/"..action.old.param2.." => "..action.new.name.."/"..action.new.param2)
		minetest.swap_node(action.pos, action.new)
		positions[i] = action.pos
	end
	minetest.log("action", "[VYHLAZENI "..operation_id.."] Finished: "..count.." replacements.")
	for i, pos in ipairs(positions) do
		minetest.check_for_falling(pos)
	end
	-- minetest.log("warning", "[vyhl] "..count.." bloků nahrazeno.")
	ch_core.systemovy_kanal(player_name, count.." bloků nahrazeno.")
end

local def = {
	description = "hůlka vyhlazení [EXPERIMENTÁLNÍ]",
	inventory_image = "ch_extras_creative_inv.png",
	wield_image = "ch_extras_creative_inv.png",
	on_use = on_use,
	groups = {tools = 1},
}

minetest.register_tool("ch_smooth:wand", def)

ch_smooth = nil

print("[MOD END] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")

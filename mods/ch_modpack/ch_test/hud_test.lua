local player_name_to_hud = {}

local hud_defaults = {
	type = "text",
	name = "TEST hud",
	position = { x = 1, y = 0.75 },
	offset = { x = -5, y = -5 },
	text = "",
	alignment = { x = -1, y = -1 },
	scale = { x = 100, y = 100 },
	number = 0xFFCCCC,
	style = 4,
	z_index = 51,
}

local function enable_hud(player, player_name)
	if player == nil or player_name == nil then return false end
	local hud_id = player:hud_add(hud_defaults)
	if hud_id == nil then
		return false
	end
	player_name_to_hud[player_name] = {
		dtime_acc = 0,
		dtime_last = 0,
		dtime_count = 0,
		hud_id = hud_id,
	}
end

local function disable_hud(player, player_name)
	if player == nil or player_name == nil then return false end
	local hud_info = player_name_to_hud[player_name]
	if hud_info == nil then return false end
	player_name_to_hud[player_name] = nil
	player:hud_remove(hud_info.hud_id)
end

local function toggle_hud(player, player_name)
	if player == nil or player_name == nil then return false end
	if player_name_to_hud[player_name] == nil then
		enable_hud(player, player_name)
	else
		disable_hud(player, player_name)
	end
end

local function update_hud_text(player, hud_id, text)
	if player ~= nil and hud_id ~= nil and text ~= nil then
		player:hud_change(hud_id, "text", text)
	end
end

local function on_leaveplayer(player, timeouted)
	local player_name = player:get_player_name()
	disable_hud(player, player_name)
end

local function on_chat_command(admin_name, player_name)
	if player_name == nil or player_name == "" then
		return false, "chybná syntaxe"
	end
	local player = minetest.get_player_by_name(player_name)
	if player == nil then
		return false, "postava "..player_name.." není ve hře!"
	end
	toggle_hud(player, player_name)
	if player_name_to_hud[player_name] ~= nil then
		return true, "úspěšně zapnuto"
	else
		return true, "úspěšně vypnuto"
	end
end

local function on_globalstep(dtime)
	for player_name, hud_info in pairs(player_name_to_hud) do
		local player = minetest.get_player_by_name(player_name)
		if player ~= nil then
			hud_info.dtime_acc = hud_info.dtime_acc + dtime
			hud_info.dtime_count = hud_info.dtime_count + 1
			hud_info.dtime_last = dtime
			local new_text = "["..hud_info.dtime_count.."] "..hud_info.dtime_last.." => "..hud_info.dtime_acc
			update_hud_text(player, hud_info.hud_id, new_text)
			print("DEBUG: will update hudtext to "..new_text)
		end
	end
end

local chat_command_def = {
	params = "<player_name>",
	description = "zapne nebo vypne test HUD",
	privs = {server = true},
	func = on_chat_command,
}

minetest.register_on_leaveplayer(on_leaveplayer)
minetest.register_globalstep(on_globalstep)
minetest.register_chatcommand("hudtest", chat_command_def)

ch_base.open_mod(minetest.get_current_modname())
local themename = ""

dreambuilder_hotbar = {}


if minetest.global_exists("dreambuilder_theme") then
	themename = dreambuilder_theme.name.."_"
end

local player_hotbar_settings = {}
local f = io.open(minetest.get_worldpath()..DIR_DELIM.."hotbar_settings","r")
if f then
	player_hotbar_settings = minetest.deserialize(f:read("*all"))
	f:close()
end

local function validate_size(s)
	local size = s and tonumber(s) or 16
	return math.floor(0.5 + math.max(1, math.min(size, 32)))
end

local hotbar_size_default = validate_size(minetest.settings:get("hotbar_size"))

local base_img = themename.."gui_hb_bg_1.png"
local imgref_len = string.len(base_img) + 8 -- accounts for the stuff in the string.format() below.

local img = {}
for i = 0, 31 do
	img[i+1] = string.format(":%04i,0=%s", i*64, base_img)
end
local hb_img = table.concat(img)

local function set_hotbar_size(player, s)
	local hotbar_size = validate_size(s)
	player:hud_set_hotbar_itemcount(hotbar_size)
	player:hud_set_hotbar_selected_image(themename.."gui_hotbar_selected.png")
	player:hud_set_hotbar_image("[combine:"..(hotbar_size*64).."x64"..string.sub(hb_img, 1, hotbar_size*imgref_len))
	return hotbar_size
end

minetest.register_on_joinplayer(function(player)
	minetest.after(0.5,function()
		set_hotbar_size(player, tonumber(player_hotbar_settings[player:get_player_name()]) or hotbar_size_default)
	end)
end)

function dreambuilder_hotbar.get_hotbar_size(player_name)
	return tonumber(player_hotbar_settings[player_name])
end

function dreambuilder_hotbar.set_hotbar_size(player_name, s)
	local player = minetest.get_player_by_name(player_name)
	if player ~= nil then
		s = set_hotbar_size(player, s)
	else
		s = validate_size(s)
	end
	player_hotbar_settings[player_name] = s
	f = io.open(minetest.get_worldpath()..DIR_DELIM.."hotbar_settings","w")
	if not f then
		minetest.log("error","Failed to save hotbar settings")
	else
		f:write(minetest.serialize(player_hotbar_settings))
		f:close()
	end
end

local chatcommand_def = {
	params = "[délka]",
	description = "Nastaví délku vaší výběrové lišty, od 1 do 32 slotů, výchozí délka je 16",
	func = function(name, slots)
		local size = set_hotbar_size(minetest.get_player_by_name(name), slots)
		player_hotbar_settings[name] = size
		minetest.chat_send_player(name, "[_] Délka výběrové lišty nastavena na " ..size.. ".")

		f = io.open(minetest.get_worldpath()..DIR_DELIM.."hotbar_settings","w")
		if not f then
			minetest.log("error","Failed to save hotbar settings")
		else
			f:write(minetest.serialize(player_hotbar_settings))
			f:close()
		end
	end,
}
minetest.register_chatcommand("lišta", chatcommand_def)
minetest.register_chatcommand("lista", chatcommand_def)
minetest.register_chatcommand("hotbar", chatcommand_def)

ch_base.close_mod(minetest.get_current_modname())

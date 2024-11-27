ch_base.open_mod(minetest.get_current_modname())
local emojis = {
	{
		name = "1_emoji",
		en_name = "smile",
		texts = {":)", ":-)"},
	}, {
		name = "2_emoji",
		en_name = "sunglasses",
		texts = {"B-)"},
	}, {
		name = "3_emoji",
		en_name = "mask",
		texts = {":#"},
	},{
		name = "4_emoji",
		en_name = "love",
		texts = {"*_*"},
	}, {
		name = "5_emoji",
		en_name = "laugh",
		texts = {":D", ":-D"},
	}, {
		name = "6_emoji",
		en_name = "kiss",
		texts = {":*", ":-*"},
	}, {
		name = "7_emoji",
		en_name = "cry",
		texts = {":_(", ":'("},
	}, {
		name = "8_emoji",
		en_name = "angry",
		texts = {">:-["},
	}, {
		name = "9_emoji",
		-- en_name = "",
		texts = {"]:-)"},
	}, {
		name = "10_emoji",
		en_name = "nothing_to_say",
		texts = {":/", ":-/"},
	}, {
		name = "11_emoji",
		en_name = "wink",
		texts = {";)", ";-)"},
	}, {
		name = "12_emoji",
		en_name = "sad",
		texts = {":(", ":-("},
	}, {
		name = "13_emoji",
		en_name = "tongue",
		texts = {";P", ";-P"},
	}, {
		name = "14_emoji",
		-- en_name = "",
		texts = {":'-D"},
	}, {
		name = "15_emoji",
		-- en_name = "",
		texts = {"~:["},
	}, {
		name = "16_emoji",
		-- en_name = "",
		texts = {"o_O"},
	}, {
		name = "17_emoji",
		-- en_name = "",
		texts = {"xD"},
	}, {
		name = "18_emoji",
		-- en_name = "",
		texts = {"xP"},
	}, {
		name = "19_emoji",
		-- en_name = "",
		texts = {":X"},
	}, {
		name = "20_emoji",
		-- en_name = "",
		texts = {":O", ":-O"},
	}
}

local name_to_def = {}
local text_to_def = {}

for _, def in ipairs(emojis) do
	if name_to_def[def.name] ~= nil then
		error("Emoji name conflict: "..def.name)
	end
	name_to_def[def.name] = def
	for _, text in ipairs(def.texts) do
		if text_to_def[text] ~= nil then
			error("Emoji text conflict: "..text)
		end
		text_to_def[text] = def
	end
end

local form = {
	"formspec_version[6]",
	"size[10.5,9.75]",
	"bgcolor[#333444cc;false]",
	"tableoptions[highlight=#000000;highlight_text=#ffffff]",
	"tablecolumns[text,align=center]",
}
for i, def in ipairs(emojis) do
	local x = (i - 1) % 5
	local y = 0.5 + (i - 1 - x) / 5 * 2.25
	x = 2.0 * x + 0.5
	local texture = "[combine:32x32:6,6="..def.name..".png"
	local em_space = "\xe2\x80\x83"
	table.insert(form, "image_button_exit["..x..","..y..";1.5,1.5;"..minetest.formspec_escape(texture)..";"..def.name..";;true;true;]")
	table.insert(form, "table["..x..","..(y + 1.5)..";1.5,0.5;;"..minetest.formspec_escape(table.concat(def.texts, em_space))..";]")
end
form = table.concat(form)

local emoji_velocity = vector.new(0, 0.1, 0)
local emoji_acceleration = vector.zero()
local function show_emoji(pos, name)
	if name_to_def[name] == nil then return end
	minetest.sound_play("emoji_sound", {pos = pos, max_hear_distance = 12, gain = 1.0,})

	minetest.add_particle{
		pos = vector.offset(pos, 0, 2.4, 0),
		velocity = emoji_velocity,
		acceleration = emoji_acceleration,
		expirationtime = 2.5,
		collisiondetection = false,
		texture = name..".png",
		size = 9,
	}
end

local def = {
	params = "[text]",
	description = "zobrazí nad postavou smajlíka; nezadáte-li text, vybere se smajlík pomocí formuláře a neobjeví se v četu",
	privs = {},
	func = function(player_name, param)
		if param == "" then
			minetest.show_formspec(player_name, "emoji_form", form)
		else
			local def = text_to_def[param]
			local player = minetest.get_player_by_name(player_name)
			if def ~= nil and player ~= nil then
				local pos = player:get_pos()
				show_emoji(pos, def.name)
				ch_core.chat("mistni", player_name, param, pos)
			end
		end
	end,
}

minetest.register_chatcommand("s", def)
minetest.register_chatcommand("smajlík", def)
minetest.register_chatcommand("smajlik", def)

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "emoji_form" then
		for name, _ in pairs(fields) do
			if name_to_def[name] ~= nil then
				show_emoji(player:get_pos(), name)
				return
			end
		end
	end
end)

--[[
minetest.register_on_chat_message(function(name, message, pos)    
	local checkingmessage=( name.." "..message .." " )

	for _, v in pairs(v) do
		if string.find(checkingmessage, v[2], 1, true) ~=nil then

			local player = minetest.get_player_by_name(name)
			
			local pos = player:get_pos()
			
			minetest.add_particlespawner(
				1, --amount
				0.01, --time
				{x=pos.x, y=pos.y+2, z=pos.z}, --minpos
				{x=pos.x, y=pos.y+2, z=pos.z}, --maxpos
				{x=0, y=0.15, z=0}, --minvel
				{x=0, y=0.15, z=0}, --maxvel
				{x=0,y=0,z=0}, --minacc
				{x=0,y=0,z=0}, --maxacc
				2.5, --minexptime
				2.5, --maxexptime
				9, --minsize
				9, --maxsize
				false, --collisiondetection
				v[1]..".png"
			)
			
		end
	
	end	
		
end)
]]
ch_base.close_mod(minetest.get_current_modname())

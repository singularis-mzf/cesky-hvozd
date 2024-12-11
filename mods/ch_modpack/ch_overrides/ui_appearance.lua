-- UNIFIED INVENTORY: APPEARANCE

local has_skinsdb = minetest.get_modpath("skinsdb")
local has_clothing = minetest.get_modpath("clothing")

if not has_skinsdb and not has_clothing then
	return -- nothing to set up
end
if not has_skinsdb and has_clothing then
	error("Unexpected configuration: clothing without skinsdb!")
end

local F = minetest.formspec_escape
local ifthenelse = ch_core.ifthenelse
local light_green = ch_core.colors.light_green
local ui = unified_inventory
local white = ch_core.colors.white

local player_name_to_skinlist = {}

local function skins_lt(a, b)
	if a._key == "character" then
		return false
	elseif b._key == "character" then
		return true
	else
		return a._key < b._key
	end
end

local function get_skinlist(player_name)
	if not has_skinsdb then
		return {}
	end
	local result = player_name_to_skinlist[player_name]
	if result == nil then
		local list = skins.get_skinlist_for_player(player_name)
		table.sort(list, skins_lt)
		result = {}
		for _, skin in ipairs(list) do
			local key = assert(skin._key)
			if not key:match("^character_") or key:match("^character_A[ABC]_") then
				table.insert(result, skin)
			end
		end
		player_name_to_skinlist[player_name] = result
	end
	return result
end

local function get_formspec(player, perplayer_formspec)
	local fs = perplayer_formspec
	local player_name = assert(player:get_player_name())
	local player_properties = player_api.get_animation(player)
	local player_mesh = assert(player_properties.model)
	-- local player_animation = player_properties.animation or ""
	local player_animation = ch_core.safe_get_4(player_api.registered_models, player_mesh, "animations", player_properties.animation)
	local player_textures = player_properties.textures
	local animation_speed = player_properties.animation_speed or 0
	local fs_mesh = F(player_mesh)
	local fs_textures = {}
	for i, tex in ipairs(assert(player_textures)) do
		fs_textures[i] = F(tex)
	end
	fs_textures = table.concat(fs_textures, ",")
	local fs_animation
	if player_animation ~= nil then --  animations ~= nil and animations[player_animation] ~= nil and animations[player_animation].animations then
		fs_animation = assert(player_animation.x)..","..assert(player_animation.y)
	else
		fs_animation = "0,0"
	end

	local formspec = {
		fs.standard_inv_bg,
		"label[", fs.std_inv_x + 0.05, ",", fs.form_header_y + 0.2, ";", light_green, ch_core.prihlasovaci_na_zobrazovaci(player_name, true), white, " — vzhled postavy (oblečení a tělo)]",
		"model[", fs.page_x + 1.0, ",", fs.page_y + 3.5, ";5,10;player_model;", fs_mesh, ";", fs_textures, ";-10,170;false;true;", fs_animation, ";", animation_speed, "]",
		"tooltip[player_model;tip: modelem můžete otáčet]",
	}

	local skinlist = get_skinlist(player_name)
	if #skinlist > 0 then
		local current_skin = skins.get_player_skin(player)
		local current_skin_index
		for i, skin in ipairs(skinlist) do
			if skin._key == current_skin._key then
				current_skin_index = i
				break
			end
		end
		if current_skin_index == nil then
			current_skin_index = #skinlist
		end
		local fs_skins = {}
		for i, skin in ipairs(skinlist) do
			table.insert(fs_skins, F(skin.name))
		end
		fs_skins = table.concat(fs_skins, ",")
		table.insert(formspec,
			"textlist[0.5,1.0;10,2.0;ch_app_vzhled;"..fs_skins..";"..current_skin_index.."]"..
			"tooltip[ch_app_vzhled;seznam je řazený následujícím způsobem:\n1) předvolby nakonec\\, 2) pohlavní znaky (mužské\\, ženské\\, bezpohlavní)\\, 3) barva pleti (bílá\\, černá\\, střední)\\,\n4) barva vlasů (bílé\\, černé\\, plavé\\, ryšavé\\, šedé\\, světle hnědé)\\, 5) barva očí (hnědá\\, modrá\\, šedá\\, zelená)\nNe všechny kombinace jsou dostupné.]")

		-- table.insert(formspec, "dropdown[0.5,1.0;10,0.5;ch_app_vzhled;"..fs_skins..";"..current_skin_index..";true]")
		local info = {}
		if (current_skin.name or "") ~= "" then
			table.insert(info, "Název vzhledu: "..F(current_skin.name))
		end
		if (current_skin.author or "") ~= "" then
			table.insert(info, "Autor/ka: "..F(current_skin.author))
		end
		if (current_skin.license or "") ~= "" then
			table.insert(info, "Licence: "..F(current_skin.license))
		end
		table.insert(formspec,
			"textarea[10.75,1.0;6.75,2.5;;;"..table.concat(info, "\n").."]")
	end

	if has_clothing then
		local x, y = fs.std_inv_x, fs.std_inv_y - 2
		table.insert(formspec,
			"label["..x..","..(y - 0.2)..";oblečení:]"..
			ui.make_inv_img_grid(x, y, 9, 1)..
			"list[detached:"..player_name.."_clothing;clothing;"..(x + ui.list_img_offset)..","..(y + ui.list_img_offset)..";9,1;]"..
			"listring[current_player;main]"..
			"listring[detached:"..player_name.."_clothing;clothing]")
	end

	return {
		draw_item_list = false,
		formspec = table.concat(formspec),
	}
end

local function on_player_receive_fields(player, formname, fields)
	if formname ~= "" or not has_skinsdb or fields.ch_app_vzhled == nil or fields.ch_app_vzhled == "" then return end
	local event = minetest.explode_textlist_event(fields.ch_app_vzhled)
	if event.type ~= "CHG" and event.type ~= "DCL" then return end
	local new_skin_index = tonumber(event.index)
	if new_skin_index == nil then return end
	local player_name = player:get_player_name()
	local skinlist = get_skinlist(player_name)
	if new_skin_index < 1 or new_skin_index > #skinlist then
		return -- invalid selection
	end
	local current_skin = skins.get_player_skin(player)
	if current_skin._key == skinlist[new_skin_index]._key then
		return -- no change
	end
	if not skins.set_player_skin(player, skinlist[new_skin_index]) then
		minetest.log("error", "Setting player skin failed!\n"..dump2({player_name = player_name, new_skin_index = new_skin_index, current_skin = current_skin, new_skin = skinlist[new_skin_index]}))
		return
	end
	-- update inventory formspec:
	ui.set_inventory_formspec(player, ui.current_page[player_name])
end

local sex_characteristics = {"AA", "AB"}
local hair_colors = {"blond", "cerne", "hnede", "plave", "rysave", "svhnede"}
local eye_colors = {"hnede", "modre", "zelene", "sede",
                    "hnede", "modre", "hnede", "sede",}

local function after_newplayer(player_name)
	local player = minetest.get_player_by_name(player_name)
	if player ~= nil then
		local skinlist = get_skinlist(player_name)
		local skinlist_index = {}
		for i, skin in ipairs(skinlist) do
			skinlist_index[skin._key] = i
		end
		for i = 1, 10 do
			local new_skin = "character_"..sex_characteristics[math.random(1, #sex_characteristics)].."_bila_"..
				hair_colors[math.random(1, #hair_colors)].."_"..eye_colors[math.random(1, #eye_colors)]
			if skinlist_index[new_skin] ~= nil then
				skins.set_player_skin(player, skinlist[skinlist_index[new_skin]])
				break
			else
				minetest.log("info", "new skin not found["..i.."]: <"..new_skin..">")
			end
		end
	end
end

ui.register_button("ch_clothing", {
	type = "image",
	image = "skins_button.png",
	tooltip = "Vzhled postavy",
	condition = function(player)
		return true
	end,
})

ui.register_page("ch_clothing", {get_formspec = get_formspec})

minetest.register_on_player_receive_fields(on_player_receive_fields)
minetest.register_on_newplayer(function(player) minetest.after(1.0, after_newplayer, player:get_player_name()) end)

if has_clothing then
	-- update inventory formspec on clothing change
	local function on_clothing_update(player)
		local player_name = player:get_player_name()
		if ui.current_page[player_name] == "ch_clothing" then
			ui.set_inventory_formspec(player, "ch_clothing")
		end
	end

	clothing:register_on_update(on_clothing_update)
end

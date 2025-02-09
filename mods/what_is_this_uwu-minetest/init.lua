ch_base.open_mod(minetest.get_current_modname())
what_is_this_uwu = dofile(minetest.get_modpath('what_is_this_uwu')..'/help.lua')

minetest.register_on_joinplayer(function(player)
	local meta = player:get_meta()

	local background_id_left = player:hud_add({
		type = "image",
		position = {x = 0.5, y = 0},
		scale = {x = 2, y = 2},
		text = '',
		offset = {x = -50, y = 35},
	})
	local background_id_middle = player:hud_add({
		type = "image",
		position = {x = 0.5, y = 0},
		scale = {x = 2, y = 2},
		text = '',
		alignment = {x = 1},
		offset = {x = -37.5, y = 35},
	})
	local background_id_right = player:hud_add({
		type = "image",
		position = {x = 0.5, y = 0},
		scale = {x = 2, y = 2},
		text = '',
		offset = {x = 0, y = 35},
	})

	local image_id = player:hud_add({
		type = "image",
		position = {x = 0.5, y = 0},
		scale = {x = 0.3, y = 0.3},
		offset = {x = -35, y = 35},
	})
	local name_id = player:hud_add({
		type = "text",
		position = {x = 0.5, y = 0},
		scale = {x = 0.3, y = 0.3},
		number = 0xffffff,
		alignment = {x = 1},
		offset = {x = 0, y = 29},
	})
	local mod_id = player:hud_add({
		type = "text",
		position = {x = 0.5, y = 0},
		scale = {x = 0.3, y = 0.3},
		number = 0xff3c0a,
		alignment = {x = 1},
		offset = {x = 0, y = 46},
	})

	meta:set_string('wit:background_left', background_id_left)
	meta:set_string('wit:background_middle', background_id_middle)
	meta:set_string('wit:background_right', background_id_right)
	meta:set_string('wit:image', image_id)
	meta:set_string('wit:name', name_id)
	meta:set_string('wit:mod', mod_id)
	meta:set_string('wit:pointed_thing', 'ignore')
	meta:set_string('wit:item_type_in_pointer', 'node')

	-- what_is_this_uwu.register_player(player, player:get_player_name())
end)

minetest.register_on_leaveplayer(function(player)
	what_is_this_uwu.remove_player(player, player:get_player_name())
end)

minetest.register_globalstep(function()
	for _, player in ipairs(what_is_this_uwu.players) do
		local meta = player:get_meta()
		local pointed_thing = what_is_this_uwu.get_pointed_thing(player)

		if pointed_thing then
			local node = minetest.get_node(pointed_thing.under)
			local node_name = node.name

			if meta:get_string('wit:pointed_thing') ~= node_name then
				local form_view, item_type, node_definition = what_is_this_uwu.get_node_tiles(node_name, meta)

				if not node_definition then
					what_is_this_uwu.unshow(player, meta)

					return
				end

				local online_charinfo = ch_data.online_charinfo[player:get_player_name()]
				local lang_code = (online_charinfo and online_charinfo.lang_code) or "cs"
				local s = minetest.get_translated_string(lang_code, node_definition._ch_node_viewname or node_definition.description)
				local i = s:find("\n")
				if i ~= nil then
					s = s:sub(1, i - 1)
				end
				local node_description = what_is_this_uwu.destrange(s)
				local mod_name, _ = what_is_this_uwu.split_item_name(node_name)

				what_is_this_uwu.show(player, meta, form_view, node_description, node_name, item_type, mod_name)
			end
		else
			what_is_this_uwu.unshow(player, meta)
		end
	end
end)

--[[
minetest.register_chatcommand('wituwu', {
	params = '',
	description = 'Show and unshow the wituwu pop-up',
	func = function(name)
		local player = minetest.get_player_by_name(name)

		if what_is_this_uwu.players_set[name] then
			what_is_this_uwu.remove_player(name)
			what_is_this_uwu.unshow(player, player:get_meta())
		else
			what_is_this_uwu.register_player(player, name)
		end

		return true, 'Option flipped'
	end
})
]]
ch_base.close_mod(minetest.get_current_modname())

-- LUPA
local def = {
	description = "lupa",
	inventory_image = "ch_extras_lupa.png",
	groups = {tool = 1},
	_ch_help = "Když držíte lupu v ruce, ukáže vám, co jsou zač věci,\nna které ukazujete.",
}
minetest.register_tool("ch_extras:lupa", def)
minetest.register_craft({
	output = "ch_extras:lupa",
	recipe = {
		{"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"},
		{"default:steel_ingot", "moreblocks:clean_glass", "default:steel_ingot"},
		{"", "", "default:steel_ingot"},
	},
})

if minetest.get_modpath("what_is_this_uwu") then
	local function playerstep(player, player_name, online_charinfo, offline_charinfo, us_time)
		local wielded_item = player:get_wielded_item()
		local item_name
		if not wielded_item:is_empty() then
			item_name = wielded_item:get_name()
		end
		if item_name == "ch_extras:lupa" then
			if not what_is_this_uwu.players_set[player_name] then
				what_is_this_uwu.register_player(player, player_name)
			end
		elseif what_is_this_uwu.players_set[player_name] then
			what_is_this_uwu.remove_player(player_name)
			what_is_this_uwu.unshow(player, player:get_meta())
		end
	end
	ch_core.register_player_globalstep(playerstep)
end

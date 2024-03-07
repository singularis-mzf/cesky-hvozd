-- not_wuzzy_dice by TumeniNodes 2/14/2017 (CC0)
-- extended and modified by Singularis 2024-03-06 (CC0)

local facedir_to_value = {
	1, 1, 1,
	-- 4:
	6, 3, 5, 4,
	-- 8:
	5, 4, 6, 3,
	-- 12:
	4, 6, 3, 5,
	-- 16:
	3, 5, 4, 6,
	-- 20:
	2, 2, 2, 2,
}
facedir_to_value[0] = 1

local function on_punch(pos, node, puncher, pointed_thing)
	if minetest.is_player(puncher) and puncher:get_player_control().aux1 then
		local player_name = puncher:get_player_name()
		if minetest.is_protected(pos, player_name) then
			minetest.record_protection_violation(pos, player_name)
			return
		end
		node.param2 = (node.param2 + 32) % 256
		minetest.swap_node(pos, node)
	end
end

local function after_place_node(pos, placer, itemstack, pointed_thing)
	local player_name = placer and placer:get_player_name()
	if player_name == nil or player_name == "" then return end
	-- local palette_index = itemstack:get_meta():get_int("palette_idx")
	local node = minetest.get_node(pos)
	local facedir = math.random(0, 23)
	local value = assert(facedir_to_value[facedir])
	node.param2 = (node.param2 - node.param2 % 32) + facedir
	minetest.swap_node(pos, node)
	local message = ch_core.prihlasovaci_na_zobrazovaci(player_name).." hodil/a na kostce číslo "..value
	for _, player in ipairs(minetest.get_connected_players()) do
		if vector.distance(pos, player:get_pos()) < 50 then
			ch_core.systemovy_kanal(player:get_player_name(), message)
		end
	end
	local sound = (minetest.registered_nodes[node.name].sounds or {}).place
	if sound ~= nil then
		minetest.sound_play(sound, {pos = pos, max_hear_distance = 32}, true)
	end
end

local def = {
	description = "hrací kostka",
	tiles = {
		{name = "not_wuzzy_dice_1.png", backface_culling = true},
		{name = "not_wuzzy_dice_2.png", backface_culling = true},
		{name = "not_wuzzy_dice_3.png", backface_culling = true},
		{name = "not_wuzzy_dice_4.png", backface_culling = true},
		{name = "not_wuzzy_dice_5.png", backface_culling = true},
		{name = "not_wuzzy_dice_6.png", backface_culling = true},
	},
	paramtype = "light",
	paramtype2 = "colorfacedir",
	palette = "not_wuzzy_dice_palette.png",

	groups = {cracky = 3, oddly_breakable_by_hand = 3, stone = 1, ui_generate_palette_items = 8},
	is_ground_content = true,
	sounds = default.node_sound_stone_defaults(),
	node_placement_prediction = "",

	after_place_node = after_place_node,
	on_punch = on_punch,
}
minetest.register_node("not_wuzzy_dice:dice", def)

--[[
for i = 1, 6 do
	minetest.register_node("not_wuzzy_dice:dice_" .. i, {
		description = "Dice",
		tiles = {"not_wuzzy_dice_" .. i .. ".png"},
		groups = {cracky = 3, stone = 1, not_in_creative_inventory = 1},
		sounds = default.node_sound_stone_defaults()
})
end
]]

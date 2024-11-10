if minetest.get_modpath("not_wuzzy_dice") then
    error("Mods conflict with not_wuzzy_dice!")
end

local dice_value_to_textures = {
    -- top, bottom, right, left, front, back
    -- TODO...
    {1, 6, 2, 5, 3, 4},
    {2, 5, 1, 6, 3, 4},
    {3, 4, 1, 6, 2, 5},
    {4, 3, 6, 1, 5, 2},
    {5, 2, 6, 1, 4, 3},
    {6, 1, 5, 2, 4, 3},
}

local dice_tile = ch_core.call(function()
    local result = {}
    for i = 1, 6 do
        result[i] = {name = "not_wuzzy_dice_"..i..".png", backface_culling = true}
    end
    return result
end)

local dice_box = {
    type = "fixed",
    fixed = {-0.25, -0.5, -0.25, 0.25, 0.0, 0.25},
}

local dice_groups = {
    cracky = 1,
    flammable = 2,
    not_in_creative_inventory = 1,
    dig_immediate = 2,
}

local dice_sounds = default.node_sound_wood_defaults()
local dice_drop = {items = {{items = {"ch_extras:dice_1"}, inherit_color = true}}}

local function make_tiles(i)
    local indices = dice_value_to_textures[i]
    local result = {}
    for j = 1, 6 do
        result[j] = assert(dice_tile[indices[j]])
    end
    return result
end

local function after_place_node(pos, placer, itemstack, pointed_thing)
	local player_name = placer and placer:get_player_name()
	if player_name == nil or player_name == "" then return end

	local node = minetest.get_node(pos)
    local color = minetest.strip_param2_color(node.param2, "colordegrotate")
    local value = math.random(1, 6)
    node.name = "ch_extras:dice_"..value
    node.param2 = color + math.random(0, 23)
    minetest.swap_node(pos, node)
	local message = ch_core.prihlasovaci_na_zobrazovaci(player_name).." hodil/a na kostce číslo "..value
	for _, player in ipairs(minetest.get_connected_players()) do
		if vector.distance(pos, player:get_pos()) < 50 then
			ch_core.systemovy_kanal(player:get_player_name(), message)
		end
	end
end

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

local function on_use(itemstack, user, pointed_thing)
	local player_name = user and user:get_player_name()
	if player_name == nil then return end
	local pos = user:get_pos()
	local value = math.random(1, 6)
	local message = ch_core.prihlasovaci_na_zobrazovaci(player_name).." hodil/a na kostce číslo "..value
	for _, player in ipairs(minetest.get_connected_players()) do
		if vector.distance(pos, player:get_pos()) < 50 then
			ch_core.systemovy_kanal(player:get_player_name(), message)
		end
	end
    itemstack:set_name("ch_extras:dice_"..value)
	local sound = dice_sounds.place
	if sound ~= nil then
		minetest.sound_play(sound, {pos = pos, max_hear_distance = 32}, true)
	end
    return itemstack
end

for i = 1, 6 do
    local tiles = make_tiles(i)
    local groups = table.copy(dice_groups)
    if i == 1 then
        groups.not_in_creative_inventory = nil
        groups.ui_generate_palette_items = 8
    end
    groups.ch_dice = i

    local image = "[inventorycube{"..tiles[1].name.."{"..tiles[5].name.."{"..tiles[3].name

    local def = {
        description = "hrací kostka",
        drawtype = "mesh",
        tiles = tiles,
        mesh = "ch_extras_dice.obj",
        paramtype = "light",
        paramtype2 = "colordegrotate",
        palette = "ch_extras_dice_palette.png",
        selection_box = dice_box,
        collision_box = dice_box,
        is_ground_content = false,
        node_placement_prediction = "",
        inventory_image = image,

        groups = groups,
        sounds = dice_sounds,
        drop = dice_drop,

        after_place_node = after_place_node,
        on_punch = on_punch,
        on_use = on_use,
    }
    minetest.register_node("ch_extras:dice_"..i, def)
end

minetest.register_craft({
	output = "ch_extras:dice_1 6",
	recipe = {
		{"bakedclay:white", "bakedclay:grey", "bakedclay:white"},
		{"bakedclay:white", "default:mese_crystal", "bakedclay:white"},
		{"bakedclay:white", "bakedclay:white", "bakedclay:white"},
	},
})

minetest.register_alias("not_wuzzy_dice:dice", "ch_extras:dice_1")

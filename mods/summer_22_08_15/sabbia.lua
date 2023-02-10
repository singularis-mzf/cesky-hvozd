--SABBIA
minetest.register_node("summer:sabbia_mare", {
	description = "plážový písek",
	tiles = {"sabbia_mare_2.png"},
	-- groups = {crumbly = 2, falling_node = 1},
    --groups = {cracky = 3, stone = 1},
	-- drop = 'summer:sabbia_mare',
	--legacy_mineral = true,
groups = {crumbly = 3, falling_node = 1, sand = 1},
	sounds = default.node_sound_sand_defaults(),
	--sounds = default.node_sound_stone_defaults(),
	_ch_help = "abyste získal/a plážový písek, použijte hrábě na žlutý písek;\nto platí i pro všechny tvary písku",
})

minetest.register_craft({
	output = "default:sand",
	recipe = {{"summer:sabbia_mare"}},
})

if minetest.get_modpath("moreblocks") then
	stairsplus:register_slabs_and_slopes("summer", "sabbia_mare", "summer:sabbia_mare", {
		description = "plážový písek",
		tiles = {"sabbia_mare_2.png"},
		groups = {crumbly = 3, falling_node = 1},
		sounds = default.node_sound_sand_defaults(),
	})
	stairsplus:register_bank_slopes("summer:sabbia_mare")
end

local function get_new_node_name(old_node_name)
	if old_node_name == "default:sand" then
		return "summer:sabbia_mare"
	end
	if not minetest.get_modpath("moreblocks") then
		return nil
	end
	local craftitem, category, alternate = stairsplus:analyze_shape(old_node_name)
	if craftitem ~= "default:sand" then
		return nil
	end
	return stairsplus:get_shape("summer:sabbia_mare", category, alternate)
end

local function rake_on_use(itemstack, user, pointed_thing)
	local player_name = user and user:get_player_name()
	if not player_name or pointed_thing.type ~= "node" then
		return
	end
	minetest.sound_play("default_dig_crumbly", {
		to_player = player_name,
		gain = 1.0
	})
	local pos = pointed_thing.under
	if minetest.is_protected(pos, player_name) then
		minetest.record_protection_violation(pos, player_name)
		return
	end
	local node = minetest.get_node(pos)
	node.name = get_new_node_name(node.name)
	if node.name ~= nil then
		minetest.swap_node(pos, node)
	end
	if not minetest.is_creative_enabled(player_name) then
		itemstack:add_wear(100)
	end
	return itemstack
end

minetest.register_tool("summer:rake", {
	description = "hrábě",
	inventory_image = "rake.png",
	on_place = rake_on_use,
	on_use = rake_on_use,
	_ch_help = "použijte hrábě na žlutý písek nebo libovolný jeho tvar\npro jeho změnu na plážový písek",
})

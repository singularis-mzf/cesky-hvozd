-- stairs/init.lua

-- Minetest 0.4 mod: stairs
-- See README.txt for licensing and other information.


-- Global namespace for functions

stairs = {}

-- Load support for MT game translation.
local S = minetest.get_translator("stairs")
-- Same as S, but will be ignored by translation file update scripts
local T = S


-- Register aliases for new pine node names

minetest.register_alias("stairs:stair_pinewood", "stairs:stair_pine_wood")
minetest.register_alias("stairs:slab_pinewood", "stairs:slab_pine_wood")


-- Get setting for replace ABM

local replace = minetest.settings:get_bool("enable_stairs_replace_abm")

local function rotate_and_place(itemstack, placer, pointed_thing)
	local p0 = pointed_thing.under
	local p1 = pointed_thing.above
	local param2 = 0

	if placer then
		local placer_pos = placer:get_pos()
		if placer_pos then
			param2 = minetest.dir_to_facedir(vector.subtract(p1, placer_pos))
		end

		local finepos = minetest.pointed_thing_to_face_pos(placer, pointed_thing)
		local fpos = finepos.y % 1

		if p0.y - 1 == p1.y or (fpos > 0 and fpos < 0.5)
				or (fpos < -0.5 and fpos > -0.999999999) then
			param2 = param2 + 20
			if param2 == 21 then
				param2 = 23
			elseif param2 == 23 then
				param2 = 21
			end
		end
	end
	return minetest.item_place(itemstack, placer, pointed_thing, param2)
end

local function warn_if_exists(nodename)
	if minetest.registered_nodes[nodename] then
		minetest.log("warning", "Overwriting stairs node: " .. nodename)
	end
end


-- Register stair
-- Node will be called stairs:stair_<subname>

function stairs.register_stair(subname, recipeitem, groups, images, description,
		sounds, worldaligntex)
	local src_def = minetest.registered_nodes[recipeitem]

	-- Set backface culling and world-aligned textures
	local stair_images = {}
	for i, image in ipairs(images) do
		if type(image) == "string" then
			stair_images[i] = {
				name = image,
				backface_culling = true,
			}
			if worldaligntex then
				stair_images[i].align_style = "world"
			end
		else
			stair_images[i] = table.copy(image)
			if stair_images[i].backface_culling == nil then
				stair_images[i].backface_culling = true
			end
			if worldaligntex and stair_images[i].align_style == nil then
				stair_images[i].align_style = "world"
			end
		end
	end
	local new_groups = table.copy(groups)
	new_groups.stair = 1
	warn_if_exists("stairs:stair_" .. subname)
	minetest.register_node(":stairs:stair_" .. subname, {
		description = description .. " (" .. S("Stair") .. ")",
		drawtype = "nodebox",
		tiles = stair_images,
		use_texture_alpha = src_def and src_def.use_texture_alpha,
		paramtype = "light",
		paramtype2 = "facedir",
		is_ground_content = false,
		groups = new_groups,
		sounds = sounds,
		node_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.5, 0.5, 0.0, 0.5},
				{-0.5, 0.0, 0.0, 0.5, 0.5, 0.5},
			},
		},
		on_place = function(itemstack, placer, pointed_thing)
			if pointed_thing.type ~= "node" then
				return itemstack
			end

			return rotate_and_place(itemstack, placer, pointed_thing)
		end,
	})

	-- for replace ABM
	if replace then
		minetest.register_node(":stairs:stair_" .. subname .. "upside_down", {
			replace_name = "stairs:stair_" .. subname,
			groups = {slabs_replace = 1},
		})
	end

	if recipeitem then
		-- Recipe matches appearence in inventory
		minetest.register_craft({
			output = "stairs:stair_" .. subname .. " 8",
			recipe = {
				{"", "", recipeitem},
				{"", recipeitem, recipeitem},
				{recipeitem, recipeitem, recipeitem},
			},
		})

		-- Use stairs to craft full blocks again (1:1)
		minetest.register_craft({
			output = recipeitem .. " 3",
			recipe = {
				{"stairs:stair_" .. subname, "stairs:stair_" .. subname},
				{"stairs:stair_" .. subname, "stairs:stair_" .. subname},
			},
		})

		-- Fuel
		local baseburntime = minetest.get_craft_result({
			method = "fuel",
			width = 1,
			items = {recipeitem}
		}).time
		if baseburntime > 0 then
			minetest.register_craft({
				type = "fuel",
				recipe = "stairs:stair_" .. subname,
				burntime = math.floor(baseburntime * 0.75),
			})
		end
	end
end


-- Register slab
-- Node will be called stairs:slab_<subname>

function stairs.register_slab(subname, recipeitem, groups, images, description,
		sounds, worldaligntex)
	local src_def = minetest.registered_nodes[recipeitem]

	-- Set world-aligned textures
	local slab_images = {}
	for i, image in ipairs(images) do
		if type(image) == "string" then
			slab_images[i] = {
				name = image,
			}
			if worldaligntex then
				slab_images[i].align_style = "world"
			end
		else
			slab_images[i] = table.copy(image)
			if worldaligntex and image.align_style == nil then
				slab_images[i].align_style = "world"
			end
		end
	end
	local new_groups = table.copy(groups)
	new_groups.slab = 1
	warn_if_exists("stairs:slab_" .. subname)
	minetest.register_node(":stairs:slab_" .. subname, {
		description = description .. " (" .. S("Slab") .. ")",
		drawtype = "nodebox",
		tiles = slab_images,
		use_texture_alpha = src_def and src_def.use_texture_alpha,
		paramtype = "light",
		paramtype2 = "facedir",
		is_ground_content = false,
		groups = new_groups,
		sounds = sounds,
		node_box = {
			type = "fixed",
			fixed = {-0.5, -0.5, -0.5, 0.5, 0, 0.5},
		},
		on_place = function(itemstack, placer, pointed_thing)
			local under = minetest.get_node(pointed_thing.under)
			local wield_item = itemstack:get_name()
			local player_name = placer and placer:get_player_name() or ""

			if under and under.name:find("^stairs:slab_") then
				-- place slab using under node orientation
				local dir = minetest.dir_to_facedir(vector.subtract(
					pointed_thing.above, pointed_thing.under), true)

				local p2 = under.param2

				-- Placing a slab on an upside down slab should make it right-side up.
				if p2 >= 20 and dir == 8 then
					p2 = p2 - 20
				-- same for the opposite case: slab below normal slab
				elseif p2 <= 3 and dir == 4 then
					p2 = p2 + 20
				end

				-- else attempt to place node with proper param2
				minetest.item_place_node(ItemStack(wield_item), placer, pointed_thing, p2)
				if not minetest.is_creative_enabled(player_name) then
					itemstack:take_item()
				end
				return itemstack
			else
				return rotate_and_place(itemstack, placer, pointed_thing)
			end
		end,
	})

	-- for replace ABM
	if replace then
		minetest.register_node(":stairs:slab_" .. subname .. "upside_down", {
			replace_name = "stairs:slab_".. subname,
			groups = {slabs_replace = 1},
		})
	end

	if recipeitem then
		minetest.register_craft({
			output = "stairs:slab_" .. subname .. " 6",
			recipe = {
				{recipeitem, recipeitem, recipeitem},
			},
		})

		-- Use 2 slabs to craft a full block again (1:1)
		minetest.register_craft({
			output = recipeitem,
			recipe = {
				{"stairs:slab_" .. subname},
				{"stairs:slab_" .. subname},
			},
		})

		-- Fuel
		local baseburntime = minetest.get_craft_result({
			method = "fuel",
			width = 1,
			items = {recipeitem}
		}).time
		if baseburntime > 0 then
			minetest.register_craft({
				type = "fuel",
				recipe = "stairs:slab_" .. subname,
				burntime = math.floor(baseburntime * 0.5),
			})
		end
	end
end


-- Optionally replace old "upside_down" nodes with new param2 versions.
-- Disabled by default.

if replace then
	minetest.register_abm({
		label = "Slab replace",
		nodenames = {"group:slabs_replace"},
		interval = 16,
		chance = 1,
		action = function(pos, node)
			node.name = minetest.registered_nodes[node.name].replace_name
			node.param2 = node.param2 + 20
			if node.param2 == 21 then
				node.param2 = 23
			elseif node.param2 == 23 then
				node.param2 = 21
			end
			minetest.set_node(pos, node)
		end,
	})
end


-- Register inner stair
-- Node will be called stairs:stair_inner_<subname>

function stairs.register_stair_inner(subname, recipeitem, groups, images,
		description, sounds, worldaligntex, full_description)
	local src_def = minetest.registered_nodes[recipeitem]

	-- Set backface culling and world-aligned textures
	local stair_images = {}
	for i, image in ipairs(images) do
		if type(image) == "string" then
			stair_images[i] = {
				name = image,
				backface_culling = true,
			}
			if worldaligntex then
				stair_images[i].align_style = "world"
			end
		else
			stair_images[i] = table.copy(image)
			if stair_images[i].backface_culling == nil then
				stair_images[i].backface_culling = true
			end
			if worldaligntex and stair_images[i].align_style == nil then
				stair_images[i].align_style = "world"
			end
		end
	end
	local new_groups = table.copy(groups)
	new_groups.stair = 1
	if full_description then
		description = full_description
	else
		description = description .. " (" .. S("Inner Stair") .. ")"
	end
	warn_if_exists("stairs:stair_inner_" .. subname)
	minetest.register_node(":stairs:stair_inner_" .. subname, {
		description = description,
		drawtype = "nodebox",
		tiles = stair_images,
		use_texture_alpha = src_def and src_def.use_texture_alpha,
		paramtype = "light",
		paramtype2 = "facedir",
		is_ground_content = false,
		groups = new_groups,
		sounds = sounds,
		node_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.5, 0.5, 0.0, 0.5},
				{-0.5, 0.0, 0.0, 0.5, 0.5, 0.5},
				{-0.5, 0.0, -0.5, 0.0, 0.5, 0.0},
			},
		},
		on_place = function(itemstack, placer, pointed_thing)
			if pointed_thing.type ~= "node" then
				return itemstack
			end

			return rotate_and_place(itemstack, placer, pointed_thing)
		end,
	})

	if recipeitem then
		minetest.register_craft({
			output = "stairs:stair_inner_" .. subname .. " 7",
			recipe = {
				{"", recipeitem, ""},
				{recipeitem, "", recipeitem},
				{recipeitem, recipeitem, recipeitem},
			},
		})

		-- Fuel
		local baseburntime = minetest.get_craft_result({
			method = "fuel",
			width = 1,
			items = {recipeitem}
		}).time
		if baseburntime > 0 then
			minetest.register_craft({
				type = "fuel",
				recipe = "stairs:stair_inner_" .. subname,
				burntime = math.floor(baseburntime * 0.875),
			})
		end
	end
end


-- Register outer stair
-- Node will be called stairs:stair_outer_<subname>

function stairs.register_stair_outer(subname, recipeitem, groups, images,
		description, sounds, worldaligntex, full_description)
	local src_def = minetest.registered_nodes[recipeitem]

	-- Set backface culling and world-aligned textures
	local stair_images = {}
	for i, image in ipairs(images) do
		if type(image) == "string" then
			stair_images[i] = {
				name = image,
				backface_culling = true,
			}
			if worldaligntex then
				stair_images[i].align_style = "world"
			end
		else
			stair_images[i] = table.copy(image)
			if stair_images[i].backface_culling == nil then
				stair_images[i].backface_culling = true
			end
			if worldaligntex and stair_images[i].align_style == nil then
				stair_images[i].align_style = "world"
			end
		end
	end
	local new_groups = table.copy(groups)
	new_groups.stair = 1
	if full_description then
		description = full_description
	else
		description = description .. " (" .. S("Outer Stair") .. ")"
	end
	warn_if_exists("stairs:stair_outer_" .. subname)
	minetest.register_node(":stairs:stair_outer_" .. subname, {
		description = description,
		drawtype = "nodebox",
		tiles = stair_images,
		use_texture_alpha = src_def and src_def.use_texture_alpha,
		paramtype = "light",
		paramtype2 = "facedir",
		is_ground_content = false,
		groups = new_groups,
		sounds = sounds,
		node_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.5, 0.5, 0.0, 0.5},
				{-0.5, 0.0, 0.0, 0.0, 0.5, 0.5},
			},
		},
		on_place = function(itemstack, placer, pointed_thing)
			if pointed_thing.type ~= "node" then
				return itemstack
			end

			return rotate_and_place(itemstack, placer, pointed_thing)
		end,
	})

	if recipeitem then
		minetest.register_craft({
			output = "stairs:stair_outer_" .. subname .. " 6",
			recipe = {
				{"", recipeitem, ""},
				{recipeitem, recipeitem, recipeitem},
			},
		})

		-- Fuel
		local baseburntime = minetest.get_craft_result({
			method = "fuel",
			width = 1,
			items = {recipeitem}
		}).time
		if baseburntime > 0 then
			minetest.register_craft({
				type = "fuel",
				recipe = "stairs:stair_outer_" .. subname,
				burntime = math.floor(baseburntime * 0.625),
			})
		end
	end
end


-- Stair/slab registration function.
-- Nodes will be called stairs:{stair,slab}_<subname>

function stairs.register_stair_and_slab(subname, recipeitem, groups, images,
		desc_stair, desc_slab, sounds, worldaligntex,
		desc_stair_inner, desc_stair_outer)
    local description = desc_stair
    stairs.register_stair(subname, recipeitem, groups, images, description,
		sounds, worldaligntex)
	stairs.register_stair_inner(subname, recipeitem, groups, images,
		description, sounds, worldaligntex)
	stairs.register_stair_outer(subname, recipeitem, groups, images,
		description, sounds, worldaligntex)
	stairs.register_slab(subname, recipeitem, groups, images, description,
		sounds, worldaligntex)
end

-- Local function so we can apply translations
local function my_register_stair_and_slab(subname, recipeitem, groups, images,
		desc_stair, desc_slab, sounds, worldaligntex)
    local description = desc_stair
	stairs.register_stair(subname, recipeitem, groups, images, description,
		sounds, worldaligntex)
	stairs.register_stair_inner(subname, recipeitem, groups, images, description,
		sounds, worldaligntex)
	stairs.register_stair_outer(subname, recipeitem, groups, images, description,
		sounds, worldaligntex)
	stairs.register_slab(subname, recipeitem, groups, images, description,
		sounds, worldaligntex)
end


-- Register default stairs and slabs

--[[
my_register_stair_and_slab(
	"wood",
	"default:wood",
	{choppy = 2, oddly_breakable_by_hand = 2, flammable = 2},
	{"default_wood.png"},
	S("Wood"),
	S("Wood"),
	default.node_sound_wood_defaults(),
	false
)

my_register_stair_and_slab(
	"junglewood",
	"default:junglewood",
	{choppy = 2, oddly_breakable_by_hand = 2, flammable = 2},
	{"default_junglewood.png"},
	S("Jungle Wood"),
	S("Jungle Wood"),
	default.node_sound_wood_defaults(),
	false
)

my_register_stair_and_slab(
	"pine_wood",
	"default:pine_wood",
	{choppy = 3, oddly_breakable_by_hand = 2, flammable = 3},
	{"default_pine_wood.png"},
	S("Pine Wood"),
	S("Pine Wood"),
	default.node_sound_wood_defaults(),
	false
)

my_register_stair_and_slab(
	"acacia_wood",
	"default:acacia_wood",
	{choppy = 2, oddly_breakable_by_hand = 2, flammable = 2},
	{"default_acacia_wood.png"},
	S("Acacia Wood"),
	S("Acacia Wood"),
	default.node_sound_wood_defaults(),
	false
)

my_register_stair_and_slab(
	"aspen_wood",
	"default:aspen_wood",
	{choppy = 3, oddly_breakable_by_hand = 2, flammable = 3},
	{"default_aspen_wood.png"},
	S("Aspen Wood"),
	S("Aspen Wood"),
	default.node_sound_wood_defaults(),
	false
)

my_register_stair_and_slab(
	"stone",
	"default:stone",
	{cracky = 3},
	{"default_stone.png"},
	S("Stone"),
	S("Stone"),
	default.node_sound_stone_defaults(),
	true
)

my_register_stair_and_slab(
	"cobble",
	"default:cobble",
	{cracky = 3},
	{"default_cobble.png"},
	S("Cobblestone"),
	S("Cobblestone"),
	default.node_sound_stone_defaults(),
	true
)

my_register_stair_and_slab(
	"mossycobble",
	"default:mossycobble",
	{cracky = 3},
	{"default_mossycobble.png"},
	S("Mossy Cobblestone"),
	S("Mossy Cobblestone"),
	default.node_sound_stone_defaults(),
	true
)

my_register_stair_and_slab(
	"stonebrick",
	"default:stonebrick",
	{cracky = 2},
	{"default_stone_brick.png"},
	S("Stone Brick"),
	S("Stone Brick"),
	default.node_sound_stone_defaults(),
	false
)

my_register_stair_and_slab(
	"stone_block",
	"default:stone_block",
	{cracky = 2},
	{"default_stone_block.png"},
	S("Stone Block"),
	S("Stone Block"),
	default.node_sound_stone_defaults(),
	true
)

my_register_stair_and_slab(
	"desert_stone",
	"default:desert_stone",
	{cracky = 3},
	{"default_desert_stone.png"},
	S("Desert Stone"),
	S("Desert Stone"),
	default.node_sound_stone_defaults(),
	true
)

my_register_stair_and_slab(
	"desert_cobble",
	"default:desert_cobble",
	{cracky = 3},
	{"default_desert_cobble.png"},
	S("Desert Cobblestone"),
	S("Desert Cobblestone"),
	default.node_sound_stone_defaults(),
	true
)

my_register_stair_and_slab(
	"desert_stonebrick",
	"default:desert_stonebrick",
	{cracky = 2},
	{"default_desert_stone_brick.png"},
	S("Desert Stone Brick"),
	S("Desert Stone Brick"),
	default.node_sound_stone_defaults(),
	false
)

my_register_stair_and_slab(
	"desert_stone_block",
	"default:desert_stone_block",
	{cracky = 2},
	{"default_desert_stone_block.png"},
	S("Desert Stone Block"),
	S("Desert Stone Block"),
	default.node_sound_stone_defaults(),
	true
)

my_register_stair_and_slab(
	"sandstone",
	"default:sandstone",
	{crumbly = 1, cracky = 3},
	{"default_sandstone.png"},
	S("Sandstone"),
	S("Sandstone"),
	default.node_sound_stone_defaults(),
	false
)

my_register_stair_and_slab(
	"sandstonebrick",
	"default:sandstonebrick",
	{cracky = 2},
	{"default_sandstone_brick.png"},
	S("Sandstone Brick"),
	S("Sandstone Brick Slab"),
	default.node_sound_stone_defaults(),
	false
)

my_register_stair_and_slab(
	"sandstone_block",
	"default:sandstone_block",
	{cracky = 2},
	{"default_sandstone_block.png"},
	S("Sandstone Block"),
	S("Sandstone Block"),
	default.node_sound_stone_defaults(),
	true
)

my_register_stair_and_slab(
	"desert_sandstone",
	"default:desert_sandstone",
	{crumbly = 1, cracky = 3},
	{"default_desert_sandstone.png"},
	S("Desert Sandstone"),
	S("Desert Sandstone"),
	default.node_sound_stone_defaults(),
	true
)

my_register_stair_and_slab(
	"desert_sandstone_brick",
	"default:desert_sandstone_brick",
	{cracky = 2},
	{"default_desert_sandstone_brick.png"},
	S("Desert Sandstone Brick"),
	S("Desert Sandstone Brick Slab"),
	default.node_sound_stone_defaults(),
	false
)

my_register_stair_and_slab(
	"desert_sandstone_block",
	"default:desert_sandstone_block",
	{cracky = 2},
	{"default_desert_sandstone_block.png"},
	S("Desert Sandstone Block"),
	S("Desert Sandstone Block"),
	default.node_sound_stone_defaults(),
	true
)

my_register_stair_and_slab(
	"silver_sandstone",
	"default:silver_sandstone",
	{crumbly = 1, cracky = 3},
	{"default_silver_sandstone.png"},
	S("Silver Sandstone"),
	S("Silver Sandstone Slab"),
	default.node_sound_stone_defaults(),
	true
)

my_register_stair_and_slab(
	"silver_sandstone_brick",
	"default:silver_sandstone_brick",
	{cracky = 2},
	{"default_silver_sandstone_brick.png"},
	S("Silver Sandstone Brick"),
	S("Silver Sandstone Brick"),
	default.node_sound_stone_defaults(),
	false
)

my_register_stair_and_slab(
	"silver_sandstone_block",
	"default:silver_sandstone_block",
	{cracky = 2},
	{"default_silver_sandstone_block.png"},
	S("Silver Sandstone Block"),
	S("Silver Sandstone Block"),
	default.node_sound_stone_defaults(),
	true
)

my_register_stair_and_slab(
	"obsidian",
	"default:obsidian",
	{cracky = 1, level = 2},
	{"default_obsidian.png"},
	S("Obsidian"),
	S("Obsidian"),
	default.node_sound_stone_defaults(),
	true
)

my_register_stair_and_slab(
	"obsidianbrick",
	"default:obsidianbrick",
	{cracky = 1, level = 2},
	{"default_obsidian_brick.png"},
	S("Obsidian Brick"),
	S("Obsidian Brick"),
	default.node_sound_stone_defaults(),
	false
)

my_register_stair_and_slab(
	"obsidian_block",
	"default:obsidian_block",
	{cracky = 1, level = 2},
	{"default_obsidian_block.png"},
	S("Obsidian Block"),
	S("Obsidian Block"),
	default.node_sound_stone_defaults(),
	true
)

my_register_stair_and_slab(
	"brick",
	"default:brick",
	{cracky = 3},
	{"default_brick.png"},
	S("Brick"),
	S("Brick"),
	default.node_sound_stone_defaults(),
	false
)

my_register_stair_and_slab(
	"steelblock",
	"default:steelblock",
	{cracky = 1, level = 2},
	{"default_steel_block.png"},
	S("Steel Block"),
	S("Steel Block"),
	default.node_sound_metal_defaults(),
	true
)

my_register_stair_and_slab(
	"tinblock",
	"default:tinblock",
	{cracky = 1, level = 2},
	{"default_tin_block.png"},
	S("Tin Block"),
	S("Tin Block"),
	default.node_sound_metal_defaults(),
	true
)

my_register_stair_and_slab(
	"copperblock",
	"default:copperblock",
	{cracky = 1, level = 2},
	{"default_copper_block.png"},
	S("Copper Block"),
	S("Copper Block"),
	default.node_sound_metal_defaults(),
	true
)

my_register_stair_and_slab(
	"bronzeblock",
	"default:bronzeblock",
	{cracky = 1, level = 2},
	{"default_bronze_block.png"},
	S("Bronze Block"),
	S("Bronze Block"),
	default.node_sound_metal_defaults(),
	true
)

my_register_stair_and_slab(
	"goldblock",
	"default:goldblock",
	{cracky = 1},
	{"default_gold_block.png"},
	S("Gold Block"),
	S("Gold Block"),
	default.node_sound_metal_defaults(),
	true
)

my_register_stair_and_slab(
	"ice",
	"default:ice",
	{cracky = 3, cools_lava = 1, slippery = 3},
	{"default_ice.png"},
	S("Ice"),
	S("Ice"),
	default.node_sound_ice_defaults(),
	true
)

my_register_stair_and_slab(
	"snowblock",
	"default:snowblock",
	{crumbly = 3, cools_lava = 1, snowy = 1},
	{"default_snow.png"},
	S("Snow Block"),
	S("Snow Block"),
	default.node_sound_snow_defaults(),
	true
)

-- Glass stair nodes need to be registered individually to utilize specialized textures.

stairs.register_stair(
	"glass",
	"default:glass",
	{cracky = 3, oddly_breakable_by_hand = 3},
	{"stairs_glass_split.png", "default_glass.png",
	"stairs_glass_stairside.png^[transformFX", "stairs_glass_stairside.png",
	"default_glass.png", "stairs_glass_split.png"},
	S("Glass"),
	default.node_sound_glass_defaults(),
	false
)

stairs.register_slab(
	"glass",
	"default:glass",
	{cracky = 3, oddly_breakable_by_hand = 3},
	{"default_glass.png", "default_glass.png", "stairs_glass_split.png"},
	S("Glass"),
	default.node_sound_glass_defaults(),
	false
)

stairs.register_stair_inner(
	"glass",
	"default:glass",
	{cracky = 3, oddly_breakable_by_hand = 3},
	{"stairs_glass_stairside.png^[transformR270", "default_glass.png",
	"stairs_glass_stairside.png^[transformFX", "default_glass.png",
	"default_glass.png", "stairs_glass_stairside.png"},
	"",
	default.node_sound_glass_defaults(),
	false,
	S("Glass")
)

stairs.register_stair_outer(
	"glass",
	"default:glass",
	{cracky = 3, oddly_breakable_by_hand = 3},
	{"stairs_glass_stairside.png^[transformR90", "default_glass.png",
	"stairs_glass_outer_stairside.png", "stairs_glass_stairside.png",
	"stairs_glass_stairside.png^[transformR90","stairs_glass_outer_stairside.png"},
	"",
	default.node_sound_glass_defaults(),
	false,
	S("Glass")
)

stairs.register_stair(
	"obsidian_glass",
	"default:obsidian_glass",
	{cracky = 3},
	{"stairs_obsidian_glass_split.png", "default_obsidian_glass.png",
	"stairs_obsidian_glass_stairside.png^[transformFX", "stairs_obsidian_glass_stairside.png",
	"default_obsidian_glass.png", "stairs_obsidian_glass_split.png"},
	S("Obsidian Glass"),
	default.node_sound_glass_defaults(),
	false
)

stairs.register_slab(
	"obsidian_glass",
	"default:obsidian_glass",
	{cracky = 3},
	{"default_obsidian_glass.png", "default_obsidian_glass.png", "stairs_obsidian_glass_split.png"},
	S("Obsidian Glass"),
	default.node_sound_glass_defaults(),
	false
)

stairs.register_stair_inner(
	"obsidian_glass",
	"default:obsidian_glass",
	{cracky = 3},
	{"stairs_obsidian_glass_stairside.png^[transformR270", "default_obsidian_glass.png",
	"stairs_obsidian_glass_stairside.png^[transformFX", "default_obsidian_glass.png",
	"default_obsidian_glass.png", "stairs_obsidian_glass_stairside.png"},
	"",
	default.node_sound_glass_defaults(),
	false,
	S("Obsidian Glass")
)

stairs.register_stair_outer(
	"obsidian_glass",
	"default:obsidian_glass",
	{cracky = 3},
	{"stairs_obsidian_glass_stairside.png^[transformR90", "default_obsidian_glass.png",
	"stairs_obsidian_glass_outer_stairside.png", "stairs_obsidian_glass_stairside.png",
	"stairs_obsidian_glass_stairside.png^[transformR90","stairs_obsidian_glass_outer_stairside.png"},
	"",
	default.node_sound_glass_defaults(),
	false,
	S("Obsidian Glass")
)
]]
-- Dummy calls to S() to allow translation scripts to detect the strings.
-- To update this add this code to my_register_stair_and_slab:
-- for _,x in ipairs({"","Inner ","Outer "}) do print(("S(%q)"):format(x..desc_stair)) end
-- print(("S(%q)"):format(desc_slab))

--[[
S("Wooden Stair")
S("Inner Wooden Stair")
S("Outer Wooden Stair")
S("Wooden Slab")
S("Jungle Wood Stair")
S("Inner Jungle Wood Stair")
S("Outer Jungle Wood Stair")
S("Jungle Wood Slab")
S("Pine Wood Stair")
S("Inner Pine Wood Stair")
S("Outer Pine Wood Stair")
S("Pine Wood Slab")
S("Acacia Wood Stair")
S("Inner Acacia Wood Stair")
S("Outer Acacia Wood Stair")
S("Acacia Wood Slab")
S("Aspen Wood Stair")
S("Inner Aspen Wood Stair")
S("Outer Aspen Wood Stair")
S("Aspen Wood Slab")
S("Stone Stair")
S("Inner Stone Stair")
S("Outer Stone Stair")
S("Stone Slab")
S("Cobblestone Stair")
S("Inner Cobblestone Stair")
S("Outer Cobblestone Stair")
S("Cobblestone Slab")
S("Mossy Cobblestone Stair")
S("Inner Mossy Cobblestone Stair")
S("Outer Mossy Cobblestone Stair")
S("Mossy Cobblestone Slab")
S("Stone Brick Stair")
S("Inner Stone Brick Stair")
S("Outer Stone Brick Stair")
S("Stone Brick Slab")
S("Stone Block Stair")
S("Inner Stone Block Stair")
S("Outer Stone Block Stair")
S("Stone Block Slab")
S("Desert Stone Stair")
S("Inner Desert Stone Stair")
S("Outer Desert Stone Stair")
S("Desert Stone Slab")
S("Desert Cobblestone Stair")
S("Inner Desert Cobblestone Stair")
S("Outer Desert Cobblestone Stair")
S("Desert Cobblestone Slab")
S("Desert Stone Brick Stair")
S("Inner Desert Stone Brick Stair")
S("Outer Desert Stone Brick Stair")
S("Desert Stone Brick Slab")
S("Desert Stone Block Stair")
S("Inner Desert Stone Block Stair")
S("Outer Desert Stone Block Stair")
S("Desert Stone Block Slab")
S("Sandstone Stair")
S("Inner Sandstone Stair")
S("Outer Sandstone Stair")
S("Sandstone Slab")
S("Sandstone Brick Stair")
S("Inner Sandstone Brick Stair")
S("Outer Sandstone Brick Stair")
S("Sandstone Brick Slab")
S("Sandstone Block Stair")
S("Inner Sandstone Block Stair")
S("Outer Sandstone Block Stair")
S("Sandstone Block Slab")
S("Desert Sandstone Stair")
S("Inner Desert Sandstone Stair")
S("Outer Desert Sandstone Stair")
S("Desert Sandstone Slab")
S("Desert Sandstone Brick Stair")
S("Inner Desert Sandstone Brick Stair")
S("Outer Desert Sandstone Brick Stair")
S("Desert Sandstone Brick Slab")
S("Desert Sandstone Block Stair")
S("Inner Desert Sandstone Block Stair")
S("Outer Desert Sandstone Block Stair")
S("Desert Sandstone Block Slab")
S("Silver Sandstone Stair")
S("Inner Silver Sandstone Stair")
S("Outer Silver Sandstone Stair")
S("Silver Sandstone Slab")
S("Silver Sandstone Brick Stair")
S("Inner Silver Sandstone Brick Stair")
S("Outer Silver Sandstone Brick Stair")
S("Silver Sandstone Brick Slab")
S("Silver Sandstone Block Stair")
S("Inner Silver Sandstone Block Stair")
S("Outer Silver Sandstone Block Stair")
S("Silver Sandstone Block Slab")
S("Obsidian Stair")
S("Inner Obsidian Stair")
S("Outer Obsidian Stair")
S("Obsidian Slab")
S("Obsidian Brick Stair")
S("Inner Obsidian Brick Stair")
S("Outer Obsidian Brick Stair")
S("Obsidian Brick Slab")
S("Obsidian Block Stair")
S("Inner Obsidian Block Stair")
S("Outer Obsidian Block Stair")
S("Obsidian Block Slab")
S("Brick Stair")
S("Inner Brick Stair")
S("Outer Brick Stair")
S("Brick Slab")
S("Steel Block Stair")
S("Inner Steel Block Stair")
S("Outer Steel Block Stair")
S("Steel Block Slab")
S("Tin Block Stair")
S("Inner Tin Block Stair")
S("Outer Tin Block Stair")
S("Tin Block Slab")
S("Copper Block Stair")
S("Inner Copper Block Stair")
S("Outer Copper Block Stair")
S("Copper Block Slab")
S("Bronze Block Stair")
S("Inner Bronze Block Stair")
S("Outer Bronze Block Stair")
S("Bronze Block Slab")
S("Gold Block Stair")
S("Inner Gold Block Stair")
S("Outer Gold Block Stair")
S("Gold Block Slab")
S("Ice Stair")
S("Inner Ice Stair")
S("Outer Ice Stair")
S("Ice Slab")
S("Snow Block Stair")
S("Inner Snow Block Stair")
S("Outer Snow Block Stair")
S("Snow Block Slab")
--]]

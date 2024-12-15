ch_base.open_mod(minetest.get_current_modname())
-- Pillars by Citorva
-- This mode is licensed as MIT licence. This code can't be edited or copyed
-- outside the terms of this license.


local ifthenelse = ch_core.ifthenelse

local basic_shape = {
	{-0.5, 0.25, -0.5, 0.5, 0.5, 0.5}, -- top
	{-0.5, -0.5, -0.5, 0.5, -0.25, 0.5}, -- bot
	{-0.25, -0.1875, -0.25, 0.25, 0.1875, 0.25}, -- body
	{-0.375, 0.1875, -0.375, 0.375, 0.25, 0.375}, -- Top Step
	{-0.375, -0.25, -0.375, 0.375, -0.1875, 0.375}, -- Bottom Step
}

local bottom_shape = {
	{-0.5, -0.5, -0.5, 0.5, -0.25, 0.5}, -- Base
	{-0.375, -0.25, -0.375, 0.375, -0.1875, 0.375}, -- First Step
	{-0.3125, -0.1875, -0.3125, 0.3125, -0.0625, 0.3125}, -- Second Step
	{-0.25, -0.0625, -0.25, 0.25, 0.5, 0.25}, -- Pillar
}

local top_shape = {
	{-0.25, -0.5, -0.25, 0.25, 0.0625, 0.25}, -- Pillar
	{-0.3125, 0.0625, -0.3125, 0.3125, 0.1875, 0.3125}, -- Second Step
	{-0.375, 0.1875, -0.375, 0.375, 0.25, 0.375}, -- First Step
	{-0.5, 0.25, -0.5, 0.5, 0.5, 0.5}, -- Base
}

local middle_shape = {
	{-0.25, -0.5, -0.25, 0.25, 0.5, 0.25}, -- body
}

local function make_half_shape(box)
	local newbox = {}
	for i, b in ipairs(box) do
		newbox[i] = {b[1], b[2], b[3] + 0.5, b[4], b[5], 0.5}
	end
	return newbox
end

local basic_shape_half = make_half_shape(basic_shape)
local bottom_shape_half = make_half_shape(bottom_shape)
local top_shape_half = make_half_shape(top_shape)
local middle_shape_half = make_half_shape(middle_shape)

local basic_shapes = {[""] = "", T = "_bot", TB = "_mid", B = "_top"}
local half_shapes = {[""] = "_half", T = "_hbot", TB = "_hmid", B = "_htop"}

local shapes = {
	{
		suffix = "",
		box = basic_shape,
		groups_override = {pillar = 1},
		sides = {},
		alt_shapes = basic_shapes,
		drop_suffix = "",
		description = "pilíř",
	}, {
		suffix = "_bot",
		box = bottom_shape,
		groups_override = {pillar = 2, not_in_creative_inventory = 1},
		sides = { "top" },
		alt_shapes = basic_shapes,
		drop_suffix = "",
		description = "pilíř (spodní díl)",
	}, {
		suffix = "_mid",
		box = middle_shape,
		groups_override = {pillar = 3, not_in_creative_inventory = 1},
		sides = { "top", "bottom" },
		alt_shapes = basic_shapes,
		drop_suffix = "",
		description = "pilíř (střední díl)",
	}, {
		suffix = "_top",
		box = top_shape,
		groups_override = {pillar = 4, not_in_creative_inventory = 1},
		sides = { "bottom" },
		alt_shapes = basic_shapes,
		drop_suffix = "",
		description = "pilíř (horní díl)",
	}, {
		suffix = "_half",
		box = basic_shape_half,
		groups_override = {pillar = 5},
		sides = {},
		alt_shapes = half_shapes,
		drop_suffix = "_half",
		description = "pilíř poloviční",
	}, {
		suffix = "_hbot",
		box = bottom_shape_half,
		groups_override = {pillar = 6, not_in_creative_inventory = 1},
		sides = { "top" },
		alt_shapes = half_shapes,
		drop_suffix = "_half",
		description = "pilíř poloviční (spodní díl)",
	}, {
		suffix = "_hmid",
		box = middle_shape_half,
		groups_override = {pillar = 7, not_in_creative_inventory = 1},
		sides = { "top", "bottom" },
		alt_shapes = half_shapes,
		drop_suffix = "_half",
		description = "pilíř poloviční (střední díl)",
	}, {
		suffix = "_htop",
		box = top_shape_half,
		groups_override = {pillar = 8, not_in_creative_inventory = 1},
		sides = { "bottom" },
		alt_shapes = half_shapes,
		drop_suffix = "_half",
		description = "pilíř poloviční (horní díl)",
	}
}

local group_to_shapedef = {}
local suffix_to_shapedef = {}

for _, shape_def in ipairs(shapes) do
	local i = assert(shape_def.groups_override.pillar)
	if group_to_shapedef[i] ~= nil then
		error("Duplicity in pillar groups!")
	end
	group_to_shapedef[i] = shape_def
	if suffix_to_shapedef[shape_def.suffix] ~= nil then
		error("Duplicity in pillar suffixes!")
	end
	suffix_to_shapedef[shape_def.suffix] = shape_def
end

-- => (recipeitem, shape_def) or (nil, nil)
local function analyze_shape(node_name)
	local ndef = minetest.registered_nodes[node_name]
	if ndef ~= nil then
		local groups = ndef.groups
		if groups ~= nil then
			local pillar = groups.pillar
			if pillar ~= nil then
				local recipeitem = ndef._ch_pillar_recipeitem
				local shape_def = group_to_shapedef[ndef.groups.pillar]
				if recipeitem ~= nil and shape_def ~= nil then
					return recipeitem, shape_def
				end
			end
		end
	end
	return nil, nil
end

local function is_pillar(node_name)
	return group_to_shapedef[minetest.get_item_group(node_name, "pillar")] ~= nil
end

--[[
	[recipeitem] = STRING, -- základ jména (tzn. pillars:XXX<suffix>)
]]
local registered_pillars = {}

local function get_shape(recipeitem, suffix)
	local pname = registered_pillars[recipeitem]
	if pname ~= nil and suffix_to_shapedef[suffix] ~= nil then
		local result = "pillars:"..pname..suffix
		if minetest.registered_nodes[result] ~= nil then
			return result
		end
	end
end

local function update_pillar(pos)
	local node = minetest.get_node(pos)
	local recipeitem, shape_def = analyze_shape(node.name)

	if recipeitem == nil then
		return -- not a pillar
	end
	local on_top = is_pillar(minetest.get_node(vector.offset(pos, 0, 1, 0)).name)
	local on_bot = is_pillar(minetest.get_node(vector.offset(pos, 0, -1, 0)).name)
	local expected_shape
	
	if on_top and on_bot then
		expected_shape = shape_def.alt_shapes.TB
	elseif on_top then
		expected_shape = shape_def.alt_shapes.T
	elseif on_bot then
		expected_shape = shape_def.alt_shapes.B
	else
		expected_shape = shape_def.alt_shapes[""]
	end
	if expected_shape ~= nil then
		local expected_node = get_shape(recipeitem, expected_shape)
		if expected_node ~= nil and expected_node ~= node.name then
			minetest.swap_node(pos, {name = expected_node})
		end
	end
end

local function after_place_node(pos, placer, itemstack, pointed_thing)
	local node = minetest.get_node(pos)
	if is_pillar(node.name) then
		update_pillar(pos)
	end
	update_pillar(vector.offset(pos, 0,-1,0))
	update_pillar(vector.offset(pos, 0,1,0))
end

local function after_dig_node(pos, oldnode, oldmetadata, digger)
	update_pillar(vector.offset(pos, 0,-1,0))
	update_pillar(vector.offset(pos, 0,1,0))
end

pillars = {}

local groups_to_inherit = {"cracky", "crumbly", "snappy", "oddly_breakable_by_hand"}
local keys_to_inherit = {"sounds", "sunlight_propagates", "use_texture_alpha"}

function pillars.register_pillar(name, def)
	local recipeitem = assert(def.basenode)
	local basenode_def = minetest.registered_nodes[recipeitem]
	if basenode_def == nil then
		error(basenode_def.." not defined!")
	end
	if registered_pillars[def.basenode] ~= nil then
		error("Pillars from "..def.basenode.." are already defined!")
	end
	local is_base_allowed = ch_core.is_shape_allowed(recipeitem, "pillar", "")
	local is_half_allowed = ch_core.is_shape_allowed(recipeitem, "pillar", "_half")
	if not is_base_allowed and not is_half_allowed then
		return -- no allowed shapes of this material
	end
	for _, sd in ipairs(shapes) do
		local drop_suffix = assert(sd.drop_suffix)
		if (is_base_allowed and drop_suffix == "") or (is_half_allowed and drop_suffix == "_half") then
			local groups = {}
			local def = {
				description = (basenode_def.description or "neznámý materiál")..": "..(sd.description or "pilíř"),
				drawtype = "nodebox",
				paramtype = "light",
				paramtype2 = "facedir",
				is_ground_content = false,
				tiles = assert(basenode_def.tiles),
				groups = groups,
				node_box = {type = "fixed", fixed = assert(sd.box)},
				-- selection_box = ...,
				connect_sides = assert(sd.sides),
				after_dig_node = after_dig_node,
				after_place_node = after_place_node,
				_ch_pillar_recipeitem = recipeitem,
			}
			for _, key in ipairs(keys_to_inherit) do
				if basenode_def[key] ~= nil then
					def[key] = basenode_def[key]
				end
			end
			for _, group in ipairs(groups_to_inherit) do
				if basenode_def.groups[group] ~= nil then
					groups[group] = basenode_def.groups[group]
				end
			end
			for g, v in pairs(sd.groups_override) do
				groups[g] = v
			end
			if sd.drop_suffix ~= sd.suffix then
				def.drop = "pillars:"..name..sd.drop_suffix
			end

			local new_node_name = "pillars:"..name..sd.suffix
		    minetest.register_node(new_node_name, def)
		end
	end
	if is_base_allowed then
		minetest.register_craft({
			output = "pillars:" .. name .. " 7",
			recipe = {
				{recipeitem, recipeitem, recipeitem},
				  {"", recipeitem, ""},
				  {recipeitem, recipeitem, recipeitem},
			}
		})
		minetest.register_craft({output = recipeitem .. " 1", recipe = {{"pillars:" .. name}}})
		if is_half_allowed then
			minetest.register_craft({output = "pillars:"..name.."_half 2", recipe = {{"pillars:"..name, "pillars:"..name}, {"", ""}}})
			minetest.register_craft({output = "pillars:"..name, recipe = {{"pillars:"..name.."_half"}}})
		end
	elseif is_half_allowed then
		minetest.register_craft({
			output = "pillars:" .. name .. "_half 7",
			recipe = {
				{recipeitem, recipeitem, recipeitem},
				  {"", recipeitem, ""},
				  {recipeitem, recipeitem, recipeitem},
			}
		})
		minetest.register_craft({output = recipeitem .. " 1", recipe = {{"pillars:" .. name.."_half"}}})
	end
	registered_pillars[def.basenode] = name
	local shape_selector_nodes = {}
	for i = 1, 8 do
		local shape_def = group_to_shapedef[i]
		if shape_def ~= nil and minetest.registered_nodes["pillars:"..name..shape_def.suffix] ~= nil then
			shape_selector_nodes[i] = "pillars:"..name..shape_def.suffix
		end
	end
	ch_core.register_shape_selector_group({columns = 4, rows = 2, nodes = shape_selector_nodes, override_rightclick = true})
end

-- Create Pillar from nodes defined in default mod

local default_lib_nodes = {
    -- STONE:
	stone = {
		basenode = "default:stone",
		description = "pilíř ze skalního kamene",
	},
	stonebrick = {
		basenode = "default:stonebrick",
		description = "pilíř z kamenných cihel",
	},
	stone_brick = {
		basenode = "darkage:stone_brick",
		description = "pilíř z kamenných cihel 2",
	},
	desert_stone = {
		basenode = "default:desert_stone",
		description = "pilíř z pouštního skalního kamene",
	},
	desert_cobble = {
		basenode = "default:desert_cobble",
		description = "pilíř z pouštního dlažebního kamene",
	},
	desert_stonebrick = {
		basenode = "default:desert_stonebrick",
		description = "pilíř z cihel z pouštního kamene",
	},
	sandstone = {
		basenode = "default:sandstone",
		description = "pilíř ze žlutého pískovce",
	},
	sandstonebrick = {
		basenode = "default:sandstonebrick",
		description = "pilíř ze žlutých pískovcových cihel",
	},
	desert_sandstone = {
		basenode = "default:desert_sandstone",
		description = "pilíř z pouštního pískovce",
	},
	desert_sandstone_brick = {
		basenode = "default:desert_sandstone_brick",
		description = "pilíř z pouštních pískovcových cihel",
	},
	silver_sandstone = {
		basenode = "default:silver_sandstone",
		description = "pilíř z bílého pískovce",
	},
	silver_sandstone_brick = {
		basenode = "default:silver_sandstone_brick",
		description = "pilíř z bílých pískovcových cihel",
	},
	obsidian = {
		basenode = "default:obsidian",
		description = "pilíř z obsidiánu",
	},
		da_marble = {
		basenode = "darkage:marble",
		description = "pilíř z bílého mramoru",
	},
	jz_marble = {
		basenode = "ch_extras:marble",
		description = "pilíř z nehodivského mramoru",
	},
	tc_marble = {
		basenode = "technic:marble",
		description = "pilíř z podzemního mramoru",
	},

	basalt = {
		basenode = "darkage:basalt",
		description = "pilíř z čediče",
	},
	basalt_brick = {
		basenode = "darkage:basalt_brick",
		description = "pilíř z čedičových cihel",
	},
	basalt_cobble = {
		basenode = "darkage:basalt_cobble",
		description = "pilíř z čedičové dlažby",
	},
	serpentine = {
		basenode = "darkage:serpentine",
		description = "pilíř z hadce (serpentinitu)",
	},
	ors_brick = {
		basenode = "darkage:ors_brick",
		description = "pilíř z cihlovcových cihel",
	},
	concrete = {
		basenode = "basic_materials:concrete_block",
		description = "pilíř z betonu",
	},
	cement = {
		basenode = "basic_materials:cement_block",
		description = "pilíř z cementu",
	},

	-- WOOD:
	wood = {
		basenode = "default:wood",
		description = "pilíř z jabloňového dřeva",
		sounds = default.node_sound_wood_defaults(),
	},
	junglewood = {
		basenode = "default:junglewood",
		description = "pilíř z dřeva džunglovníku",
		sounds = default.node_sound_wood_defaults(),
	},
	pine_wood = {
		basenode = "default:pine_wood",
		description = "pilíř z borového dřeva",
		sounds = default.node_sound_wood_defaults(),
	},
	acacia_wood = {
		basenode = "default:acacia_wood",
		description = "pilíř z akáciového dřeva",
		sounds = default.node_sound_wood_defaults(),
	},
	aspen_wood = {
		basenode = "default:aspen_wood",
		description = "pilíř z osikového dřeva",
		sounds = default.node_sound_wood_defaults(),
	},
	date_palm = {
		basenode = "moretrees:date_palm_planks",
		description = "pilíř z datlovníkového dřeva",
		sounds = default.node_sound_wood_defaults(),
	},
	ebony = {
		basenode = "moretrees:ebony_planks",
		description = "pilíř z ebenového dřeva",
		sounds = default.node_sound_wood_defaults(),
	},
	spruce = {
		basenode = "moretrees:spruce_planks",
		description = "pilíř ze smrkového dřeva",
		sounds = default.node_sound_wood_defaults(),
	},
	plumtree = {
		basenode = "moretrees:plumtree_planks",
		description = "pilíř ze švestkového dřeva",
		sounds = default.node_sound_wood_defaults(),
	},
	poplar = {
		basenode = "moretrees:poplar_planks",
		description = "pilíř z topolového dřeva",
		sounds = default.node_sound_wood_defaults(),
	},

	-- METAL:
	copper = {
		basenode = "default:copperblock",
		description = "pilíř z mědi",
		sounds = default.node_sound_metal_defaults(),
	},
	copperpatina = {
		basenode = "moreblocks:copperpatina",
		description = "pilíř z mědi s patinou",
		sounds = default.node_sound_metal_defaults(),
	},
	iron = {
		basenode = "default:steelblock",
		description = "pilíř ze železa",
		sounds = default.node_sound_metal_defaults(),
	},
	cast_iron = {
		basenode = "technic:cast_iron_block",
		description = "pilíř z litého železa",
		sounds = default.node_sound_metal_defaults(),
	},
	gold = {
		basenode = "default:goldblock",
		description = "pilíř ze zlata",
		sounds = default.node_sound_metal_defaults(),
	},
	brass = {
		basenode = "basic_materials:brass_block",
		description = "pilíř z mosazi",
		sounds = default.node_sound_metal_defaults(),
	},
	bronze = {
		basenode = "default:bronzeblock",
		description = "pilíř z bronzu",
		sounds = default.node_sound_metal_defaults(),
	},
	bridger_white = {
		basenode = "bridger:block_white",
		description = "pilíř z bílého bloku",
	},
	bridger_steel = {
		basenode = "bridger:block_steel",
		description = "pilíř z černého bloku",
	},
	bridger_red = {
		basenode = "bridger:block_red",
		description = "pilíř z červeného bloku",
	},
	bridger_green = {
		basenode = "bridger:block_green",
		description = "pilíř ze zeleného bloku",
	},
	bridger_yellow = {
		basenode = "bridger:block_yellow",
		description = "pilíř ze žlutého bloku",
	},

	-- CLAY/PLASTER:
	bakedclay_black = {
		basenode = "bakedclay:black",
		description = "pilíř z černého páleného jílu",
	},
	plaster_white = {
		basenode = "ch_core:plaster_white",
		description = "pilíř s bílou omítkou",
	},
	plaster_red = {
		basenode = "ch_core:plaster_red",
		description = "pilíř s červenou omítkou",
	},
	plaster_blue = {
		basenode = "ch_core:plaster_blue",
		description = "pilíř s modrou omítkou",
	},
	plaster_medium_amber_s50 = {
		basenode = "ch_core:plaster_medium_amber_s50",
		description = "pilíř s okrovou omítkou",
	},
	plaster_orange = {
		basenode = "ch_core:plaster_orange",
		description = "pilíř s oranžovou omítkou",
	},
	plaster_pink = {
		basenode = "ch_core:plaster_pink",
		description = "pilíř s růžovou omítkou",
	},
	plaster_grey = {
		basenode = "ch_core:plaster_grey",
		description = "pilíř s šedou omítkou",
	},
	plaster_dark_grey = {
		basenode = "ch_core:plaster_dark_grey",
		description = "pilíř s tmavě šedou omítkou",
	},
	plaster_dark_green = {
		basenode = "ch_core:plaster_dark_green",
		description = "pilíř s tmavozelenou omítkou",
	},
	plaster_cyan = {
		basenode = "ch_core:plaster_cyan",
		description = "pilíř s tykrysovou omítkou",
	},
	plaster_green = {
		basenode = "ch_core:plaster_green",
		description = "pilíř se zelenou omítkou",
	},
	plaster_yellow = {
		basenode = "ch_core:plaster_yellow",
		description = "pilíř se žlutou omítkou",
	},
}

for k, v in pairs(default_lib_nodes) do
    -- texture_name = v[3] or v[1]

	local ndef = minetest.registered_nodes[v.basenode]

	if ndef then
		pillars.register_pillar(k, {
			--[[ description = v.description or "pilíř",
			textures = ndef.tiles, -- v.tiles or ndef.tiles,
			sounds = v.sounds or default.node_sound_stone_defaults(),
			groups = {snappy=2, cracky=3, oddly_breakable_by_hand=3}, ]]
			basenode = v.basenode,
		})
	else
		minetest.log("warning", v.basenode.." not found as a basenode for a pillar!")
	end
end

ch_base.close_mod(minetest.get_current_modname())

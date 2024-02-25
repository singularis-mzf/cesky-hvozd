-- Pillars by Citorva
-- This mode is licensed as MIT licence. This code can't be edited or copyed
-- outside the terms of this license.

print("[MOD BEGIN] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")
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

local function is_pillar(pos)
	return minetest.get_item_group(minetest.get_node(pos).name, "pillar") > 0
end

local function connected(pos, name, top)
    local v_dir = vector.new(0,-1,0)
    
    if top == true then
        v_dir = vector.new(0,1,0)
    end

    local aside = vector.add(pos, v_dir)
	if is_pillar(aside) then
		return true
	end

	return false
end

local function swap(pos, node, name)
	if node.name == name then
		return
	end

	minetest.set_node(pos, {name = name})
end

local function update_pillar(pos)
	if not is_pillar(pos) then
		return
	end
	local node = minetest.get_node(pos)
	local name = node.name
	
	if name:sub(-4) == "_top" or
	   name:sub(-4) == "_bot" or
	   name:sub(-4) == "_mid" then
		name = name:sub(1, -5)
	end

	local any = node.param2
	
	local on_top = connected(pos, name, true)
	local on_bot = connected(pos, name, false)
	
	if on_top and on_bot then
	    swap(pos, node, name .. "_mid", any)
	elseif on_top then
	    swap(pos, node, name .. "_bot", any)
	elseif on_bot then
	    swap(pos, node, name .. "_top", any)
	else
	    swap(pos, node, name, any)
	end
end

minetest.register_on_placenode(function(pos, node)
	if minetest.get_item_group(node, "pillar") then
		update_pillar(pos)
	end
	update_pillar(vector.add(pos, vector.new(0,-1,0)))
	update_pillar(vector.add(pos, vector.new(0,1,0)))
end)

minetest.register_on_dignode(function(pos)
	update_pillar(vector.add(pos, vector.new(0,-1,0)))
	update_pillar(vector.add(pos, vector.new(0,1,0)))
end)

pillars = {}

local function join_groups(a, b)
	local result = table.copy(a)
	for g, v in pairs(b) do
		result[g] = v
	end
	return result
end

function pillars.register_pillar(name, def)
	assert(def.basenode)
	local basenode_def = minetest.registered_nodes[def.basenode]
	if basenode_def == nil then
		error(basenode_def.." not defined!")
	end
    local groups = table.copy(def.groups)
	groups.pillar = 1
	
	local no_inv_groups = table.copy(groups)
	no_inv_groups.not_in_creative_inventory = 1

	local shapes_def = {
		{"", basic_shape, join_groups(def.groups, {pillar = 4})},
		{"_top", top_shape, join_groups(def.groups, {pillar = 3, not_in_creative_inventory = 1})},
		{"_bot", bottom_shape, join_groups(def.groups, {pillar = 1, not_in_creative_inventory = 1})},
		{"_mid", middle_shape, join_groups(def.groups, {pillar = 2, not_in_creative_inventory = 1})}}

	for k, v in pairs(shapes_def) do
        local sides = { "top", "bottom" }

        if v[1] == "_top" then
            sides = { "bottom" }
        elseif v[1] == "_bot" then
            sides = { "top" }
        elseif v[1] == "" then
            sides = {}
        end

	    minetest.register_node(":pillars:" .. name .. v[1], {
		    description = (basenode_def.description or "neznámý materiál")..": pilíř",
		    drawtype = "nodebox",
		    paramtype = "light",
			paramtype2 = "facedir",
		    is_ground_content = false,
		    sunlight_propagates = def.sunlight_propagates,
		    inventory_image = def.inventory_image,
		    wield_image = def.wield_image,
		    tiles = def.textures,
		    use_texture_alpha = def.use_texture_alpha or "opaque",
		    groups = v[3],
		    drop = "pillars:" .. name,
		    sounds = def.sounds,

		    node_box = {
			    type = "fixed",
			    fixed = v[2]
		    },
		    selection_box = {
			    type = "fixed",
			    fixed = v[2]
		    },
		    connect_sides = sides,
			on_punch = function(pos, node, puncher)
				local player_name = puncher and puncher:get_player_name()
				if player_name and puncher:get_player_control().aux1 then
					if minetest.is_protected(pos, player_name) then
						minetest.record_protection_violation(pos, player_name)
					else
						node.name = "pillars:"..name..(shapes_def[k + 1] or shapes_def[1])[1]
						minetest.swap_node(pos, node)
					end
				end
			end,
	    })
	end

	minetest.register_craft({
		output = "pillars:" .. name .. " 7",
		recipe = {{def.basenode, def.basenode, def.basenode},
			  {"",def.basenode,""},
			  {def.basenode, def.basenode, def.basenode}}
	})
	minetest.register_craft({
		output = def.basenode .. " 1",
		recipe = {{"pillars:" .. name}}
	})
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
		basenode = "jonez:marble",
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
		basenode = "ebony:wood",
		description = "pilíř z ebenového dřeva",
		sounds = default.node_sound_wood_defaults(),
	},
	spruce = {
		basenode = "moretrees:spruce_planks",
		description = "pilíř ze smrkového dřeva",
		sounds = default.node_sound_wood_defaults(),
	},
	plumtree = {
		basenode = "plumtree:wood",
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

	-- PLASTER:
	plaster_white = {
		basenode = "solidcolor:plaster_white",
		description = "pilíř s bílou omítkou",
	},
	plaster_red = {
		basenode = "solidcolor:plaster_red",
		description = "pilíř s červenou omítkou",
	},
	plaster_blue = {
		basenode = "solidcolor:plaster_blue",
		description = "pilíř s modrou omítkou",
	},
	plaster_medium_amber_s50 = {
		basenode = "solidcolor:plaster_medium_amber_s50",
		description = "pilíř s okrovou omítkou",
	},
	plaster_orange = {
		basenode = "solidcolor:plaster_orange",
		description = "pilíř s oranžovou omítkou",
	},
	plaster_pink = {
		basenode = "solidcolor:plaster_pink",
		description = "pilíř s růžovou omítkou",
	},
	plaster_grey = {
		basenode = "solidcolor:plaster_grey",
		description = "pilíř s šedou omítkou",
	},
	plaster_dark_grey = {
		basenode = "solidcolor:plaster_dark_grey",
		description = "pilíř s tmavě šedou omítkou",
	},
	plaster_dark_green = {
		basenode = "solidcolor:plaster_dark_green",
		description = "pilíř s tmavozelenou omítkou",
	},
	plaster_cyan = {
		basenode = "solidcolor:plaster_cyan",
		description = "pilíř s tykrysovou omítkou",
	},
	plaster_green = {
		basenode = "solidcolor:plaster_green",
		description = "pilíř se zelenou omítkou",
	},
	plaster_yellow = {
		basenode = "solidcolor:plaster_yellow",
		description = "pilíř se žlutou omítkou",
	},
}

for k, v in pairs(default_lib_nodes) do
    -- texture_name = v[3] or v[1]

	local ndef = minetest.registered_nodes[v.basenode]

	if ndef then
		pillars.register_pillar(k, {
			description = v.description or "pilíř",
			textures = ndef.tiles, -- v.tiles or ndef.tiles,
			sounds = v.sounds or default.node_sound_stone_defaults(),
			groups = {snappy=2, cracky=3, oddly_breakable_by_hand=3},
			basenode = v.basenode,
		})
	else
		minetest.log("warning", v.basenode.." not found as a basenode for a pillar!")
	end
end

print("[MOD END] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")

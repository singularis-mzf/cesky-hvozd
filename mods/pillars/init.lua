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

function pillars.register_pillar(name, def)
    local groups = table.copy(def.groups)
	groups.pillar = 1
	
	local no_inv_groups = table.copy(groups)
	no_inv_groups.not_in_creative_inventory = 1
    
	for k, v in pairs({{"", basic_shape, groups},
	                   {"_top", top_shape, no_inv_groups},
	                   {"_bot", bottom_shape, no_inv_groups},
	                   {"_mid", middle_shape, no_inv_groups}}) do
        local sides = { "top", "bottom" }
	    
        if v[1] == "_top" then
            sides = { "bottom" }
        elseif v[1] == "_bot" then
            sides = { "top" }
        elseif v[1] == "" then
            sides = {}
        end
	
	    minetest.register_node(":pillars:" .. name .. v[1], {
		    description = def.description,
		    drawtype = "nodebox",
		    paramtype = "light",
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
		    connect_sides = sides
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
    -- Define all pillars from stone
    
    {"stone", "Pil???? ze skaln??ho kamene"},
    {"cobble", "Pil???? z dla??ebn??ho kamene"},
    {"stonebrick", "Pil???? z kamenn??ch cihel", "stone_brick"},
    {"stone_block", "Pil???? z kamenn??ch blok??"},
    {"mossycobble", "Pil???? z dla??ebn??ho kamene porostl??ho mechem"},
    
    {"desert_stone", "Pil???? z pou??tn??ho skaln??ho kamene"},
    {"desert_cobble", "Pil???? z pou??tn??ho dla??ebn??ho kamene"},
    {"desert_stonebrick", "Pil???? z cihel z pou??tn??ho kamene", "desert_stone_brick"},
    {"desert_stone_block", "Pil???? z blok?? pou??tn??ho kamene"},
    
    {"sandstone", "Pil???? ze ??lut??ho p??skovce"},
    {"sandstonebrick", "Pil???? ze ??lut??ch p??skovcov??ch cihel", "sandstone_brick"},
    {"sandstone_block", "Pil???? ze ??lut??ch p??skovcov??ch blok??"},
    
    {"desert_sandstone", "Pil???? z pou??tn??ho p??skovce"},
    {"desert_sandstone_brick", "Pil???? z pou??tn??ch p??skovcov??ch cihel"},
    {"desert_sandstone_block", "Pil???? z pou??tn??ch p??skovcov??ch blok??"},
    
    {"silver_sandstone", "Pil???? z b??l??ho p??skovce"},
    {"silver_sandstone_brick", "Pil???? z b??l??ch p??skovcov??ch cihel"},
    {"silver_sandstone_block", "Pil???? z b??l??ch p??skovcov??ch blok??"},
    
    {"obsidian", "Pil???? z obsidi??nu"},
    {"obsidianbrick", "Pil???? z obsidi??nov??ch cihel", "obsidian_brick"},
    {"obsidian_block", "Pil???? z obsidi??nov??ch blok??"},
    
    -- Define all pillar from wood planks
    {"wood", "Pil???? z jablo??ov??ho d??eva", sound = default.node_sound_wood_defaults()},
    {"junglewood", "Pil???? z d??eva d??unglovn??ku", sound = default.node_sound_wood_defaults()},
    {"pine_wood", "Pil???? z borov??ho d??eva", sound = default.node_sound_wood_defaults()},
    {"acacia_wood", "Pil???? z ak??ciov??ho d??eva", sound = default.node_sound_wood_defaults()},
    {"aspen_wood", "Pil???? z osikov??ho d??eva", sound = default.node_sound_wood_defaults()},
}

for k, v in pairs(default_lib_nodes) do
    texture_name = v[1]
    sound = default.node_sound_stone_defaults()
    
    if v[3] then
        texture_name = v[3]
    end
    
    if v.sound then
        sound = v.sound
    end
    
    pillars.register_pillar(v[1], {
	    description = v[2],
	    textures = {"default_" .. texture_name .. ".png"},
	    sounds = sound,
	    groups = {snappy=2, cracky=3, oddly_breakable_by_hand=3},
	    basenode = "default:" .. v[1]
    })
end

print("[MOD END] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")

-- barvitelná tyč
------------------
local ifthenelse = assert(ch_core.ifthenelse)
local pole_texture = ifthenelse(minetest.get_modpath("solidcolor"), "solidcolor_clay.png", "default_clay.png")
local pole_sounds = default.node_sound_metal_defaults()

local def = {
    description = "barvitelná tyč (spojující se)",
    drawtype = "nodebox",
    tiles = {
        {name = pole_texture, backface_culling = true, align_style = "world"},
    },
    node_box = {
        type = "connected",
        fixed = {-0.125, -0.125, -0.125, 0.125, 0.125, 0.125},
        connect_top = {-0.125, 0.125, -0.125, 0.125, 0.5, 0.125}, -- +Y
        connect_bottom = {-0.125, -0.5, -0.125, 0.125, -0.125, 0.125}, -- -Y
        connect_front = {-0.125, -0.125, -0.5, 0.125, 0.125, -0.125}, -- -Z
        connect_left = {-0.5, -0.125, -0.125, -0.125, 0.125, 0.125}, -- -X
        connect_back = {-0.125, -0.125, 0.125, 0.125, 0.125, 0.5}, -- +Z
        connect_right = {0.125, -0.125, -0.125, 0.5, 0.125, 0.125}, -- +X
    },
    connect_sides = {"left", "right", "top", "bottom", "front", "back"},
    connects_to = {"group:panel_pole", "group:full_cube_node", "group:attracts_poles"}, -- no fence, no wall
    is_ground_content = false,
    sunlight_propagates = true,
    paramtype = "light",
    paramtype2 = "color",
    palette = "unifieddyes_palette_extended.png",
    on_construct = unifieddyes.on_construct,
    on_dig = unifieddyes.on_dig,

    groups = {panel_pole = 1, oddly_breakable_by_hand = 1, cracky = 1, choppy = 1, ud_param2_colorable = 1, not_blocking_trains = 1},
    sounds = pole_sounds,
    check_for_pole = true,
}

minetest.register_node("ch_extras:colorable_pole", def)

def = {
    description = "barvitelná tyč (přímá)",
    drawtype = "nodebox",
    tiles = {{name = pole_texture, backface_culling = true, align_style = "world"}},
    is_ground_content = false,
    sunlight_propagates = true,
    paramtype = "light",
    paramtype2 = "color",
    palette = "unifieddyes_palette_extended.png",
    on_construct = unifieddyes.on_construct,
    -- on_dig = unifieddyes.on_dig,
    drop = {items = {{items = {"ch_extras:colorable_pole_flat"}, inherit_color = true}}},

    groups = {panel_pole = 1, cracky = 1, choppy = 1, ud_param2_colorable = 1, not_blocking_trains = 1, not_in_creative_inventory = 1},
    sounds = pole_sounds,
    check_for_pole = true,
}

ch_core.register_nodes(def, {
    ["ch_extras:colorable_pole_flat"] = { -- Y
        node_box = {
            type = "fixed",
            fixed = {-0.125, -0.5, -0.125, 0.125, 0.5, 0.125},
        },
        groups = ch_core.assembly_groups(def.groups, {not_in_creative_inventory = 0}),
    },
    ["ch_extras:colorable_pole_flat_2"] = { -- X
        node_box = {
            type = "fixed",
            fixed = {-0.5, -0.125, -0.125, 0.5, 0.125, 0.125},
        },
    },
    ["ch_extras:colorable_pole_flat_3"] = { -- Z
        node_box = {
            type = "fixed",
            fixed = {-0.125, -0.125, -0.5, 0.125, 0.125, 0.5},
        },
    },
}, {
    {
        output = "ch_extras:colorable_pole_flat",
        recipe = {{"ch_extras:colorable_pole"}},
    }, {
        output = "ch_extras:colorable_pole",
        recipe = {{"ch_extras:colorable_pole_flat"}},
    }
})

local nodedir_group = {}
local name1, name2, name3 = "ch_extras:colorable_pole_flat", "ch_extras:colorable_pole_flat_2", "ch_extras:colorable_pole_flat_3"
for i = 0, 23 do
    nodedir_group[i] = name1
end
for i = 12, 19 do
    nodedir_group[i] = name2
end
for i = 4, 11 do
    nodedir_group[i] = name3
end

ch_core.register_nodedir_group(nodedir_group)

minetest.register_craft({
    output = "ch_extras:colorable_pole 6",
    recipe = {
        {"dye:red", "dye:green", "dye:blue"},
        {"group:panel_pole", "group:panel_pole", "group:panel_pole"},
        {"group:panel_pole", "group:panel_pole", "group:panel_pole"},
    },
})

--[[
minetest.register_lbm({
    label = "Convert old colorable poles",
    name = "ch_extras:colorable_poles_update",
    nodenames = {"ch_extras:colorable_pole_flat"},
    -- run_at_every_load = true, -- TODO: remove
    action = function(pos, node, dtime_s)
        local color = unifieddyes.color_to_name(node.param2, {_ch_ud_palette = "unifieddyes_palette_colorwallmounted.png"})
        if color ~= nil then
            local new_param2, second_result = unifieddyes.getpaletteidx("dye:"..color, "extended")
            if new_param2 ~= nil and new_param2 ~= node.param2 then
                minetest.log("action", "Will update colorable pole at "..minetest.pos_to_string(pos)..": "..node.param2.." => "..new_param2.." (color="..color..")")
                node.param2 = new_param2
                minetest.swap_node(pos, node)
                return
            end
        end
    end,
})
]]
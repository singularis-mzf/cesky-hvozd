-- si_frames/init.lua
-- Add a wooden frame over windows
-- Copyright (C) 2018-2019  Hans von Smacker
-- Copyright (C) 2024  1F616EMO
-- SPDX-License-Identifier: AGPL-3.0-or-later

local S = minetest.get_translator("si_frames")
local NS = function(s) return s end
local nodes = minetest.registered_nodes

---@class si_frames
si_frames = {}

local type_of_frames = {
    wfs = {
        name = NS("Simple Wooden Frame (@1)"),
        model = "si_frame_simple.obj",
        craft = function(materieal)
            return {
                { "group:stick", "group:stick", "group:stick" },
                { "group:stick", materieal,     "group:stick" },
                { "group:stick", "group:stick", "group:stick" }
            }
        end,
    },
    wfq = {
        name = NS("Quartered Window Frame (@1)"),
        model = "si_frame_quartered.obj",
        craft = function(materieal)
            return {
                { "",              "default:stick", "" },
                { "default:stick", materieal,       "default:stick" },
                { "",              "default:stick", "" }
            }
        end,
    },
    wfqd = {
        name = NS("Quartered (Diagonal) Window Frame (@1)"),
        model = "si_frame_quartered_diagonal.obj",
        craft = function(materieal)
            return {
                { "group:stick", "",        "group:stick" },
                { "",            materieal, "" },
                { "group:stick", "",        "group:stick" }
            }
        end,
    },
    wfr = {
        name = NS("Rhombus Window Frame (@1)"),
        model = "si_frame_rhombus2.obj",
        craft = function(materieal)
            return {
                { "",            "group:stick", "group:stick" },
                { "",            materieal,     "" },
                { "group:stick", "group:stick", "" }
            }
        end,
    },
}

local node_box = {
    type = "fixed",
    fixed = {
        { -0.4, -0.45, 0.4, 0.4, 0.4, 0.5 }
    },
}

local keep_groups = {
    -- General groups
    "not_in_creative_inventory",

    -- Minetest Game dig groups
    "crumby", "cracky", "snappy", "choppy", "fleshy", "explody", "oddly_breakable_by_hand", "dig_immediate",

    -- MineClone2 dig groups
    "pickaxey", "axey", "shovely", "swordly", "shearsy", "handy", "creative_breakable",

    -- MineClone2 interaction groups
    "flammable", "fire_encouragement", "fire_flammability",
}
local function prepare_groups(groups)
    if not groups then return {} end

    local rtn = {}
    for _, key in ipairs(keep_groups) do
        rtn[key] = groups[key]
    end
    return rtn
end

---Register all type of frames for a node
function si_frames.register_frames(name, def)
    if not def then def = {} end

    def.tiles = { def.texture }
    def.drawtype = "mesh"
    def.paramtype = "light"
    def.paramtype2 = "facedir"
    def.is_ground_content = false
    def.sunlight_propagates = true
    def.walkable = false
    def.selection_box = node_box
    def.collisionbox = node_box

    for variant, variant_def in pairs(type_of_frames) do
        local vdef = table.copy(def)
        vdef.description = S(variant_def.name, def.description or name)
        vdef.mesh = variant_def.model
        -- FIXME: Hand display texture is still broken
        vdef.inventory_image = "(si_frames_of.png^" .. def.texture .. ")^[mask:si_frames_" .. variant .. ".png"
        vdef.wield_image = def.texture .. "^si_frames_" .. variant .. ".png"
        minetest.register_node("si_frames:" .. variant .. "_" .. name, vdef)

        minetest.register_craft({
            output = "si_frames:" .. variant .. "_" .. name,
            recipe = variant_def.craft(def.materieal)
        })
    end
end

local function prepare_def(node, rotate)
    return {
        description = nodes[node].description,
        texture = nodes[node].tiles[1] .. (rotate and "^[transform1" or ""),
        groups = prepare_groups(nodes[node].groups),
        sounds = nodes[node].sounds,
        materieal = node,
    }
end

if minetest.get_modpath("default") then
    si_frames.register_frames("wood", prepare_def("default:wood"))
    si_frames.register_frames("junglewood", prepare_def("default:junglewood"))
    si_frames.register_frames("pine_wood", prepare_def("default:pine_wood"))
    si_frames.register_frames("acacia_wood", prepare_def("default:acacia_wood"))
    si_frames.register_frames("aspen_wood", prepare_def("default:aspen_wood"))
end

if minetest.get_modpath("maple") then
    si_frames.register_frames("maple_wood", prepare_def("maple:maple_wood"))
end

if minetest.get_modpath("ethereal") then
    si_frames.register_frames("basandra_wood", prepare_def("ethereal:basandra_wood"))
    si_frames.register_frames("sakura_wood", prepare_def("ethereal:sakura_wood", true))
    si_frames.register_frames("willow_wood", prepare_def("ethereal:willow_wood"))
    si_frames.register_frames("redwood_wood", prepare_def("ethereal:redwood_wood"))
    si_frames.register_frames("frost_wood", prepare_def("ethereal:frost_wood"))
    si_frames.register_frames("yellow_wood", prepare_def("ethereal:yellow_wood"))
    si_frames.register_frames("palm_wood", prepare_def("ethereal:palm_wood"))
    si_frames.register_frames("banana_wood", prepare_def("ethereal:banana_wood"))
    si_frames.register_frames("birch_wood", prepare_def("ethereal:birch_wood"))
    si_frames.register_frames("olive_wood", prepare_def("ethereal:olive_wood"))
    si_frames.register_frames("bamboo_block", prepare_def("ethereal:bamboo_block", true))
end

if minetest.get_modpath("mcl_core") then
    si_frames.register_frames("wood", prepare_def("mcl_core:wood"))
    si_frames.register_frames("darkwood", prepare_def("mcl_core:darkwood"))
    si_frames.register_frames("junglewood", prepare_def("mcl_core:junglewood"))
    si_frames.register_frames("sprucewood", prepare_def("mcl_core:sprucewood"))
    si_frames.register_frames("acaciawood", prepare_def("mcl_core:acaciawood"))
    si_frames.register_frames("birchwood", prepare_def("mcl_core:birchwood"))
end

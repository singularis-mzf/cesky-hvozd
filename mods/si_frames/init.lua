ch_base.open_mod(core.get_current_modname())
-- si_frames/init.lua
-- Add a wooden frame over windows
-- Copyright (C) 2018-2019  Hans von Smacker
-- Copyright (C) 2024  1F616EMO
-- Copyright (C) 2024 Singularis
-- SPDX-License-Identifier: AGPL-3.0-or-later

local S = core.get_translator("si_frames")
local NS = function(s) return s end
local nodes = core.registered_nodes

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

function si_frames.register_frames(name, def)
    error("This API not supported on Cesky hvozd")
end

---Register all type of frames for a node
function si_frames.register_frames2(nodename)
    local ndef = nodes[nodename]
    if ndef == nil then
        core.log("warning", "si_frames.register_frames2() called on unknown node '"..nodename.."'!")
        return
    end
    local modname, name = nodename:match("^(.*):(.*)$")
    local def = {
        description = ndef.description,
        groups = prepare_groups(ndef.groups),
        sounds = ndef.sounds,
    }
    local texture = ndef.tiles[1] .. (rotate and "^[transform1" or "")

    def.tiles = { texture }
    def.drawtype = "mesh"
    def.paramtype = "light"
    def.paramtype2 = "facedir"
    def.is_ground_content = false
    def.sunlight_propagates = true
    def.walkable = false
    def.selection_box = node_box
    def.collisionbox = node_box

    for variant, variant_def in pairs(type_of_frames) do
        print("DEBUG: variant "..variant.." of "..nodename)
        if ch_core.is_shape_allowed(nodename, "si_frames", variant) then
            local vdef = table.copy(def)
            vdef.description = S(variant_def.name, def.description or name)
            vdef.mesh = variant_def.model
            -- FIXME: Hand display texture is still broken
            vdef.inventory_image = "(si_frames_of.png^" .. texture .. ")^[mask:si_frames_" .. variant .. ".png"
            vdef.wield_image = texture .. "^si_frames_" .. variant .. ".png"
            core.register_node("si_frames:" .. variant .. "_" .. name, vdef)

            core.register_craft({
                output = "si_frames:" .. variant .. "_" .. name,
                recipe = variant_def.craft(nodename)
            })
        else
            print("DEBUG: not registering ".."si_frames:" .. variant .. "_" .. name.." because is_shape_allowed is false.")
        end
    end
end

for _, nodename in ipairs(ch_core.get_materials_from_shapes_db("si_frames")) do
    si_frames.register_frames2(nodename)
end
ch_base.close_mod(minetest.get_current_modname())

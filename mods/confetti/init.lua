--[[

The MIT License (MIT)
Copyright (C) 2024 Flay Krunegan

Permission is hereby granted, free of charge, to any person obtaining a copy of this
software and associated documentation files (the "Software"), to deal in the Software
without restriction, including without limitation the rights to use, copy, modify, merge,
publish, distribute, sublicense, and/or sell copies of the Software, and to permit
persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or
substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.

]]

local modname = minetest.get_current_modname()

print("[MOD BEGIN] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")

local modpath = minetest.get_modpath(modname)

confetti = {}
confetti.particle_amount = tonumber(minetest.settings:get(modname .. ".particle_amount")) or 110
confetti.cooldown = tonumber(minetest.settings:get(modname .. ".cooldown_delay")) or 0.3
local recipe_output_amount = 8

local tex_base = "ch_core_white_pixel.png^[resize:8x8"
local item_base = "confetti_item.png"

local confetti_colors = {
    red = {
        description = "červené konfety",
        color = "#990000",
    },
    blue = {
        description = "modré konfety",
        color = "#1867ce",
    },
    green = {
        description = "zelené konfety",
        color = "#008200",
    },
    white = {
        description = "bílé konfety",
        color = "#dddddd",
    },
    grey = {
        description = "šedé konfety",
        color = "#a0a0a0",
    },
    yellow = {
        description = "žluté konfety",
        color = "#9e9e00",
    },
    black = {
        description = "černé konfety",
        color = "#000000",
    },
    violet = {
        description = "fialové konfety",
        color = "#812396",
    },
    pink = {
        description = "růžové konfety",
        color = "#ff5dc2",
    },
    orange = {
        description = "oranžové konfety",
        color = "#c16700",
    },
    cyan = {
        description = "tyrkysové konfety",
        color = "#60c4c2",
    },
    brown = {
        description = "hnědé konfety",
        color = "#823528",
    },
}

-- texpool preprocessing:
local rainbow_texpool = {}
for color, cdef in pairs(confetti_colors) do
    local texpool = cdef.texpool
    if texpool == nil then
        texpool = {tex_base.."^[multiply:"..assert(cdef.color)}
        cdef.texpool = texpool
    end
    if color ~= "black" then
        table.insert(rainbow_texpool, cdef.texpool[1])
    end
end

confetti_colors.rainbow = {
    description = "různobarevné konfety",
    inventory_image = "confetti_rainbow.png",
    texpool = rainbow_texpool,
    recipe = {
        { "",              "dye:blue",      "dye:green" },
        { "",              "default:stick", "dye:red" },
        { "default:stick", "",              "" },
    },
}

-- get actual eye_pos of the player (including eye_offset)
local function player_get_rel_eye_pos(player)
    local p_pos = vector.zero()
    local p_eye_height = player:get_properties().eye_height
    p_pos.y = p_pos.y + p_eye_height
    local p_eye_pos = p_pos
    local p_eye_offset = vector.multiply(player:get_eye_offset(), 0.1)
    local yaw = player:get_look_horizontal()
    p_eye_pos = vector.add(p_eye_pos, vector.rotate_around_axis(p_eye_offset, { x = 0, y = 1, z = 0 }, yaw))
    return p_eye_pos
end

local function create_confetti(itemstack, user, _pointed_thing, texpool)
    if not user or not user:is_player() then
        return
    end
    local rel_eye_pos = player_get_rel_eye_pos(user)
    local pos = vector.add(user:get_pos(), rel_eye_pos)

    local dir = user:get_look_dir()
    local particle_amount = confetti.particle_amount
    local particle_size = 1.0
    local jitter = 10

    local origin = vector.add(vector.multiply(dir, 0.5), vector.subtract(rel_eye_pos, vector.new(0, 1, 0)))
    local sound_pos = vector.add(origin, pos)

    local def = {
        amount = particle_amount,
        time = 0.01,
        pos = vector.add(pos, vector.multiply(dir, 1.0)),
        radius = { min = 0.0, max = 0.3, bias = -10 },
        drag_tween = { vector.new(1.5, 0, 1.5), 0.1 },
        jitter_tween = {
            style = "pulse",
            reps = 3,
            { min = vector.new(0, 0, 0),             max = vector.new(0, 0, 0), },
            { min = vector.new(-jitter, -jitter*0.2, -jitter), max = vector.new(jitter, jitter*0.4, jitter), }
        },
        attract = {
            kind = "point",
            strength = -5.5,
            origin = origin,
        },
        acc = { x = 0, y = -4, z = 0 },
        exptime = 10,
        size = particle_size,
        collisiondetection = true,
        collision_removal = true,
        texpool = texpool,
    }

    if type(user) == "userdata" then
        -- can attach only to entities/players
        def.attract.origin_attached = user
        def.attract.direction_attached = user
    else
        -- this is probably a nodebreaker?
        def.attract.origin = vector.add(vector.multiply(dir, 0.5), pos)
        sound_pos = vector.add(vector.multiply(dir, 0.5), pos)
    end

    minetest.add_particlespawner(def)

    -- sound_name = "mesecons_button_pop"
    minetest.sound_play("default_grass_footstep", {
        pos = sound_pos,
        max_hear_distance = 40,
        gain = 1.0,
        pitch = 6.0,
    })

    if not minetest.is_creative_enabled(user:get_player_name()) then
        itemstack:take_item(1)
    end
    return itemstack
end

for color, cdef in pairs(confetti_colors) do
    local texpool = assert(cdef.texpool)
    minetest.register_craftitem("confetti:" .. color, {
        description = assert(cdef.description),
        inventory_image = cdef.inventory_image or (item_base.."^[multiply:"..assert(cdef.color)),
        on_use = function(itemstack, user, pointed_thing)
            if user and type(user) == "userdata" and user:is_player() then
                local player_name = user:get_player_name()
                local online_charinfo = ch_core.online_charinfo[player_name]
                if online_charinfo ~= nil then
                    local current_time = minetest.get_us_time()/1000000
                    local last_time = online_charinfo.last_confetti_use
                    if last_time and current_time - last_time < confetti.cooldown then
                        --minetest.chat_send_player(player_name, ("Don't spam, wait %fs."):format(confetti.cooldown - (current_time - last_time)))
                        return
                    end
                    online_charinfo.last_confetti_use = current_time
                end
            end

            return create_confetti(itemstack, user, pointed_thing, texpool)
        end,
    })
    minetest.register_craft({
        output = "confetti:" .. color.." "..recipe_output_amount,
        recipe = cdef.recipe or {
            { "",              "dye:" .. color, "dye:" .. color },
            { "",              "default:stick", "dye:" .. color },
            { "default:stick", "",              "" },
        }
    })
end

print("[MOD END] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")

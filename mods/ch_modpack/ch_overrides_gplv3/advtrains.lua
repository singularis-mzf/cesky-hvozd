-- Mod ch_overrides_gplv3
-- Copyright (C) 2025 Singularis
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.

if not core.get_modpath("advtrains") then
    return
end
ch_core.register_event_type("player_overrun", {
    description = "srážka s vlakem",
    access = "players",
    color = "#ff3333",
    chat_access = "public",
})
    
local repeat_protection = {}
local has_penalty = core.settings:get_bool("ch_player_overrun_penalty", false)
    
local function player_overrun_step(player_name)
    local online_charinfo = ch_data.online_charinfo[player_name]
    local player = core.get_player_by_name(player_name)
    if player ~= nil and online_charinfo ~= nil and online_charinfo.player_overrun_hud ~= nil then
        if player:get_hp() >= 10 then
            -- remove penalty
            player:hud_remove(online_charinfo.player_overrun_hud)
            online_charinfo.player_overrun_hud = nil
        else
            core.after(1, player_overrun_step, player_name)
        end
    end
end
    
local function on_player_overrun(player, train_id, train_direction, train_velocity)
    local player_name = player:get_player_name()
    local now = core.get_us_time()
    local protection = repeat_protection[player_name]
    if protection ~= nil and now < protection then
        return
    end
    ch_core.add_event("player_overrun", "{PLAYER} byl/a sražen/a vlakem č. "..train_id.." jedoucím "..math.ceil(train_velocity).." m/s!", player_name)
    core.sound_play("player_damage", {pos = player:get_pos(), max_hear_distance = 50}, true)
    repeat_protection[player_name] = now + 1000000
    if has_penalty then
        player:set_hp(1)
        local online_charinfo = ch_data.online_charinfo[player_name] or {}
        online_charinfo.player_overrun_hud = player:hud_add({
            type = "image",
            name = "player_overrun_hud",
            alignment = {x = 1, y = 1},
            z_index = -390,
            scale = {x = -100, y = -100},
            text = "ch_core_white_pixel.png^[multiply:#ff0000^[opacity:50",
        })
        core.after(1, player_overrun_step, player_name)
        -- TODO...
    end
    --[[
    print("DEBUG: Postava "..player_name.." byla sražena vlakem "..train_id.." na pozici "..
        core.pos_to_string(player:get_pos()).." při rychlosti "..train_velocity.." směrem jízdy "..
        core.pos_to_string(train_direction)..".")
        ]]
end

advtrains.register_on_player_overrun(on_player_overrun)

local function on_change(pos, old_node, new_node, player, nodespec)
    local old_is_track = core.get_item_group(old_node.name, "save_in_at_nodedb") ~= 0
    local new_is_track = core.get_item_group(new_node.name, "save_in_at_nodedb") ~= 0
    if not (old_is_track and new_is_track) then
        core.log("error", "advtrains on_change() called for change ("..old_node.name.."/"..tostring(old_node.param2)..") => ("..
            new_node.name.."/"..tostring(new_node.param2).."); is_track = ("..tostring(old_is_track)..", "..tostring(new_is_track)..")!")
        return false
    end
    local player_name = player and player:get_player_name()
    if
        player_name and
        advtrains.check_track_protection(pos, player_name)
    then
        local can_modify, reason = advtrains.can_dig_or_modify_track(pos)
        if can_modify then
            advtrains.ndb.swap_node(pos, new_node)
            core.log("action", player_name.." used shape selector to change "..old_node.name.."/"..
                old_node.param2.." to "..new_node.name.."/"..new_node.param2.." at "..core.pos_to_string(pos))
            return true
        else
            core.chat_send_player(player_name, "Změna selhala: "..tostring(reason))
            core.log("action", player_name.." failed to use shape selector to change "..old_node.name.."/"..
                old_node.param2.." to "..new_node.name.."/"..new_node.param2.." at "..core.pos_to_string(pos))
            return false
        end
    else
        if player_name == nil then
            player_name = "???"
        else
            core.chat_send_player(player_name, "Nemůžete změnit tento blok.")
        end
        core.log("action", player_name.." failed to use shape selector to change "..old_node.name.."/"..
            old_node.param2.." to "..new_node.name.."/"..new_node.param2.." at "..core.pos_to_string(pos))
        return
    end
end

if core.get_modpath("advtrains_interlocking") then
    for _, v in ipairs({"on", "off"}) do
        ch_core.register_shape_selector_group({
            columns = 3,
            nodes = {
                "advtrains:signal_wall_l_"..v,
                "advtrains:signal_wall_t_"..v,
                "advtrains:signal_wall_r_"..v,
                "advtrains:signal_wall_b_"..v,
                {name = "advtrains:signal_wall_p_"..v, label = ">tyč"},
            },
            on_change = on_change,
        })
    end
end

if core.get_modpath("advtrains_signals_ks") then
    for _, rot in ipairs({"0", "30", "45", "60"}) do
        ch_core.register_shape_selector_group({
            columns = 6,
            nodes = {
                {name = "advtrains_signals_ks:sign_4_"..rot, label = "4"},
                {name = "advtrains_signals_ks:sign_6_"..rot, label = "6"},
                {name = "advtrains_signals_ks:sign_8_"..rot, label = "8"},
                {name = "advtrains_signals_ks:sign_12_"..rot, label = "12"},
                {name = "advtrains_signals_ks:sign_16_"..rot, label = "16"},
                {name = "advtrains_signals_ks:sign_e_"..rot, label = "max"},

                {name = "advtrains_signals_ks:sign_lf7_4_"..rot, label = "4"},
                {name = "advtrains_signals_ks:sign_lf7_6_"..rot, label = "6"},
                {name = "advtrains_signals_ks:sign_lf7_8_"..rot, label = "8"},
                {name = "advtrains_signals_ks:sign_lf7_12_"..rot, label = "12"},
                {name = "advtrains_signals_ks:sign_lf7_16_"..rot, label = "16"},
                {name = "advtrains_signals_ks:sign_lf7_e_"..rot, label = "max"},

                {name = "advtrains_signals_ks:sign_lf_4_"..rot, label = "4"},
                {name = "advtrains_signals_ks:sign_lf_6_"..rot, label = "6"},
                {name = "advtrains_signals_ks:sign_lf_8_"..rot, label = "8"},
                {name = "advtrains_signals_ks:sign_lf_12_"..rot, label = "12"},
                {name = "advtrains_signals_ks:sign_lf_16_"..rot, label = "16"},
                {name = "advtrains_signals_ks:sign_lf_e_"..rot, label = "max"},

                "advtrains_signals_ks:sign_hfs_"..rot,
                "advtrains_signals_ks:sign_pam_"..rot,
                {},
                {},
                {},
                {},

                "advtrains_signals_ks:sign_ne4_"..rot,
                "advtrains_signals_ks:sign_ne3x1_"..rot,
                "advtrains_signals_ks:sign_ne3x2_"..rot,
                "advtrains_signals_ks:sign_ne3x3_"..rot,
                "advtrains_signals_ks:sign_ne3x4_"..rot,
                "advtrains_signals_ks:sign_ne3x5_"..rot,
            },
            on_change = on_change,
        })
        ch_core.register_shape_selector_group({
            columns = 8,
            nodes = {
                {name = "advtrains_signals_ks:mast_mast_"..rot, param2 = 0x0300},
                {name = "advtrains_signals_ks:mast_mast_"..rot, param2 = 0x0320},
                {name = "advtrains_signals_ks:mast_mast_"..rot, param2 = 0x0340},
                {name = "advtrains_signals_ks:mast_mast_"..rot, param2 = 0x0360},
                {name = "advtrains_signals_ks:mast_mast_"..rot, param2 = 0x0380},
                {name = "advtrains_signals_ks:mast_mast_"..rot, param2 = 0x03a0},
                {name = "advtrains_signals_ks:mast_mast_"..rot, param2 = 0x03c0},
                {name = "advtrains_signals_ks:mast_mast_"..rot, param2 = 0x03e0},
            },
            -- on_change = on_change, -- not for node-db!
        })
    end
end

if
    core.get_modpath("unifieddyes") and
    core.registered_nodes["advtrains_line_automation:jrad"] and
    core.registered_nodes["advtrains_line_automation:jrad_on_pole"]
then
    local groups = core.registered_nodes["advtrains_line_automation:jrad"].groups or {}
    groups.ud_param2_colorable = 1
    local override = {
        tiles = {
            {name = "ch_core_white_pixel.png^[multiply:#cccccc"},
            {name = "ch_core_white_pixel.png^[multiply:#cccccc"},
            {name = "ch_core_white_pixel.png^[multiply:#cccccc"},
            {name = "ch_core_white_pixel.png^[multiply:#cccccc"},
            {name = "ch_jrad_frame.png", backface_culling = true},
            {name = "ch_jrad_frame.png", backface_culling = true},
        },
        overlay_tiles = {"", "", "", "",
            {name = "ch_jrad_paper.png", color = "white", backface_culling = true},
            {name = "ch_jrad_paper.png", color = "white", backface_culling = true},
        },
        use_texture_alpha = "clip",
        paramtype2 = "color4dir",
        palette = "unifieddyes_palette_color4dir.png",
        groups = groups,
        on_dig = unifieddyes.on_dig,
    }
    core.override_item("advtrains_line_automation:jrad", override)

    override.tiles[5] = override.tiles[1]
    override.overlay_tiles[5] = override.overlay_tiles[1]
    groups = core.registered_nodes["advtrains_line_automation:jrad_on_pole"].groups or {}
    core.override_item("advtrains_line_automation:jrad_on_pole", override)
    ch_core.register_shape_selector_group({nodes = {
        {name = "advtrains_line_automation:jrad", param2 = 0xff00},
        {name = "advtrains_line_automation:jrad_on_pole", param2 = 0xff00},
    }})
    core.register_craft({
        output = "advtrains_line_automation:jrad_on_pole",
        recipe = {{"advtrains_line_automation:jrad"}},
    })
    core.register_craft({
        output = "advtrains_line_automation:jrad",
        recipe = {{"advtrains_line_automation:jrad_on_pole"}},
    })
    core.register_craft({
        output = "advtrains_line_automation:jrad 9",
        recipe = {
            {"default:steel_ingot", "default:paper", "dye:black"},
            {"technic:zinc_ingot", "default:paper", "default:mese_crystal"},
            {"default:steel_ingot", "default:paper", "dye:black"},
        },
    })
end

-- Výběrové boxy pro svahy kolejí:

local prefixes = {
    "advtrains:dtrack_vst",
    "advtrains:dtrack_rg_vst",
    "advtrains:dtrack_concrete_vst",
    "advtrains:dtrack_rg_concrete_vst",
    "advtrains:dtrack_tieless_vst",
    "advtrains:dtrack_tieless_rg_vst",
}

for i = 2, 8 do
    local name
    local step = 1 / (4 * i) -- čtvrtina výškového rozdílu na jeden blok
    for j = 1, i do
        local b = (j - 7 / 8) * (4 * step) - 0.5 -- nejnižší stupeň bez korekce
        local override = {
            walkable = true,
            selection_box = {
                type = "fixed",
                fixed = {
                    {-0.75, -0.5, -2/4, 0.75, b, -1/4},
                    {-0.75, -0.5, -1/4, 0.75, b + step, 0/4},
                    {-0.75, -0.5, 0/4, 0.75, b + 2 * step, 1/4},
                    {-0.75, -0.5, 1/4, 0.75, b + 3 * step, 2/4},
                },
            },
            collision_box = {
                type = "fixed",
                fixed = {
                    {-1.5, -0.5, -2/4, 1.5, b, -1/4},
                    {-1.5, -0.5, -1/4, 1.5, b + step, 0/4},
                    {-1.5, -0.5, 0/4, 1.5, b + 2 * step, 1/4},
                    {-1.5, -0.5, 1/4, 1.5, b + 3 * step, 2/4},
                },
            },
        }
        for _, prefix in ipairs(prefixes) do
            if i == 2 then
                name = prefix..j
            else
                name = prefix..i..j
            end
            if core.registered_nodes[name] ~= nil then
                core.override_item(name, override)
            end
        end
    end
end

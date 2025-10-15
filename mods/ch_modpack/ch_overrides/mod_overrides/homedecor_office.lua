-- Kalendář
if core.get_modpath("ch_fonts") and core.get_modpath("display_api") and core.get_modpath("font_api") and core.get_modpath("signs") and core.get_modpath("signs_api") then
    local old_def = assert(core.registered_nodes["homedecor:calendar"])
    local function do_nothing() end
    local old_on_construct = old_def.on_construct or do_nothing

    local function update_calendar(pos, node, meta, cas, skip_update_entities)
        local l, s, jmcz, jmsk
        if node.name ~= "homedecor:calendar" then
            return
        end
        if cas == nil then
            cas = ch_time.aktualni_cas()
            if cas == nil then
                return
            end
        end
        s = cas:nazev_mesice(1)
        s = ch_core.utf8_truncate_right(s, 3, "")
        s = ch_core.na_velka_pismena(s)
        meta:set_string("display_text", cas.den.."\n"..s)
        s = assert(cas:den_v_tydnu_nazev())
        l = assert(ch_core.utf8_seek(s, 1, 1))
        s = ch_core.na_velka_pismena(s:sub(1, l - 1))..s:sub(l, -1).." "..cas.den..". "..cas:nazev_mesice(2).." "..cas.rok
        s = s.."\nV ČR má svátek: "..(cas:jmeniny("cz") or "").."\nV SK má sviatok: "..(cas:jmeniny("sk") or "")
		meta:set_string("infotext", s)
        meta:set_string("last_yyyy_mm_dd", cas:YYYY_MM_DD())
        if not skip_update_entities then
            display_api.update_entities(pos)
        end
    end

    local function calendar_tick(pos, node, meta)
        if node.name ~= "homedecor:calendar" then
            return
        end
        local cas = ch_time.aktualni_cas()
        local YYYY_MM_DD = cas:YYYY_MM_DD()
        if meta:get_string("last_yyyy_mm_dd") ~= YYYY_MM_DD then
            update_calendar(pos, node, meta, cas)
        end
    end

    local override = {
        tiles = {
            "[combine:32x32:0,0=homedecor_calendar.png:5,10=ch_core_white_pixel.png\\^[resize\\:16x17",
        },
        display_entities = {
            ["signs:display_text"] = {
                top = 0.22,
                aspect_ratio = 0.75,
                depth = 3/8 - display_api.entity_spacing,
                size = {x = 12/16, y = 8/16},
                maxlines = 2,
                on_display_update = font_api.on_display_update,
                color = "#000000",
                font_name = "dvssans",
            },
        },
        groups = ch_core.assembly_groups(old_def.groups, {display_api = 1}),
        on_construct = function(pos)
            old_on_construct(pos)
            update_calendar(pos, core.get_node(pos), core.get_meta(pos), nil, true)
            -- core.get_meta(pos):set_string("display_text", "10\nÚNO")
            return display_api.on_construct(pos)
        end,
        on_destruct = display_api.on_destruct,
        on_place = display_api.on_place,
        on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
            update_calendar(pos, node, core.get_meta(pos))
            return itemstack
        end,
        on_rotate = signs_api.on_rotate,
    }
    local nodenames = {"homedecor:calendar"}

    core.override_item(nodenames[1], override)

    core.register_lbm({
        label = "Update calendars on load",
        name = "ch_overrides:update_calendars",
        nodenames = nodenames,
        run_at_every_load = true,
        action = function(pos, node, dtime_s)
            update_calendar(pos, node, core.get_meta(pos))
        end,
    })

    core.register_abm({
        label = "Update calendars regularly",
        nodenames = nodenames,
        interval = 60,
        chance = 1,
        catch_up = false,
        action = function(pos, node, active_object_count, active_object_count_wider)
            calendar_tick(pos, node, core.get_meta(pos))
        end,
    })
end

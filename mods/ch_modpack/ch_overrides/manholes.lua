local function closed_manhole_on_construct(pos)
    local meta = core.get_meta(pos)
    meta:set_int("is_manhole", 1)
    meta:set_string("infotext", "průlez")
end

local function manhole_on_rightclick(pos, node, clicker)
    if clicker ~= nil then
        local player_name = clicker:get_player_name()
	    if core.is_protected(pos, player_name) then
		    core.record_protection_violation(pos, player_name)
		    return
	    end
    end
	local meta = core.get_meta(pos)
    local is_manhole = meta:get_int("is_manhole") ~= 0
    if clicker:get_player_control().aux1 then
        if is_manhole then
            meta:set_int("is_manhole", 0)
			meta:set_string("infotext", "")
        else
		    meta:set_int("is_manhole", 1)
		    meta:set_string("infotext", "průlez")
		end
        return
    end
    if is_manhole then
		node.name = assert(core.registered_nodes[node.name].manhole_alt)
		core.swap_node(pos, node)
    end
end

local function after_change(pos, old_node, new_node)
    local craftitem, category, alternate = stairsplus:analyze_shape(new_node.name)
    if craftitem ~= nil and alternate == "_manhole_closed" then
        closed_manhole_on_construct(pos)
    end
end

for _, material in ipairs(ch_core.get_materials_from_shapes_db("all")) do
    local name_closed = stairsplus:get_shape(material, "stair", "_manhole_closed")
    local name_open = stairsplus:get_shape(material, "stair", "_manhole_open")
    if name_open ~= nil and name_closed ~= nil then
        core.override_item(name_closed, {
            on_construct = closed_manhole_on_construct,
            on_rightclick = manhole_on_rightclick,
            manhole_alt = name_open,
        })
        core.override_item(name_open, {
            on_rightclick = manhole_on_rightclick,
            manhole_alt = name_closed,
        })
        ch_core.register_shape_selector_group({
            nodes = {name_open, name_closed},
            after_change = after_change,
        })
    end
end

-- Stormdrains:

if core.get_modpath("streets") then
    for _, name in ipairs(ch_core.get_materials_from_shapes_db("all")) do
        local allow_stormdrain = ch_core.is_shape_allowed(name, "streets", "stormdrain")
        if allow_stormdrain then
            core.log("action", "DEBUG: will register stormdrain for "..name)
            streets.register_manholes(name, false, true, nil)
        end
    end
end

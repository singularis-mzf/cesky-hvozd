print("DEBUG: manholes.lua")

local function open_manhole_on_construct(pos)
    local meta = core.get_meta(pos)
    meta:set_int("is_manhole", 1)
    meta:set_string("infotext", "průlez")
end
local function manhole_on_rightclick(pos, node, clicker)
    print("DEBUG: manhole_on_rightclick() called on "..node.name)
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
			meta:set_int("infotext", "")
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


--[[
			tiles = table.copy(tiles),
			drawtype = "nodebox",
			paramtype = "light",
			paramtype2 = "facedir",
			on_rightclick = closed_manhole_on_rightclick,
			sunlight_propagates = true,
			node_box = closed_manhole_node_box,
			manhole_alt = name_open,
			climbable = true,
			_ch_help = "Průlez po umístění aktivujete pomocí Aux1+pravý klik,\npak ho můžete otevírat/zavírat pravým kliknutím.\n"..
				"Průlez lze otáčet do všech 24 orientací.",
			_ch_help_group = "manhole",
]]

print("DEBUG: will register materials...")
for _, material in ipairs(ch_core.get_materials_from_shapes_db("all")) do
    local name_closed = stairsplus:get_shape(material, "stair", "_manhole_closed")
    local name_open = stairsplus:get_shape(material, "stair", "_manhole_open")
    print("DEBUG: material tested ("..material..") = "..tostring(name_closed)..", "..tostring(name_open))
    if name_open ~= nil and name_closed ~= nil then
        -- TODO
        print("DEBUG: Manhole material found: "..material)
        print("DEBUG: Will override "..name_closed)
        core.override_item(name_closed, {
            description = core.registered_nodes[name_closed].description.." [OVERRIDEN]",
            on_rightclick = manhole_on_rightclick,
            manhole_alt = name_open,
        })
        print("DEBUG: Will override "..name_open)
        core.override_item(name_open, {
            description = core.registered_nodes[name_closed].description.." [OVERRIDEN]",
            on_construct = open_manhole_on_construct,
            on_rightclick = manhole_on_rightclick,
            manhole_alt = name_closed,
        })
    end
end
print("DEBUG: materials registered")
-- print(stairsplus:get_shape("darkage:gneiss", "stair", "_manhole_open"))print(stairsplus:get_shape("darkage:gneiss", "stair", "_manhole_open"))

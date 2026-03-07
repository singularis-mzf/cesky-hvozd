local asphalt_nodes = {
    ["building_blocks:Tar"] = "ch_overrides:asphalt_black_bus",
    ["streets:asphalt_red"] = "ch_overrides:asphalt_red_bus",
    ["streets:asphalt_blue"] = "ch_overrides:asphalt_blue_bus",
    ["streets:asphalt_yellow"] = "ch_overrides:asphalt_yellow_bus",
}

for asphalt_node_name, new_prefix in pairs(asphalt_nodes) do
    local ndef = core.registered_nodes[asphalt_node_name]
    if ndef ~= nil then
        assert(ndef.description)
        assert(type(ndef.tiles) == "table")
        local def = {
            description = ndef.description.." (nápis BUS)",
            tiles = ndef.tiles,
            use_texture_alpha = "blend",
            overlay_tiles = {{name = "ch_overrides_bus_overlay.png", color = "#cccccc", backface_culling = true}, "", "", "", "", "", ""},
            paramtype2 = "facedir",
            sounds = ndef.sounds,
            groups = ndef.groups,
        }
        core.register_node(new_prefix, def)
    else
        core.log("warning", "Expected item '"..asphalt_node_name.."' is not registered!")
    end
end

local rotations = {"", "_r180"}
local variants = {"", "_slope_lower", "_slope_upper", "_slope_triple"}
local groups_override = {platform = 1}

for _, variant in ipairs(variants) do
    for _i, rotation in ipairs(rotations) do
        local name = "streets:mark_solid_white_bus_platform"..variant..rotation
        local ndef = core.registered_nodes[name]
        if ndef ~= nil then
            core.override_item(name, {
                groups = ch_core.assembly_groups(ndef.groups, groups_override)
            })
        else
            core.log("warning", "[ch_overrides] Expected node "..name.." is not present!")
        end
    end
end

local cube_drawtypes = {
    normal = 1,
    glasslike = 2,
    glasslike_framed = 3,
    glasslike_framed_optional = 4,
    allfaces = 5,
    allfaces_optional = 6,
    plantlike_rooted = 7,
}

local function get_attracts_poles_rank(name, ndef)
    local groups = ndef.groups or {}
    if groups.sign then
        if not name:match("_yard$") and not name:match("_on_pole$") then
            return 1
        end
    elseif groups.display_api then
        if
            not name:match("^digiterms:") and
            not name:match("^ontime_clocks:") and
            not name:match("^signs_road:inv") -- no invisible signs
        then
            return 1
        end
    elseif groups.streets_light or groups.technic_cnc_arch216_flange or
        groups.technic_cnc_bannerstone or groups.technic_cnc_block_fluted or
        groups.technic_cnc_cylinder or
        groups.technic_cnc_oct or
        groups.technic_cnc_opposedcurvededge or
        groups.technic_cnc_onecurvededge or
        groups.technic_cnc_sphere or
        groups.technic_cnc_spike or
        groups.technic_cnc_twocurvededge or
        groups.technic_cnc_valley
    then
            return 1
    elseif name:match("^itemframes:") and name ~= "itemframes:frame_invis" then
        return 1
    end
    return 0
end

local function get_full_cube_rank(ndef)
    local result = 1
    local drawtype = ndef.drawtype
    if drawtype == nil then return 1 end
    local result = cube_drawtypes[drawtype]
    if result ~= nil then return result end
    if drawtype == "nodebox" then
        local node_box = ndef.node_box
        if node_box == nil or node_box.type == nil or node_box.type == "regular" then
            return 8
        end
    end
    return 0
end

local function do_override()
    local count = 0
    local names = {}
    for name, _ in pairs(minetest.registered_nodes) do
        if name:find(":") then
            table.insert(names, name)
        end
    end
    for _, name in ipairs(names) do
        local ndef = minetest.registered_nodes[name]
        local new_groups = ch_core.assembly_groups(ndef.groups, {
            attracts_poles = get_attracts_poles_rank(name, ndef),
            ["drawtype_"..(ndef.drawtype or "normal")] = 1,
            full_cube_node = get_full_cube_rank(ndef),
        })
        minetest.override_item(name, {groups = new_groups})
        count = count + 1
    end
    print("[ch_overrides/drawtype_groups] "..count.." nodes overriden")
end

do_override()

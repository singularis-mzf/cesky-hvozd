local cube_drawtypes = {
    normal = 1,
    glasslike = 2,
    glasslike_framed = 3,
    glasslike_framed_optional = 4,
    allfaces = 5,
    allfaces_optional = 6,
    plantlike_rooted = 7,
}

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
        local rank = get_full_cube_rank(ndef)
        -- print("DEBUG: rank for "..name.." is "..rank)
        if rank > 0 then
            minetest.override_item(name, {
                groups = ch_core.assembly_groups(ndef.groups, {full_cube_node = rank})
            })
            count = count + 1
        end
    end
    print("[ch_overrides/drawtype_groups] "..count.." full cube nodes group overriden ("..#names.." candidates)")
end

do_override()

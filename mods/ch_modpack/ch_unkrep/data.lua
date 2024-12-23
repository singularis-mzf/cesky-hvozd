local ifthenelse = assert(ch_core.ifthenelse)

local filename = core.get_worldpath().."/ch_unkrep.dat"
local acc_dtime = 0
local next_clean_dtime = 0

local data = {
    [".mb_shapes"] = {
        -- {date, category, alternate}
        {20241223, "micro", ""},
        {20241223, "micro", "_1"},
        {20241223, "micro", "_12"},
        {20241223, "micro", "_15"},
        {20241223, "micro", "_2"},
        {20241223, "micro", "_4"},
        {20241223, "panel", ""},
        {20241223, "panel", "_1"},
        {20241223, "panel", "_12"},
        {20241223, "panel", "_15"},
        {20241223, "panel", "_2"},
        {20241223, "panel", "_4"},
        {20241223, "panel", "_banister"},
        {20241223, "panel", "_element"},
        {20241223, "panel", "_element_flat"},
        {20241223, "panel", "_l"},
        {20241223, "panel", "_l1"},
        {20241223, "panel", "_pole"},
        {20241223, "panel", "_pole_flat"},
        {20241223, "panel", "_special"},
        {20241223, "panel", "_wall"},
        {20241223, "panel", "_wall_flat"},
        {20241223, "panel", "_wide"},
        {20241223, "panel", "_wide_1"},
        {20241223, "slab", ""},
        {20241223, "slab", "_1"},
        {20241223, "slab", "_14"},
        {20241223, "slab", "_15"},
        {20241223, "slab", "_2"},
        {20241223, "slab", "_arcade"},
        {20241223, "slab", "_arcade_flat"},
        {20241223, "slab", "_bars"},
        {20241223, "slab", "_cube"},
        {20241223, "slab", "_quarter"},
        {20241223, "slab", "_rcover"},
        {20241223, "slab", "_table"},
        {20241223, "slab", "_three_quarter"},
        {20241223, "slab", "_three_sides"},
        {20241223, "slab", "_three_sides_half"},
        {20241223, "slab", "_three_sides_u"},
        {20241223, "slab", "_triplet"},
        {20241223, "slab", "_two_sides"},
        {20241223, "slab", "_two_sides_half"},
        {20241223, "slope", ""},
        {20241223, "slope", "_beveled"},
        {20241223, "slope", "_cut"},
        {20241223, "slope", "_cut2"},
        {20241223, "slope", "_diagfiller22a"},
        {20241223, "slope", "_diagfiller22b"},
        {20241223, "slope", "_diagfiller45"},
        {20241223, "slope", "_half"},
        {20241223, "slope", "_half_raised"},
        {20241223, "slope", "_inner"},
        {20241223, "slope", "_inner_cut"},
        {20241223, "slope", "_inner_cut_half"},
        {20241223, "slope", "_inner_cut_half_raised"},
        {20241223, "slope", "_inner_half"},
        {20241223, "slope", "_inner_half_raised"},
        {20241223, "slope", "_outer"},
        {20241223, "slope", "_outer_cut"},
        {20241223, "slope", "_outer_cut_half"},
        {20241223, "slope", "_outer_half"},
        {20241223, "slope", "_outer_half_raised"},
        {20241223, "slope", "_roof22"},
        {20241223, "slope", "_roof22_3"},
        {20241223, "slope", "_roof22_raised"},
        {20241223, "slope", "_roof22_raised_3"},
        {20241223, "slope", "_roof45"},
        {20241223, "slope", "_roof45_3"},
        {20241223, "slope", "_slab"},
        {20241223, "slope", "_tripleslope"},
        {20241223, "slope", "_valley"},
        {20241223, "stair", ""},
        {20241223, "stair", "_alt"},
        {20241223, "stair", "_alt_1"},
        {20241223, "stair", "_alt_2"},
        {20241223, "stair", "_alt_4"},
        {20241223, "stair", "_chimney"},
        {20241223, "stair", "_inner"},
        {20241223, "stair", "_outer"},
        {20241223, "stair", "_triple"},
        {20241223, "stair", "_wchimney"},
    },
}
local tools = {}

local function normalize_name(name)
    assert(type(name) == "string")
    if name:match("^:") then
        name = name:sub(2, -1)
    end
    if not name:match(":") then
        return nil
    end
    return name
end

local function reg_alias(old_name, new_name)
    assert(type(old_name) == "string")
    assert(type(new_name) == "string")
    if data[old_name] ~= nil then
        return
    end
    data[old_name] = {
        method = "alias",
        new_name = assert(new_name),
    }
end

local function reg_upgrade_tool(callback) -- => tool_handle
    assert(type(callback) == "function")
    table.insert(tools, callback)
    return {index = #tools}
end

local function reg_item(old_name, new_name, tool)
    assert(type(old_name) == "string")
    assert(type(new_name) == "string")
    if data[old_name] ~= nil then
        return
    end
    if new_name == old_name then
        error("[ch_unkrep] New name must be different then the old one ("..new_name..")!")
    end
    if core.registered_items[old_name] ~= nil then
        error("[ch_unkrep] Bad registration: "..old_name.." is a "..tostring(core.registered_items[old_name].type).."!")
    end
    if core.registered_items[new_name] == nil then
        error("[ch_unkrep] Bad registration: "..old_name.." would be repaired to an unknown item  "..new_name.."!")
    end
    local new_record = {
        method = "item",
        new_name = new_name,
    }
    if tool ~= nil then
        new_record.tool = tool.index
    end
    data[old_name] = new_record
end

local function reg_node(date, old_name, new_name, tool, no_lbm)
    assert(type(old_name) == "string")
    assert(type(new_name) == "string")
    if data[old_name] ~= nil then
        return
    end
    if new_name == old_name then
        error("[ch_unkrep] New name must be different then the old one ("..new_name..")!")
    end
    if core.registered_nodes[old_name] ~= nil then
        error("[ch_unkrep] Bad registration: "..old_name.." is a known node!")
    end
    if core.registered_nodes[new_name] == nil then
        error("[ch_unkrep] Bad registration: "..old_name.." would be repaired to an unknown node  "..new_name.."!")
    end
    local new_record = {
        method = "node",
        new_name = new_name,
    }
    if tool ~= nil then
        new_record.tool = tool.index
    end
    if not no_lbm then
        new_record.lbm_date = date
    end
    data[old_name] = new_record
end

local function reg_mb_node(date, old_name, new_name, tool, no_lbm)
    assert(type(date) == "string")
    assert(type(old_name) == "string")
    assert(type(new_name) == "string")
    old_name, new_name = normalize_name(old_name), normalize_name(new_name)
    if old_name == nil or new_name == nil then return end -- bad names
    local old_modname, old_varname = old_name:match("^([^:]+):(.*)$")
    local new_modname, new_varname = new_name:match("^([^:]+):(.*)$")
    if old_modname == nil or new_modname == nil or old_varname == nil or new_varname == nil then
        return
    end
    reg_node(date, old_name, new_name, tool, no_lbm)
    if old_modname == "default" then
        old_modname = "moreblocks"
    end
    if new_modname == "default" then
        new_modname = "moreblocks"
    end
    for _, shape in ipairs(assert(data)) do
        -- shape = {date, category, alternate}
        if shape[1] <= date then
            reg_node(date, old_modname..":"..shape[2].."_"..old_varname..shape[3], new_modname..":"..shape[2].."_"..new_varname..shape[3], tool, no_lbm)
        end
    end
end

local function get_data(old_name)
    if data == nil then
        -- load data from the file
        local f = io.open(filename)
        if f then
            local text = f:read("*a")
            f:close()
            data = core.deserialize(text, true)
            if type(data) ~= "table" then
                error("Deserialization of "..filename.." failed!")
            end
            next_clean_dtime = acc_dtime + 30
            if old_name == nil then
                print("DEBUG: unkrep data loaded")
            else
                print("DEBUG: unkrep data loaded because of '"..old_name.."'")
            end
        else
            error("Cannot open "..filename.."!")
        end
    end
    return data
end

function ch_unkrep.repair_itemstack(itemstack)
    if itemstack:is_empty() then
        return false
    end
    local name = itemstack:get_name()
    local my_data = get_data(name)
    local record = my_data[name]
    if record == nil then
        return false
    end
    local tool
    if record.tool ~= nil then
        tool = tools[record.tool]
    end
    if tool == nil then
        itemstack:set_name(record.new_name)
        return true
    else
        return tool("itemstack", itemstack)
    end
end

function ch_unkrep.repair_node(pos, node)
    local name = node.name
    local param2 = node.param2
    local my_data = get_data(name)
    local record = my_data[name]
    if record == nil or record.method == "item" then
        return false
    end
    local tool
    if record.tool ~= nil then
        tool = tools[record.tool]
    end
    if tool == nil then
        node.name = record.new_name
        core.swap_node(pos, node)
        core.log("action", "Unknown node "..name.."/"..param2.." at "..core.pos_to_string(pos).." repaired to "..node.name)
        return true
    elseif tool("node", pos, node, {name = assert(record.new_name), param = node.param, param2 = node.param2}) then
        core.log("action", "Unknown node "..name.."/"..param2.." at "..core.pos_to_string(pos).." repaired using a tool")
        return true
    else
        core.log("warning", "Unknown node "..name.."/"..param2.." at "..core.pos_to_string(pos).." not repaired, because the tool failed")
        return false
    end
end

local function lbm_action(pos, node, dtime_s)
    ch_unkrep.repair_node(pos, node)
end

local function commit_aliases_and_lbms()
    assert(data)
    local keys = {}
    local key = next(data)
    while key ~= nil do
        if key:sub(1, 1) ~= "." then
            table.insert(keys, key)
        end
        key = next(data, key)
    end
    -- Remove known items and commit aliases:
    for i = 1, #keys do
        local old_name = keys[i]
        local record = data[old_name]
        if core.registered_items[old_name] ~= nil then
            core.log("warning", old_name.." was registered for repair as unknown, but it is "..tostring(core.registered_items[old_name].type).."!")
            data[old_name] = nil
        elseif record.method == "alias" then
            core.register_alias(old_name, record.new_name)
            data[old_name] = nil
        elseif record.method == "node" and core.registered_nodes[record.new_name] == nil then
            core.log("warning", "[ch_unkrep] Bad registration: "..old_name.." will be repaired to an unknown node '"..record.new_name.."'!")
        elseif record.method == "item" and core.registered_items[record.new_name] == nil then
            core.log("warning", "[ch_unkrep] Bad registration: "..old_name.." will be repaired to an unknown item '"..record.new_name.."'!")
        end
    end
    -- LBMs:
    local lbm_nodenames = {}
    for old_name, record in pairs(data) do
        local date = record.lbm_date
        if date ~= nil then
            local list = lbm_nodenames[date]
            if list == nil then
                list = {}
                lbm_nodenames[date] = list
            end
            table.insert(list, old_name)
        end
    end
    for date, nodenames in pairs(lbm_nodenames) do
        core.register_lbm({
            label = "Upgrade unknown nodes: "..date,
            name = "ch_unkrep:u_"..date:gsub("-", "_"),
            nodenames = nodenames,
            action = lbm_action,
        })
    end
end

-- REGISTRATIONS


-- END OF REGISTRATIONS
commit_aliases_and_lbms()

local function globalstep(dtime)
    acc_dtime = acc_dtime + dtime
    if acc_dtime < next_clean_dtime then
        return
    end
    data = nil
    print("DEBUG: unkrep data cleared")
    next_clean_dtime = acc_dtime + 30
end
core.register_globalstep(globalstep)

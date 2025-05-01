local ifthenelse = ch_core.ifthenelse
local doors_by_group = {}

for n, _ in pairs(doors.registered_doors) do
    if core.registered_nodes[n] ~= nil then
        local nbase, nsuffix = n:match("^(.*)(_cd_[abcd])$")
        if nsuffix == nil then
            nbase, nsuffix = n:match("^(.*)(_[abcd])$")
        end
        if nbase ~= nil and nsuffix ~= nil then
            local group = doors_by_group[nbase]
            if group == nil then
                group = {}
                doors_by_group[nbase] = group
            end
            group[nsuffix] = n
        end
    end
end

local function on_change(pos, old_node, new_node, player, nodespec)
    local pos_above = vector.offset(pos, 0, 1, 0)
    local node_above = core.get_node(pos_above)
    if doors.is_hidden(node_above.name) then
        if old_node.name:sub(-1,-1) ~= new_node.name:sub(-1,-1) then
            local meta = core.get_meta(pos)
            meta:set_int("state", (meta:get_int("state") + 2) % 4)
        end
        doors.swap_door(pos, new_node)
    end
end

local function nodespecs(n1, n2, n3, n4)
    local t = {}
    if n1 ~= nil then table.insert(t, n1) end
    if n2 ~= nil then table.insert(t, n2) end
    if n3 ~= nil then table.insert(t, n3) end
    if n4 ~= nil then table.insert(t, n4) end
    return t
end

for nbase, nset in pairs(doors_by_group) do
    for _, ss_nodes in ipairs({
        nodespecs(nset["_a"], nset["_b"], nset["_cd_a"], nset["_cd_b"]),
        nodespecs(nset["_c"], nset["_d"], nset["_cd_c"], nset["_cd_d"]),
    }) do
        if #ss_nodes > 1 then
            ch_core.register_shape_selector_group({
                columns = 2,
                nodes = ss_nodes,
                on_change = on_change,
                check_owner = ifthenelse(core.registered_nodes[ss_nodes[1]].on_key_use ~= nil, true, false),
            })
        end
    end
end

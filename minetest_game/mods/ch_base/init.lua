ch_base = {}

local n = 0
local open_modname
local us_openned
local orig_node_count

local function count_nodes()
    local t = core.registered_nodes
    local name = next(t)
    local count = 0
    while name ~= nil do
        count = count + 1
        name = next(t, name)
    end
    return count
end

function ch_base.open_mod(modname)
    if open_modname ~= nil then
        error("ch_base.open_mod(): mod "..tostring(open_modname).." is already openned!")
    end
    open_modname = assert(modname)
    us_openned = core.get_us_time()
    orig_node_count = count_nodes()
    n = n + 1
    print("["..modname.."] init started ("..n..")")
end

function ch_base.close_mod(modname)
    if open_modname ~= modname then
        error("ch_base.close_mod(): mod "..tostring(modname).." is not openned!")
    end
    local diff = core.get_us_time() - us_openned
    print("["..modname.."] init finished ("..n..") in "..math.ceil(diff / 1000.0).." ms (+"..(count_nodes() - orig_node_count).." nodes)")
    open_modname = nil
    us_openned = nil
end

function ch_base.mod_checkpoint(name)
    if open_modname == nil then
        error("ch_base.mod_checkpoint() outside of mod initialization!")
    end
    print("["..open_modname.."] checkpoint "..(name or "nil").." at "..math.ceil((core.get_us_time() - us_openned) / 1000.0).." ms")
end

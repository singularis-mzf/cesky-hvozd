ch_base = {}

local get_us_time = core.get_us_time
local n = 0
local open_modname
local us_openned
local orig_node_count
local orig_memory
local enable_performance_logging = core.settings:get_bool("ch_enable_performance_logging", false)

local function ifthenelse(a, b, c)
    if a then return b else return c end
end

--[[
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
]]

local function count_nodes()
    return 0
end

function ch_base.open_mod(modname)
    if open_modname ~= nil then
        error("ch_base.open_mod(): mod "..tostring(open_modname).." is already openned!")
    end
    open_modname = assert(modname)
    us_openned = get_us_time()
    orig_node_count = count_nodes()
    orig_memory = collectgarbage("count")
    n = n + 1
    print("["..modname.."] init started ("..n..")")
end

function ch_base.close_mod(modname)
    if open_modname ~= modname then
        error("ch_base.close_mod(): mod "..tostring(modname).." is not openned!")
    end
    local diff = math.ceil((get_us_time() - us_openned) / 1000.0)
    local memory_now = collectgarbage("count")
    local memory_diff = memory_now - orig_memory
    memory_diff = string.format(ifthenelse(memory_diff >= 0, "+%.3f kB", "%.3f kB"), memory_diff)
    local msg = "["..modname.."] init finished ("..n..")"
    if diff >= 10 then
        msg = msg.." in "..diff.." ms"
    end
    local new_nodes = count_nodes() - orig_node_count
    if new_nodes > 0 then
        msg = msg.." +"..new_nodes.." nodes"
    end
    msg = msg.." "..memory_diff.."."
    print(msg)
    open_modname = nil
    us_openned = nil
end

function ch_base.mod_checkpoint(name)
    if open_modname == nil then
        error("ch_base.mod_checkpoint() outside of mod initialization!")
    end
    print("["..open_modname.."] checkpoint "..(name or "nil").." at "..math.ceil((get_us_time() - us_openned) / 1000.0).." ms")
end

if enable_performance_logging then
-- Performance watching:
-- * globalstep
-- * ABM
-- * LBM
-- * entity on_step
-- * unmeasured time

local counters = {}
local measured = {} -- key => {count = int, time = long}
local global_measure_start
local measure_start, measure_stop
local measure_active = false

local function run_and_measure(label, f, ...)
    if measure_active then
        return f(...)
    end
    measure_start = get_us_time()
    if global_measure_start == nil then
        global_measure_start = measure_start
    end
    measure_active = true
    local result = f(...)
    measure_active = false
    measure_stop = get_us_time()
    local m = measured[label]
    if m == nil then
        measured[label] = {count = 1, time = measure_stop - measure_start, maxtime = measure_stop - measure_start}
    else
        m.count = m.count + 1
        m.time = m.time + (measure_stop - measure_start)
        if m.time > m.maxtime then
            m.maxtime = m.time
        end
    end
    return result
end

local function acquire_label(label_type)
    local modname = open_modname or "nil"
    local counter = counters[modname..":"..label_type] or 1
    counters[modname..":"..label_type] = counter + 1
    return modname..":"..label_type..":"..counter
end

local orig_register_globalstep = assert(core.register_globalstep)
local orig_register_lbm = assert(core.register_lbm)
local orig_register_abm = assert(core.register_abm)
local orig_register_entity = assert(core.register_entity)

function core.register_globalstep(func)
    assert(func)
    local label = acquire_label("globalstep")
    return orig_register_globalstep(function(...)
        return run_and_measure(label, func, ...)
    end)
end

function core.register_lbm(def, ...)
    assert(type(def) == "table")
    local orig_action = def.action
    if type(orig_action) ~= "function" then
        return orig_register_lbm(def, ...)
    end
    local label = acquire_label("lbm")
    local new_def = {}
    for k, v in pairs(def) do
        new_def[k] = v
    end
    new_def.action = function(...)
        return run_and_measure(label, orig_action, ...)
    end
    return orig_register_lbm(new_def, ...)
end

function core.register_abm(def, ...)
    assert(type(def) == "table")
    local orig_action = def.action
    assert(orig_action)
    local label = acquire_label("abm")
    local new_def = {}
    for k, v in pairs(def) do
        new_def[k] = v
    end
    new_def.action = function(...)
        return run_and_measure(label, orig_action, ...)
    end
    return orig_register_abm(new_def, ...)
end

function core.register_entity(name, def, ...)
    assert(type(name) == "string")
    assert(type(def) == "table")
    local orig_on_step = def.on_step
    if orig_on_step ~= nil then
        local label = (open_modname or "nil")..":entity_on_step:["..name.."]"
        local new_def = {
            on_step = function(...)
                return run_and_measure(label, orig_on_step, ...)
            end,
        }
        setmetatable(new_def, {__index = def})
        def = new_def
    end
    return orig_register_entity(name, def, ...)
end

local def = {
    params = "",
    description = "vypíše do logu naměřené údaje o výkonu",
    privs = {server = true},
    func = function(player_name, param)
        if not global_measure_start then
            return false, "měření nezačalo"
        end
        local now = get_us_time()
        local m = {}
        local total_time = 0
        for label, data in pairs(measured) do
            table.insert(m, {label, data})
            total_time = total_time + data.time
        end
        table.sort(m, function(a, b) return a[2].time > b[2].time end)
        local result = {"Performance log ["..#m.." items]:"}
        for _, package in ipairs(m) do
            local label, data = package[1], package[2]
            table.insert(result, string.format("- %s = %0.3f ms (c=%d) maxtime=%0.3f ms",
                label, math.ceil(data.time / 1000.0), data.count, math.ceil(data.maxtime / 1000.0)))
        end
        table.insert(result, string.format("==============\ntotal measured: %0.3f ms\ntotal unmeasured: %0.3f",
            math.ceil(total_time / 1000.0), math.ceil((now - global_measure_start - total_time) / 1000.0)))
        result = table.concat(result, "\n")
        core.log("action", result)
        return true, "vypsáno"
    end,
}

core.register_chatcommand("vykon", def)
core.register_chatcommand("výkon", def)
end -- if enable_performance_logging

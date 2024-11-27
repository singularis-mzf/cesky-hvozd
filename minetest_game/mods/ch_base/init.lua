ch_base = {}

local n = 0
local open_modname

function ch_base.open_mod(modname)
    if open_modname ~= nil then
        error("ch_base.open_mod(): mod "..tostring(open_modname).." is already openned!")
    end
    open_modname = assert(modname)
    n = n + 1
    print("["..modname.."] init started ("..n..")")
end

function ch_base.close_mod(modname)
    if open_modname ~= modname then
        error("ch_base.close_mod(): mod "..tostring(modname).." is not openned!")
    end
    open_modname = nil
    print("["..modname.."] init finished ("..n..")")
end

function ch_base.mod_checkpoint(name)
end

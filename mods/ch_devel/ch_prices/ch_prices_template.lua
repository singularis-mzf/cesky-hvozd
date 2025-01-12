local result = {}
local function a(name, old_name)
    table.insert(result, {"a", assert(name), assert(old_name)})
end

local function fix(name, sell_price, buy_price)
    table.insert(result, {"f", assert(name), sell_price, buy_price})
end

local function mk(name, items)
    assert(type(items) == "table")
    table.insert(result, {"m", assert(name), items})
end
-- ================================================================
-- DEFINICE:
-- ================================================================

fix("default:cobble", 25, 1)
fix("default:diamond", 100000)
a("default:stone", "default:cobble")

-- ================================================================
return result

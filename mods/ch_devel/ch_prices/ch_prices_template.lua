local result = {}

-- Stanovuje, že cena položky 'name' bude přímo odvozena od ceny
-- položky 'old_name'.
local function a(name, old_name)
    table.insert(result, {"a", assert(name), assert(old_name)})
end

-- Stanovuje pevnou cenu prodeje a nákupu pro danou položku.
-- Jedna z cen může být nil, pokud položku nelze koupit/prodat.
local function fix(name, sell_price, buy_price)
    table.insert(result, {"f", assert(name), sell_price, buy_price})
end

-- Stanovuje, že položka 'name' se vyrábí z položek v seznamu 'items'.
-- items = {
--   {material_name [, material_count]}...
-- }
-- kde material_count může být i desetinné číslo
--
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

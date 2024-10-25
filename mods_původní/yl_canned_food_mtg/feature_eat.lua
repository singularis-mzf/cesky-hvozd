-- item eat integration
if (yl_canned_food_mtg.settings.enable_eat ~= true) then return false end

-- dependencies
if (minetest.get_modpath("vessels") == nil) then
    yl_canned_food_mtg.log("feature item_eat enabled, but mod vessels not found")
    return false
end

local amount = 0

for _, recipe in ipairs(yl_canned_food_mtg.data) do

    -- normal
    local redefinition = {
        on_use = minetest.item_eat(recipe.nutrition, "vessels:glass_bottle")
    }
    minetest.override_item(recipe.out, redefinition)

    -- pickled
    local redefinition_plus = {
        on_use = minetest.item_eat(recipe.nutrition * 2, "vessels:glass_bottle")
    }
    minetest.override_item(recipe.out .. "_plus", redefinition_plus)

    amount = amount + 1
end

yl_canned_food_mtg.log("item eat integration: " .. dump(amount))

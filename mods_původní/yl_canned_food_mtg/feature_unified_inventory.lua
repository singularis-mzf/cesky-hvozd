-- unified_inventory integration
if (yl_canned_food_mtg.settings.enable_unified_inventory ~= true) then
    return false
end

-- dependencies
if (minetest.get_modpath("unified_inventory") == nil) then
    yl_canned_food_mtg.log(
        "feature unfied_inventory enabled, but mod unfied_inventory not found")
    return false
end

assert((type(unified_inventory.register_craft_type) == "function"),
       "register_craft_type does not exist in unified_inventory")
assert((type(unified_inventory.register_craft) == "function"),
       "register_craft does not exist in unified_inventory")

unified_inventory.register_craft_type("yl_canned_food", {
    description = yl_canned_food_mtg.t(
        "unified_inventory_register_craft_type_description"),
    icon = "yl_canned_food_mtg_unified_inventory_craft.png",
    width = 1,
    height = 1,
    uses_crafting_grid = false
})

local amount = 0

for _, recipe in ipairs(yl_canned_food_mtg.data) do
    unified_inventory.register_craft({
        output = recipe.out .. "_plus",
        type = "yl_canned_food",
        items = {recipe.out}
    })
    amount = amount + 1
end

yl_canned_food_mtg.log("unfied_inventory integration: " .. dump(amount))

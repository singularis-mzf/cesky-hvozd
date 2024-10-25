-- recipes integration
if (yl_canned_food_mtg.settings.enable_recipes ~= true) then return false end

local amount = 0

local function group_has_member(group)
    for itemname, _ in pairs(minetest.registered_items) do
        if minetest.get_item_group(itemname, group) ~= 0 then return true end
    end
    return false
end

local itemcache = {}

local vessel = "vessels:glass_bottle"

itemcache[vessel] = true

for _, recipe in ipairs(yl_canned_food_mtg.data) do
    itemcache[recipe.out] = true

    local ingredient = recipe.base_mod .. ":" .. recipe.base_item
    itemcache[ingredient] = true

    for _, additive in ipairs(recipe.additives) do itemcache[additive] = true end
end

local item_good = {}

for item, _ in pairs(itemcache) do
    local groupname = item:match("^group:(.*)")
    if (groupname == nil) then
        item_good[item] = (minetest.registered_items[item] ~= nil)
    else
        item_good[item] = group_has_member(groupname)
    end
end

for _, recipe in ipairs(yl_canned_food_mtg.data) do

    local crafting = {}
    local success = true

    -- vessel
    table.insert(crafting, vessel)
    if (item_good[vessel] ~= false) then
        success = success and true
    else
        success = false
    end

    -- additive
    for _, additive in ipairs(recipe.additives) do
        table.insert(crafting, additive)
        if (item_good[additive] ~= false) then
            success = success and true
        else
            success = false
        end
    end
    -- ingredient
    local ingredient = recipe.base_mod .. ":" .. recipe.base_item

    for i = recipe.base_amount, 1, -1 do
        table.insert(crafting, ingredient)
        if (item_good[ingredient] ~= false) then
            success = success and true
        else
            success = false
        end
    end

    if (success == true) then
        -- register the craft
        minetest.register_craft({
            output = recipe.out,
            type = "shapeless",
            recipe = crafting
        })

        amount = amount + 1
    else
        minetest.log("warning",
                     yl_canned_food_mtg.t("recipe_not_good", recipe.out))
    end
end

yl_canned_food_mtg.log("recipes integration: " .. dump(amount))

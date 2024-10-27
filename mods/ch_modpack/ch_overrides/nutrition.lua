local count = 0

for name, idef in pairs(minetest.registered_items) do
    if idef ~= nil then
        local groups = idef.groups
        if groups ~= nil and groups.ch_food ~= nil and groups.ch_food ~= 0 and minetest.get_item_group(name, "not_in_creative_inventory") == 0 then
            minetest.override_item(name, {
                description = idef.description.." ("..groups.ch_food.." kcal)",
            })
            count = count + 1
        end
    end
end
print("[ch_overrides/nutrition] "..count.." items overriden.")

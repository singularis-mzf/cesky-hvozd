local counter = 0

for id,definition in pairs(minetest.registered_nodes) do
    local groups = definition.groups
    local origin = definition.mod_origin
    local circular_saw = id == 'moreblocks:circular_saw'

    local stair_or_slab = groups.stair or groups.slab
    local moreblocks_object = origin == 'moreblocks' and not circular_saw

    if (stair_or_slab or moreblocks_object) and string.find(id, ":stair_") then
        local tiles = definition.tiles
        local target_tiles = {}

        for index,_ in pairs(tiles) do
            if type(tiles[index]) == 'table' then
                tiles[index].align_style = 'world'
                target_tiles[index] = tiles[index]
            else
                target_tiles[index] = {
                    name = tiles[index],
                    align_style = 'world'
                }
            end
        end

        minetest.override_item(id, {
            tiles = target_tiles
        })
		counter = counter + 1
    end
end

print("[redef] Aligned Textures:  "..counter.." nodes redefined")

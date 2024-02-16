local sound_api = {}

local has_default_mod = minetest.get_modpath("default")
for _, sound in ipairs({"stone", "glass"}) do
    local sound_function_name = "node_sound_" .. sound .. "_defaults"
    if has_default_mod then
        sound_api[sound_function_name] = default[sound_function_name]
    else
        if sound_function_name == "node_sound_stone_defaults" then
            sound_api[sound_function_name] = function()
                return {
                    footstep = {name = "stoneblocks_stone_step"},
                    dig = {name = "stoneblocks_stone_dig"},
                    place = {name = "stoneblocks_stone_place"},
                }
            end
        elseif sound_function_name == "node_sound_glass_defaults" then
            sound_api[sound_function_name] = function()
                return {
                    footstep = {name = "stoneblocks_glass_step"},
                    dig = {name = "stoneblocks_glass_dig"},
                    place = {name = "stoneblocks_glass_place"},
                }
            end
        end
    end
end

return sound_api
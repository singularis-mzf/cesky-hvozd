
local sound_api = stoneblocks.soundApi
local S = stoneblocks.S

local stoneblocks_check_player_within = tonumber(minetest.settings:get('stoneblocks_check_player_within')) or 2
local stoneblocks_stay_lit_for = tonumber(minetest.settings:get('stoneblocks_stay_lit_for')) or 2

if stoneblocks_check_player_within < 1 or stoneblocks_check_player_within > 20 then
    minetest.log("warning", "incorrect settings for stoneblocks_check_player_within using default")
    stoneblocks_check_player_within = 2
end
if stoneblocks_stay_lit_for < 1 or stoneblocks_stay_lit_for > 600 then
    minetest.log("warning", "incorrect settings for stoneblocks_stay_lit_for using default")
    stoneblocks_stay_lit_for = 2
end

local function initialize_dark_block(pos)
    local timer = minetest.get_node_timer(pos)
    minetest.log("action", "setting up dark block")
    timer:start(0.5) -- check half second for players
end

local function register_stoneblock(name, description)
    -- Define your "unlit" block with the on_construct callback
    minetest.register_node("stoneblocks:" .. name, {
        description = S(description),
        tiles = { name .. ".png" },
        groups = { stone = 1, cracky = 2, oddly_breakable_by_hand = 1},
        sounds = sound_api.node_sound_glass_defaults(),
        on_construct = initialize_dark_block,
        on_timer = function(pos)
            local objs = minetest.get_objects_inside_radius(pos, stoneblocks_check_player_within) -- is the radius to check for players
            for _, obj in ipairs(objs) do
                if obj:is_player() then
                    minetest.swap_node(pos, { name = "stoneblocks:" .. name .. "_lit" })
                    -- Start a timer to switch back after X seconds
                    local timer = minetest.get_node_timer(pos)
                    timer:start(stoneblocks_stay_lit_for) -- number of seconds the block to stay lit
                    return false                      -- Stop checking once switched to lit
                end
            end
            return true -- Continue checking if not switched to lit
        end,
    })
end

local function register_lit_stoneblock(name, description)
    -- Define your "lit" block
    minetest.register_node("stoneblocks:" .. name .. "_lit", {
        description = S(description),
        tiles = { name .. "_lit.png" },
        light_source = minetest.LIGHT_MAX, -- Max light
        groups = { stone = 1, cracky = 2,  oddly_breakable_by_hand = 1, not_in_creative_inventory = 1 },
        sounds = sound_api.node_sound_glass_defaults(),
        drop = "stoneblocks:" .. name, -- Ensure it drops the unlit version
        
    
        -- When constructed or swapped from unlit, start the timer
        on_construct = function(pos)
            local timer = minetest.get_node_timer(pos)
            timer:start(1) -- Start checking immediately
            minetest.log("action", "drop unlit " .. "stoneblocks:" .. name)
            minetest.log("action", "setting up lit block" .. name .. "_lit.png" )
        end,

        -- Define on_timer to handle reversion or continuous check
        on_timer = function(pos)
            local objs = minetest.get_objects_inside_radius(pos, stoneblocks_check_player_within) -- radius for player detection
            local player_nearby = false
            for _, obj in ipairs(objs) do
                if obj:is_player() then
                    player_nearby = true
                    break
                end
            end

            if player_nearby then
                -- If a player is still nearby, reset the timer to check again
                local timer = minetest.get_node_timer(pos)
                timer:start(1) -- Continue checking for player presence
            else
                -- If no players are nearby, switch back to the unlit version and reinitialize
                minetest.swap_node(pos, { name = "stoneblocks:" .. name })
                initialize_dark_block(pos)
            end
        end,
    })
end

local function register_sensitive_block(name, description)
    register_stoneblock(name, description)
    register_lit_stoneblock(name, description)
end

register_sensitive_block("stoneblocks_sensitive_glass_block", "Sensitive Glass Block")
register_sensitive_block("stoneblocks_lantern_yellow", "Yellow Stone Lantern")
register_sensitive_block("stoneblocks_lantern_blue", "Blue Stone Lantern")
register_sensitive_block("stoneblocks_lantern_green", "Green Stone Lantern")
register_sensitive_block("stoneblocks_lantern_red_green_yellow", "Red and Green with Yellow Stone Lantern")
register_sensitive_block("stoneblocks_lantern_red", "Red Stone Lantern")
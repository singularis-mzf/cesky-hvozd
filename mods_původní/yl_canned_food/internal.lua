-- log
--
local function log(text)
    local logmessage = yl_canned_food.t("log_prefix", yl_canned_food.modname,
                                        text)
    if (yl_canned_food.settings.debug == true) then
        minetest.log("action", logmessage)
    end
    return logmessage
end

function yl_canned_food.log(text) return log(text) end

-- get_node_definition
--

local function get_node_definition(additonal_values)
    local t = {
        drawtype = "plantlike",
        paramtype = "light",
        is_ground_content = false,
        walkable = false,
        selection_box = {
            type = "fixed",
            fixed = {-0.25, -0.5, -0.25, 0.25, 0.3, 0.25}
        },
        groups = {
            attached_node = 1,
            dig_immediate = 3,
            canned_food = 1,
            vessel = 1
        }
    }
    for k, v in pairs(additonal_values) do t[k] = v end
    return t
end

function yl_canned_food.get_node_definition(additonal_values)
    return get_node_definition(additonal_values)
end

local function can_set(pos)
    if (yl_canned_food.settings.freeze == true) then return false end
    local light = minetest.get_node_light(pos)
    local roll = math.random() * 100
    if ((light and (light > yl_canned_food.settings.max_light)) or
        (roll > yl_canned_food.settings.chance)) then return false end
    return true
end

function yl_canned_food.can_set(pos) return can_set(pos) end

-- register_food
--

local function register_food(itemstring, itemdesc, origin)

    local stages = {}

    table.insert(stages, {
        stage_name = origin .. ":" .. itemstring[1],
        -- next_stages = origin .. ":" .. itemstring[2],
        next_stages = {
            {
                origin .. ":" .. itemstring[2], 1,
                {can_set = yl_canned_food.can_set}, nil
            }
        },
        duration = tonumber(yl_canned_food.settings.duration) or 600,
        tiles = {"yl_canned_food_" .. itemstring[1] .. ".png"},
        description = itemdesc[1],
        node_definition = yl_canned_food.get_node_definition({
            inventory_image = "yl_canned_food_" .. itemstring[1] .. ".png"
        }),
        overwrite = false,
        restart = true
    })

    table.insert(stages, {
        stage_name = origin .. ":" .. itemstring[2],
        tiles = {"yl_canned_food_" .. itemstring[2] .. ".png"},
        description = itemdesc[2],
        node_definition = yl_canned_food.get_node_definition({
            inventory_image = "yl_canned_food_" .. itemstring[2] .. ".png"
        })
    })

    local success, good, bad, total, reasons =
        yl_api_nodestages.register_stages(stages)

    if (success == false) then
        yl_canned_food.log("action", "item = " .. dump(itemstring[1]))
        yl_canned_food.log("action", "success = " .. dump(success))
        yl_canned_food.log("action", "good = " .. dump(good))
        yl_canned_food.log("action", "bad = " .. dump(bad))
        yl_canned_food.log("action", "total = " .. dump(total))
        yl_canned_food.log("action", "reasons = " .. dump(reasons))
        return false
    end

    return true
end

function yl_canned_food.register_food(itemstring, itemdesc, origin)
    return register_food(itemstring, itemdesc, origin)
end

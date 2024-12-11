local internal = ...

local ifthenelse = ch_core.ifthenelse

internal.features = {
    -- has_autosort = {type = "bool", default = false}, -- not supported yet
    has_title = {type = "bool", default = true},
    height = {type = "int", default = 4},
    ownership = {type = "string", default = "owner"}, -- "none" (everyone is owner), "owner", "given" (not supported yet)
    pipeworks = {type = "bool", default = false},
    qmove = {type = "bool", default = false},
    trash = {type = "bool", default = true},
    width = {type = "int", default = 8},
}

function internal.get_feature(name, meta, feature)
    local fdef, idef, value = internal.features[feature], core.registered_items[name]
    if fdef == nil then
        return nil -- unknown feature
    end
    if fdef.type == "string" then
        value = meta:get_string("ch_chest_"..feature)
        if value ~= "" then
            return value -- value from metadata
        elseif idef ~= nil then
            local fixed_features = idef.ch_chest
            if fixed_features ~= nil then
                value = fixed_features[feature]
                if value ~= nil then
                    return value -- value from def.ch_chest
                end
            end
        end
    else
        value = meta:get_int("ch_chest_"..feature)
        if value ~= 0 then
            if fdef.type == "bool" then
                return value > 0
            else
                return value
            end
        else
            local fixed_features = idef.ch_chest
            if fixed_features ~= nil then
                value = fixed_features[feature]
                if value ~= nil then
                    return value -- value from def.ch_chest
                end
            end
        end
    end
    return fdef.default
end

function internal.set_feature(meta, feature, value)
    local fdef = internal.features[feature]
    if fdef == nil then
        return false
    elseif fdef.type == "string" then
        if value == nil then
            value = ""
        end
        meta:set_string("ch_chest_"..feature, value)
    elseif fdef.type == "int" then
        if value == nil then
            value = 0
        end
        meta:set_int("ch_chest_"..feature, value)
    elseif fdef.type == "bool" then
        if value == nil then
            value = 0
        elseif value then
            value = 1
        else
            value = -1
        end
        meta:set_int("ch_chest_"..feature, value)
    else
        error("Unsupported feature type: "..fdef.type.."!")
    end
    return true
end

--[[
local function get_player_category(name, meta, player_name)
    -- => admin || owner || group || player || none
    --[ [
        admin – plný přístup, může darovat nebo měnit vlastnictví
        owner – plný přístup, může darovat
        group – známá postava, omezený přístup
        player – cizí postava, omezený nebo žádný přístup
        none – žádný přístup
    ] ]
    if player_name == nil then
        return "none" -- no access
    end
    local player_role = ch_core.get_player_role(player_name)
    if player_role == "admin" then
        return "admin"
    elseif player_role == "new" then
        return "none"
    end
    local ownership = internal.get_feature(name, meta, "ownership")
    if ownership == "none" or (ownership == "owner" and meta:get_string("owner") == player_name) then
        return "owner"
    else
        return "player"
    end
end
]]

function internal.can_view(name, meta, player_name)
    local ownership = internal.get_feature(name, meta, "ownership")
    if ownership == "none" then
        return ifthenelse(player_name == nil or ch_core.get_player_role(player_name) ~= "new", true, false)
    else -- ownership == "owner"
        local owner = meta:get_string("owner")
        return player_name ~= nil and (ch_core.get_player_role(player_name) == "admin" or player_name == owner)
    end
end

function internal.can_put(name, meta, player_name)
    local ownership = internal.get_feature(name, meta, "ownership")
    if ownership == "none" then
        return ifthenelse(player_name == nil or ch_core.get_player_role(player_name) ~= "new", true, false)
    else -- ownership == "owner"
        local owner = meta:get_string("owner")
        return player_name ~= nil and (ch_core.get_player_role(player_name) == "admin" or player_name == owner)
    end
end

function internal.can_take(name, meta, player_name)
    local ownership = internal.get_feature(name, meta, "ownership")
    if ownership == "none" then
        return ifthenelse(player_name == nil or ch_core.get_player_role(player_name) ~= "new", true, false)
    else -- ownership == "owner"
        local owner = meta:get_string("owner")
        return player_name ~= nil and (ch_core.get_player_role(player_name) == "admin" or player_name == owner)
    end
end

function internal.can_setup(name, meta, player_name)
    local ownership = internal.get_feature(name, meta, "ownership")
    if ownership == "none" then
        return ifthenelse(player_name == nil or ch_core.get_player_role(player_name) ~= "new", true, false)
    else -- ownership == "owner"
        local owner = meta:get_string("owner")
        return player_name ~= nil and (ch_core.get_player_role(player_name) == "admin" or player_name == owner)
    end
end

function internal.update_chest_infotext(node, meta)
    local has_title = internal.get_feature(node.name, meta, "has_title")
    local ownership = internal.get_feature(node.name, meta, "ownership")
    local result = {}
    if has_title then
        table.insert(result, meta:get_string("title"))
    end
    if ownership == "owner" then
        table.insert(result, "truhlu vlastní: "..ch_core.prihlasovaci_na_zobrazovaci(meta:get_string("owner")))
    end
    if #result > 0 then
        result = table.concat(result, "\n")
    else
        result = ""
    end
    meta:set_string("infotext", result)
end

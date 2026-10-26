ch_base.open_mod(minetest.get_current_modname())

local modpath = minetest.get_modpath(minetest.get_current_modname())

ch_say = {
    sounds = {},
}

local allowed_parameters = {
    gain = true,
    pitch = true,
    fade = true,
    start_time = true,
}
local no_parameters = {}

local function normalize_players(player_names)
    local player_name, player_data
    if type(player_names) == "string" then
        -- 1 player?
        player_data = ch_data.online_charinfo[player_names]
        if player_data ~= nil then
            -- 1 online player
            return {[player_names] = player_data}, 1
        else
            return {}, 0
        end
    else
        local set_players, n_players = {}, 0
        for _, player_name in ipairs(player_names) do
            if set_players[player_name] == nil then
                player_data = ch_data.online_charinfo[player_name]
                if player_data ~= nil then
                    n_players = n_players + 1
                    set_players[player_name] = player_data
                end
            end
        end
        return set_players, n_players
    end
end

local unknown_texts = {}

local function normalize_texts(texts)
    local t = type(texts)
    local result = {}
    if t == "string" then
        if texts ~= "" then
            local sound_parts = ch_say.sounds[texts]
            if sound_parts ~= nil then
                table.insert_all(result, sound_parts)
            elseif unknown_texts[texts] == nil then
                unknown_texts[texts] = true
                core.log("action", "[ch_say] Unknown text put to say: \""..texts.."\"")
            end
        end
    elseif t == "table" then
        for _, text in ipairs(texts) do
            if text ~= "" then
                local sound_parts = ch_say.sounds[text]
                if sound_parts ~= nil then
                    table.insert_all(result, sound_parts)
                elseif unknown_texts[text] == nil then
                    unknown_texts[text] = true
                    core.log("action", "[ch_say] Unknown text put to say: \""..text.."\"")
                end
            end
        end
    elseif t ~= "nil" then
        error("[ch_say] Invalid 'texts' type: "..t)
    end
    return result, #result
end

local say_next
say_next = function(args)
    local player_name = args.player_name
    local player_data = ch_data.online_charinfo[player_name]
    if player_data ~= nil then
        -- player is still in game
        local channel_data = player_data.ch_say_channels
        if channel_data ~= nil then
            channel_data = channel_data[args.channel]
            if channel_data ~= nil and channel_data.generation == args.generation then
                -- channel generation match
                local sounds, i = args.sounds, args.i
                local sound = assert(sounds[i])
                local parameters = table.copy(sound.parameters)
                parameters.to_player = player_name
                channel_data.current_handle = core.sound_play(sound.name, parameters) -- play the current sound

                if sounds[i + 1] ~= nil then
                    -- plan playing the next sound
                    args.i = i + 1
                    core.after(sound.length, say_next, args)
                end
            end
        end
    end
end

local function vivify_table(t, k)
    if t[k] ~= nil then
        return t[k]
    else
        local result = {}
        t[k] = result
        return result
    end
end

function ch_say.register_sound(text, parts)
    if ch_say.sounds[text] ~= nil then
        core.log("warning", "[ch_say] Text '"..text.."' already registered!")
        return false
    end
    assert(type(parts) == "table")
    if parts[1] == nil and part.name ~= nil then
        parts = {parts}
    end
    local new_sound = {}
    for i, part in ipairs(parts) do
        local parameters
        assert(type(part.name) == "string")
        assert(type(part.length) == "number")
        for k, v in pairs(part) do
            if allowed_parameters[k] then
                if parameters == nil then
                    parameters = {[k] = v}
                else
                    parameters[k] = v
                end
            end
        end
        if parameters == nil then
            parameters = no_parameters
        end
        new_sound[i] = {
            name = part.name, -- sound file or "" for no sound
            length = part.length, -- length is seconds
            parameters = parameters, -- sound parameters
        }
    end
    if new_sound[1] == nil then
        core.log("error", "[ch_say] registration of '"..text.."' failed!")
        return false
    end
    ch_say.sounds[text] = new_sound
    return true
end


function ch_say.say(channel, player_names, texts)
    channel = "default" -- channel argument is ignored in this version
    local sounds, n_sounds = normalize_texts(texts)
    if n_sounds == 0 then
        return true -- no known texts to say
    end
    local set_players, n_players = normalize_players(player_names)
    if n_players == 0 then
        return true -- no online players to speak to
    end
    for player_name, player_data in pairs(set_players) do
        local channel_data = vivify_table(vivify_table(player_data, "ch_say_channels"), channel)
        local generation = channel_data.generation
        local handle

        -- initialize or increment channel generation:
        if generation == nil then
            generation = 1
        else
            generation = generation + 1
            handle = channel_data.current_handle
            if handle ~= nil then
                channel_data.current_handle = nil
                core.sound_stop(handle) -- stop the previous sound in this channel
            end
        end
        channel_data.generation = generation

        -- start the new sound:
        say_next({
            player_name = player_name,
            channel = channel,
            generation = generation,
            sounds = sounds,
            i = 1,
        })
    end
    return true
end

core.register_chatcommand("say", {
    params = "text",
    description = "(testování)",
    privs = {server = true},
    func = function(name, params)
        local texts = string.split(params, "|")
        ch_say.say("default", name, texts)
    end,
})

local register_sounds = loadfile(modpath.."/sounds.lua")
if not register_sounds then
    error("File "..modpath.."/sounds.lua is missing or invalid!")
end
register_sounds()

ch_base.close_mod(minetest.get_current_modname())

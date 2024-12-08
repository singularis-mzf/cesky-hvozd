ch_core.register_event_type("player_overrun", {
    description = "srážka s vlakem",
    access = "players",
    color = "#ff3333",
    chat_access = "public",
})

local repeat_protection = {}
local has_penalty = core.settings:get_bool("ch_player_overrun_penalty", false)

local function on_player_overrun(player, train_id, train_direction, train_velocity)
    local player_name = player:get_player_name()
    local now = core.get_us_time()
    local protection = repeat_protection[player_name]
    if protection ~= nil and now < protection then
        return
    end
    ch_core.add_event("player_overrun", "{PLAYER} byl/a sražen/a vlakem č. "..train_id.." jedoucím "..math.ceil(train_velocity).." m/s!", player_name)
    core.sound_play("player_damage", {pos = player:get_pos(), max_hear_distance = 50}, true)
    repeat_protection[player_name] = now + 1000000
    if has_penalty then
        player:set_hp(1)
        -- TODO...
    end
    --[[
    print("DEBUG: Postava "..player_name.." byla sražena vlakem "..train_id.." na pozici "..
        core.pos_to_string(player:get_pos()).." při rychlosti "..train_velocity.." směrem jízdy "..
        core.pos_to_string(train_direction)..".")
        ]]
end

advtrains.register_on_player_overrun(on_player_overrun)

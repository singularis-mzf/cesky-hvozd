local S = emote.S
local facedir_to_look_horizontal = emote.util.facedir_to_look_horizontal
local vector_rotate_xz = emote.util.vector_rotate_xz

emote.emotes = {}

emote.attached_to_node = {}
emote.emoting = {}

local stand_name = "vstaň"

-- API functions

function emote.register_emote(name, def)
    emote.emotes[name] = def
	local alias = def.alias
	local def = {
		description = S(("Makes your character perform the %s emote"):format(name)),
		func = function(playername)
			local player = minetest.get_player_by_name(playername)
			if emote.start(player, name) then
				return true -- , S(("you %s"):format(name))
			else
				return false, S(("animace se nepodařila: %s"):format(name))
			end
		end,
	}
	minetest.register_chatcommand(name, def)
	if alias then
		minetest.register_chatcommand(alias, def)
	end
end

function emote.start(player, emote_name)
	if not minetest.is_player(player) then
		emote.emoting[player] = nil
		return
	end

	local emote_def = emote.emotes[emote_name]

	if not emote_def then
		minetest.log("warning", "emote definition for emote named '"..emote_name.."' not found!")
		return false
	end

	local player_name = player:get_player_name()
	minetest.log("action", "will set emote '"..emote_name.."' (animation '"..(emote_def.anim_name or "nil").."') for player "..player_name)
	player_api.set_animation(player, emote_def.anim_name, emote_def.speed)
	if emote_name == stand_name then
		emote.emoting[player] = nil
		player_api.player_attached[player_name] = nil
	else
		emote.emoting[player] = emote_name
		player_api.player_attached[player_name] = true
	end

	if emote.settings.announce_in_chat then
		minetest.chat_send_all(("* %s %s"):format(player_name, emote_def.description))
	end

	if emote_def.stop_after then
		minetest.after(emote_def.stop_after, emote.stop, player)
	end

	return true
end

function emote.stop(player)
	minetest.log("action", "will stop emote of player "..player:get_player_name())
	emote.start(player, stand_name)
end

function emote.list()
	local r = {}
	for emote_name, _ in pairs(emote.emotes) do
		table.insert(r, emote_name)
	end
	return r
end

function emote.attach_to_node(player, pos, locked)
	local node = minetest.get_node(pos)
	if node.name == "ignore" then
		return false
	end

	if emote.attached_to_node[player] then
		return
	end

	local def = minetest.registered_nodes[node.name].emote or {}

	local emotedef = {
		eye_offset = def.eye_offset or {x = 0, y = 1/2, z = 0},
		player_offset = def.player_offset or {x = 0, y = 0, z = 0},
		look_horizontal_offset = def.look_horizontal_offset or 0,
		emotestring = def.emotestring or "sedni",
	}

	local look_horizontal = facedir_to_look_horizontal(node.param2)
	local offset = vector_rotate_xz(emotedef.player_offset, look_horizontal)
	local rotation = look_horizontal + emotedef.look_horizontal_offset
	local new_pos = vector.add(pos, offset)

	emote.start(player, emotedef.emotestring)

	if locked then
		local object = minetest.add_entity(new_pos, "emote:attacher")
		if object then
			object:get_luaentity():init(player)
			object:setyaw(rotation)

			player:set_attach(object, "", emotedef.eye_offset, minetest.facedir_to_dir(node.param2))

			emote.attached_to_node[player] = object
		end

	else
		emote.start(player, emotedef.emotestring)

		player:set_pos(new_pos)
		player:set_eye_offset(emotedef.eye_offset, {x = 0, y = 0, z = 0})
	end

	player:set_look_horizontal(rotation)
end

function emote.attach_to_entity(player, emotestring, obj)
	-- not implemented yet.
end

function emote.detach(player)
	if emote.attached_to_node[player] then
		emote.attached_to_node[player]:detach()
	end
	-- check if attached?
	player:set_eye_offset(vector.new(), vector.new())
	emote.stop(player)
end

minetest.register_globalstep(function()
	for player in pairs(emote.emoting) do
		local ctrl = player:get_player_control()
		if ctrl and (ctrl.jump or ctrl.up or ctrl.down or ctrl.left or ctrl.right) then
			emote.stop(player)
		end
	end
end)

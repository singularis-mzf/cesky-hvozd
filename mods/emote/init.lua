local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local S = minetest.get_translator(modname)

emote = {
	modname = modname,
	modpath = modpath,

	extra_animations = {
		wave = {x = 192, y = 196, override_local = true},
		point = {x = 196, y = 196, override_local = true},
	},

	S = S,

	log = function(level, messagefmt, ...)
		return minetest.log(level, ("[%s] %s"):format(modname, messagefmt:format(...)))
	end,

	dofile = function(...)
		return dofile(table.concat({modpath, ...}, DIR_DELIM) .. ".lua")
	end,
}

emote.dofile("settings")
emote.dofile("util")
emote.dofile("api")
emote.dofile("entity")

local model = player_api.registered_models["character.b3d"]

--[[
for anim_name, anim_def in pairs(emote.extra_animations) do
	model.animations[anim_name] = anim_def
end ]]

emote.register_emote("vstaň", {
	alias = "vstan",
	anim_name = "stand",
	speed = 30,
	description = S("stands up")
})

emote.register_emote("sedni", {
	anim_name = "sit",
	speed = 30,
	description = S("sits")
})

emote.register_emote("lehni", {
	anim_name = "lay",
	speed = 30,
	description = S("lies down")
})

emote.register_emote("ahoj", {
	anim_name = "wave",
	speed = 15,
	stop_after = 4,
	description = S("waves")
})

emote.register_emote("ukaž", {
	alias = "ukaz",
	anim_name = "point",
	speed = 30,
	description = S("points")
})

emote.dofile("beds")

local first_extra_animation

for k, _ in pairs(emote.extra_animations) do
	first_extra_animation = k
	break
end

local function update_extra_animations(player_name)
	local x = minetest.get_player_by_name(player_name)
	if not x then return end
	x = x:get_properties()
	if not x then return end
	x = x.mesh
	if not x then return end
	x = player_api.registered_models[x]
	if not x then return end
	x = x.animations
	if not x then return end
	if not x[first_extra_animation] then
		minetest.log("action", "will update extra animations for player "..player_name)
		for anim_name, anim_def in pairs(emote.extra_animations) do
			x[anim_name] = table.copy(anim_def)
		end
	end
end

if first_extra_animation then
	minetest.register_on_joinplayer(function(player, last_login)
		minetest.after(0.5, update_extra_animations, player:get_player_name())
	end)
end

--[[
model.animations.freeze = {x = 205, y = 205, override_local = true}
emote.register_emote("freeze", {
	anim_name = "freeze",
	speed = 30,
	description = S("freezes")
})
]]

--[[
-- testing tool - punch any node to test attachment code
] ]--
minetest.register_tool("emote:sleep", {
	description = "use me on a bed bottom",
	groups = {not_in_creative_inventory = 1},
	on_use = function(itemstack, user, pointed_thing)
		-- the delay here is weird, but the client receives a mouse-up event
		-- after the punch and switches back to "stand" animation, undoing
		-- the animation change we're doing.
		minetest.after(0.5, emote.attach_to_node, user, pointed_thing.under)
	end
})
]]

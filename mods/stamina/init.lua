print("[MOD BEGIN] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")

stamina = {players = {}, mod = "redo"}

STAMINA_TICK = tonumber(minetest.settings:get("stamina_tick")) or 800
							-- time in seconds after that 1 stamina point is taken
STAMINA_TICK_MIN = 4		-- stamina ticks won't reduce stamina below this level
STAMINA_HEALTH_TICK = 4		-- time in seconds after player gets healed/damaged
STAMINA_MOVE_TICK = 0.5		-- time in seconds after the movement is checked
STAMINA_POISON_TICK = 1.25	-- time in seconds after player is poisoned

STAMINA_EXHAUST_DIG = 2		-- exhaustion increased this value after digged node
STAMINA_EXHAUST_PLACE = 1	-- .. after digging node
STAMINA_EXHAUST_MOVE = 1.5	-- .. if player movement detected
STAMINA_EXHAUST_JUMP = 5	-- .. if jumping
STAMINA_EXHAUST_CRAFT = 2	-- .. if player crafts
STAMINA_EXHAUST_PUNCH = 40	-- .. if player punches another player
STAMINA_EXHAUST_LVL = 160	-- at what exhaustion player saturation gets lowered

STAMINA_HEAL = 2			-- number of HP player gets healed after STAMINA_HEALTH_TICK
STAMINA_HEAL_LVL = 5		-- lower level of saturation needed to get healed

STAMINA_VISUAL_MAX = 20		-- hud bar extends only to 20
STAMINA_MAX_STAMINA = 60
STAMINA_HUNGER_LEVEL = 30   -- levels of stamina < this are considered hunger
STAMINA_DRUNK_SECONDS = 60

SPRINT_SPEED = 0.3			-- how much faster player can run if satiated
SPRINT_JUMP = 0.1			-- how much higher player can jump if satiated
SPRINT_DRAIN = 0.35			-- how fast to drain satation while sprinting (0-1)

local stamina_privs = {ch_registered_player = true, interact = true}

local function is_stamina_enabled(player_name)
	local result = minetest.check_player_privs(player_name, stamina_privs)
	return result
end

local function should_hide(hud_name, level)
	if hud_name == "damage" then
		return level == 0
	elseif hud_name == "hlad" then
		return level < 5
	elseif hud_name == "opilost" then
		return level == 0
	else
		return false
	end
end

local function should_unhide(hud_name, level)
	if hud_name == "damage" then
		return level > 0
	elseif hud_name == "hlad" then
		return level > 5
	elseif hud_name == "opilost" then
		return level > 0
	else
		return false
	end
end

local function get_int_attribute(player)

	-- pipeworks fake player check
	if not player or not player.get_attribute then
		return nil
	end

	local meta = player:get_meta()
	local level = meta and meta:get_string("stamina:level")

	if level then
		return tonumber(level)
	end

	return nil
end

local function stamina_update_hud(player, stamina_level)
	local player_name = player:get_player_name()
	local player_data, hud_status, is_hunger, hud_maxvalue, hud_value
	local player_data = stamina.players[player_name]
	local is_hunger
	-- hud_status: "normal", "poisoned", "drunk"
	-- is_hunger: true, false

	-- stamina_level 0..29 = hlad, stamina_level 30..60 = sytost

	if stamina_level < STAMINA_HUNGER_LEVEL then
		is_hunger = true
		hud_value = STAMINA_HUNGER_LEVEL - stamina_level
		hud_maxvalue = STAMINA_HUNGER_LEVEL
	else
		is_hunger = false
		hud_value = stamina_level - STAMINA_HUNGER_LEVEL
		hud_maxvalue = STAMINA_MAX_STAMINA - STAMINA_HUNGER_LEVEL
	end
	minetest.log("action", "[debug] Stamina update: stamina_level = "..stamina_level..", hunger_level = "..STAMINA_HUNGER_LEVEL..", is_hunger = "..(is_hunger and "true" or "false")..", hud = "..hud_value.." of "..hud_maxvalue)

	if not player_data.hud_status then
		-- init
		hud_status = "normal"
		player_data.hud_status = hud_status
		player_data.hud_value = hud_value
		player_data.was_hunger = nil -- not is_hunger -- trigger update

		player_data.hud_label = "" -- DEBUG

		hb.init_hudbar(player, "hlad", 0, hud_maxvalue, true)
	end

	if player_data.poisoned then
		hud_status = "poisoned"
	elseif player_data.drunk then
		hud_status = "drunk"
	else
		hud_status = "normal"
	end

	local result
	if player_data.hud_status ~= hud_status or player_data.was_hunger ~= is_hunger then
		-- update everything
		local hud_icon, hud_bgicon, hud_bar, hud_label

		if hud_status == "poisoned" then
			hud_label = is_hunger and "otrava+hlad" or "otrava"
			hud_bar = "hudbars_bar_poison.png"
		elseif hud_status == "drunk" then
			hud_label = is_hunger and "hlad" or "sytost"
			hud_bar = "hudbars_bar_poison.png"
		else
			hud_label = is_hunger and "hlad" or "sytost"
			hud_bar = "hudbars_bar_stamina.png"
		end

		minetest.log("action", "[debug] Stamina of "..player:get_player_name().." HUD label: ("..player_data.hud_label..") => ("..hud_label.."), HUD value: ("..player_data.hud_value..") => ("..hud_value..")")

		player_data.hud_status = hud_status
		player_data.was_hunger = is_hunger
		player_data.hud_value = hud_value
		hb.unhide_hudbar(player, "hlad")
		local state_before = hb.get_hudbar_state(player, "hlad")
		result = hb.change_hudbar(player, "hlad", hud_value, hud_maxvalue, hud_icon, hud_bgicon, hud_bar, hud_label, 0xFFFFFF)
		local state_after = hb.get_hudbar_state(player, "hlad")

		player_data.hud_label = hud_label

		minetest.log("action", "[debug] Stamina: change = "..dump2({before = state_before, after = state_after, arguments = {player, "hlad", hud_value, hud_maxvalue, hud_icon, hud_bgicon, hud_bar, hud_label, 0xFFFFFF}}))

	elseif player_data.hud_value ~= hud_value then
		-- update only the value
		minetest.log("action", "[debug] Stamina of "..player:get_player_name().." HUD value update: ("..player_data.hud_value..") => ("..hud_value..")")
		player_data.hud_value = hud_value
		if not hb.get_hudbar_state(player, "hlad").hidden then
			result = hb.change_hudbar(player, "hlad", hud_value, nil, nil, nil, nil, player_data.hud_label)
		end
	else
		result = false
	end
	if not is_stamina_enabled(player_name) then
		hb.hide_hudbar(player, "hlad")
	elseif hud_status ~= "normal" or hud_value > 5 then
		hb.unhide_hudbar(player, "hlad")
		hb.change_hudbar(player, "hlad", player_data.hud_value, nil, nil, nil, nil, player_data.hud_label)
	elseif hud_value < 4 then
		hb.hide_hudbar(player, "hlad")
	end
	return result
end

local function stamina_update_level(player, level)

	-- pipeworks fake player check
	if not player.get_attribute then
		return nil
	end

	local old = get_int_attribute(player)

	if level > STAMINA_MAX_STAMINA then
		level = STAMINA_MAX_STAMINA
	end

	if level == old then -- To suppress HUD update
		return
	end

	-- don't update stamina for player with no interact or ch_registered_player priv
	if not is_stamina_enabled(player:get_player_name()) then
		return
	end

	local meta = player and player:get_meta() ; if not meta then return end

	-- minetest.log("action", "stamina change: "..player:get_player_name()..": "..old.." -> "..level)

	meta:set_string("stamina:level", level)

	stamina_update_hud(player, level)
end


-- global function for mods to amend stamina level
stamina.change = function(player, change)

	local name = player:get_player_name()

	if not name or not change or change == 0 then
		return false
	end

	local level = (get_int_attribute(player) or 0) + change

	if level < 0 then level = 0 end

	if level > STAMINA_MAX_STAMINA then level = STAMINA_MAX_STAMINA end

	stamina_update_level(player, level)

	return true
end


local function exhaust_player(player, v)

	if not player
	or not player.is_player
	or not player:is_player()
	or not player.set_attribute then
		return
	end

	local name = player:get_player_name()

	if not name then
		return
	end

	local exhaustion = stamina.players[name].exhaustion + v

	if exhaustion > STAMINA_EXHAUST_LVL then

		exhaustion = 0

		local h = get_int_attribute(player) or 0

		if h > 0 then
			stamina_update_level(player, h - 1)
		end
	end

	stamina.players[name].exhaustion = exhaustion
end


-- Sprint settings and function
local monoids = minetest.get_modpath("player_monoids")
local pova_mod = minetest.get_modpath("pova")

local function head_particle(player, texture)

	if not player then return end

	local prop = player:get_properties()
	local pos = player:get_pos() ; pos.y = pos.y + (prop.eye_height or 1.23) -- mouth level
	local dir = player:get_look_dir()

	minetest.add_particlespawner({
		amount = 5,
		time = 0.1,
		minpos = pos,
		maxpos = pos,
		minvel = {x = dir.x - 1, y = dir.y, z = dir.z - 1},
		maxvel = {x = dir.x + 1, y = dir.y, z = dir.z + 1},
		minacc = {x = 0, y = -5, z = 0},
		maxacc = {x = 0, y = -9, z = 0},
		minexptime = 1,
		maxexptime = 1,
		minsize = 1,
		maxsize = 2,
		texture = texture
	})
end

local function drunk_tick()

	for _,player in ipairs(minetest.get_connected_players()) do

		local name = player:get_player_name()

		if name
		and stamina.players[name]
		and stamina.players[name].drunk then

			-- play burp sound every 20 seconds when drunk
			local num = stamina.players[name].drunk

			if num and num > 0 and math.floor(num / 20) == num / 20 then

				head_particle(player, "bubble.png")

				minetest.sound_play("stamina_burp",
						{to_player = name, gain = 0.7}, true)
			end

			stamina.players[name].drunk = stamina.players[name].drunk - 1

			if stamina.players[name].drunk < 1 then

				stamina.players[name].drunk = nil
				stamina.players[name].units = 0

				stamina_update_hud(player, get_int_attribute(player) or 0)
				hb.hide_hudbar(player, "opilost")
			else
				hb.change_hudbar(player, "opilost", stamina.players[name].drunk)
			end

			-- effect only works when not riding boat/cart/horse etc.
			if not player:get_attach() then

				local yaw = player:get_look_horizontal() + math.random(-0.5, 0.5)

				player:set_look_horizontal(yaw)
			end
		end
	end
end


local function health_tick()

	for _,player in ipairs(minetest.get_connected_players()) do

		local name = player:get_player_name()

		if name then

			local air = player:get_breath() or 0
			local hp = player:get_hp()
			local h = get_int_attribute(player) or 0

			if hp < STAMINA_VISUAL_MAX -- don't heal if fully healed
			and hp > 0 -- don't heal if dead
			and h -- don't heal if the stamina level is unknown
			and h >= STAMINA_HEAL_LVL -- don't heal if the stamina level is too low
			and 20 * h >= hp * 30 then

				if not stamina.players[name].poisoned and air > 0 then -- don't heal if poisoned or drowning
					player:set_hp(hp + STAMINA_HEAL)
				end

				stamina_update_level(player, h - 1)
			end
		end
	end
end


local function action_tick()

	for _,player in ipairs(minetest.get_connected_players()) do

		local controls = player and player:get_player_control()

		-- Determine if the player is walking or jumping
		if controls then

			if controls.jump then
				exhaust_player(player, STAMINA_EXHAUST_JUMP)

			elseif controls.up
			or controls.down
			or controls.left
			or controls.right then
				exhaust_player(player, STAMINA_EXHAUST_MOVE)
			end
		end
	end
end


local function poison_tick()

	for _,player in ipairs(minetest.get_connected_players()) do

		local name = player and player:get_player_name()

		if name
		and stamina.players[name]
		and stamina.players[name].poisoned
		and stamina.players[name].poisoned > 0 then

			stamina.players[name].poisoned =
				stamina.players[name].poisoned - 1

			local hp = player:get_hp() - 1

			head_particle(player, "stamina_poison_particle.png")

			if hp > 0 then
				player:set_hp(hp, {poison = true})
			end

		elseif name
		and stamina.players[name]
		and stamina.players[name].poisoned then
			stamina.players[name].poisoned = nil
			stamina_update_hud(player, get_int_attribute(player) or 0)
		end
	end
end


local function stamina_tick()

	for _,player in ipairs(minetest.get_connected_players()) do

		local h = player and get_int_attribute(player)

		if h and h > STAMINA_TICK_MIN then
			stamina_update_level(player, h - 1)
		end
	end
end

--- HUD BARS ---
local hudbar_formatstring = "@1"
local hudbar_formatstring_config = {
	order = { "label" --[[, "value", "max_value"]] },
	textdomain = "hudbars",
}
hb.register_hudbar("damage", 0xFFFFFF, "zranění", { icon = "hudbars_icon_health.png", bgicon = "hudbars_bgicon_health.png", bar = "hudbars_bar_health.png" }, 0, 19, false, hudbar_formatstring, hudbar_formatstring_config)

hb.register_hudbar("hlad", 0xFFFFFF, "hlad", { icon = "default_apple.png", bgicon = nil, bar = "hudbars_bar_stamina.png" }, 0, STAMINA_MAX_STAMINA, false, hudbar_formatstring, hudbar_formatstring_config)

hb.register_hudbar("opilost", 0xFFFFFF, "opilost", { icon = "stamina_wine_bottle.png", bgicon = nil, bar = "hudbars_bar_drunk.png" }, 0, STAMINA_DRUNK_SECONDS, false, hudbar_formatstring, hudbar_formatstring_config)

-- Time based stamina functions
local stamina_timer, health_timer, action_timer, poison_timer, drunk_timer = 0,0,0,0,0

local function stamina_globaltimer(dtime)

	stamina_timer = stamina_timer + dtime
	health_timer = health_timer + dtime
	action_timer = action_timer + dtime
	poison_timer = poison_timer + dtime
	drunk_timer = drunk_timer + dtime

	-- simulate drunk walking (thanks LumberJ)
	if drunk_timer > 1.0 then
		drunk_tick() ; drunk_timer = 0
	end

	-- hurt player when poisoned
	if poison_timer > STAMINA_POISON_TICK then
		poison_tick() ; poison_timer = 0
	end

	-- particle animation
	if action_timer > STAMINA_MOVE_TICK then
		action_tick() ; action_timer = 0
	end

	-- lower saturation by 1 point after STAMINA_TICK
	if stamina_timer > STAMINA_TICK then
		stamina_tick() ; stamina_timer = 0
	end

	-- heal or damage player, depending on saturation
	if health_timer > STAMINA_HEALTH_TICK then
		health_tick() ; health_timer = 0
	end
end


-- override core.do_item_eat() so we can redirect hp_change to stamina
core.do_item_eat = function(hp_change, replace_with_item, itemstack, user, pointed_thing)

	if user.is_fake_player then
		return -- abort if called by fake player (eg. pipeworks-wielder)
	end

	local old_itemstack = itemstack

	itemstack = stamina.eat(hp_change, replace_with_item, itemstack, user, pointed_thing)

	for _, callback in pairs(core.registered_on_item_eats) do

		local result = callback(hp_change, replace_with_item, itemstack, user,
				pointed_thing, old_itemstack)

		if result then
			return result
		end
	end

	return itemstack
end

-- not local since it's called from within core context
function stamina.eat(hp_change, replace_with_item, itemstack, user, pointed_thing)

	if not itemstack or not user then
		return itemstack
	end

	local level = get_int_attribute(user) or 0

	-- if level >= STAMINA_VISUAL_MAX then
	--	return itemstack
	--end

	local name = user:get_player_name()

	if hp_change > 0 then

		stamina_update_level(user, level + hp_change)

	elseif hp_change < 0 then

		-- assume hp_change < 0
		stamina.players[name].poisoned = -hp_change
		stamina_update_hud(user, level)
	end

	-- if {drink=1} group set then use sip sound instead of default eat
	local snd = "stamina_eat"
	local itemname = itemstack:get_name()
	local def = minetest.registered_items[itemname]

	if def and def.groups and def.groups.drink then
		snd = "stamina_sip"
	end

	minetest.sound_play(snd, {to_player = name, gain = 0.7}, true)

	-- particle effect when eating
	local texture  = minetest.registered_items[itemname].inventory_image

	head_particle(user, texture)

	-- if player drinks milk then stop poison and being drunk
	local item_name = itemstack:get_name() or ""
	if item_name == "mobs:bucket_milk"
	or item_name == "mobs:glass_milk"
	or item_name == "farming:soy_milk" then

		stamina.players[name].poisoned = 0
		stamina.players[name].drunk = 0
	end

	itemstack:take_item()

	if replace_with_item then

		if itemstack:is_empty() then
			itemstack:add_item(replace_with_item)
		else
			local inv = user:get_inventory()

			if inv:room_for_item("main", {name = replace_with_item}) then
				inv:add_item("main", replace_with_item)
			else
				local pos = user:get_pos()

				if pos then core.add_item(pos, replace_with_item) end
			end
		end
	end

	-- check for alcohol
	local units = minetest.registered_items[itemname].groups
			and minetest.registered_items[itemname].groups.alcohol or 0

	if units > 0 then
		stamina.players[name].units = (stamina.players[name].units or 0) + 1

		if stamina.players[name].units > 3 then

			stamina.players[name].drunk = STAMINA_DRUNK_SECONDS
			stamina.players[name].units = 0

			stamina_update_hud(user, get_int_attribute(user) or 0)
			hb.change_hudbar(user, "opilost", stamina.players[name].drunk)
			hb.unhide_hudbar(user, "opilost")

			minetest.chat_send_player(name,
					minetest.get_color_escape_sequence("#1eff00")
					.. "*** najednou je vám nějak divně!")
		end
	end

	return itemstack
end

function stamina.exhaust_player_by_craft(player)
	exhaust_player(player, STAMINA_EXHAUST_CRAFT)
end

minetest.register_on_joinplayer(function(player)
	if not player then return end

	local level = STAMINA_MAX_STAMINA

	if get_int_attribute(player) then
		level = math.min(get_int_attribute(player), STAMINA_MAX_STAMINA)
	else
		local meta = player:get_meta()
		meta:set_string("stamina:level", level)
	end

	local name = player:get_player_name()

	-- HUDBARS
	local hud_level = 20 - player:get_hp()
	local start_hidden = should_hide("damage", hud_level)
	hb.init_hudbar(player, "damage", hud_level, 19, start_hidden)

	-- hud_level = STAMINA_MAX_STAMINA - level
	-- start_hidden = should_hide("hlad", hud_level)
	-- hb.init_hudbar(player, "hlad", hud_level, STAMINA_MAX_STAMINA, start_hidden)

	hb.init_hudbar(player, "opilost", 0, STAMINA_DRUNK_SECONDS, true)

	stamina.players[name] = {
		hud_id = 0,
		exhaustion = 0,
		poisoned = nil,
		drunk = nil,
		sprint = nil
	}
	stamina_update_hud(player, level)
end)

minetest.register_on_respawnplayer(function(player)

	local name = player:get_player_name() ; if not name then return end

	--[[ if stamina.players[name].poisoned
	or stamina.players[name].drunk then
		hb.change_hudbar(player, "hlad", nil, nil, nil, nil, "hudbars_bar_stamina.png")
	end ]]

	stamina.players[name].exhaustion = 0
	stamina.players[name].poisoned = nil
	stamina.players[name].drunk = nil
	stamina.players[name].sprint = nil

	stamina_update_level(player, STAMINA_MAX_STAMINA)
end)

minetest.register_globalstep(stamina_globaltimer)

minetest.register_on_placenode(function(pos, oldnode, player, ext)
	exhaust_player(player, STAMINA_EXHAUST_PLACE)
end)

minetest.register_on_dignode(function(pos, oldnode, player, ext)
	exhaust_player(player, STAMINA_EXHAUST_DIG)
end)

minetest.register_on_craft(function(itemstack, player, old_craft_grid, craft_inv)
	exhaust_player(player, STAMINA_EXHAUST_CRAFT)
end)

minetest.register_on_punchplayer(function(player, hitter, time_from_last_punch,
		tool_capabilities, dir, damage)
	exhaust_player(hitter, STAMINA_EXHAUST_PUNCH)
end)

-- clear when player leaves
minetest.register_on_leaveplayer(function(player)
	if player then
		stamina.players[player:get_player_name()] = nil
	end
end)

-- HP change changes
minetest.register_on_player_hpchange(function(player, hp_change, reason)
	local old_hp = player:get_hp()
	if minetest.is_creative_enabled(player:get_player_name()) then
		hp_change = 20 - old_hp -- in creative mode always maximal HP
	elseif old_hp + hp_change <= 0 then
		hp_change = 1 - old_hp -- immortality
	end
	local new_hp = old_hp + hp_change
	if new_hp > 20 then
		new_hp = 20
	end
	if hp_change ~= 0 then
		hb.change_hudbar(player, "damage", 20 - new_hp)
		if new_hp == 20 then
			hb.hide_hudbar(player, "damage")
		else
			hb.unhide_hudbar(player, "damage")
		end
	end
	return hp_change
end, true)

minetest.register_chatcommand("stamina", {
	params = "<new_value>",
	privs = {server = true},
	func = function(chat_player_name, param)
		local player = minetest.get_player_by_name(chat_player_name)
		local new_value = tonumber(param)
		if new_value ~= nil then
			stamina_update_level(player, new_value)
			return true
		else
			return false, "Chybné číslo: "..param
		end
	end,
})

print("[MOD END] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")

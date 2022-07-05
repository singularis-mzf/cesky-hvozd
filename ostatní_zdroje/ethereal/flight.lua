local flight_secs = minetest.settings:get("ethereal.flightpotion_duration") or (5 * 60)
local timer_check = 5 -- seconds per check
local S = ethereal.intllib
local is_50 = minetest.has_feature("object_use_texture_alpha")


-- disable flight
local function set_flight(user, set)

	if not user then return end

	local name = user:get_player_name()
	local privs = minetest.get_player_privs(name)

	privs.fly = set

	minetest.set_player_privs(name, privs)

	-- when 'fly' removed set timer to temp value for checks
	if not set then

		if is_50 then
			local meta = user:get_meta() ; if not meta then return end

			meta:set_string("ethereal:fly_timer", "-99")
		else
			user:set_attribute("ethereal:fly_timer", "-99")
		end
	end
end


-- after function
local function ethereal_set_flight(user)

	if not user then return end

	local timer, meta

	if is_50 then

		meta = user:get_meta() ; if not meta then return end

		timer = tonumber(meta:get_string("ethereal:fly_timer") or "") or 0
	else
		timer = tonumber(user:get_attribute("ethereal:fly_timer") or "") or 0
	end

	if not timer then return end -- nil check

	-- if timer ran out then remove 'fly' privelage
	if timer <= 0 and timer ~= -99 then

		set_flight(user, nil)

		return
	end

	local name = user:get_player_name()
	local privs = minetest.get_player_privs(name)

	-- have we already applied 'fly' privelage?
	if not privs.fly then
		set_flight(user, true)
	end

	-- handle timer
	timer = timer - timer_check

	-- show expiration message and play sound
	if timer < 10 then

		minetest.chat_send_player(name,
				minetest.get_color_escape_sequence("#ff5500")
				.. S("Flight timer about to expire!"))

		minetest.sound_play("default_dig_dig_immediate",
				{to_player = name, gain = 1.0}, true)
	end

	-- store new timer setting
	if is_50 then
		meta:set_string("ethereal:fly_timer", timer)
	else
		user:set_attribute("ethereal:fly_timer", timer)
	end

	minetest.after(timer_check, function()
		ethereal_set_flight(user)
	end)
end


-- on join / leave
minetest.register_on_joinplayer(function(player)

	if not player then return end

	local timer, meta

	if is_50 then

		meta = player:get_meta() ; if not meta then return end
		timer = meta:get_string("ethereal:fly_timer") or ""
	else
		timer = player:get_attribute("ethereal:fly_timer") or ""
	end

	-- first run to set fly timer if no number found
	if timer == "" then
		ethereal_set_flight(player)
		return
	end

	timer = tonumber(timer) or 0

	if timer == -99 then
		return
	end

	local privs = minetest.get_player_privs(player:get_player_name())

	if privs.fly and timer then

		minetest.after(timer_check, function()
			ethereal_set_flight(player)
		end)
	end
end)


-- potion item
minetest.register_node("ethereal:flight_potion", {
	description = S("Flight Potion"),
	drawtype = "plantlike",
	tiles = {"ethereal_flight_potion.png"},
	inventory_image = "ethereal_flight_potion.png",
	wield_image = "ethereal_flight_potion.png",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	selection_box = {
		type = "fixed",
		fixed = {-0.2, -0.37, -0.2, 0.2, 0.31, 0.2}
	},
	groups = {dig_immediate = 3},
	sounds = default.node_sound_glass_defaults(),

	on_use = function(itemstack, user, pointed_thing)

		-- get privs
		local name = user:get_player_name()
		local privs = minetest.get_player_privs(name)
		local timer, meta

		if is_50 then

			meta = user:get_meta() ; if not meta then return end
			timer = meta:get_string("ethereal:fly_timer") or ""
		else
			timer = user:get_attribute("ethereal:fly_timer") or ""
		end

		if privs.fly then

			local msg = timer

			if timer == "" or timer == "-99" then
				msg = S("unlimited")
			end

			minetest.chat_send_player(name,
				minetest.get_color_escape_sequence("#ffff00")
				.. S("Flight already granted, @1 seconds left!", msg))

			return
		end

		if is_50 then
			meta:set_string("ethereal:fly_timer", flight_secs)
		else
			user:set_attribute("ethereal:fly_timer", flight_secs)
		end

		minetest.chat_send_player(name,
				minetest.get_color_escape_sequence("#1eff00")
				.. S("Flight granted, you have @1 seconds!", flight_secs))

		ethereal_set_flight(user)

		-- take item
		itemstack:take_item()

		-- return empty bottle
		local inv = user:get_inventory()

		if inv:room_for_item("main", {name = "vessels:glass_bottle"}) then
			user:get_inventory():add_item("main", "vessels:glass_bottle")
		else
			minetest.add_item(user:get_pos(), {name = "vessels:glass_bottle"})
		end

		return itemstack
	end
})


-- recipe
minetest.register_craft({
	output = "ethereal:flight_potion",
	recipe = {
		{"ethereal:etherium_dust", "ethereal:etherium_dust", "ethereal:etherium_dust"},
		{"ethereal:etherium_dust", "ethereal:fire_dust", "ethereal:etherium_dust"},
		{"ethereal:etherium_dust", "vessels:glass_bottle", "ethereal:etherium_dust"}
	}
})

local modpath = ...
local climatez = {}
climatez.wind = {}
climatez.climates = {}
climatez.players = {}
climatez.settings = {}

local has_ch_sky = minetest.get_modpath("ch_sky")

--Settings

local settings = Settings(modpath .. "/climatez.conf")

climatez.settings = {
	climate_min_height = tonumber(settings:get("climate_min_height")),
	climate_max_height = tonumber(minetest.settings:get('climate_max_height', true)) or 120,
	climate_change_ratio = tonumber(settings:get("climate_change_ratio")),
	radius = tonumber(settings:get("climate_radius")),
	climate_duration = tonumber(settings:get("climate_duration")),
	duration_random_ratio = tonumber(settings:get("climate_duration_random_ratio")),
	climate_period = tonumber(settings:get("climate_period")),
	climate_rain_sound = settings:get_bool("climate_rain_sound"),
	thunder_sound = settings:get_bool("thunder_sound"),
	storm_chance = tonumber(settings:get("storm_chance")),
	lightning = settings:get_bool("lightning"),
	lightning_chance = tonumber(settings:get("lightning_chance")),
	dust_effect = settings:get_bool("dust_effect"),
	rain_particles = tonumber(settings:get("rain_particles")) or 30,
	rain_falling_speed = tonumber(settings:get("rain_falling_speed")) or 15,
	lightning_duration = tonumber(settings:get("lightning_duration")) or 0.15,
	rain_sound_gain = tonumber(settings:get("rain_sound_gain")) or 0.35,
}

local timer = 0 -- A timer to create climates each x seconds an for lightning too.
local climatez_disabled = false

local get_sky, set_sky
if has_ch_sky then
	get_sky, set_sky = ch_sky.get_sky, ch_sky.set_sky
else
	function get_sky(player)
		return player:get_sky(true)
	end
	function set_sky(player, sky)
		return player:set_sky(sky)
	end
end
local function get_clouds(player)
	return player:get_clouds()
end
local function set_clouds(player, clouds)
	return player:set_clouds(clouds)
end

--Helper Functions

local function remove_table_by_key(tab, key)
	local i = 0
	local keys, values = {},{}
	for k, v in pairs(tab) do
		i = i + 1
		keys[i] = k
		values[i] = v
	end

	while i > 0 do
		if keys[i] == key then
			table.remove(keys, i)
			table.remove(values, i)
			break
		end
		i = i - 1
	end

	local new_tab = {}

	for j = 1, #keys do
		new_tab[keys[j]] = values[j]
	end

	return new_tab
end

local function player_inside_climate(player_pos)
	--This function returns the climate_id if inside and true/false if the climate is enabled or not
	--check altitude
	if (player_pos.y < climatez.settings.climate_min_height) or (player_pos.y > climatez.settings.climate_max_height) then
		return false, nil, nil
	end
	--check if on water
	player_pos.y = player_pos.y + 1
	local node_name = minetest.get_node(player_pos).name
	if minetest.registered_nodes[node_name] and (
		minetest.registered_nodes[node_name]["liquidtype"] == "source" or
		minetest.registered_nodes[node_name]["liquidtype"] == "flowing") then
			return false, nil, true
	end
	player_pos.y = player_pos.y - 1
	--If sphere's centre coordinates is (cx,cy,cz) and its radius is r,
	--then point (x,y,z) is in the sphere if (x−cx)2+(y−cy)2+(z−cz)2<r2.
	for i, _climate in ipairs(climatez.climates) do
		local climate_center = climatez.climates[i].center
		if climatez.settings.radius > math.sqrt((player_pos.x - climate_center.x)^2+
			(player_pos.y - climate_center.y)^2 +
			(player_pos.z - climate_center.z)^2
			) then
				if climatez.climates[i].disabled then
					return i, true, false
				else
					return i, false, false
				end
		end
	end
	return false, false, false
end

local function has_light(minp, maxp)
	local manip = minetest.get_voxel_manip()
	local e1, e2 = manip:read_from_map(minp, maxp)
	local area = VoxelArea:new{MinEdge=e1, MaxEdge=e2}
	local data = manip:get_light_data()
	local node_num = 0
	local light = false

	for i in area:iterp(minp, maxp) do
		node_num = node_num + 1
		if node_num < 5 then
			if data[i] and data[i] == 15 then
				light = true
				break
			end
		else
			node_num = 0
		end
	end

	return light
end

local function is_on_surface(player_pos)
	local height = minetest.get_spawn_level(player_pos.x, player_pos.z)
	--minetest.chat_send_all(tostring(height))
	if not height then
		return false
	end
	if (player_pos.y + 5) >= height then
		return true
	end
end

--DOWNFALLS REGISTRATIONS

climatez.registered_downfalls = {}

local function register_downfall(name, def)
	local new_def = table.copy(def)
	climatez.registered_downfalls[name] = new_def
end

register_downfall("rain", {
	min_pos = {x = -15, y = 20, z = -15},
	max_pos = {x = 15, y = 20, z = 15},
	falling_speed = climatez.settings.rain_falling_speed,
	amount = climatez.settings.rain_particles,
	exptime = 2,
	size = 1.75,
	texture = {"climatez_rain.png", "climatez_rain2.png", "climatez_rain3.png"},
})

register_downfall("storm", {
	min_pos = {x = -15, y = 20, z = -15},
	max_pos = {x = 15, y = 20, z = 15},
	falling_speed = 20,
	amount = 20,
	exptime = 1,
	size = 1.5,
	texture = {"climatez_rain.png", "climatez_rain2.png", "climatez_rain3.png"},
})

register_downfall("snow", {
	min_pos = {x = -15, y = 10, z= -15},
	max_pos = {x = 15, y = 10, z = 15},
	falling_speed = 5,
	amount = 10,
	exptime = 5,
	size = 1,
	texture= {"climatez_snow.png", "climatez_snow2.png", "climatez_snow3.png"},
})

register_downfall("sand", {
	min_pos = {x = -20, y = -4, z = -20},
	max_pos = {x = 20, y = 4, z = 20},
	falling_speed = -1,
	amount = 25,
	exptime = 1,
	size = 4,
	texture = "climatez_sand.png",
})

--WIND STUFF

local function create_wind()
	local wind = {
		x = math.random(0,5),
		y = 0,
		z = math.random(0,5)
	}
	return wind
end

function climatez.get_player_wind(player_name)
	local player = minetest.get_player_by_name(player_name)
	if not player then
		return
	end
	local player_pos = player:get_pos()
	local climate_id = player_inside_climate(player_pos)
	if climate_id then
		return climatez.climates[climate_id].wind
	else
		return create_wind()
	end
end

--LIGHTING

local function show_lightning(player_name)
	local player = minetest.get_player_by_name(player_name)
	if not player then
		return
	end
	local hud_id = player:hud_add({
		hud_elem_type = "image",
		text = "climatez_lightning.png",
		position = {x=0, y=0},
		scale = {x=-100, y=-100},
		alignment = {x=1, y=1},
		offset = {x=0, y=0}
	})
	--save the lightning per player, NOT per climate
	player:get_meta():set_int("climatez:lightning", hud_id)
	if climatez.settings.thunder_sound then
		minetest.sound_play("climatez_thunder", {
			to_player = player_name,
			loop = false,
			gain = 1.0,
		})
	end
end

local function remove_lightning(player_name)
	local player = minetest.get_player_by_name(player_name)
	if not player then
		return
	end
	local meta = player:get_meta()
	local hud_id = meta:get_int("climatez:lightning")
	player:hud_remove(hud_id)
	meta:set_int("climatez:lightning", -1)
end

-- raind sounds

local function start_rain_sound(player_name)
	local rain_sound_handle = minetest.sound_play("climatez_rain", {
		to_player = player_name,
		loop = true,
		gain = climatez.settings.rain_sound_gain
	})
	climatez.players[player_name].rain_sound_handle = rain_sound_handle
end

local function stop_rain_sound(player_name, rain_sound_handle)
	minetest.sound_stop(rain_sound_handle)
	climatez.players[player_name].rain_sound_handle = nil
end


-- CLIMATE PLAYERS FUNCTIONS

local function add_climate_player(player_name, climate_id, downfall_type)

	if climatez_disabled or downfall_type == "sand" then
		return
	end

	local player = minetest.get_player_by_name(player_name)
	climatez.players[player_name] = {
		climate_id = climate_id,
		sky_color = nil,
		clouds_color = nil,
		rain_sound_handle = nil,
		disabled = false,
		hud_id = nil,
		downfall_type = downfall_type,
	}
	local downfall_sky_color, downfall_clouds_color

	if downfall_type == "rain" or downfall_type == "storm" or downfall_type == "snow" then
		downfall_sky_color = "#808080"
		downfall_clouds_color = "#C0C0C0"
	else --"sand"
		downfall_sky_color = "#DEB887"
		downfall_clouds_color = "#DEB887"
	end
	climatez.players[player_name].sky_color = get_sky(player).sky_color or "#8cbafa"
	set_sky(player, {
		sky_color = {
			day_sky = downfall_sky_color,
		}
	})
	climatez.players[player_name].clouds_color = get_clouds(player).color or "#fff0f0e5"
	set_clouds(player, {
		color = downfall_clouds_color,
	})

	if downfall_type == "sand" and climatez.settings.dust_effect then
		climatez.players[player_name].hud_id = player:hud_add({
			hud_elem_type = "image",
			text = "climatez_dust.png",
			position = {x=0, y=0},
			scale = {x=-100, y=-100},
			alignment = {x=1, y=1},
			offset = {x=0, y=0}
		})
	end

	if climatez.settings.climate_rain_sound and (downfall_type == "rain" or downfall_type== "storm")
		and is_on_surface(player:get_pos()) then
			start_rain_sound(player_name)
	end

	--minetest.chat_send_all(player_name.." added to climate "..tostring(climate_id))
end

local function remove_climate_player_effects(player_name)
	local player = minetest.get_player_by_name(player_name)
	if not player then
		return
	end
	set_sky(player, {
		sky_color = {
			day_sky = climatez.players[player_name].sky_color,
		}
	})
	set_clouds(player, {
		color = climatez.players[player_name].clouds_color,
	})

	local downfall_type = climatez.players[player_name].downfall_type

	local rain_sound_handle = climatez.players[player_name].rain_sound_handle
	if rain_sound_handle and climatez.settings.climate_rain_sound
		and (downfall_type == "rain" or downfall_type == "storm") then
			stop_rain_sound(player_name, rain_sound_handle)
	end

	--[[ if downfall_type == "sand" and climatez.settings.dust_effect then
		player:hud_remove(climatez.players[player_name].hud_id)
	end ]]

	local lightning = player:get_meta():get_int("climatez:lightning")
	if downfall_type == "storm" and lightning > 0 then
		remove_lightning(player_name)
	end

end

local function remove_climate_player(player_name)
	remove_climate_player_effects(player_name)
	--remove the player-->
	climatez.players = remove_table_by_key(climatez.players, player_name)
end

local function remove_climate_players(climate_id)
	for _player_name, _climate in pairs(climatez.players) do
		local _climate_id = _climate.climate_id
		if _climate_id == climate_id then
			local _player = minetest.get_player_by_name(_player_name)
			if _player then
				remove_climate_player(_player_name)
				--minetest.chat_send_all(_player_name.." removed from climate")
			end
		end
	end
end

--CLIMATE FUNCTIONS

local function get_id()
	local id
	--search for a free position
	for i= 1, (#climatez.climates+1) do
		if not climatez.climates[i] then
			id = i
			break
		end
	end
	return id
end

local climate = {
	--A disabled climate is a not removed climate,
	--but inactive, so another climate changes are not allowed yet.
	id = nil,
	disabled = false,
	center = {},
	downfall_type = "",
	wind = {},
	timer = 0,
	end_time = 0,

	new = function(self, climate_id, player_name)

		local new_climate = {}

		setmetatable(new_climate, self)

		self.__index = self

		--Get the climate_id
		new_climate.id = climate_id

		--program climate's end
		local climate_duration = climatez.settings.climate_duration
		local climate_duration_random_ratio = climatez.settings.duration_random_ratio
		--minetest.chat_send_all(tostring(climate_id))
		new_climate.end_time = (math.random(climate_duration - (climate_duration*climate_duration_random_ratio),
			climate_duration + (climate_duration*climate_duration_random_ratio)))

		--Get the center of the climate
		local player = minetest.get_player_by_name(player_name)
		new_climate.center = player:get_pos()

		--Get the downfall type

		--Firstly get some biome data
		local biome_data = minetest.get_biome_data(new_climate.center)
		local biome_heat = biome_data.heat
		local biome_humidity = biome_data.humidity

		local downfall_type

		if biome_heat > 28 and biome_humidity >= 35 then
			local chance = math.random(climatez.settings.storm_chance)
			if chance == 1 then
				downfall_type = "storm"
			else
				downfall_type = "rain"
			end
		elseif biome_heat >= 50 and biome_humidity <= 20  then
			downfall_type = "sand"
		elseif biome_heat <= 28 then
			downfall_type = "snow"
		end

		if not downfall_type then
			downfall_type = "rain"
		end

		new_climate.downfall_type = downfall_type

		--minetest.chat_send_all(tostring(biome_heat).. ", "..downfall_type)

		--Get the wind of the climate
		--Create wind
		local wind = create_wind()

		--strong wind if a storm
		if downfall_type == "storm" then
			wind = {
				x = wind.x * 2,
				y = wind.y,
				z = wind.z * 2,
			}
		end

		--very strong wind if a sandstorm
		if downfall_type == "sand" then
			if wind.x < 1 then
				wind.x = 1
				wind.y = 1
			end
			wind = {
				x = wind.x * 5,
				y = wind.y,
				z = wind.z * 5,
			}
		end

		new_climate.wind = wind

		--save the player
		add_climate_player(player_name, new_climate.id, new_climate.downfall_type)

		return new_climate

	end,

	on_timer = function(self)
		--minetest.chat_send_all(tostring(self.timer))
		if not(self.disabled) and self.timer >= self.end_time then
			self:remove() --remove the climate
			self.timer = 0
		elseif self.disabled and self.timer > climatez.settings.climate_period then
			--remove the climate after the period time:
			climatez.climates = remove_table_by_key(climatez.climates, self.id)
			--minetest.chat_send_all("end of period time")
		end
	end,

	remove = function(self)
		--remove the players
		remove_climate_players(self.id)
		--disable the climate, but do not remove it
		self.disabled = true
	end,

	stop = function(self)
		--remove the players
		remove_climate_players(self.id)
		--remove the climate
		climatez.climates = remove_table_by_key(climatez.climates, self.id)
	end,

	apply = function(self, _player_name)

		local _player = minetest.get_player_by_name(_player_name)

		local _player_pos = _player:get_pos()

		local downfall = climatez.registered_downfalls[self.downfall_type]
		local wind_pos = vector.multiply(self.wind, -1)
		local minp = vector.add(vector.add(_player_pos, downfall.min_pos), wind_pos)
		local maxp = vector.add(vector.add(_player_pos, downfall.max_pos), wind_pos)

		--Check if in player in interiors or not
		if not has_light(minp, maxp) then
			return
		end

		local vel = {x = self.wind.x, y = - downfall.falling_speed, z = self.wind.z}
		local acc = {x = 0, y = 0, z = 0}
		local exp = downfall.exptime

		local downfall_texture
		if type(downfall.texture) == "table" then
			downfall_texture = downfall.texture[math.random(#downfall.texture)]
		else
			downfall_texture = downfall.texture
		end

		minetest.add_particlespawner({
			amount = downfall.amount, time=0.5,
			minpos = minp, maxpos = maxp,
			minvel = vel, maxvel = vel,
			minacc = acc, maxacc = acc,
			minexptime = exp, maxexptime = exp,
			minsize = downfall.size, maxsize= downfall.size,
			collisiondetection = true, collision_removal = true,
			vertical = true,
			texture = downfall_texture, playername = _player_name
		})

		--Lightning
		if self.downfall_type == "storm" and climatez.settings.lightning then
			local lightning = _player:get_meta():get_int("climatez:lightning")
			--minetest.chat_send_all(tostring(lightning))
			--minetest.chat_send_all(tonumber(timer))
			if lightning <= 0  then
				local chance = math.random(climatez.settings.lightning_chance)
				if chance == 1 then
					if is_on_surface(_player_pos) then
						show_lightning(_player_name)
						minetest.after(climatez.settings.lightning_duration, remove_lightning, _player_name)
					end
				end
			end
		end

		if climatez.settings.climate_rain_sound
			and (self.downfall_type == "rain" or self.downfall_type == "storm") then
				local rain_sound_handle = climatez.players[_player_name].rain_sound_handle
				if rain_sound_handle and not(is_on_surface(_player_pos)) then
					stop_rain_sound(_player_name, rain_sound_handle)
				elseif not(rain_sound_handle) and is_on_surface(_player_pos) then
					start_rain_sound(_player_name)
				end
		end

		--minetest.chat_send_all("Climate created by ".._player_name)
	end
}

--CLIMATE CORE: GLOBALSTEP

minetest.register_globalstep(function(dtime)
	--Update the climate timers
	for _, _climate in pairs(climatez.climates) do
		_climate.timer = _climate.timer + dtime
		_climate:on_timer()
	end
	timer = timer + dtime
	if timer >= 1 then
		for _, player in ipairs(minetest.get_connected_players()) do
			local player_name = player:get_player_name()
			local player_pos = player:get_pos()
			local climate_id, climate_disabled, on_water = player_inside_climate(player_pos)
			--minetest.chat_send_all(player_name .. " in climate "..tostring(climate_id))
			local _climate = climatez.players[player_name]
			if _climate and on_water then
				remove_climate_player(player_name)
			elseif not(climate_disabled) and _climate then
				local _climate_id = _climate.climate_id --check if player still inside the climate
				if not(_climate_id == climate_id) then --the comparation should be in this order!!!
					remove_climate_player(player_name)
					--minetest.chat_send_all(player_name.." abandoned a climate")
				end
			elseif climate_id and not(climate_disabled) and not(_climate) then --another player enter into the climate
				local downfall_type = climatez.climates[climate_id].downfall_type
				add_climate_player(player_name, climate_id, downfall_type)
				--minetest.chat_send_all(player_name.." entered into the climate")
			elseif not(climate_id) and not(_climate) then --chance to create a climate
				if not climatez_disabled and not climate_disabled then --if not in a disabled climate
					local chance = math.random(climatez.settings.climate_change_ratio)
					if chance == 1 then
						local new_climate_id = get_id()
						climatez.climates[new_climate_id] = climate:new(new_climate_id, player_name)
						--minetest.chat_send_all(player_name.." created a climate id="..new_climate_id)
					end
				end
			end
		end
		timer = 0
	end
	--Apply the climates to the players with climate defined
	for _player_name, _climate in pairs(climatez.players) do
		local player = minetest.get_player_by_name(_player_name)
		if player and _climate then
			if not(_climate.disabled) then
				if climatez.climates[_climate.climate_id] then
					climatez.climates[_climate.climate_id]:apply(_player_name)
				end
			end
		end
	end
end)

--COMMANDS

minetest.register_chatcommand("climatez", {
	privs = {
        server = true,
    },
	description = "Nastavení počasí",
    func = function(name, param)
		local subcommand, player_name
		local i = 0
		for word in string.gmatch(param, "([%a%d_-]+)") do
			if i == 0 then
				subcommand = word
			else
				player_name = word
			end
			i = i + 1
		end
		if not(subcommand == "stop") and not(subcommand == "start") and not(subcommand == "enable") and not(subcommand == "disable") then
			return true, "Chyba: Podpříkazy příkazu climatez jsou 'stop | start'"
		end
		--if subcommand then
			--minetest.chat_send_all("subcommand =".. subcommand)
		--end
		--if player_name then
			--minetest.chat_send_all("player name =".. player_name)
		--end
		if subcommand == "stop" then
			if player_name then --remove the climate only for that player
				local player = minetest.get_player_by_name(player_name)
				if player then
					if climatez.players[player_name] then
						remove_climate_player_effects(player_name)
						climatez.players[player_name].disabled = true
					else
						minetest.chat_send_player(player_name, player_name .. " ".. "nemá žádné počasí.")
					end
				else
					minetest.chat_send_player(name, "Hráč/ka "..player_name.." není online.")
				end
			else
				local player = minetest.get_player_by_name(name)
				if player then
					if climatez.players[name] then
						climatez.climates[climatez.players[name].climate_id]:stop()
					else
						minetest.chat_send_player(name, "Nejste v žádném počasí.")
					end
				end
			end
		elseif subcommand == "start" then
			local player = minetest.get_player_by_name(name)
			if player then
				if climatez.players[name] then
					climatez.climates[climatez.players[name].climate_id]:stop()
				end
					local new_climate_id = get_id()
					climatez.climates[new_climate_id] = climate:new(new_climate_id, name)
			end
		elseif subcommand == "enable" or subcommand == "disable" then
			climatez_disabled = subcommand == "disable"
		end
    end,
})

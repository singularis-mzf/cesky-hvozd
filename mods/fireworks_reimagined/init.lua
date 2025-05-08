--============--
--=== INIT ===--
--============--
local rules = mesecon.rules.pplate
local modpath = minetest.get_modpath("fireworks_reimagined")
fireworks_reimagined = {}
local firework_shapes = {
	{shape = "sphere", description = "Sphere"},
	{shape = "star", description = "Star"},
	{shape = "ring", description = "Ring"},
	{shape = "burst", description = "Burst"},
	{shape = "cube", description = "Cube"},
	{shape = "spiral", description = "Spiral"},
	{shape = "chaotic", description = "Chaotic"},
	{shape = "flame", description = "Flame"},
	{shape = "snowflake", description = "Snowflake"},
	{shape = "present", description = "Present"},
	{shape = "christmas_tree", description = "Christmas Tree"},
	{shape = "hour_glass", description = "Hour Glass"},
}

local function random_color()
    local r, g, b
    repeat
        r = math.random(0, 255)
        g = math.random(0, 255)
        b = math.random(0, 255)
    until r > 250 or g > 250 or b > 250  -- Ensure at least one value is above 190
    return string.format("#%02X%02X%02X", r, g, b)
end

local function random_explosion_colors()
    local color1 = random_color()
    local color2 = random_color()
    if math.random(2) == 1 then
        return {color1}
    else
        return {color1, color2}
    end
end


--===========--
--=== API ===--
--===========--

--=== Individual particles ===--

function fireworks_reimagined.spawn_firework_explosion_ip(pos, shape, double, color_def, color_def_2, alpha, texture, psize)
	local explosion_colors = random_explosion_colors()
	local radius = math.random(4, 7)
	local size
	local color
	local colored_texture
	if psize then
		size = psize
	else
		size = math.random(2, 4)
	end
	local glow = math.random(12, 15)
	local function spawn_colored_particle(velocity)
		if not color_def then
			color = explosion_colors[math.random(#explosion_colors)]
		elseif color_def and color_def_2 then
			if math.random(2) == 1 then
				color = color_def
			else
				color = color_def_2
			end
		else
			color = color_def
		end
		if not alpha then
			alpha = 128
		end
		if texture then
			colored_texture = texture.."^[colorize:" .. color .. ":" .. alpha
		else
			colored_texture = "black.png^[colorize:" .. color .. ":" .. alpha
		end
		local random_speed = math.random() + 0.5
		local particle_properties = {
			pos = pos,
			velocity = velocity,
			acceleration = {x=0, y=-10, z=0},
			expirationtime = 2.5,
			size = size,
			texture = {
				name = colored_texture,
				scale_tween = {
					style = "fwd",
					reps = 1,
					1.0,
					0.0,
					-0.1
				},
			},
			glow = glow,
			collisiondetection = true,
			collision_removal = true,
		}
		minetest.add_particle(particle_properties)
		minetest.after(0.3, function()
			local breaking_velocity = {
				x = velocity.x + math.random(-2, 2),
				y = velocity.y - 4,
				z = velocity.z + math.random(-2, 2)
			}
			local breaking_particle_properties = {
				pos = pos,
				velocity = breaking_velocity,
				acceleration = {x = 0, y = -10, z = 0},
				expirationtime = 2.2,
				size = size,
				texture = {
					name = colored_texture,
					scale_tween = {
						style = "fwd",
						reps = 1,
						1.0,
						0.0,
						-0.1
					},
				},
				glow = glow,
				collisiondetection = true,
				collision_removal = true,
			}
			minetest.add_particle(breaking_particle_properties)
			if double == true then
				minetest.add_particle(breaking_particle_properties)
			end
		end)
	end
	

	if shape == "sphere" then
		for i = 1, 360, 15 do
			for j = -90, 90, 15 do
				local theta = math.rad(i)
				local phi = math.rad(j)
				local x = math.cos(phi) * math.cos(theta) * radius
				local y = math.sin(phi) * radius
				local z = math.cos(phi) * math.sin(theta) * radius
				spawn_colored_particle({x = x, y = y, z = z})
			end
		end
	elseif shape == "star" then
		local star_points = {
			{x = radius, y = 0, z = 0},
			{x = -radius, y = 0, z = 0},
			{x = 0, y = radius, z = 0},
			{x = 0, y = -radius, z = 0},
			{x = 0, y = 0, z = radius},
			{x = 0, y = 0, z = -radius},
		}
		for _, point in ipairs(star_points) do
			spawn_colored_particle(point)
		end
	elseif shape == "ring" then
		for i = 1, 360, 15 do
			local theta = math.rad(i)
			local x = math.cos(theta) * radius
			local z = math.sin(theta) * radius
			local y = 0
			spawn_colored_particle({x = x, y = y, z = z})
		end
	elseif shape == "christmas_tree" then
		local height = 10
		local base_radius = 4
		for i = 1, height do
			local current_radius = base_radius * (1 - i / height)
			for j = 1, 360, 30 do
				local theta = math.rad(j)
				local x = math.cos(theta) * current_radius
				local z = math.sin(theta) * current_radius
				spawn_colored_particle({x = x, y = i, z = z})
			end
		end
	elseif shape == "present" then
		for x = -radius, radius, radius do
			for y = -radius, radius, radius do
				for z = -radius, radius, radius do
					spawn_colored_particle({x = x, y = y, z = z})
				end
			end
		end
		for i = 1, 360, 30 do
			local theta = math.rad(i)
			local x = math.cos(theta) * (radius / 2)
			local z = math.sin(theta) * (radius / 2)
			local y = radius
			spawn_colored_particle({x = x, y = y, z = z})
		end
	elseif shape == "snowflake" then
		local arms = 6
		for i = 1, arms do
			local angle = (2 * math.pi / arms) * i
			local x = math.cos(angle) * radius
			local z = math.sin(angle) * radius
			for j = 1, radius do
				spawn_colored_particle({x = x * (j / radius), y = 0, z = z * (j / radius)})
			end
		end
	elseif shape == "spiral" then
		local spiral_height = 3
		local spiral_turns = 20
		local rotation_speed = 0.1
		local radius_start = 7
		local radius_end = 7

		for i = 1, 360 * spiral_turns, 15 do
			local angle = math.rad(i)
			local y = (i / 360) * spiral_height

			local radius = radius_start + ((radius_end - radius_start) * (y / spiral_height))

			local rotation_angle = angle * rotation_speed

			local x = math.cos(rotation_angle) * radius
			local z = math.sin(rotation_angle) * radius

			spawn_colored_particle({x = x, y = y, z = z})
		end
	elseif shape == "hour_glass" then
		local num_turns = 10
		for i = 1, 360 * num_turns, 15 do
			local theta = math.rad(i)
			local y = (i / 360) * num_turns
			local radius = 10 - (y / 2)
			local x = math.cos(theta) * radius
			local z = math.sin(theta) * radius
			spawn_colored_particle({x = x, y = y, z = z})
		end
	elseif shape == "chaotic" then
		local num_particles = 150
		for i = 1, num_particles do
			local x = (math.random() - 0.5) * 2 * radius
			local y = (math.random() - 0.5) * 2 * radius
			local z = (math.random() - 0.5) * 2 * radius
			local rs = math.random() + 0.5
			local random_velocity = {x = x + math.random(-3, 3) * rs, y = y + math.random(-3, 3) * rs, z = z + math.random(-3, 3) * rs}
			spawn_colored_particle(random_velocity)
		end
	elseif shape == "cube" then
		for x = -radius, radius, radius do
			for y = -radius, radius, radius do
				for z = -radius, radius, radius do
					spawn_colored_particle({x = x, y = y, z = z})
				end
			end
		end
	elseif shape == "flame" then
		local flame_height = 10
		local base_radius = 3
		for i = 1, 100 do
			local theta = math.rad(math.random(360))
			local r = math.random() * base_radius
			local x = math.cos(theta) * r
			local z = math.sin(theta) * r
			local y = math.random() * flame_height
			spawn_colored_particle({x = x, y = y, z = z})
		end
	elseif shape == "burst" then
		for i = 1, 100 do
			local x = (math.random() - 0.5) * 2 * radius
			local y = (math.random() - 0.5) * 2 * radius
			local z = (math.random() - 0.5) * 2 * radius
			spawn_colored_particle({x = x, y = y, z = z})
		end
	end
end

function fireworks_reimagined.spawn_firework_explosion(pos, color_def, color_def_2, alpha, texture, psize)
	local explosion_colors = random_explosion_colors()
	local radius = math.random(5, 8)
	local mnpsize = psize or 1.5
	local mxpsize = psize or 4
	local glow = math.random(10, 15)
	local color = color_def or explosion_colors[math.random(#explosion_colors)]
	color_def_2 = color_def_2 or explosion_colors[math.random(#explosion_colors)]
	alpha = alpha or 128

	local chosen_color
	if math.random(1, 2) == 1 then
		chosen_color = color
	else
		chosen_color = color_def_2
	end

	local x = (math.random() - 0.5) * 2 * radius
	local y = (math.random() - 0.5) * 2 * radius
	local z = (math.random() - 0.5) * 2 * radius
	local rs = math.random() + 0.5
	local random_velocity = {x = x + math.random(-3, 3) * rs, y = y + math.random(-3, 3) * rs, z = z + math.random(-3, 3) * rs}
	local tex = texture or "black.png"

	local particle_params = {
		amount = 600,
		time = 0.6,
		minpos = pos,
		maxpos = pos,
		minexptime = 1.6,
		maxexptime = 4.0,

		radius = {min = -12.0, max = 9.0, bias = 0},

		minsize = mnpsize * 0.8,
		maxsize = mxpsize * 1.3,

		minvel = {x = -math.random(2,3), y=4, z= -math.random(3, 5)},
		maxvel = {x = math.random(5,6), y=6, z=math.random(6, 7)},
		acc = {x=0, y= -6, z=0},
		glow = glow,

		collisiondetection = true,
		collision_removal = true,
		drag = vector.new(0, -0.8, 0),

		particlespawner_tweenable = true,
		texpool = {
			{
				name = tex .. "^[colorize:" .. color .. ":" .. alpha,
				scale_tween = {
					style = "fwd",
					reps = 1,
					1.0,
					0.0,
					-0.1
				},
			},
			{
				name = tex .. "^[colorize:" .. color_def_2 .. ":" .. alpha,
				scale_tween = {
					style = "fwd",
					reps = 1,
					1.0,
					0.0,
					-0.1
				},
			}
		},
	}

	minetest.add_particlespawner(particle_params)
end

function fireworks_reimagined.register_firework_explosion(pos, delay, color_grid, depth_layers, texture, batch_size, log)
	local grid_width = #color_grid[1]
	local grid_height = #color_grid
	local size_multiplier = 1.6
	local particle_lifetime = 2.5 - delay
	local radius = 1.2
	local b_size = batch_size or 10
	local color_particles = {}
	for z = 0, depth_layers do
		for y = 1, grid_height do
			for x = 1, grid_width do
				local color = color_grid[y][x]
				if color ~= "#000000" then
					color_particles[color] = color_particles[color] or {}
					local particle_pos = vector.add(pos, vector.new(
						(x - (grid_width / 2)) * size_multiplier,
						(y - (grid_height / 2)) * size_multiplier,
						(z - (depth_layers / 2)) * size_multiplier
					))
					table.insert(color_particles[color], particle_pos)
				end
			end
		end
	end
	local total_spawners = 0
	for color, positions in pairs(color_particles) do
		local colored_texture = texture and (texture .. "^[colorize:" .. color) or ("black.png^[colorize:" .. color)
		for i = 1, #positions, b_size do
			local batch_positions = {}
			for j = i, math.min(i + b_size - 1, #positions) do
				table.insert(batch_positions, positions[j])
			end
			local world_minpos = vector.new(1e10, 1e10, 1e10)
			local world_maxpos = vector.new(-1e10, -1e10, -1e10)
			for _, pos in ipairs(batch_positions) do
				world_minpos = vector.new(
					math.min(world_minpos.x, pos.x),
					math.min(world_minpos.y, pos.y),
					math.min(world_minpos.z, pos.z)
				)
				world_maxpos = vector.new(
					math.max(world_maxpos.x, pos.x),
					math.max(world_maxpos.y, pos.y),
					math.max(world_maxpos.z, pos.z)
				)
			end
			minetest.add_particlespawner({
				amount = #batch_positions,
				time = delay,
				minpos = world_minpos,
				maxpos = world_maxpos,
				minvel = {x = -radius*3, y = 0, z = -radius*3},
				maxvel = {x = radius*3, y = 2, z = radius*3},
				minvel = {x = math.random(-4,-5), y=0, z=math.random(-6, -7)},
				maxvel = {x = math.random(4,5), y=2, z=math.random(6, 7)},
				acc = {x=0, y=-6, z=0},
				minexptime = delay,
				maxexptime = particle_lifetime,
				minsize = 1.2,
				maxsize = 2.0,
				collisiondetection = true,
				collision_removal = true,
				vertical = false,
				glow = math.random(12, 15),
				drag = -0.6,
				texture = {
					name = colored_texture,
					scale = {x = 1, y = 1},
					scale_tween = {{x = 1, y = 1}, {x = 1.5, y = 1.5}, {x = 0, y = 0}},
				}
			})
			total_spawners = total_spawners + 1
		end
	end
	if log == true then
		minetest.log("warning", "Total particle spawners used: " .. total_spawners)
	end
end

local last_rightclick_time = {}
local last_mesecons_time = {}

function fireworks_reimagined.register_firework_node(tiles, shape, entity, cooldown, mese_cooldown, ip)
	minetest.register_alias("fireworks_reimagined:firework_" .. shape .. "_0", "fireworks_reimagined:firework_" .. shape)
	minetest.register_alias("fireworks_reimagined:firework_" .. shape .. "_10", "fireworks_reimagined:firework_" .. shape)
	minetest.register_node(":fireworks_reimagined:firework_" .. shape, {
		description = "Firework (" .. shape .. ")",
		tiles = { tiles or "fireworks_" .. shape .. ".png" },
		groups = { cracky = 1, oddly_breakable_by_hand = 1 },
		paramtype = "light",
		light_source = 5,
		on_construct = function(pos)
			local meta = minetest.get_meta(pos)
			meta:set_string("allow_others", "false")
			meta:set_string("c1", "#FFFFFF")
			meta:set_string("c2", "#FF0000")
			local inv = meta:get_inventory()
			inv:set_size("fuse", 1)
			inv:set_size("firework_rocket", 25)
		end,
		after_place_node = function(pos, placer)
			local meta = minetest.get_meta(pos)
			local placer_name = placer:get_player_name()
			meta:set_string("owner", placer_name)
		end,
		on_punch = function(pos, node, clicker)
			local wielded_item = clicker:get_wielded_item():get_name()
			if wielded_item == "" then
				local meta = minetest.get_meta(pos)
				local owner = meta:get_string("owner")
				local player_name = clicker:get_player_name()
				local privs = minetest.get_player_privs(player_name)
				local is_owner = player_name == owner or privs.fireworks_master
				local inv = meta:get_inventory()
				if inv:is_empty("fuse") then
					inv:set_size("fuse", 1)
				end
				if inv:is_empty("firework_rockets") then
					inv:set_size("firework_rockets", 25)
				end
				local spos = pos.x .. "," .. pos.y .. "," .. pos.z
				if is_owner and not privs.fireworks_admin then
					local formspec = "size[11,9.5]" ..
					"label[2.5,0.0;Firework Settings]" ..
					"checkbox[0.5,1.5;allow_others;Allow others to launch;" .. meta:get_string("allow_others") .. "]" ..
					"list[nodemeta:" .. spos .. ";fuse;8,2;1,1;]" ..
					"field[0.5,3.0;7.5,0.5;cone;First Fireworks Color;" .. meta:get_string("c1") .. "]" ..
					"field[0.5,4.5;7.5,0.5;ctwo;Second Fireworks Color;" .. meta:get_string("c2") .. "]" ..
					"list[current_player;main;0,4.85;8,4;]" ..
					"button_exit[8,3.5;3,1;save;Save]" ..
					"listring[nodemeta:" .. spos .. ";fuse]" ..
					"listring[current_player;main]" ..
					default.get_hotbar_bg(0, 4.85)
					minetest.show_formspec(player_name, "fireworks_reimagined:settings_" .. minetest.pos_to_string(pos), formspec)
				elseif privs.fireworks_admin then
					local formspec = "size[10,12]" ..
					"label[2.5,0.0;Firework Settings]" ..
					"checkbox[0.5,1.5;allow_others;Allow others to launch;" .. meta:get_string("allow_others") .. "]" ..
					"field[0.5,1.5;7.5,0.5;delay;Launch Delay (seconds);" .. meta:get_int("delay") .. "]" ..
					"field[0.5,3.0;7.5,0.5;cone;First Fireworks Color;" .. meta:get_string("c1") .. "]" ..
					"field[0.5,4.5;7.5,0.5;ctwo;Second Fireworks Color;" .. meta:get_string("c2") .. "]" ..
					"button_exit[2.5,5.5;3,1;save;Save]"
					minetest.show_formspec(player_name, "fireworks_reimagined:settings_" .. minetest.pos_to_string(pos), formspec)
				end
			else
				return false
			end
		end,
		on_rightclick = function(pos, node, clicker)
			local meta = minetest.get_meta(pos)
			local owner = meta:get_string("owner")
			local player_name = clicker:get_player_name()
			local privs = minetest.get_player_privs(player_name)
			local is_owner = player_name == owner or privs.fireworks_master or privs.fireworks_admin
			local pos_hash = minetest.hash_node_position(pos)
			local allow_others = meta:get_string("allow_others") == "true"
			local is_allowed = is_owner or allow_others or privs.fireworks_master or privs.fireworks_admin
			local current_time = minetest.get_gametime()
			local cd = cooldown or 3
			local c1 = meta:get_string("c1")
			local c2 = meta:get_string("c2")

			if meta:get_string("owner") == "" then
				meta:set_string("owner", player_name)
			end

			local inv = meta:get_inventory()
			if inv:is_empty("fuse") then
				inv:set_size("fuse", 1)
			end
			local fuse_stack = inv:get_stack("fuse", 1)
			local fuse_count = fuse_stack:get_count()
			local delay
			if not privs.fireworks_admin then
				delay = fuse_count
			elseif privs.fireworks_admin then
				delay = meta:get_int("delay")
			end

			if is_allowed and (not last_rightclick_time[pos_hash] or current_time - last_rightclick_time[pos_hash] >= cd) then
				last_rightclick_time[pos_hash] = current_time
				inv:set_stack("fuse", 1, nil)
				minetest.after(delay, function()
					local firework_entity = minetest.add_entity(pos, entity or "fireworks_reimagined:firework_entity")
					if firework_entity then
						if ip ~= (nil or false) then
							firework_entity:get_luaentity().ip = true
						end
						firework_entity:get_luaentity().firework_shape = shape
						firework_entity:get_luaentity().color1 = c1
						firework_entity:get_luaentity().color2 = c2
						minetest.sound_play("fireworks_launch", {
							pos = pos,
							max_hear_distance = 40,
							gain = 4.0
						})
					end
				end)
			elseif not is_allowed then
				minetest.chat_send_player(player_name, "You don't have permission to launch this firework.")
			elseif privs.fireworks_master or privs.fireworks_admin then
				minetest.after(delay, function()
					local firework_entity = minetest.add_entity(pos, entity or "fireworks_reimagined:firework_entity")
					if firework_entity then
						if ip ~= (nil or false) then
							firework_entity:get_luaentity().ip = true
						end
						firework_entity:get_luaentity().firework_shape = shape
						firework_entity:get_luaentity().color1 = c1
						firework_entity:get_luaentity().color2 = c2
						minetest.sound_play("fireworks_launch", {
							pos = pos,
							max_hear_distance = 40,
							gain = 4.0
						})
						inv:set_stack("fuse", 1, nil)
					end
				end)
			else
				minetest.chat_send_player(player_name, "Please wait before launching another firework!")
			end
		end,
		mesecons = { effector = {
			rules = rules,
			action_on = function(pos, node)
				local pos_hash = minetest.hash_node_position(pos)
				local current_time = minetest.get_gametime()
				local meta = minetest.get_meta(pos)
				local c1 = meta:get_string("c1")
				local c2 = meta:get_string("c2")
				local mcd = mese_cooldown or 4
				if not last_mesecons_time[pos_hash] or current_time - last_mesecons_time[pos_hash] >= mcd then
					last_mesecons_time[pos_hash] = current_time
					local firework_entity = minetest.add_entity(pos, entity or "fireworks_reimagined:firework_entity")
					if firework_entity then
						if ip ~= (nil or false) then
							firework_entity:get_luaentity().ip = true
						end
						firework_entity:get_luaentity().firework_shape = shape
						firework_entity:get_luaentity().color1 = c1
						firework_entity:get_luaentity().color2 = c2
						minetest.sound_play("fireworks_launch", {
							pos = pos,
							max_hear_distance = 40,
							gain = 4.0
						})
					end
				end
			end,
		}},
		on_metadata_inventory_put = function(pos, listname, index, stack, player)
			if listname == "fuse" and stack:get_name() == "fireworks_reimagined:fuse" then
				local meta = minetest.get_meta(pos)
				local inv = meta:get_inventory()
				local fuse_stack = inv:get_stack("fuse", 1)
				if fuse_stack:get_count() > 15 then
					fuse_stack:set_count(15)
					inv:set_stack("fuse", 1, fuse_stack)
				end
			end
		end,
		allow_metadata_inventory_put = function(pos, listname, index, stack, player)
			if listname == "fuse" and stack:get_name() == "fireworks_reimagined:fuse" then
				return math.min(stack:get_count(), 15)
			elseif listname == "extras" and minetest.get_item_group(stack:get_name(), "firework_rocket") > 0 then
				return 1
			end
			return 0
		end,
	})
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	local pos = minetest.string_to_pos(formname:match("fireworks_reimagined:settings_(.*)"))
	if pos and player then
		local meta = minetest.get_meta(pos)
		local player_name = player:get_player_name()
		local privs = minetest.get_player_privs(player_name)
		local is_owner = player_name == meta:get_string("owner") or privs.fireworks_master
		if is_owner then
			if fields.delay and tonumber(fields.delay) then
				meta:set_int("delay", tonumber(fields.delay))
			end
			if fields.cone and fields.cone then
				meta:set_string("c1", fields.cone)
			end
			if fields.ctwo then
				meta:set_string("c2", fields.ctwo)
			end
			if fields.allow_others then
				meta:set_string("allow_others", fields.allow_others)
			else
				local current_allow_others = meta:get_string("allow_others")
				meta:set_string("allow_others", current_allow_others ~= "" and current_allow_others or "false")
			end
		end
	end
end)


local registered_fireworks = {}
function fireworks_reimagined.register_firework_entity(name, def)
	local entity_def = {
		initial_properties = {
			fireworks    = true,
			textures = {"fireworks_rocket_white.png"},
			glow = 10,
			collisionbox = {-0.25,-0.25,-0.25,0.25,0.25,0.25},
			physical     = true,
			collide_with_objects = false,
			velocity = 0,
		},
		yaw = 0,
		acceleration = 5,
		static_save = false,
		firework_shape = def.firework_shape or "sphere",
		time_remaining = def.time_remaining or 3,
		spiral = def.spiral or false,
		spiral_force = def.spiral_force or 100,
		spiral_radius = def.spiral_radius or 0.1,
		thrust = def.thrust or 10,
		color1 = nil,
		color2 = nil ,
		------------BY NIWLA23--MIT LICENSE------------
		on_activate = function(self, staticdata, dtime_s)
			if def.on_activate ~= nil then
				def.on_activate(self, staticdata, dtime_s)
			end
			self.object:set_armor_groups({immortal = 1})
			minetest.sound_play(self.launch_noise, {
				max_hear_distance = 100,
				gain = 10.0,
				object = self.object,
			})
			if self.spiral == true and self.spiral_force > 0 then
				self.velocity = self.spiral_force
				self.spiraling = true
				self.time_remaining = self.time_remaining * 2
			else
				self.velocity = 0
			end	
		end,
		collision = function(self)
			local pos = self.object:get_pos()
			local vel = self.object:get_velocity()
			local x   = 0
			local z   = 0
			for _,object in ipairs(minetest.get_objects_inside_radius(pos, 1)) do
				if object:is_player() or (object:get_luaentity() and object:get_luaentity().mob == true and object ~= self.object) then
					local pos2 = object:get_pos()
					local vec  = {x=pos.x-pos2.x, z=pos.z-pos2.z}
					local force = (1) - vector.distance({x=pos.x,y=0,z=pos.z}, {x=pos2.x,y=0,z=pos2.z})
					x = x + (vec.x * force) * 20
					z = z + (vec.z * force) * 20
				end
			end
			return({x,z})
		end,
		movement = function(self)
			if self.spiraling == true then
				self.yaw = self.yaw + self.spiral_radius
				if self.yaw > math.pi*2 then
					self.yaw = self.yaw - (math.pi*2)
				end
			end		
			local collide_values = self.collision(self)
			local c_x = collide_values[1]
			local c_z = collide_values[2]
			local vel = self.object:get_velocity()
			local x   = math.sin(self.yaw) * -self.velocity
			local z   = math.cos(self.yaw) *  self.velocity
			local gravity = -10
			if self.thrust > 0 then
				gravity = self.thrust
			end
			if self.spiral == true then
				if gravity == -10 then
					self.object:set_acceleration({x=(x - vel.x + c_x)*self.acceleration,y=-10,z=(z - vel.z + c_z)*self.acceleration})				
				else
					self.object:set_acceleration({x=(x - vel.x + c_x)*self.acceleration,y=(gravity-vel.y)*self.acceleration,z=(z - vel.z + c_z)*self.acceleration})
				end
			else
				self.object:set_velocity({x=0, y=20, z=0})
			end
		end,
		------------------------------------------------
		on_step = function(self, dtime)
			local pos = self.object:get_pos()
			if not pos then return end
			self.movement(self)
			pos.y = pos.y + (self.initial_properties.velocity * dtime)
			self.time_remaining = self.time_remaining - dtime
			if self.time_remaining <= 0 then
				def.firework_explosion(pos, self.color1, self.color2)
				self.object:remove()
				minetest.sound_play("fireworks_explosion", {
					pos = pos,
					max_hear_distance = 150,
					gain = 20.0
				})
			end
		end,
	}
	minetest.register_entity(":"..name, entity_def)
	registered_fireworks[name] = entity_def
end

--==================--
--=== LOCAL FUNC ===--
--==================--

local function spawn_firework_entity(pos, firework_shape)
	local obj = minetest.add_entity(pos, "fireworks_reimagined:firework_entity")
	if obj then
		obj:get_luaentity().firework_shape = firework_shape
	end
end

local function spawn_random_firework(pos)
	local shapes = {"sphere", "star", "ring", "burst", "cube", "spiral", "chaotic", "flame", "snowflake", "present", "christmas_tree"}
	local random_shape = shapes[math.random(#shapes)]
	spawn_firework_entity(pos, random_shape)
end

--==================--
--=== REGISTRIES ===--
--==================--

minetest.register_entity("fireworks_reimagined:firework_entity", {
	initial_properties = {
		physical = true,
		collide_with_objects = false,
		visual = "sprite",
		textures = {"fireworks_rocket_white.png"},
		velocity = 0.5,
		glow = 5,
	},
	firework_shape = "sphere",
	time_remaining = 2,
	ip = false,
	static_save = false,
	on_step = function(self, dtime)
		local pos = self.object:get_pos()
		if not pos then return end
		pos.y = pos.y + (self.initial_properties.velocity * dtime)
		self.object:set_velocity({x = 0, y = 20, z = 0})
		self.time_remaining = self.time_remaining - dtime
		if self.time_remaining <= 0 then
			if self.ip == true then
				fireworks_reimagined.spawn_firework_explosion_ip(pos, self.firework_shape or "chaotic", false, nil, nil, nil, nil, nil)
			else
				fireworks_reimagined.spawn_firework_explosion(pos, nil, nil, nil, nil, nil)
			end
			self.object:remove()
			minetest.sound_play("fireworks_explosion", {
				pos = pos,
				max_hear_distance = 60,
				gain = 20.0
			})
		end
	end,
})

local usage_limit = 3
local cooldown_time = 4
local user_usage = {}

minetest.register_craftitem("fireworks_reimagined:firework_item", {
	description = "Firework (Random)",
	inventory_image = "fireworks_item.png",
	on_use = function(itemstack, user, pointed_thing)
		local player_name = user:get_player_name()
		local current_time = minetest.get_gametime()
		
		local privs = minetest.get_player_privs(player_name)
		if privs.fireworks_master or privs.fireworks_admin then
			local pos = user:get_pos()
			pos.y = pos.y + 1.5
			spawn_random_firework(pos)
			itemstack:take_item()
			return itemstack
		end
		if not user_usage[player_name] then
			user_usage[player_name] = {
				uses = 0,
				last_used = 0,
			}
		end

		local usage_data = user_usage[player_name]
		if current_time - usage_data.last_used >= cooldown_time then
			usage_data.uses = 0
			usage_data.last_used = current_time
		end
		if usage_data.uses < usage_limit then
			local pos = user:get_pos()
			pos.y = pos.y + 1.5
			spawn_random_firework(pos)
			itemstack:take_item()
			usage_data.uses = usage_data.uses + 1
			return itemstack
		else
			minetest.chat_send_player(player_name, "You can only use this item 3 times every 4 seconds.")
			return itemstack
		end
	end,
})

minetest.register_privilege("fireworks_master", {
	description = ("Allows the player with this priv to not be affected by the user cooldown on fireworks."),
	give_to_singleplayer = false,
})

minetest.register_privilege("fireworks_admin", {
	description = ("Administrator priv for fireworks."),
	give_to_singleplayer = false,
})

minetest.register_on_leaveplayer(function(player)
	local player_name = player:get_player_name()
	user_usage[player_name] = nil
end)

minetest.register_craftitem("fireworks_reimagined:fuse", {
	description = ("Fuse"),
	inventory_image = "farming_string.png^[multiply:#343434",
	groups = {flammable = 1},
})

minetest.register_craft({
	output = "fireworks_reimagined:fuse 9",
	recipe = {
		{"farming:string", "farming:string", "farming:string"},
		{"farming:string", "default:coal_lump", "farming:string"},
		{"farming:string", "farming:string", "farming:string"},
	}
})

dofile(modpath.."/crafting.lua")
dofile(modpath.."/colored.lua")
dofile(modpath.."/images.lua")
dofile(modpath.."/default.lua")
dofile(modpath.."/test.lua")

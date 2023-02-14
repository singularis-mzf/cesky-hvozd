local look_yaw = {
	[0] = math.pi,
	[1] = math.pi / 2,
	[2] = 0,
	[3] = -math.pi / 2,
}
local bed_to_kind = {}

function emote.bed_onrightclick(pos, node, clicker, itemstack, pointed_thing)
	if clicker and clicker:is_player() then
		local player_name = clicker:get_player_name()
		local velocity = vector.length(clicker:get_velocity())
		local distance = vector.distance(pos, clicker:get_pos())
		local bed_kind = bed_to_kind[node.name]

		if velocity > 0.001 or distance > 2.0 then
			minetest.log("action", "Player "..player_name.." tried to go to bed, but: velocity = "..velocity..", distance = "..distance..".")
			return nil
		elseif bed_kind == nil then
			minetest.log("error", "Bed "..node.name.." of unknown kind used at "..minetest.pos_to_string(pos).."!")
			return nil
		end
		-- clicker:set_eye_offset(vector.new(0, -13, 0), vector.new(0, 0, 0))
		-- clicker:set_physics_override({speed = 0, jump = 0, gravity = 0})

		local x_coef, z_coef = 0.5, 0.5
		local y_shift = 0.5
		local facedir = node.param2 % 4
		if bed_kind == "simple_bed" then
			y_shift = 0.0625
		elseif bed_kind == "fancy_bed" then
			y_shift = -0.05
		elseif bed_kind == "asciugamano" then
			y_shift = -0.49
			x_coef, z_coef = 0.0, 0.0
			facedir = (facedir + 3) % 4
		else
			y_shift = 0.5
		end

		local dir = minetest.facedir_to_dir(facedir)
		clicker:set_look_horizontal(look_yaw[facedir])
		clicker:set_look_vertical(-0.9 * math.pi)
		clicker:set_pos(vector.new(pos.x + x_coef * dir.x, pos.y + y_shift, pos.z + z_coef * dir.z))

		minetest.after(0.5, function()
			local player = minetest.get_player_by_name(player_name)
			if player then
				emote.start(player, "lehni")
			end
		end)
	end
	return nil
end

function emote.register_bed(name, kind)
	local ndef = minetest.registered_nodes[name]
	if ndef ~= nil then
		minetest.override_item(name, {on_rightclick = emote.bed_onrightclick})
		if kind == nil then
		local ndef = minetest.registered_nodes[node.name]
		local cbox = ndef and ndef.collision_box
		local y_shift = 0.5
		if cbox and cbox.type == "fixed" and cbox.fixed then
			y_shift = cbox.fixed[5]
		end
		end
		bed_to_kind[name] = kind
	else
		minetest.log("warning", "Bed node "..name.." not found!")
	end
end

emote.register_bed("beds:bed", "simple_bed")
emote.register_bed("beds:fancy_bed", "fancy_bed")

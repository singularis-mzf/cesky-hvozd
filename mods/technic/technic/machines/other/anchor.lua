local S = technic.getter

local desc = S("Administrative World Anchor")

local function compute_forceload_positions(pos, meta)
	local radius = meta:get_int("radius")
	local minpos = vector.subtract(pos, vector.new(radius, radius, radius))
	local maxpos = vector.add(pos, vector.new(radius, radius, radius))
	local minbpos = {}
	local maxbpos = {}
	for _, coord in ipairs({"x","y","z"}) do
		minbpos[coord] = math.floor(minpos[coord] / 16) * 16
		maxbpos[coord] = math.floor(maxpos[coord] / 16) * 16
	end
	local flposes = {}
	for x = minbpos.x, maxbpos.x, 16 do
		for y = minbpos.y, maxbpos.y, 16 do
			for z = minbpos.z, maxbpos.z, 16 do
				table.insert(flposes, vector.new(x, y, z))
			end
		end
	end
	return flposes
end

local function currently_forceloaded_positions(meta)
	local ser = meta:get_string("forceloaded")
	return ser == "" and {} or minetest.deserialize(ser)
end

local function forceload_off(meta)
	local flposes = currently_forceloaded_positions(meta)
	meta:set_string("forceloaded", "")
	for _, p in ipairs(flposes) do
		minetest.forceload_free_block(p)
	end
end

local function forceload_on(pos, meta)
	local want_flposes = compute_forceload_positions(pos, meta)
	local have_flposes = {}
	for _, p in ipairs(want_flposes) do
		if minetest.forceload_block(p) then
			table.insert(have_flposes, p)
		end
	end
	meta:set_string("forceloaded", #have_flposes == 0 and "" or minetest.serialize(have_flposes))
end

local function set_display(pos, meta)
	meta:set_string("infotext", S(meta:get_int("enabled") ~= 0 and "@1 Enabled" or "@1 Disabled", desc))
	meta:set_string("formspec",
		"size[5,3.5]"..
		"item_image[0,0;1,1;technic:admin_anchor]"..
		"label[1,0;"..minetest.formspec_escape(desc).."]"..
		"label[0,1;"..minetest.formspec_escape(S("Owner:").." "..meta:get_string("owner")).."]"..
		(meta:get_int("locked") == 0 and
			"button[3,1;2,1;lock;"..minetest.formspec_escape(S("Unlocked")).."]" or
			"button[3,1;2,1;unlock;"..minetest.formspec_escape(S("Locked")).."]")..
		"field[0.25,2.3;1,1;radius;"..minetest.formspec_escape(S("Radius:"))..";"..meta:get_int("radius").."]"..
		(meta:get_int("enabled") == 0 and
			"button[3,2;2,1;enable;"..minetest.formspec_escape(S("Disabled")).."]" or
			"button[3,2;2,1;disable;"..minetest.formspec_escape(S("Enabled")).."]")..
		"label[0,3;"..minetest.formspec_escape(S("Keeping @1/@2 map blocks loaded", #currently_forceloaded_positions(meta), #compute_forceload_positions(pos, meta))).."]")
end

minetest.register_node("technic:admin_anchor", {
	description = desc,
	drawtype = "normal",
	tiles = {"technic_admin_anchor.png"},
	is_ground_content = true,
	groups = {cracky=3},
	sounds = default.node_sound_stone_defaults(),
	_ch_help = "Slouží k trvalému držení mapových bloků v aktivitě.\nUmístit ji může kdokoliv, ale jen Administrace ji může nastavit a zapnout.",
	after_place_node = function (pos, placer)
		local meta = minetest.get_meta(pos)
		if placer and placer:is_player() then
			meta:set_string("owner", placer:get_player_name())
		end
		set_display(pos, meta)
	end,
	can_dig = function (pos, player)
		local meta = minetest.get_meta(pos)
		return meta:get_int("locked") == 0 or (player and player:is_player() and player:get_player_name() == meta:get_string("owner"))
	end,
	on_destruct = function (pos)
		local meta = minetest.get_meta(pos)
		forceload_off(meta)
	end,
	on_receive_fields = function (pos, formname, fields, sender)
		local sender_is_player = sender and sender:is_player()
		local meta = minetest.get_meta(pos)
		local sender_has_owner_rights = sender_is_player and (sender:get_player_name() == meta:get_string("owner") or minetest.check_player_privs(sender, "protection_bypass"))
		if (meta:get_int("locked") ~= 0 or fields.lock) and not sender_has_owner_rights then
			return
		end
		if fields.unlock then meta:set_int("locked", 0) end
		if fields.lock then meta:set_int("locked", 1) end
		if fields.disable or fields.enable or fields.radius then
			forceload_off(meta)
			if fields.disable then meta:set_int("enabled", 0) end
			if sender_is_player and minetest.check_player_privs(sender, "server") then
				if fields.enable then meta:set_int("enabled", 1) end
				if fields.radius and string.find(fields.radius, "^[0-9]+$") and tonumber(fields.radius) < 256 then meta:set_int("radius", fields.radius) end
			elseif (fields.enable and not fields.disable) or fields.radius then
				minetest.chat_send_player(sender:get_player_name(), S("ERROR: Only players with server privilege may enable Administrative World Anchor or change its radius!"))
			end
			if meta:get_int("enabled") ~= 0 then
				forceload_on(pos, meta)
			end
		end
		set_display(pos, meta)
	end,
})

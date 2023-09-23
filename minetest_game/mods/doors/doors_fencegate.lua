local S = minetest.get_translator("doors")

----fence gate----
local fence_collision_extra = minetest.settings:get_bool("enable_fence_tall") and 3/8 or 0

local function toggle_fencegate(pos, node, clicker)
	node = node or minetest.get_node(pos)

	if clicker and not default.can_interact_with_node(clicker, pos) then
		return false
	end

	local node_def = minetest.registered_nodes[node.name]
	local meta = minetest.get_meta(pos)
	local timer = minetest.get_node_timer(pos)

	minetest.swap_node(pos, {name = node_def._gate, param2 = node.param2})
	minetest.sound_play(node_def._gate_sound, {pos = pos, gain = 0.15, max_hear_distance = 8}, true)
	if string.sub(node.name, -5) == "_open" then
		if meta:get_int("zavirasamo") > 0 then
			timer:stop()
		end
	else
		if meta:get_int("zavirasamo") > 0 then
			timer:start(1)
		end
	end
end

function doors.fencegate_state(self)
	local node = minetest.get_node(self.pos)
	return string.sub(node.name, -5) == "_open"
end

function doors.fencegate_open(self, player)
	if not doors.fencegate_state(self) then
		return toggle_fencegate(self.pos, minetest.get_node(self.pos), player)
	end
end

function doors.fencegate_close(self, player)
	if doors.fencegate_state(self) then
		return toggle_fencegate(self.pos, minetest.get_node(self.pos), player)
	end
end

function doors.fencegate_toggle(self, player)
	return toggle_fencegate(self.pos, nil, player)
end

function doors.register_fencegate(name, def)
	local fence = {
		description = def.description,
		drawtype = "mesh",
		tiles = {},
		paramtype = "light",
		paramtype2 = "facedir",
		sunlight_propagates = true,
		is_ground_content = false,
		drop = name .. "_closed",
		connect_sides = {"left", "right"},
		groups = def.groups,
		sounds = def.sounds,
		on_rightclick = doors.door_rightclick --[[ function(pos, node, clicker, itemstack, pointed_thing)
			local node_def = minetest.registered_nodes[node.name]
			minetest.swap_node(pos, {name = node_def._gate, param2 = node.param2})
			minetest.sound_play(node_def._gate_sound, {pos = pos, gain = 0.15,
				max_hear_distance = 8}, true)
			return itemstack
		end ]],
		on_timer = doors.on_timer,
		after_place_node = function(pos, placer, itemstack, pointed_thing)
			local pn = placer:get_player_name()
			local meta = minetest.get_meta(pos)
			meta:set_string("placer", pn)
			doors.update_infotext(pos, nil, meta)
			return minetest.is_creative_enabled(pn)
		end,
		selection_box = {
			type = "fixed",
			fixed = {-1/2, -1/2, -1/4, 1/2, 1/2, 1/4}
		},
	}

	if type(def.texture) == "string" then
		fence.tiles[1] = {name = def.texture, backface_culling = true}
	elseif def.texture.backface_culling == nil then
		fence.tiles[1] = table.copy(def.texture)
		fence.tiles[1].backface_culling = true
	else
		fence.tiles[1] = def.texture
	end

	if not fence.sounds then
		fence.sounds = default.node_sound_wood_defaults()
	end

	local fence_closed = table.copy(fence)
	fence_closed.groups = table.copy(fence.groups)
	fence_closed.groups.fence = 1
	fence_closed.mesh = "doors_fencegate_closed.obj"
	fence_closed._gate = name .. "_open"
	fence_closed._gate_sound = "doors_fencegate_open"
	fence_closed.collision_box = {
		type = "fixed",
		fixed = {-1/2, -1/2, -1/8, 1/2, 1/2 + fence_collision_extra, 1/8}
	}

	local fence_open = table.copy(fence)
	fence_open.mesh = "doors_fencegate_open.obj"
	fence_open._gate = name .. "_closed"
	fence_open._gate_sound = "doors_fencegate_close"
	fence_open.groups.not_in_creative_inventory = 1
	fence_open.groups.fence = 2
	fence_open.collision_box = {
		type = "fixed",
		fixed = {{-1/2, -1/2, -1/8, -3/8, 1/2 + fence_collision_extra, 1/8},
			 {-1/2, -3/8, -1/2, -3/8, 3/8,                         0  }}
	}

	minetest.register_node(":" .. name .. "_closed", fence_closed)
	minetest.register_node(":" .. name .. "_open", fence_open)

	doors.registered_fencegates[name.."_closed"] = true
	doors.registered_fencegates[name.."_open"] = true

	minetest.register_craft({
		output = name .. "_closed",
		recipe = {
			{"group:stick", def.material, "group:stick"},
			{"group:stick", def.material, "group:stick"}
		}
	})
end

doors.register_fencegate("doors:gate_wood", {
	description = S("Apple Wood Fence Gate"),
	texture = "default_wood.png",
	material = "default:wood",
	groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2}
})

doors.register_fencegate("doors:gate_acacia_wood", {
	description = S("Acacia Wood Fence Gate"),
	texture = "default_acacia_wood.png",
	material = "default:acacia_wood",
	groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2}
})

doors.register_fencegate("doors:gate_junglewood", {
	description = S("Jungle Wood Fence Gate"),
	texture = "default_junglewood.png",
	material = "default:junglewood",
	groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2}
})

doors.register_fencegate("doors:gate_pine_wood", {
	description = S("Pine Wood Fence Gate"),
	texture = "default_pine_wood.png",
	material = "default:pine_wood",
	groups = {choppy = 3, oddly_breakable_by_hand = 2, flammable = 3}
})

doors.register_fencegate("doors:gate_aspen_wood", {
	description = S("Aspen Wood Fence Gate"),
	texture = "default_aspen_wood.png",
	material = "default:aspen_wood",
	groups = {choppy = 3, oddly_breakable_by_hand = 2, flammable = 3}
})

ch_core.open_submod("markers", {})

local texture = "ch_core_chessboard.png^[makealpha:255,255,255^[opacity:240"

local function remove_object(self)
	self.object:remove()
end
local function remove_object_after(self, delay)
	if delay > 0 then
		minetest.after(delay, remove_object, self)
	else
		remove_object(self)
	end
end
local function remove_object_after_timeout(self, shift)
	remove_object_after(self, (self.timeout or shift) - shift)
end
local function on_activate(self, staticdata, dtime_s)
	minetest.after(1, remove_object_after_timeout, self, 1)
end

local def = {
	initial_properties = {
		physical = false,
		pointable = false,
		visual = "cube",
		textures = {texture, texture, texture, texture, texture, texture},
		use_texture_alpha = true,
		backface_culling = false,
		static_save = false,
		shaded = false,
	},
	on_activate = on_activate,
}
minetest.register_entity("ch_core:markers", def)

function ch_core.show_aabb(coords, timeout)
	local size = vector.new(coords[4] - coords[1], coords[5] - coords[2], coords[6] - coords[3])
	local center = vector.new(
		0.5 * (coords[4] + coords[1]) - 0.5,
		0.5 * (coords[5] + coords[2]) - 0.5,
		0.5 * (coords[6] + coords[3]) - 0.5)
	local obj = minetest.add_entity(center, "ch_core:markers")
	obj:set_properties{visual_size = size}
	obj:get_luaentity().timeout = timeout or 16
	return obj
end

ch_core.close_submod("markers")

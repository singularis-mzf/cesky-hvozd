local internal = ...

local def = {
	description = "hranice kontejneru",
	drawtype = "normal",
	tiles = {
		{name = "area_containers_wall.png", backface_culling = true}, -- +Y
		{name = "area_containers_wall.png^[makealpha:204,204,204", backface_culling = true, color = "white"}, -- -Y
		{name = "area_containers_wall.png", backface_culling = true},
		{name = "area_containers_wall.png", backface_culling = true},
		{name = "area_containers_wall.png", backface_culling = true},
		{name = "area_containers_wall.png", backface_culling = true},
	},
	use_texture_alpha = "clip",
	paramtype = "light",
	paramtype2 = "color",
	palette = "unifieddyes_palette_extended.png",
	diggable = false,
	is_ground_content = false,
	sunlight_propagates = true,
	sounds = default.node_sound_stone_defaults(),
	groups = {
		-- not_in_creative_inventory = 1,
		ud_param2_colorable = 1,
	},
	light_source = 3,

	-- can_dig = function() return false end,
	-- on_rightclick = internal.on_rightclick,
	on_blast = function() end,
}

minetest.register_node("ch_containers:wall", def)

if minetest.get_modpath("mesecons_mvps") then
	mesecon.register_mvps_stopper("ch_containers:wall")
end

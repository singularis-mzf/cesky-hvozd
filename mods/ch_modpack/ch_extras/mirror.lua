local def, nbox
local F = minetest.formspec_escape

-- ch_extras:mirror
---------------------------------------------------------------
local function on_construct(pos)
	minetest.get_meta(pos):set_string("infotext", "zrcadlo")
end

local function show_formspec(player)
	if not minetest.is_player(player) then return end
	local player_name = assert(player:get_player_name())
	local player_viewname = ch_core.prihlasovaci_na_zobrazovaci(player_name, true)
	local player_properties = player_api.get_animation(player)
	local player_mesh = assert(player_properties.model)
	local player_animation = ch_core.safe_get_4(player_api.registered_models, player_mesh, "animations", player_properties.animation)
	local player_textures = player_properties.textures
	local animation_speed = player_properties.animation_speed or 0
	local fs_mesh = F(player_mesh)
	local fs_textures = {}
	for i, tex in ipairs(assert(player_textures)) do
		fs_textures[i] = F(tex)
	end
	fs_textures = table.concat(fs_textures, ",")
	local fs_animation
	if player_animation ~= nil then --  animations ~= nil and animations[player_animation] ~= nil and animations[player_animation].animations then
		fs_animation = assert(player_animation.x)..","..assert(player_animation.y)
	else
		fs_animation = "0,0"
	end

	local formspec = {
		ch_core.formspec_header({
			formspec_version = 6,
			size = {8, 16},
			auto_background = true,
		}),
		"label[1.5,1.0;", F(player_viewname), "]"..
		"model[0,0;8,16;player_model;",
		F(assert(player_properties.model)),
		";",
		fs_textures,
		";0,170;false;true;",
		fs_animation,
		";",
		animation_speed,
		"]"..
		"button_exit[7,0.5;0.75,0.75;close;X]"..
		"button[0.5,15;7,0.75;refresh;obnovit]",
	}
	minetest.show_formspec(player_name, "ch_extras:mirror", table.concat(formspec))
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "ch_extras:mirror" then
		if fields.refresh then
			show_formspec(player)
		end
		return true
	end
end)

nbox = {
	type = "fixed",
	fixed = {-0.5 + 1/16, -0.5, 0.5 - 2/16, 0.5 - 1/16, 0.5, 0.5},
}
def = {
	description = "zrcadlo",
	drawtype = "nodebox",
	collision_box = nbox,
	selection_box = nbox,
	node_box = nbox,
	tiles = {
		{name = "ch_core_white_pixel.png", color = "#744f27"},
		{name = "ch_core_white_pixel.png", color = "#744f27"},
		{name = "ch_core_white_pixel.png", color = "#744f27"},
		{name = "ch_core_white_pixel.png", color = "#744f27"},
		{name = "ch_core_white_pixel.png", color = "#9a8167"},
		{name = "[combine:64x64:4,0=ch_extras_mirror.jpg\\^[resize\\:56x64", color = "white"},
	},
	use_texture_alpha = "opaque",
	inventory_image = "ch_extras_mirror.jpg",
	wield_image = "ch_extras_mirror.jpg",
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {cracky = 2, oddly_breakable_by_hand = 2},
	sounds = default.node_sound_glass_defaults(),
	on_construct = on_construct,
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		show_formspec(clicker)
	end,
	on_use = function(itemstack, user, pointed_thing)
		show_formspec(user)
	end,
}
minetest.register_node("ch_extras:mirror", def)

minetest.register_craft({
	output = "ch_extras:mirror",
	recipe = {
		{"default:stick", "default:stick", "default:stick"},
		{"default:stick", "xpanes:pane_flat", "default:stick"},
		{"default:stick", "default:stick", "default:stick"},
	},
})

minetest.register_lbm({
	label = "Upgrade legacy mirrors",
	name = "ch_extras:mirrors",
	nodenames = {"mirrors:mirror", "ch_extras:mirror"},
	action = function(pos, node, dtime_s)
		if node.name ~= "ch_extras:mirror" then
			node.name = "ch_extras:mirror"
			minetest.swap_node(pos, node)
		end
		on_construct(pos)
	end,
})

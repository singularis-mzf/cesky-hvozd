local S = ...

function vanity.get_vanity_formspec(clicker)
	--5.4--local model = player_api.get_gender_model(gender)

	local _base_texture = player_api.get_base_texture_table(clicker)

	local face_preview = minetest.formspec_escape(player_api.compose_base_texture(_base_texture, {
		canvas_size ="16x16",
		skin_texture = "vanity_face_base.png",
		eyebrowns_pos = "0,0",
		eye_right_pos = "2,8",
		eye_left_pos = "10,8",
		mouth_pos = "0,12",
		hair_preview = true,
		hair_pos = "0,0",
	}))

	local formspec =
		"formspec_version[4]"..
		"size[10,8.25]"..
		"image[0.5,0.5;4,4;".. face_preview .."]"..
		--Skins
		"label[6,0.5;"..S("Skin Tone")..":]"..
		"image_button[4.75,0.75;1,1;player_normal_skin.png;btn_normal_skin;]"..
		"image_button[6,0.75;1,1;player_light_brown_skin.png;btn_light_brown_skin;]"..
		"image_button[7.25,0.75;1,1;player_brown_skin.png;btn_brown_skin;]"..
		"image_button[8.5,0.75;1,1;player_black_skin.png;btn_black_skin;]"..
		--Eyes
		"label[6,2.25;"..S("Eyes Color")..":]"..
		"image_button[4.75,2.5;1,1;player_blue_eye.png;btn_blue_eye;]"..
		"image_button[6,2.5;1,1;player_brown_eye.png;btn_brown_eye;]"..
		"image_button[7.25,2.5;1,1;player_green_eye.png;btn_green_eye;]"..
		"image_button[8.5,2.5;1,1;player_black_eye.png;btn_black_eye;]"..
		"image_button[4.75,3.75;1,1;player_gray_eye.png;btn_gray_eye;]"..
		"image_button[6,3.75;1,1;player_hazel_eye.png;btn_hazel_eye;]"..
		"image_button[7.25,3.75;1,1;player_violet_eye.png;btn_violet_eye;]"..
		"image_button[8.5,3.75;1,1;player_pink_eye.png;btn_pink_eye;]"..
		--Hairs
		"label[0.5,5.25;"..S("Hair").."\n"..S("Color")..":]"..
		"tooltip[btn_black_hair;"..S("Dark-haired").."]"..
		"style[btn_black_hair;bgcolor=black]"..
		"image_button[2.25,5;1,1;;btn_black_hair;]"..
		"tooltip[btn_gray_hair;"..S("Gray-haired").."]"..
		"style[btn_gray_hair;bgcolor=lightgray]"..
		"image_button[3.5,5;1,1;;btn_gray_hair;]"..
		"tooltip[btn_light_brown_hair;"..S("Light-Brown").."]"..
		"style[btn_light_brown_hair;bgcolor=sandybrown]"..
		"image_button[4.75,5;1,1;;btn_light_brown_hair;]"..
		"tooltip[btn_brown_hair;"..S("Brown").."]"..
		"style[btn_brown_hair;bgcolor=sienna]"..
		"image_button[6,5;1,1;;btn_brown_hair;]"..
		"tooltip[btn_red_hair;"..S("Red-haired").."]"..
		"style[btn_red_hair;bgcolor=orange]"..
		"image_button[7.25,5;1,1;;btn_red_hair;]"..
		"tooltip[btn_blonde_hair;"..S("Blonde").."]"..
		"style[btn_blonde_hair;bgcolor=yellow]"..
		"image_button[8.5,5;1,1;;btn_blonde_hair;]"..
		"style_type[button_exit;bgcolor=#006699;textcolor=white]"..
		"button_exit[4.75,6.5;1,1;btn_close;"..S("Close").."]"
	return formspec
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "form:vanity" then
		return
	end
	if not player or fields.quit then
		return
	end
	local player_name = player:get_player_name()
	local base_texture = player_api.get_base_texture_table(player)
	if fields.btn_blue_eye then
		base_texture["eye"] = "player_blue_eye.png"
	elseif fields.btn_brown_eye then
		base_texture["eye"] = "player_brown_eye.png"
	elseif fields.btn_green_eye then
		base_texture["eye"] = "player_green_eye.png"
	elseif fields.btn_gray_eye then
		base_texture["eye"] = "player_gray_eye.png"
	elseif fields.btn_hazel_eye then
		base_texture["eye"] = "player_hazel_eye.png"
	elseif fields.btn_violet_eye then
		base_texture["eye"] = "player_violet_eye.png"
	elseif fields.btn_black_eye then
		base_texture["eye"] = "player_black_eye.png"
	elseif fields.btn_pink_eye then
		base_texture["eye"] = "player_pink_eye.png"
	elseif fields.btn_normal_skin then
		base_texture["skin"].color = "normal"
	elseif fields.btn_light_brown_skin then
		base_texture["skin"].color = "light_brown"
	elseif fields.btn_brown_skin then
		base_texture["skin"].color = "brown"
	elseif fields.btn_black_skin then
		base_texture["skin"].color = "black"
	elseif fields.btn_black_hair then
		base_texture["hair"].color = "black"
		base_texture["eyebrowns"].color = "gray"
	elseif fields.btn_gray_hair then
		base_texture["hair"].color = "gray"
		base_texture["eyebrowns"].color = "gray"
	elseif fields.btn_light_brown_hair then
		base_texture["hair"].color = "light_brown"
		base_texture["eyebrowns"].color = "light_brown"
	elseif fields.btn_brown_hair then
		base_texture["hair"].color = "brown"
		base_texture["eyebrowns"].color = "brown"
	elseif fields.btn_red_hair then
		base_texture["hair"].color = "red"
		base_texture["eyebrowns"].color = "red"
	elseif fields.btn_blonde_hair then
		base_texture["hair"].color = "blonde"
		base_texture["eyebrowns"].color = "blonde"
	end
	player_api.set_base_texture(player, base_texture)
	player_api.set_texture(player)
	minetest.show_formspec(player_name,
		"form:vanity", vanity.get_vanity_formspec(player))
	return true
end)

-- Vanity Set

minetest.register_node("vanity:vanity", {
    description = S("Vanity Table"),
	drawtype = "mesh",
	mesh = "vanity_set.b3d",
    tiles = {"vanity_vanity.png"},
    use_texture_alpha = "clip",
    paramtype2 = "facedir",
    is_ground_content = false,
    groups = {cracky=3, wood=1},

	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		local player_name = player:get_player_name()
		minetest.show_formspec(player_name,
			"form:vanity", vanity.get_vanity_formspec(player))
	end,
})

minetest.register_craft({
	output = "vanity:vanity",
	type = "shaped",
		recipe = {
		{"", "", ""},
		{"", "group:mirror", ""},
		{"", "group:wood", ""},
	}
})

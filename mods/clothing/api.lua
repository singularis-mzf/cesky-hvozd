clothing = {
	formspec = "size[8,8.5]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		"list[current_player;main;0,4.7;8,1;]"..
		"list[current_player;main;0,5.85;8,3;8]"..
		default.get_hotbar_bg(0,4.7),
	registered_callbacks = {
		on_update = {},
		on_load = {},
		on_equip = {},
		on_unequip = {},
	},
	player_textures = {},
}

clothing.have_wool = minetest.get_modpath("wool")~=nil;
clothing.have_farming = minetest.get_modpath("farming")~=nil;
clothing.have_bonemeal = minetest.get_modpath("bonemeal")~=nil;
clothing.have_skeletons = minetest.get_modpath("skeletons")~=nil;
clothing.have_unified = minetest.get_modpath("unified_inventory")~=nil;
clothing.have_skinsdb = minetest.get_modpath("skinsdb")~=nil;

clothing.translator = minetest.get_translator("clothing");

-- Clothing callbacks

clothing.register_on_update = function(self, func)
	if type(func) == "function" then
		table.insert(self.registered_callbacks.on_update, func)
	end
end

clothing.register_on_load = function(self, func)
	if type(func) == "function" then
		table.insert(self.registered_callbacks.on_load, func)
	end
end

clothing.register_on_equip = function(self, func)
	if type(func) == "function" then
		table.insert(self.registered_callbacks.on_equip, func)
	end
end

clothing.register_on_unequip = function(self, func)
	if type(func) == "function" then
		table.insert(self.registered_callbacks.on_unequip, func)
	end
end

clothing.run_callbacks = function(self, callback, player, index, stack)
	if stack then
		local def = stack:get_definition() or {}
		if type(def[callback]) == "function" then
			def[callback](player, index, stack)
		end
	end
	local callbacks = self.registered_callbacks[callback]
	if callbacks then
		for _, func in pairs(callbacks) do
			func(player, index, stack)
		end
	end
end

clothing.compute_player_texture_layers = function(self, clothing_stacks)
	local layer = {
		cape = {},
		clothing = {},
	}
	for i, stack in ipairs(clothing_stacks) do
		if stack:get_count() == 1 then
			local def = stack:get_definition()
			if def.groups and def.uv_image then
				if def.groups.clothing == 1 then
					table.insert(layer.clothing, def.uv_image)
				elseif def.groups.cape == 1 then
					table.insert(layer.cape, def.uv_image)
				end
			end
		end
	end
	return layer
end

clothing.set_player_clothing = function(self, player)
	if not player then
		return
	end
	local name = player:get_player_name()

	local layer = {
		clothing = {},
		cape = {},
	}

	local player_meta = player:get_meta();
	--local clothing_meta = player:get_attribute("clothing:inventory")
	local clothing_meta = player_meta:get_string("clothing:inventory")
	local clothes = clothing_meta and minetest.deserialize(clothing_meta) or {}

	local capes = {}
	for i=1, 9 do
		local stack = ItemStack(clothes[i])
		if stack:get_count() == 1 then
			local def = stack:get_definition()
			if def.uv_image then
				if def.groups.clothing == 1 then
					table.insert(layer.clothing, def.uv_image)
				elseif def.groups.cape == 1 then
					table.insert(layer.cape, def.uv_image)
				end
			end
		end
	end
	local clothing_out = table.concat(layer.clothing, "^")
	local cape_out = table.concat(layer.cape, "^")
	if clothing_out == "" then
		clothing_out = "blank.png"
	end
	if cape_out == "" then
		cape_out = "blank.png"
	end
	if minetest.global_exists("multiskin") then
		local skin = multiskin.skins[name]
		if skin then
			skin.clothing = clothing_out
			skin.cape = cape_out
			multiskin.update_player_visuals(player)
		end
	else
		clothing.player_textures[name] = clothing.player_textures[name] or {}
		clothing.player_textures[name].clothing = clothing_out
		clothing.player_textures[name].cape = cape_out
	end
	self:run_callbacks("on_update", player)
end

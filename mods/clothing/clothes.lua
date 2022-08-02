
local S = clothing.translator;

local hood_mask_load = nil
local hood_mask_equip = nil
local hood_mask_unequip = nil

if minetest.settings:get_bool("clothing_enable_hood_mask", true) then
  local have_hidename = minetest.get_modpath("hidename")
    
  hood_mask_equip = function(player, index, stack)
    player:set_nametag_attributes({color = {a = 0, r = 255, g = 255, b = 255}})
  end
  hood_mask_unequip = function (player, index, stack)
    player:set_nametag_attributes({color = {a = 255, r = 255, g = 255, b = 255}})
  end
  if have_hidename then
    hood_mask_equip = function(player, index, stack)
      hidename.hide(player:get_player_name())
    end
    hood_mask_unequip = function(player, index, stack)
      hidename.show(player:get_player_name())
    end
  end
  hood_mask_load = hood_mask_equip
end

local groups_clothing_in_ci = {clothing = 1}
local groups_clothing_not_in_ci = {clothing = 1, not_in_creative_inventory = 1}
local groups_cape_in_ci = {cape = 1}
local groups_cape_not_in_ci = {cape = 1, not_in_creative_inventory = 1}

-- groups_cape_in_ci = groups_cape_not_in_ci
-- groups_clothing_in_ci = groups_clothing_not_in_ci

local clothing_types = {
	-- required keys: cloth_desc, color_suffix
	-- optional keys: cape, single_color = true, dual_color = true, stripy, pictures = {inv_pos, uv_pos}
	--                on_load, on_equip, on_unequip
	cape = {
		cloth_desc = "plášť",
		color_suffix = "ý",
		cape = true,
		-- pictures = { inv_pos = "16x16:4,4", uv_pos = "64x32:56,22" },
		stripy = false, -- not supported yet
	},
	glove_left = {
		cloth_desc = "levá rukavice",
		color_suffix = "á",
		stripy = true,
	},
	glove_right = {
		cloth_desc = "pravá rukavice",
		color_suffix = "á",
		stripy = true,
	},
	gloves = {
		cloth_desc = "rukavice",
		color_suffix = "é",
		stripy = true,
	},
	hood_mask = {
		cloth_desc = "kukla",
		color_suffix = "á",
		stripy = true,
		on_load = hood_mask_load,
		on_equip = hood_mask_equip,
		on_unequip = hood_mask_unequip,
	},
	pants = {
		cloth_desc = "kalhoty",
		color_suffix = "é",
		stripy = true,
	},
	shirt = {
		cloth_desc = "tričko",
		color_suffix = "é",
		-- pictures = { inv_pos = "16x16:4,4", uv_pos = "64x64:44,78" },
		stripy = true,
	},
	shoes = {
		cloth_desc = "boty",
		color_suffix = "é",
		dual_color = false,
		stripy = false,
	},
	shorts = {
		cloth_desc = "krátké kalhoty",
		color_suffix = "é",
		stripy = true,
	},
	shortshirt = {
		cloth_desc = "tričko s krátkým rukávem",
		color_suffix = "é",
		stripy = true,
	},
	skullcap = {
		cloth_desc = "čepice",
		color_suffix = "á",
		stripy = true,
	},
	undershirt = {
		cloth_desc = "tílko",
		color_suffix = "é",
		stripy = true,
	},
}

-- if pictures_def is not nil, this will register a new clothing item
-- based on definition "def" for every supported picture
-- name_base: the base of the name of the item (e. g. "clothing:hood_mask_yellow_green")
-- def: original item definition used in minetest.register_craftitem()
-- pictures_def: pictures settings or nil
-- name_base_alias: alias to name_base or nil
local function register_clothes_with_pictures(name_base, def, pictures_def, name_base_alias)
	if pictures_def then
		for picture, pic_data in pairs(clothing.pictures) do
			local ndef = table.copy(def)
			ndef.description = def.description.." s obrázkem"
			ndef.inventory_image = def.inventory_image.."^[combine:"..pictures_def.inv_pos.."="..pic_data.texture
			ndef.uv_image = def.uv_image.."^[combine:"..pictures_def.uv_pos.."="..pic_data.texture
			minetest.register_craftitem(name_base.."_picture_"..picture, ndef)
			if name_base_alias then
				minetest.register_alias(name_base_alias.."_picture_"..picture, name_base.."_picture_"..picture)
			end
		end
	end
end

for color, data in pairs(clothing.colors) do
	local desc, groups_clothing, groups_cape
	desc = data.color
	if data.in_creative_inventory > 0 then
		groups_clothing = groups_clothing_in_ci
		groups_cape = groups_cape_in_ci
	else
		groups_clothing = groups_clothing_not_in_ci
		groups_cape = groups_cape_not_in_ci
	end

	for cloth_type, cloth_def in pairs(clothing_types) do
		local inv_img = "(clothing_inv_"..cloth_type..".png^[multiply:#"..data.hex..")"
		local uv_img = "(clothing_uv_"..cloth_type..".png^[multiply:#"..data.hex..")"
		local groups, def

		if cloth_def.cape then
			groups = groups_cape
		else
			groups = groups_clothing
		end

		if cloth_def.single_color ~= false and not data.hex2 then
			def = {
				description = data.color..cloth_def.color_suffix.." "..cloth_def.cloth_desc,
				inventory_image = inv_img,
				uv_image = uv_img,
				groups = groups,
				on_load = cloth_def.on_load,
				on_equip = cloth_def.on_equip,
				on_unequip = cloth_def.on_unequip,
			}

			minetest.register_craftitem("clothing:"..cloth_type.."_"..color, def)
			-- register_clothes_with_pictures(name_base, def, pictures_def, name_base_alias)
			register_clothes_with_pictures("clothing:"..cloth_type.."_"..color, def, cloth_def.pictures, data.alias)
		end

		if data.hex2 then
			if cloth_def.dual_color ~= false then
				local clothing_uv_second_color = "clothing_uv_second_color.png"
				if cloth_def.cape then
					clothing_uv_second_color = "clothing_uv_cape_second_color.png"
				end

				def = {
					description = data.color..cloth_def.color_suffix.." "..cloth_def.cloth_desc,
					inventory_image = inv_img.."^(((clothing_inv_"..cloth_type..".png^clothing_inv_second_color.png)^[makealpha:0,0,0)^[multiply:#"..data.hex2..")",
					uv_image = uv_img.."^(((clothing_uv_"..cloth_type..".png^"..clothing_uv_second_color..")^[makealpha:0,0,0)^[multiply:#"..data.hex2..")",
					groups = groups,
					on_load = cloth_def.on_load,
					on_equip = cloth_def.on_equip,
					on_unequip = cloth_def.on_unequip,
				}
				minetest.register_craftitem("clothing:"..cloth_type.."_"..color, def)
				minetest.register_alias("clothing:"..cloth_type.."_"..data.alias, "clothing:"..cloth_type.."_"..color)
				register_clothes_with_pictures("clothing:"..cloth_type.."_"..color, def, cloth_def.pictures, "clothing:"..cloth_type.."_"..data.alias)
			end
			if cloth_def.stripy then
				def = {
					description = "pruhovan"..cloth_def.color_suffix.." "..data.color..cloth_def.color_suffix.." "..cloth_def.cloth_desc,
					inventory_image = inv_img.."^(((clothing_inv_"..cloth_type..".png^clothing_inv_stripy_second_color.png)^[makealpha:0,0,0)^[multiply:#"..data.hex2..")",
					uv_image = uv_img.."^(((clothing_uv_"..cloth_type..".png^clothing_uv_stripy_second_color.png)^[makealpha:0,0,0)^[multiply:#"..data.hex2..")",
					groups = groups,
					on_load = cloth_def.on_load,
					on_equip = cloth_def.on_equip,
					on_unequip = cloth_def.on_unequip,
				}
				minetest.register_craftitem("clothing:"..cloth_type.."_"..color.."_stripy", def)
				minetest.register_alias("clothing:"..cloth_type.."_"..data.alias.."_stripy", "clothing:"..cloth_type.."_"..color.."_stripy")
				register_clothes_with_pictures("clothing:"..cloth_type.."_"..color.."_stripy", def, cloth_def.pictures, "clothing:"..cloth_type.."_"..data.alias.."_stripy")
			end
		end
	end

--[[
  for picture, pic_data in pairs(clothing.pictures) do
    -- t-shirt
    local inv_img = "(clothing_inv_shirt.png^[multiply:#"..data.hex..")";
    local uv_img = "(clothing_uv_shirt.png^[multiply:#"..data.hex..")";
    if data.hex2 then
      inv_img = "("..inv_img.."^(((clothing_inv_shirt.png^clothing_inv_second_color.png)^[makealpha:0,0,0)^[multiply:#"..data.hex2.."))";
      uv_img = "("..uv_img.."^(((clothing_uv_shirt.png^clothing_uv_second_color.png)^[makealpha:0,0,0)^[multiply:#"..data.hex2.."))";
    end
    minetest.register_craftitem("clothing:shirt_"..color.."_picture_"..picture, {
      description = desc.."é tričko s obrázkem",
      inventory_image = inv_img.."^[combine:16x16:4,4="..pic_data.texture,
      uv_image = uv_img.."^[combine:64x64:20,39="..pic_data.texture,
      groups = groups_clothing,
    })
    if data.alias then
      minetest.register_alias("clothing:shirt_"..data.alias.."_picture_"..picture, "clothing:shirt_"..color.."_picture_"..picture)
    end
    
    -- cape
    local inv_img = "(clothing_inv_cape.png^[multiply:#"..data.hex..")";
    local uv_img = "(clothing_uv_cape.png^[multiply:#"..data.hex..")";
    if data.hex2 then
      inv_img = "("..inv_img.."^(((clothing_inv_cape.png^clothing_inv_second_color.png)^[makealpha:0,0,0)^[multiply:#"..data.hex2.."))";
      uv_img = "("..uv_img.."^(((clothing_uv_cape.png^clothing_uv_cape_second_color.png)^[makealpha:0,0,0)^[multiply:#"..data.hex2.."))";
    end
    minetest.register_craftitem("clothing:cape_"..color.."_picture_"..picture, {
      description = desc.."ý plášť s obrázkem",
      inventory_image = inv_img.."^[combine:16x16:4,4="..pic_data.texture,
      uv_image = uv_img.."^[combine:64x32:56,22="..pic_data.texture,
      groups = groups_cape,
    })
    if data.alias then
      minetest.register_alias("clothing:cape_"..data.alias.."_picture_"..picture, "clothing:cape_"..color.."_picture_"..picture)
    end
  end
]]
end

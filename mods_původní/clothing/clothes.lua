
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

for color, data in pairs(clothing.colors) do
	local desc = data.color;
  desc = desc:gsub("%a", string.upper, 1);
  desc = desc.." ";
  
  -- clothes
  -- skullcap (old hat)
  local inv_img = "(clothing_inv_skullcap.png^[multiply:#"..data.hex..")";
  local uv_img = "(clothing_uv_skullcap.png^[multiply:#"..data.hex..")";
  if data.hex2 then
    inv_img = inv_img.."^(((clothing_inv_skullcap.png^clothing_inv_second_color.png)^[makealpha:0,0,0)^[multiply:#"..data.hex2..")";
    uv_img = uv_img.."^(((clothing_uv_skullcap.png^clothing_uv_second_color.png)^[makealpha:0,0,0)^[multiply:#"..data.hex2..")";
  end
	minetest.register_craftitem("clothing:skullcap_"..color, {
		description = desc..S("cotton skullcap"),
		inventory_image = inv_img,
		uv_image = uv_img,
		groups = {clothing=1},
    
    on_load = function(player, index, stack)
      -- change old :hat item to :skullcap item
      local count = stack:get_count()
      stack:set_name("clothing:skullcap_"..color)
      stack:set_count(count)
    end,
	})
	minetest.register_alias("clothing:hat_"..color, "clothing:skullcap_"..color)
  if data.alias then
	  minetest.register_alias("clothing:skullcap_"..data.alias, "clothing:skullcap_"..color)
	  minetest.register_alias("clothing:hat_"..data.alias, "clothing:skullcap_"..color)
  end
  
  -- t-shirt
  local inv_img = "(clothing_inv_shirt.png^[multiply:#"..data.hex..")";
  local uv_img = "(clothing_uv_shirt.png^[multiply:#"..data.hex..")";
  if data.hex2 then
    inv_img = inv_img.."^(((clothing_inv_shirt.png^clothing_inv_second_color.png)^[makealpha:0,0,0)^[multiply:#"..data.hex2..")";
    uv_img = uv_img.."^(((clothing_uv_shirt.png^clothing_uv_second_color.png)^[makealpha:0,0,0)^[multiply:#"..data.hex2..")";
  end
	minetest.register_craftitem("clothing:shirt_"..color, {
		description = desc..S("cotton shirt"),
		inventory_image = inv_img,
		uv_image = uv_img,
		groups = {clothing=1},
	})
  if data.alias then
	  minetest.register_alias("clothing:shirt_"..data.alias, "clothing:shirt_"..color)
  end
  
  -- pants
  local inv_img = "(clothing_inv_pants.png^[multiply:#"..data.hex..")";
  local uv_img = "(clothing_uv_pants.png^[multiply:#"..data.hex..")";
  if data.hex2 then
    inv_img = inv_img.."^(((clothing_inv_pants.png^clothing_inv_second_color.png)^[makealpha:0,0,0)^[multiply:#"..data.hex2..")";
    uv_img = uv_img.."^(((clothing_uv_pants.png^clothing_uv_second_color.png)^[makealpha:0,0,0)^[multiply:#"..data.hex2..")";
  end
	minetest.register_craftitem("clothing:pants_"..color, {
		description = desc..S("cotton pants"),
		inventory_image = inv_img,
		uv_image = uv_img,
		groups = {clothing=1},
	})
  if data.alias then
	  minetest.register_alias("clothing:pants_"..data.alias, "clothing:pants_"..color)
  end
  
  -- cape
  local inv_img = "(clothing_inv_cape.png^[multiply:#"..data.hex..")";
  local uv_img = "(clothing_uv_cape.png^[multiply:#"..data.hex..")";
  if data.hex2 then
    inv_img = inv_img.."^(((clothing_inv_cape.png^clothing_inv_second_color.png)^[makealpha:0,0,0)^[multiply:#"..data.hex2..")";
    uv_img = uv_img.."^(((clothing_uv_cape.png^clothing_uv_cape_second_color.png)^[makealpha:0,0,0)^[multiply:#"..data.hex2..")";
  end
	minetest.register_craftitem("clothing:cape_"..color, {
		description = desc..S("cotton cape"),
		inventory_image = inv_img,
		uv_image = uv_img,
		groups = {cape=1},
	})
  if data.alias then
	  minetest.register_alias("clothing:cape_"..data.alias, "clothing:cape_"..color)
  end
  
  -- hood mask
  local inv_img = "(clothing_inv_hood_mask.png^[multiply:#"..data.hex..")";
  local uv_img = "(clothing_uv_hood_mask.png^[multiply:#"..data.hex..")";
  if data.hex2 then
    inv_img = inv_img.."^(((clothing_inv_hood_mask.png^clothing_inv_second_color.png)^[makealpha:0,0,0)^[multiply:#"..data.hex2..")";
    uv_img = uv_img.."^(((clothing_uv_hood_mask.png^clothing_uv_second_color.png)^[makealpha:0,0,0)^[multiply:#"..data.hex2..")";
  end
	minetest.register_craftitem("clothing:hood_mask_"..color, {
		description = desc..S("cotton hood mask"),
		inventory_image = inv_img,
		uv_image = uv_img,
		groups = {clothing=1},
    on_load = hood_mask_load,
    on_equip = hood_mask_equip,
    on_unequip = hood_mask_unequip,
	})
  if data.alias then
	  minetest.register_alias("clothing:hood_mask_"..data.alias, "clothing:hood_mask_"..color)
  end
  
  -- right glove
  local inv_img = "(clothing_inv_glove_right.png^[multiply:#"..data.hex..")";
  local uv_img = "(clothing_uv_glove_right.png^[multiply:#"..data.hex..")";
  if data.hex2 then
    inv_img = inv_img.."^(((clothing_inv_glove_right.png^clothing_inv_second_color.png)^[makealpha:0,0,0)^[multiply:#"..data.hex2..")";
    uv_img = uv_img.."^(((clothing_uv_glove_right.png^clothing_uv_second_color.png)^[makealpha:0,0,0)^[multiply:#"..data.hex2..")";
  end
	minetest.register_craftitem("clothing:glove_right_"..color, {
		description = desc..S("cotton right glove"),
		inventory_image = inv_img,
		uv_image = uv_img,
		groups = {clothing=1},
	})
  if data.alias then
	  minetest.register_alias("clothing:glove_right_"..data.alias, "clothing:glove_right_"..color)
  end
  
  -- left glove
  local inv_img = "(clothing_inv_glove_left.png^[multiply:#"..data.hex..")";
  local uv_img = "(clothing_uv_glove_left.png^[multiply:#"..data.hex..")";
  if data.hex2 then
    inv_img = inv_img.."^(((clothing_inv_glove_left.png^clothing_inv_second_color.png)^[makealpha:0,0,0)^[multiply:#"..data.hex2..")";
    uv_img = uv_img.."^(((clothing_uv_glove_left.png^clothing_uv_second_color.png)^[makealpha:0,0,0)^[multiply:#"..data.hex2..")";
  end
	minetest.register_craftitem("clothing:glove_left_"..color, {
		description = desc..S("cotton left glove"),
		inventory_image = inv_img,
		uv_image = uv_img,
		groups = {clothing=1},
	})
  if data.alias then
	  minetest.register_alias("clothing:glove_left_"..data.alias, "clothing:glove_left_"..color)
  end
  
  -- gloves
  local inv_img = "(clothing_inv_gloves.png^[multiply:#"..data.hex..")";
  local uv_img = "(clothing_uv_gloves.png^[multiply:#"..data.hex..")";
  if data.hex2 then
    inv_img = inv_img.."^(((clothing_inv_gloves.png^clothing_inv_second_color.png)^[makealpha:0,0,0)^[multiply:#"..data.hex2..")";
    uv_img = uv_img.."^(((clothing_uv_gloves.png^clothing_uv_second_color.png)^[makealpha:0,0,0)^[multiply:#"..data.hex2..")";
  end
	minetest.register_craftitem("clothing:gloves_"..color, {
		description = desc..S("cotton gloves"),
		inventory_image = inv_img,
		uv_image = uv_img,
		groups = {clothing=1},
	})
  if data.alias then
	  minetest.register_alias("clothing:gloves_"..data.alias, "clothing:gloves_"..color)
  end
  
  -- undershirt
  local inv_img = "(clothing_inv_undershirt.png^[multiply:#"..data.hex..")";
  local uv_img = "(clothing_uv_undershirt.png^[multiply:#"..data.hex..")";
  if data.hex2 then
    inv_img = inv_img.."^(((clothing_inv_undershirt.png^clothing_inv_second_color.png)^[makealpha:0,0,0)^[multiply:#"..data.hex2..")";
    uv_img = uv_img.."^(((clothing_uv_undershirt.png^clothing_uv_second_color.png)^[makealpha:0,0,0)^[multiply:#"..data.hex2..")";
  end
	minetest.register_craftitem("clothing:undershirt_"..color, {
		description = desc..S("cotton undershirt"),
		inventory_image = inv_img,
		uv_image = uv_img,
		groups = {clothing=1},
	})
  if data.alias then
	  minetest.register_alias("clothing:undershirt_"..data.alias, "clothing:undershirt_"..color)
  end
  
  -- t-shirt short sleeve
  local inv_img = "(clothing_inv_shortshirt.png^[multiply:#"..data.hex..")";
  local uv_img = "(clothing_uv_shortshirt.png^[multiply:#"..data.hex..")";
  if data.hex2 then
    inv_img = inv_img.."^(((clothing_inv_shortshirt.png^clothing_inv_second_color.png)^[makealpha:0,0,0)^[multiply:#"..data.hex2..")";
    uv_img = uv_img.."^(((clothing_uv_shortshirt.png^clothing_uv_second_color.png)^[makealpha:0,0,0)^[multiply:#"..data.hex2..")";
  end
	minetest.register_craftitem("clothing:shortshirt_"..color, {
		description = desc..S("cotton short with short sleeve"),
		inventory_image = inv_img,
		uv_image = uv_img,
		groups = {clothing=1},
	})
  if data.alias then
	  minetest.register_alias("clothing:shortshirt_"..data.alias, "clothing:shortshirt_"..color)
  end
  
  -- shorts
  local inv_img = "(clothing_inv_shorts.png^[multiply:#"..data.hex..")";
  local uv_img = "(clothing_uv_shorts.png^[multiply:#"..data.hex..")";
  if data.hex2 then
    inv_img = inv_img.."^(((clothing_inv_shorts.png^clothing_inv_second_color.png)^[makealpha:0,0,0)^[multiply:#"..data.hex2..")";
    uv_img = uv_img.."^(((clothing_uv_shorts.png^clothing_uv_second_color.png)^[makealpha:0,0,0)^[multiply:#"..data.hex2..")";
  end
	minetest.register_craftitem("clothing:shorts_"..color, {
		description = desc..S("cotton shorts"),
		inventory_image = inv_img,
		uv_image = uv_img,
		groups = {clothing=1},
	})
  if data.alias then
	  minetest.register_alias("clothing:shorts_"..data.alias, "clothing:shorts_"..color)
  end
  
  
  for picture, pic_data in pairs(clothing.pictures) do
    -- t-shirt
    local inv_img = "(clothing_inv_shirt.png^[multiply:#"..data.hex..")";
    local uv_img = "(clothing_uv_shirt.png^[multiply:#"..data.hex..")";
    if data.hex2 then
      inv_img = "("..inv_img.."^(((clothing_inv_shirt.png^clothing_inv_second_color.png)^[makealpha:0,0,0)^[multiply:#"..data.hex2.."))";
      uv_img = "("..uv_img.."^(((clothing_uv_shirt.png^clothing_uv_second_color.png)^[makealpha:0,0,0)^[multiply:#"..data.hex2.."))";
    end
    minetest.register_craftitem("clothing:shirt_"..color.."_picture_"..picture, {
      description = desc..S("cotton shirt with picture"),
      inventory_image = inv_img.."^[combine:16x16:4,4="..pic_data.texture,
      uv_image = uv_img.."^[combine:64x64:20,39="..pic_data.texture,
      groups = {clothing=1},
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
      description = desc..S("cotton cape with picture"),
      inventory_image = inv_img.."^[combine:16x16:4,4="..pic_data.texture,
      uv_image = uv_img.."^[combine:64x32:56,22="..pic_data.texture,
      groups = {cape=1},
    })
    if data.alias then
      minetest.register_alias("clothing:cape_"..data.alias.."_picture_"..picture, "clothing:cape_"..color.."_picture_"..picture)
    end
  end
end


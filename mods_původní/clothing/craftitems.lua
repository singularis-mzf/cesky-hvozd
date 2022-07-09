
local S = clothing.translator;

minetest.register_craftitem("clothing:yarn_spool_empty", {
  description = S("Empty yarn spool"),
  inventory_image = "clothing_yarn_spool_empty.png",
});

minetest.register_craftitem("clothing:bone_needle", {
  description = S("Bone needle"),
  inventory_image = "clothing_bone_needle.png",
});

for color, data in pairs(clothing.colors) do
	local desc = data.color;
  desc = desc:gsub("%a", string.upper, 1);
  desc = desc.." ";
  
  if (data.hex2==nil) then
    -- yarn
    minetest.register_craftitem("clothing:yarn_spool_"..color, {
      description = desc..S("yarn spool"),
      inventory_image = "clothing_yarn_spool_empty.png^(clothing_yarn_spool_fill.png^[multiply:#"..data.hex..")",
    });
  end
  
  -- fabric
  local inv_img = "(clothing_fabric.png^[multiply:#"..data.hex..")";
  if data.hex2 then
    inv_img = inv_img.."^(((clothing_fabric.png^clothing_inv_second_color.png)^[makealpha:0,0,0)^[multiply:#"..data.hex2..")";
  end
  minetest.register_craftitem("clothing:fabric_"..color, {
    description = desc..S("fabric"),
    inventory_image = inv_img,
  });
  if data.alias then
    minetest.register_alias("clothing:fabric_"..data.alias, "clothing:fabric_"..color)
  end
end


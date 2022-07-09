
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
	local groups

  if (data.hex2==nil) then
    -- yarn
    minetest.register_craftitem("clothing:yarn_spool_"..color, {
      description = "cívka "..desc.."é nitě",
      inventory_image = "clothing_yarn_spool_empty.png^(clothing_yarn_spool_fill.png^[multiply:#"..data.hex..")",
      -- groups = groups, -- all (basic) spools to the creative inventory
    });
  end
  
  -- fabric
  local inv_img = "(clothing_fabric.png^[multiply:#"..data.hex..")";
  if data.hex2 then
    inv_img = inv_img.."^(((clothing_fabric.png^clothing_inv_second_color.png)^[makealpha:0,0,0)^[multiply:#"..data.hex2..")";
  end
  if data.in_creative_inventory or not data.hex2 then
    groups = nil
  elseif not groups then
    groups = {not_in_creative_inventory = 1}
  end
  minetest.register_craftitem("clothing:fabric_"..color, {
    description = desc.."á látka",
    inventory_image = inv_img,
    groups = groups,
  });
  if data.alias then
    minetest.register_alias("clothing:fabric_"..data.alias, "clothing:fabric_"..color)
  end
end



local S = clothing.translator;

local groups_yarn = {clothing_yarn = 1}
local groups_fabric_singlecolor = {clothing_fabric = 1, clothing_fabric_singlecolor = 1}
local groups_fabric_squared = {clothing_fabric = 1, clothing_fabric_squared = 1}
local groups_fabric_stripy = {clothing_fabric = 1, clothing_fabric_stripy = 1}

minetest.register_craftitem("clothing:yarn_spool_empty", {
	description = S("Empty yarn spool"),
	inventory_image = "clothing_yarn_spool_empty.png",
})

minetest.register_craftitem("clothing:bone_needle", {
	description = S("Bone needle"),
	inventory_image = "clothing_bone_needle.png",
})

for color, data in pairs(clothing.colors) do
	local desc = data.color;
	local groups

	if data.hex2 == nil then
		-- yarn
		minetest.register_craftitem("clothing:yarn_spool_"..color, {
			description = "cívka "..desc.."é nitě",
			inventory_image = "clothing_yarn_spool_empty.png^(clothing_yarn_spool_fill.png^[multiply:#"..data.hex..")",
			groups = groups_yarn,
		})
	end

	-- fabric
	local description
	local inv_img = "(clothing_fabric.png^[multiply:#"..data.hex..")";
	if data.hex2 then
		description = "kostičkovaná "..data.color.."á látka"
		inv_img = inv_img.."^(((clothing_fabric.png^clothing_inv_second_color.png)^[makealpha:0,0,0)^[multiply:#"..data.hex2..")";
		groups = groups_fabric_squared
	else
		description = data.color.."á látka"
		groups = groups_fabric_singlecolor
	end
	minetest.register_craftitem("clothing:fabric_"..color, {
		description = description,
		inventory_image = inv_img,
		groups = groups,
	})
	if data.alias then
		minetest.register_alias("clothing:fabric_"..data.alias, "clothing:fabric_"..color)
	end

	if data.hex2 then
		minetest.register_craftitem("clothing:fabric_"..color.."_stripy", {
			description = "pruhovaná "..desc.."á látka",
			inventory_image = "(clothing_fabric.png^[multiply:#"..data.hex..")^(((clothing_fabric.png^clothing_inv_stripy_second_color.png)^[makealpha:0,0,0)^[multiply:#"..data.hex2..")",
			groups = groups_fabric_stripy,
		})
	end
end


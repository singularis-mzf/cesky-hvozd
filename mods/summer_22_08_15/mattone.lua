local mattones = {
	mattoneA = {
		description = "bledá cihla",
		image = "mattoneA.png^[transformFX",
		recipe_item = "jonez:marble",
	},
	mattoneG = {
		description = "šedá cihla",
		image = "mattone.png^[transformFX",
		recipe_item = "moreblocks:grey_bricks",
	},
	mattoneP = {
		description = "růžová cihla",
		image = "mattoneP.png^[transformFX",
		recipe_item = "dye:pink",
	},
	mattoneR = {
		description = "oranžová cihla",
		image = "mattoneR.png^[transformFX",
		recipe_item = "building_blocks:Adobe",
	},
}

local brick = "default:clay_brick"
local brick_row = {brick, brick, brick}

for name, data in pairs(mattones) do
	minetest.register_craftitem("summer:"..name, {
		description = data.description,
		inventory_image = data.image,
	})

	if data.recipe_item ~= nil then
		minetest.register_craft({
			output = "summer:"..name.." 9",
			recipe = {
				brick_row,
				{brick, data.recipe_item, brick},
				brick_row,
			},
		})
	end
end

minetest.register_craft({
	output = "summer:mattoneR 9",
	recipe = {
		brick_row,
		{brick, "cottages:loam", brick},
		brick_row,
	},
})


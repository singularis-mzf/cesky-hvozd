ch_base.open_mod(minetest.get_current_modname())
-- Minetest 0.4 mod: bucket
-- See README.txt for licensing and other information.


bucket.register_empty_bucket("bucket_wooden:bucket_empty", {
	description = "prázdné vědro",
	inventory_image = "bucket_wooden.png",
	node_name = "bucket_wooden:bucket_empty_placed",
})

bucket.register_full_bucket("bucket_wooden:bucket_water", "bucket_wooden:bucket_empty", "default:water_source", {
	description = "vědro vody",
	flowing = "default:water_flowing",
	inventory_image = "bucket_wooden_water.png",
	groups = {water_bucket = 1},
	node_name = "bucket_wooden:bucket_water_placed",
})

bucket.register_full_bucket("bucket_wooden:bucket_river_water", "bucket_wooden:bucket_empty", "default:river_water_source", {
	description = "vědro říční vody",
	flowing = "default:river_water_flowing",
	inventory_image = "bucket_wooden_river_water.png",
	groups = {water_bucket = 1},
	node_name = "bucket_wooden:bucket_river_water_placed",
	force_renew = true,
})

minetest.register_craft({
	output = 'bucket_wooden:bucket_empty 1',
	recipe = {
		{'group:wood', '', 'group:wood'},
		{'', 'group:wood', ''},
	}
})

if minetest.registered_items["farming:bowl"] then
	minetest.register_craft({
		output = 'farming:bowl 4',
		recipe = {'bucket_wooden:bucket_empty'},
		type = 'shapeless',
	})
end

if minetest.registered_items["ethereal:bowl"] then
	minetest.register_craft({
		output = 'ethereal:bowl 4',
		recipe = {'bucket_wooden:bucket_empty'},
		type = 'shapeless',
	})
end

minetest.register_craft({
	type = "fuel",
	recipe = "bucket_wooden:bucket_empty",
	burntime = 22,
})

ch_base.close_mod(minetest.get_current_modname())

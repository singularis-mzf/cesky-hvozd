minetest.register_craftitem("summer:mattoneG", {
	description = "Mattone",
	inventory_image = "mattone.png",
	
})
    minetest.register_craftitem("summer:mattoneR", {
	description = "MattoneR",
	inventory_image = "mattoneR.png",
	
})
minetest.register_craftitem("summer:mattoneA", {
	description = "MattoneA",
	inventory_image = "mattoneA.png",
	
})    
    minetest.register_craftitem("summer:mattoneP", {
	description = "MattoneP",
	inventory_image = "mattoneP.png",
	
})    
--craftMATTONE

minetest.register_craft({
	type = 'cooking',
	recipe = "summer:pietraA",
	cooktime = 2,
	output = "summer:mattoneA",
})
minetest.register_craft({
	type = 'cooking',
	recipe = "summer:pietra",
	cooktime = 2,
	output = "summer:mattoneG",
})
minetest.register_craft({
	type = 'cooking',
	recipe = "summer:desert_pietra",
	cooktime = 2,
	output = "summer:mattoneR",
})
minetest.register_craft({
	type = 'cooking',
	recipe = "summer:pietraP",
	cooktime = 2,
	output = "summer:mattoneP",
})

--cute block
minetest.register_craft({
	output = "cutepie:cute_block 6",
	recipe = {
		{'wool:black', 'wool:yellow', 'wool:black'},
		{'wool:yellow', 'wool:yellow', 'wool:yellow'},
		{'wool:black', 'wool:yellow', 'wool:black'}
	}
})

--cute block 2
minetest.register_craft({
	output = "cutepie:cute_block2 6",
	recipe = {
		{'wool:pink', 'wool:violet', 'wool:pink'},
		{'wool:violet', 'wool:violet', 'wool:violet'},
		{'wool:pink', 'wool:violet', 'wool:pink'}
	}
})

--cute cobble
minetest.register_craft({
	output = "cutepie:cute_cobble 6",
	recipe = {
		{'dye:red', 'dye:yellow', 'dye:green'},
		{'default:cobble', 'dye:blue', 'default:cobble'},
		{'', '', ''}
	}
})

--cute purple tile
minetest.register_craft({
	output = "cutepie:cute_purple_tile 2",
	recipe = {
		{'dye:red', 'dye:blue', ''},
		{'cutepie:cute_block', 'cutepie:cute_block', ''},
		{'', '', ''}
	}
})

--cute cane
minetest.register_craft({
	output = "cutepie:cute_cane 6",
	recipe = {
		{'wool:red', 'wool:white', 'wool:red'},
		{'wool:white', 'wool:red', ''},
		{'wool:red', '', ''}
	}
})

--cute blocks
minetest.register_craft({
	output = "cutepie:cute_blocks 6",
	recipe = {
		{'cutepie:cute_cobble', 'cutepie:cute_cobble', 'cutepie:cute_cobble'},
		{'cutepie:cute_cobble', 'cutepie:cute_light', 'cutepie:cute_cobble'},
		{'cutepie:cute_cobble', 'cutepie:cute_cobble', 'cutepie:cute_cobble'}
	}
})

--cute light
minetest.register_craft({
	output = "cutepie:cute_light 2",
	recipe = {
		{'wool:yellow', 'default:torch', 'wool:yellow'},
		{'wool:black', 'wool:yellow', 'wool:black'},
		{'wool:yellow', 'default:torch', 'wool:yellow'}
	}
})

--cute pinknblue
minetest.register_craft({
	output = "cutepie:cute_pinknblue 1",
	recipe = {
		{'cutepie:cute_cobble', 'dye:pink', ''},
		{'', '', ''},
		{'', '', ''}
	}
})

--cute blue x
minetest.register_craft({
	output = "cutepie:cute_bluex 1",
	recipe = {
		{'cutepie:cute_pinknblue', '', ''},
		{'', '', ''},
		{'', '', ''}
	}
})
--cute greennorange
minetest.register_craft({
	output = "cutepie:cute_greennorange 1",
	recipe = {
		{'cutepie:cute_cobble', 'dye:orange', ''},
		{'', '', ''},
		{'', '', ''}
	}
})
--cute green x
minetest.register_craft({
	output = "cutepie:cute_greenx 1",
	recipe = {
		{'cutepie:cute_greennorange', '', ''},
		{'', '', ''},
		{'', '', ''}
	}
})

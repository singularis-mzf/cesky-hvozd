-- stairs/init.lua

-- Global namespace for functions

stairs = {
	register_stair = function(subname, recipeitem, groups, images, description, sounds, worldaligntex)
	end,
	register_slab = function(subname, recipeitem, groups, images, description, sounds, worldaligntex)
	end,
	register_stair_inner = function(subname, recipeitem, groups, images, description, sounds, worldaligntex, full_description)
	end,
	register_stair_outer = function(subname, recipeitem, groups, images, description, sounds, worldaligntex, full_description)
	end,
	register_stair_and_slab = function(subname, recipeitem, groups, images, desc_stair, desc_slab, sounds, worldaligntex, desc_stair_inner, desc_stair_outer)
	end,
}

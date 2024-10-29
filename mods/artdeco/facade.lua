if not minetest.global_exists('facade') then return end

local function register(recipe_item)
	local def = minetest.registered_nodes[recipe_item]
	local modname, subname = recipe_item:match("^([^:]+):([^:]+)$")
    facade.register_facade_nodes(modname, subname, recipe_item, def.description or subname)
end

register("artdeco:1e")
register("artdeco:2d")
register("artdeco:italianmarble")

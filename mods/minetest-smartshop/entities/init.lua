smartshop.entities = {
	element_dir = {
	    vector.new(0, 0, -1),
	    vector.new(-1, 0, 0),
	    vector.new(0, 0, 1),
	    vector.new(1, 0, 0),
	},
	entity_offset = vector.new(0.01, 6.5/16, 0.01),
}

local function flip1(x)
	if x == 0 then
		return 0
	else
		return -x
	end
end

local function flip(v)
	return vector.new(flip1(v.x), flip1(v.y), flip1(v.z))
end

for i = 0, 23, 1 do
	smartshop.entities.element_dir[i + 1] = flip(minetest.facedir_to_dir(i))
	--[[ local element_dir = smartshop.entities.element_dir
	print("DEBUG: element_dir["..(i + 1).."] = ("..element_dir[i + 1].x..", "..element_dir[i + 1].y..", "..element_dir[i + 1].z..")") ]]
end

smartshop.dofile("entities", "quad_upright_sprite")
smartshop.dofile("entities", "single_sprite")
smartshop.dofile("entities", "single_upright_sprite")
smartshop.dofile("entities", "single_wielditem")
smartshop.dofile("entities", "remove_legacy_entities")

minetest.register_lbm({
	name = "smartshop:load_shop",
	nodenames = {
        "smartshop:shop",
        "smartshop:shop_full",
        "smartshop:shop_empty",
        "smartshop:shop_used",
        "smartshop:shop_admin"
    },
    run_at_every_load = true,
	action = function(pos, node)
		local shop = smartshop.api.get_object(pos)
		shop:update_appearance()
	end,
})

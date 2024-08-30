-- FLOWERS

local flowers_nodes = {
	"bakedclay:delphinium",
	"bakedclay:mannagrass",
	"bakedclay:thistle",
	"default:fern_1",
	"default:fern_2",
	"default:fern_3",
	"default:grass_1",
	"default:grass_2",
	"default:grass_3",
	"default:grass_4",
	"default:grass_5",
	"default:junglegrass",
	"default:marram_grass_1",
	"default:marram_grass_2",
	"default:marram_grass_3",
	"farming:artichoke_1",
	"farming:artichoke_2",
	"farming:artichoke_3",
	"farming:artichoke_4",
	"farming:artichoke_5",
	"farming:carrot_1",
	"farming:carrot_2",
	"farming:carrot_3",
	"farming:carrot_4",
	"farming:carrot_5",
	"farming:carrot_6",
	"farming:carrot_7",
	"farming:carrot_8",
	"farming:eggplant_1",
	"farming:eggplant_2",
	"farming:eggplant_3",
	"farming:eggplant_4",
	"farming:hemp_1",
	"farming:hemp_2",
	"farming:hemp_3",
	"farming:hemp_4",
	"farming:hemp_5",
	"farming:hemp_6",
	"farming:hemp_7",
	"farming:hemp_8",
	"farming:mint_1",
	"farming:mint_2",
	"farming:mint_3",
	"farming:mint_4",
	"farming:spinach_1",
	"farming:spinach_2",
	"farming:spinach_3",
	"farming:spinach_4",
	"flowers:chrysanthemum_green",
	"flowers:dandelion_white",
	"flowers:dandelion_yellow",
	"flowers:geranium",
	"flowers:mushroom_brown",
	"flowers:mushroom_red",
	"flowers:rose",
	"flowers:tulip",
	"flowers:tulip_black",
	"flowers:viola",
}

local flowers_override = {
	paramtype2 = "meshoptions",
	place_param2 = 8,
}

for _, flower_node in pairs(flowers_nodes) do
	local ndef = minetest.registered_nodes[flower_node]
	if ndef ~= nil and ndef.drawtype == "plantlike" then
		minetest.override_item(flower_node, flowers_override)
	end
end

minetest.register_lbm({
	label = "Upgrade flowers",
	name = "ch_overrides:flowers_1",
	nodenames = flowers_nodes,
	run_at_every_load = false,
	action = function(pos, node, dtime_s)
		if node.param2 ~= 8 then
			node.param2 = 8
			minetest.swap_node(pos, node)
		end
	end,
})

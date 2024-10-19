
local lily = minetest.get_content_id 'flowers:waterlily_waving'

local grassnodes = {
	[minetest.get_content_id 'default:grass_1'] = true,
	[minetest.get_content_id 'default:grass_2'] = true,
	[minetest.get_content_id 'default:grass_3'] = true,
	[minetest.get_content_id 'default:grass_4'] = true,
	[minetest.get_content_id 'default:grass_5'] = true,
	
	[minetest.get_content_id 'default:dry_grass_1'] = true,
	[minetest.get_content_id 'default:dry_grass_2'] = true,
	[minetest.get_content_id 'default:dry_grass_3'] = true,
	[minetest.get_content_id 'default:dry_grass_4'] = true,
	[minetest.get_content_id 'default:dry_grass_5'] = true,

	[minetest.get_content_id 'default:junglegrass'] = true,
	
	[minetest.get_content_id 'default:fern_1'] = true,
	[minetest.get_content_id 'default:fern_2'] = true,
	[minetest.get_content_id 'default:fern_3'] = true,
	
	[minetest.get_content_id 'flowers:geranium'] = true,
	[minetest.get_content_id 'flowers:chrysanthemum_green'] = true,
	[minetest.get_content_id 'flowers:dandelion_yellow'] = true,
	[minetest.get_content_id 'flowers:dandelion_white'] = true,
	[minetest.get_content_id 'flowers:viola'] = true,
	[minetest.get_content_id 'flowers:tulip'] = true,
	[minetest.get_content_id 'flowers:tulip_black'] = true,
	[minetest.get_content_id 'flowers:rose'] = true,
	[minetest.get_content_id 'flowers:waterlily'] = true,
	[lily] = true,
	
	[minetest.get_content_id 'default:leaves'] = true,
	[minetest.get_content_id 'default:acacia_leaves'] = true,
	[minetest.get_content_id 'default:aspen_leaves'] = true,
	[minetest.get_content_id 'default:pine_needles'] = true,
	[minetest.get_content_id 'default:jungleleaves'] = true
}

if minetest.get_modpath 'ebiomes' and minetest.settings: get_bool('awg.load_module_ebiomes', true) then
	grassnodes[minetest.get_content_id 'ebiomes:afzelia_leaves'] = true
	grassnodes[minetest.get_content_id 'ebiomes:alder_leaves'] = true
	grassnodes[minetest.get_content_id 'ebiomes:ash_leaves'] = true
	grassnodes[minetest.get_content_id 'ebiomes:bamboo_leaves'] = true
	grassnodes[minetest.get_content_id 'ebiomes:beech_leaves'] = true
	grassnodes[minetest.get_content_id 'ebiomes:birch_leaves'] = true
	grassnodes[minetest.get_content_id 'ebiomes:chestnut_leaves'] = true
	grassnodes[minetest.get_content_id 'ebiomes:cypress_leaves'] = true
	grassnodes[minetest.get_content_id 'ebiomes:downy_birch_leaves'] = true
	grassnodes[minetest.get_content_id 'ebiomes:hornbeam_leaves'] = true
	grassnodes[minetest.get_content_id 'ebiomes:limba_leaves'] = true
	grassnodes[minetest.get_content_id 'ebiomes:maple_leaves'] = true
	grassnodes[minetest.get_content_id 'ebiomes:mizunara_leaves'] = true
	grassnodes[minetest.get_content_id 'ebiomes:oak_leaves'] = true
	grassnodes[minetest.get_content_id 'ebiomes:olive_leaves'] = true
	grassnodes[minetest.get_content_id 'ebiomes:pear_leaves'] = true
	grassnodes[minetest.get_content_id 'ebiomes:quince_leaves'] = true
	grassnodes[minetest.get_content_id 'ebiomes:siri_leaves'] = true
	grassnodes[minetest.get_content_id 'ebiomes:stoneoak_leaves'] = true
	grassnodes[minetest.get_content_id 'ebiomes:sugi_leaves'] = true
	grassnodes[minetest.get_content_id 'ebiomes:tamarind_leaves'] = true
	grassnodes[minetest.get_content_id 'ebiomes:willow_leaves'] = true
end

minetest.register_on_generated(function(vm, minp, maxp, blockseed)
	local dat = vm: get_data()
	local p2dat = vm: get_param2_data()
	
	local min, max = vm: get_emerged_area()
	local area = VoxelArea(min, max)
	
	for index in area: iterp(minp, maxp) do
		if grassnodes[dat[index]] then
			p2dat[index] = math.random(0, 239)
		end
		
		if dat[index] == lily then
			dat[index] = minetest.get_content_id('flowers:waterlily_waving_' .. math.random(1,4))
		end
	end
	
	vm: set_data(dat)
	vm: set_param2_data(p2dat)
end)

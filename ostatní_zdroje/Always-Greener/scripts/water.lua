
local function get_biome_water_color(pos)
	local biomedat = minetest.get_biome_data(pos)
	
	local heat = biomedat.heat
	local humidity = biomedat.humidity
	
	if pos.y < -15 then
		humidity = math.min(0, humidity + (pos.y * 0.25))
	end
	
	local flowing = minetest.find_node_near(pos, 4, {
		'default:water_flowing', 'default:river_water_flowing'
	})
	
	if flowing then
		local dist = pos: distance(flowing)
		
		if heat > 0 and math.abs(pos.y - flowing.y) < 2 then
			heat = heat - math.max(0, ((5 - dist) * (heat/4)))
		end
		
		if humidity > 0 and math.abs(pos.y - flowing.y) < 2 then
			humidity = humidity - math.max(0, ((5 - dist) * (humidity/4)))
		end
	end
	
	local heat_scaled = math.floor((math.max(0, math.min(heat, 100)) / 100) * 16)
	local humidity_scaled = math.floor((math.max(0, math.min(humidity, 100)) / 100) * 16)
	
	return math.min(255, (16 * humidity_scaled) + math.min(15, heat_scaled))
end

local function water_on_construct (pos)
	local node = minetest.get_node(pos)
	node.param2 = get_biome_water_color(pos)
	minetest.swap_node(pos, node)
end

local alt_map = minetest.settings: get_bool('awg.water_color_dull', false)

minetest.override_item('default:water_source', {
	paramtype2 = 'color',
	color = '#ffffff',
	palette = alt_map and 'awg_water_colormap_2.png' or 'awg_water_colormap.png',
	on_construct = water_on_construct
})

minetest.override_item('default:river_water_source', {
	paramtype2 = 'color',
	color = '#ffffff',
	palette = alt_map and 'awg_water_colormap_2.png' or 'awg_water_colormap.png',
	on_construct = water_on_construct
})

minetest.register_on_liquid_transformed(function(pos_list)
	for i = 1, #pos_list do
		local pos = pos_list[i]
		local nodes = minetest.find_nodes_in_area(pos + vector.new(4, 0, 4), pos - vector.new(4, 0, 4), {'default:water_source', 'default:river_water_source'}, true)
		if nodes['default:water_source'] then
			for _, pos2 in pairs(nodes['default:water_source']) do
				local node = minetest.get_node(pos2)
				local color = get_biome_water_color(pos2)
				if node.param2 ~= color then
					node.param2 = color
					minetest.swap_node(pos2, node)
				end
			end
		end
	end
end)

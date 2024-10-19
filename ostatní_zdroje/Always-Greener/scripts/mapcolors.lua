
local grassnodes = {
	[minetest.get_content_id 'default:dirt_with_grass'] = true,
	[minetest.get_content_id 'always_greener:dry_dirt_with_grass'] = true,
}

local waternodes = {
	[minetest.get_content_id 'default:water_source'] = true,
	[minetest.get_content_id 'default:river_water_source'] = true,
	[minetest.get_content_id 'default:water_flowing'] = true,
	[minetest.get_content_id 'default:river_water_flowing'] = true
}

local alt_chill = minetest.settings: get_bool('awg.grass_alt_chill', true)
local alt_dry = minetest.settings: get_bool('awg.grass_alt_dry', true)
local grass_water_prox = minetest.settings: get_bool('awg.grass_water_prox', true)

local function get_biome_grass_color(pos)
	local biomedat = minetest.get_biome_data(pos)
	
	local heat = biomedat.heat
	local humidity = biomedat.humidity
	
	if pos.y > 80 then
		heat = heat - (alt_chill and ((pos.y - 80) * 0.5) or 0)
		humidity = humidity - (alt_dry and ((pos.y - 80) * 0.75) or 0)
	end
	
	if grass_water_prox then
		local water = minetest.find_node_near(pos, 8, {
			'default:water_source', 'default:river_water_source',
			'default:water_flowing', 'default:river_water_flowing'
		})
		
		if water then
			local dist = pos: distance(water)
			humidity = humidity + (math.max(0, 8 - dist - math.random(0, 1)) * 8)
		end
	end
	
	local heat_scaled = math.floor((math.max(0, math.min(heat, 100)) / 100) * 16)
	local humidity_scaled = math.floor((math.max(0, math.min(humidity, 100)) / 100) * 16)
	
	return math.max(0, math.min(255, (16 * math.min(15, humidity_scaled)) + math.min(15, heat_scaled)))
end

local water_blend_flowing = minetest.settings: get_bool('awg.water_blend_flowing', true)
local water_depth_dry = minetest.settings: get_bool('awg.water_depth_dry', true)
local water_alt_chill = minetest.settings: get_bool('awg.water_alt_chill', true)

local function get_biome_water_color(pos)
	local biomedat = minetest.get_biome_data(pos)
	
	local heat = biomedat.heat
	local humidity = biomedat.humidity
	
	if water_alt_chill and pos.y > 90 then
		heat = heat - ((pos.y - 90) * 0.75) or 0
		humidity = humidity - ((pos.y - 90) * 0.75) or 0
	end
	
	if water_depth_dry and pos.y < -15 then
		humidity = math.min(0, humidity + (pos.y * 0.25))
	end
	
	if water_blend_flowing then
		local flowing = minetest.find_node_near(pos, 6, {
			'default:water_flowing', 'default:river_water_flowing'
		})
		
		if flowing then
			local dist = pos: distance(flowing)
			
			if heat > 0 and math.abs(pos.y - flowing.y) < 2 then
				heat = heat - math.max(0, ((7 - dist) * (heat/6)))
			end
			
			if humidity > 0 and math.abs(pos.y - flowing.y) < 2 then
				humidity = humidity - math.max(0, ((7 - dist) * (humidity/6)))
			end
		end
	end
	local heat_scaled = math.floor((math.max(0, math.min(heat, 100)) / 100) * 16)
	local humidity_scaled = math.floor((math.max(0, math.min(humidity, 100)) / 100) * 16)
	
	
	return math.max(0, math.min(255, (16 * math.min(15, humidity_scaled)) + math.min(15, heat_scaled)))
end

local water_color = minetest.settings: get_bool('awg.water_color', true)

minetest.register_on_generated(function(vm, minp, maxp, blockseed)
	local dat = vm: get_data()
	local p2dat = vm: get_param2_data()
	
	local min, max = vm: get_emerged_area()
	local area = VoxelArea(min, max)
	
	for index in area: iterp(minp, maxp) do
		if grassnodes[dat[index]] then
			p2dat[index] = get_biome_grass_color(area: position(index))
		end
		
		if water_color and waternodes[dat[index]] then
			p2dat[index] = get_biome_water_color(area: position(index))
		end
	end
	
	vm: set_data(dat)
	vm: set_param2_data(p2dat)
end)

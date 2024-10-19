
local biome_defs = {}

biome_defs[minetest.get_biome_id 'grassland'] = minetest.settings: get_bool('awg.grassland_marsh', true) and {
	remove = {
		[minetest.get_content_id 'default:grass_1'] = true,
		[minetest.get_content_id 'default:grass_2'] = true,
		[minetest.get_content_id 'default:grass_3'] = true,
		[minetest.get_content_id 'default:grass_4'] = true,
		[minetest.get_content_id 'default:grass_5'] = true,
		[minetest.get_content_id 'always_greener:grass_6'] = true,
		[minetest.get_content_id 'always_greener:grass_7'] = true,
		
		[minetest.get_content_id 'flowers:dandelion_white'] = true,
		[minetest.get_content_id 'flowers:dandelion_yellow'] = true,
		[minetest.get_content_id 'flowers:rose'] = true,
		[minetest.get_content_id 'flowers:tulip'] = true,
		[minetest.get_content_id 'flowers:tulip_black'] = true,
		[minetest.get_content_id 'flowers:viola'] = true,
		
		[minetest.get_content_id 'always_greener:sage'] = true
	},
	replace = {
		[minetest.get_content_id 'default:dirt_with_grass'] = {
			{
				node = minetest.get_content_id 'default:water_source',
				chance = 4,
				air_above = true,
				surrounded = true,
				adjacent = {
					[minetest.get_content_id 'default:dirt_with_grass'] = true,
					[minetest.get_content_id 'default:dirt'] = true
				}
			}
		}
	},
	decorations = {
		[minetest.get_content_id 'default:dirt_with_grass'] = {
			{
				node = {
					minetest.get_content_id 'always_greener:bulrush_1',
					minetest.get_content_id 'always_greener:bulrush_2'
				},
				chance = 2,
				random_rot = true
			},
			{
				node = {
					minetest.get_content_id 'always_greener:cane_bottom',
					minetest.get_content_id 'always_greener:cane_middle',
					minetest.get_content_id 'always_greener:cane_top'
				},
				chance = 4,
				height = 3,
				top_chance = 2,
				random_rot = true
			},
			{
				node = {
					minetest.get_content_id 'always_greener:marshgrass_1',
					minetest.get_content_id 'always_greener:marshgrass_2',
					minetest.get_content_id 'always_greener:marshgrass_3'
				},
				chance = 1,
				random_rot = true
			},
		}
	}
}

local noise = minetest.get_perlin {
	seed = 2938,
	offset = 0.5,
	scale = 0.665,
	spread = {x = 110, y = 110, z = 110},
	octaves = 3,
	persist = 0.54
}

local air = minetest.get_content_id 'air'

minetest.register_on_generated(function(vm, minp, maxp, blockseed)
	local dat = vm: get_data()
	local dat2 = vm: get_data()
	local p2dat = vm: get_param2_data()
	
	local min, max = vm: get_emerged_area()
	local area = VoxelArea(min, max)
	
	for index in area: iterp(minp, maxp) do
		local pos = area: position(index)
		local bdata = minetest.get_biome_data(pos)
		local biomedef = biome_defs[bdata.biome]
		local in_sub_biome = biomedef and (noise: get_3d(pos) > 1.1 - (math.random() * 0.15))
		
		if in_sub_biome then
			if biomedef.remove[dat[index]] then
				dat2[index] = air
			end
			
			local replace = biomedef.replace[dat[index]]
			if type(replace) == 'number' then
				dat2[index] = replace
			elseif type(replace) == 'table' then
				local rule = replace[math.random(1, #replace)]
				if rule and math.random(1, rule.chance) == 1 then
					local allow = true
					
					if rule.air_above and dat[index+area.ystride] ~= air then
						allow = false
					end
					
					if rule.adjacent then
						if rule.surrounded then
							local a = dat[index+1]
							local b = dat[index-1]
							local c = dat[index+area.zstride]
							local d = dat[index-area.zstride]
							
							if not (
								rule.adjacent[a] and
								rule.adjacent[b] and
								rule.adjacent[c] and
								rule.adjacent[d]
							) then
								allow = false
							end
						else
							local adjacent = minetest.find_node_near(pos, 1.5, rule.adjacent)
							if not adjacent then allow = false end
						end
					end
					
					if allow then
						dat2[index] = rule.node
					end
				end
			end
		end
	end
	
	for index in area: iterp(minp, maxp) do
		local pos = area: position(index)
		local bdata = minetest.get_biome_data(pos)
		local biomedef = biome_defs[bdata.biome]
		local in_sub_biome = biomedef and (noise: get_3d(pos) > 1.1 - (math.random() * 0.15))
		
		if in_sub_biome then
			local deco = biomedef.decorations[dat2[index]]
			if deco then
				for _, rule in ipairs(deco) do
					if math.random(1, rule.chance) == 1 then
						if rule.height then
							local rotation = 0
							if rule.random_rot then
								rotation = math.random(0, 239)
							end
							
							local height = math.random(1, rule.height)
							
							if #rule.node > 1 then
								local bottom = rule.node[1]
								local middle = rule.node[2]
								local top    = rule.node[3]
								
								if dat2[index+area.ystride] == air then
									dat2[index+area.ystride] = bottom
									p2dat[index+area.ystride] = rotation
									
									local mid_success = true
									for i = 2, height+1 do
										local newind = index+(area.ystride*i)
										if dat2[newind] == air then
											dat2[newind] = middle
											p2dat[newind] = rotation
										else
											mid_success = false
											break
										end
									end
									
									local topind = index+(area.ystride*(height+2))
									if mid_success and ((not rule.top_chance) or math.random(1, rule.top_chance) == 1) and dat2[topind] == air then
										dat2[topind] = top
										p2dat[topind] = rotation
									end
								end
							else
								for i = 1, height do
									local newind = index+(area.ystride*i)
									if dat2[newind] == air then
										dat2[newind] = type(rule.node) == 'number' and rule.node or rule.node[math.random(1, #rule.node)]
									end
								end
							end
						else
							if dat2[index+area.ystride] == air then
								dat2[index+area.ystride] = type(rule.node) == 'number' and rule.node or rule.node[math.random(1, #rule.node)]
								
								if rule.random_rot then
									p2dat[index+area.ystride] = math.random(0, 239)
								end
							end
						end
						
						break
					end
				end
			end
		end
	end
	
	vm: set_data(dat2)
	vm: set_param2_data(p2dat)
end)

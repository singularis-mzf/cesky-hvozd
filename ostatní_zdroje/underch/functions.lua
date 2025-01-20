underch.functions = {}

function underch.functions.make_permanent_fire(pos, igniter)
	local flame_pos = {x = pos.x, y = pos.y + 1, z = pos.z}
	if minetest.get_node(flame_pos).name == "air" then
		minetest.set_node(flame_pos, {name = "fire:permanent_flame"})
	end
end

function underch.functions.remove_permanent_fire(pos, oldnode)
	pos.y = pos.y + 1
	if minetest.get_node(pos).name == "fire:permanent_flame" then
		minetest.remove_node(pos)
	end
end


function underch.functions.get_pressure(h, r)
	local x = h / -1000
	r = (r+1);
	-- Some precalculated magic numbers
	local top = 0
	local bottom = 0
	if x < 12 then
		if x < 0 then
			top = 0.01075*x - 0.66667
		else
			if x < 2 then
				top = 0.16667*x - 0.66667
			else
				top = 0.03333*x - 0.4
			end
		end
	else
		if x < 25 then
			if x < 20 then
				top = 0.04167*x - 0.5
			else
				top = 0.06667*x - 1
			end
		else
			top = 0.05556*x - 0.72222
		end
	end
	if x < 20 then
		if x < 0.2 then
			bottom = 0.01068*x - 0.6688
		else
			if x < 10 then
				bottom = 0.03401*x - 0.67347
			else
				bottom = 0.03333*x - 0.66667
			end
		end
	else
		if x < 25 then
			bottom = 0.06667*x - 1.33333
		else
			bottom = 0.05556*x - 1.05556
		end
	end
	local pressure = (r*top + (1-r)*bottom)*2
	if h > 0 then
		pressure = math.min(pressure, -0.8)
	end
	return pressure
end

if underch.polynomial_pressure then
	underch.functions.get_pressure = function(h, r)
		local x = h / -1000
		r = (r+1);
		-- Some precalculated magic numbers
		local top = -0.5 + (x + 1.0)*(0.1388888889 + (x - 0.2)*(-0.01543209878 + (x - 2.0)*(0.0006921306369 + (x - 12.0)*(-0.00001692713955 + (x - 20.0)*(1.781544043E-7 + (x - 25.0)*2.521866255E-9)))))
		local bottom = -0.5 + (x + 1.0)*(0.08333333335 + (x - 1.0)*(-0.005892255893 + (x - 10.0)*(0.0002759423812 + (x - 20.0)*(-0.000008676346390 + (x - 25.0)*(1.290608758E-7 + (x - 32.0)*6.980982443E-9)))))
		local pressure = (r*top + (1-r)*bottom)*2
		if h > 0 then
			pressure = math.min(pressure, -0.8)
		end
		return pressure
	end
end

function underch.functions.get_biome(darkness, water, pressure)
	darkness = math.min(math.max(darkness, -0.999), 0.999)
	water = math.min(math.max(water, -0.999), 0.999)
	pressure = math.floor(math.min(math.max((pressure + 1)*3, 0), 5))

	--print("" + darkness + " " + water + " " + pressure)

	if pressure < 3 then
		darkness = math.floor((darkness + 1)*2)
		water = math.floor((water + 1)*2)
		return pressure*16 + water*4 + darkness
	elseif pressure == 3 then
		darkness = math.floor((darkness + 1)*1.5)
		water = math.floor((water + 1)*1.5)
		return 48 + water*3 + darkness
	elseif pressure == 4 then
		darkness = math.floor(darkness + 1)
		water = math.floor(water + 1)
		return 57 + water*2 + darkness
	else
		return 61
	end
end

function underch.functions.replace(vi, data, def1, def2)
	if data[vi] == def1 then
		data[vi] = def2
	end
end

function underch.functions.ore(vi, data, def1, def2, chance)
	if data[vi] == def1 and math.random() < chance then
		data[vi] = def2
	end
end

function underch.functions.on_floor(x, y, z, vi, area, data, def_floor, def1, def2, chance, alt)
	local bi = area:index(x,y-1,z)
	if (data[bi] == def_floor or data[bi] == alt) and data[vi] == def1 and math.random() < chance then
		data[vi] = def2
	end
end

function underch.functions.in_floor(x, y, z, vi, area, data, def_floor, def1, def2, chance, alt)
	local bi = area:index(x,y+1,z)
	if (data[vi] == def_floor or data[vi] == alt) and data[bi] == def1 and math.random() < chance then
		data[vi] = def2
	end
end

function underch.functions.on_floor_rr(x, y, z, vi, area, data, p2data, def_floor, def1, def2, chance, alt)
	local bi = area:index(x,y-1,z)
	if (data[bi] == def_floor or data[bi] == alt) and data[vi] == def1 and math.random() < chance then
		data[vi] = def2
		p2data[vi] = math.floor(4*math.random())
	end
end

function underch.functions.on_roof(x, y, z, vi, area, data, def_roof, def1, def2, chance, lastlayer, alt)
	local bi = area:index(x,y+1,z)
	if (not lastlayer) and (data[bi] == def_roof or data[bi] == alt) and data[vi] == def1 and math.random() < chance then
		data[vi] = def2
	end
end

function underch.functions.in_roof(x, y, z, vi, area, data, def_floor, def1, def2, chance, lastlayer, alt)
	local bi = area:index(x,y-1,z)
	if (not lastlayer) and (data[vi] == def_floor or data[vi] == alt) and data[bi] == def1 and math.random() < chance then
		data[vi] = def2
	end
end

function underch.functions.on_wall_f(x, y, z, vi, area, data, p2data, def_wall, def1, def2, chance, lastlayer, alt)
	if data[vi] ~= def1 or math.random() > chance then
		return
	end
	
	local dirs = {}
	local dirs_c = 0

	if data[area:index(x,y-1,z)] == def_wall or data[area:index(x,y-1,z)] == alt then
		dirs[dirs_c] = 0
		dirs_c = dirs_c + 1
	end

	if data[area:index(x,y,z-1)] == def_wall or data[area:index(x,y,z-1)] == alt then
		dirs[dirs_c] = 4
		dirs_c = dirs_c + 1
	end

	if data[area:index(x,y,z+1)] == def_wall or data[area:index(x,y,z+1)] == alt then
		dirs[dirs_c] = 8
		dirs_c = dirs_c + 1
	end

	if data[area:index(x-1,y,z)] == def_wall or data[area:index(x-1,y,z)] == alt then
		dirs[dirs_c] = 12
		dirs_c = dirs_c + 1
	end

	if data[area:index(x+1,y,z)] == def_wall or data[area:index(x+1,y,z)] == alt then
		dirs[dirs_c] = 16
		dirs_c = dirs_c + 1
	end

	if (data[area:index(x,y+1,z)] == def_wall or data[area:index(x,y+1,z)] == alt) and (not lastlayer) then
		dirs[dirs_c] = 20
		dirs_c = dirs_c + 1
	end

	if dirs_c == 0 then
		return
	end

	data[vi] = def2
	p2data[vi] = dirs[math.floor(dirs_c*math.random())] + math.floor(4*math.random())
end

function underch.functions.on_wall_w(x, y, z, vi, area, data, p2data, def_wall, def1, def2, chance, lastlayer, alt)
	if data[vi] ~= def1 or math.random() > chance then
		return
	end
	
	local dirs = {}
	local dirs_c = 0

	if (data[area:index(x,y+1,z)] == def_wall or data[area:index(x,y+1,z)] == alt) and (not lastlayer) then
		dirs[dirs_c] = 0
		dirs_c = dirs_c + 1
	end

	if data[area:index(x,y-1,z)] == def_wall or data[area:index(x,y-1,z)] == alt then
		dirs[dirs_c] = 1
		dirs_c = dirs_c + 1
	end

	if data[area:index(x+1,y,z)] == def_wall or data[area:index(x+1,y,z)] == alt then
		dirs[dirs_c] = 2
		dirs_c = dirs_c + 1
	end

	if data[area:index(x-1,y,z)] == def_wall or data[area:index(x-1,y,z)] == alt then
		dirs[dirs_c] = 3
		dirs_c = dirs_c + 1
	end

	if data[area:index(x,y,z+1)] == def_wall or data[area:index(x,y,z+1)] == alt then
		dirs[dirs_c] = 4
		dirs_c = dirs_c + 1
	end

	if data[area:index(x,y,z-1)] == def_wall or data[area:index(x,y,z-1)] == alt then
		dirs[dirs_c] = 5
		dirs_c = dirs_c + 1
	end

	if dirs_c == 0 then
		return
	end

	data[vi] = def2
	p2data[vi] = dirs[math.floor(dirs_c*math.random())]
end

function underch.functions.is_crust(x, y, z, vi, area, data, stone)
	local dai = data[area:index(x+1,y,z)]
	if (dai ~= underch.c_crust and dai ~= underch.c_bulk and dai ~= stone) then
		return true
	end

	dai = data[area:index(x-1,y,z)]
	if (dai ~= underch.c_crust and dai ~= underch.c_bulk and dai ~= stone) then
		return true
	end

	dai = data[area:index(x,y+1,z)]
	if (dai ~= underch.c_crust and dai ~= underch.c_bulk and dai ~= stone) then
		return true
	end

	dai = data[area:index(x,y-1,z)]
	if (dai ~= underch.c_crust and dai ~= underch.c_bulk and dai ~= stone) then
		return true
	end

	dai = data[area:index(x,y,z+1)]
	if (dai ~= underch.c_crust and dai ~= underch.c_bulk and dai ~= stone) then
		return true
	end

	dai = data[area:index(x,y,z-1)]
	if (dai ~= underch.c_crust and dai ~= underch.c_bulk and dai ~= stone) then
		return true
	end
	
	return false
end

function underch.functions.register_stairs(id_, groups_, texture_, name_, sounds_)
	if underch.have_stairsredo then
		stairs.register_all(id_, "underch:" .. id_, groups_, texture_, name_ .. " Stair", name_ .. " Slab", sounds_)
	elseif underch.have_moreblocks then
		stairsplus:register_all("underch", id_, "underch:" .. id_, {
			description = name_,
			tiles = texture_,
			groups = groups_,
			sounds = sounds_,
		})
	elseif underch.have_stairs then
		stairs.register_stair_and_slab(id_, "underch:" .. id_, groups_, texture_, name_ .. " Stair", name_ .. " Slab", sounds_)
	end
end

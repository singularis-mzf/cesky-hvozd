ch_core.open_submod("shapes_db", {})

local programs = {
	all = {[""] = true},
	default = {
		[""] = true,
		["micro/"] = true,
		["micro/_1"] = true,
		["micro/_2"] = true,
		["micro/_4"] = true,
		["micro/_12"] = true,
		["micro/_15"] = true,
		["panel/"] = true,
		["panel/_1"] = true,
		["panel/_2"] = true,
		["panel/_4"] = true,
		["panel/_12"] = true,
		["panel/_15"] = true,
		["panel/_special"] = true, -- vychýlená tyč I
		["panel/_l"] = true, -- vychýlená tyč L
		["panel/_l1"] = true, -- rohový panel do tvaru L
		["panel/_wide"] = true,
		["panel/_wide_1"] = true,
		["slab/"] = true,
		["slab/_quarter"] = true,
		["slab/_three_quarter"] = true,
		["slab/_1"] = true,
		["slab/_2"] = true,
		["slab/_14"] = true,
		["slab/_15"] = true,
		["slab/_two_sides"] = true, --deska L (dvě strany)
		["slab/_three_sides"] = true, -- deska rohová (tři strany)
		["slab/_three_sides_u"] = true, -- deska U (tři strany)
		["slab/_triplet"] = true, -- trojitá deska
		["slab/_cube"] = true, -- kvádr
		["slab/_two_sides_half"] = true, -- deska L (dvě strany, seříznutá)
		["slab/_three_sides_half"] = true, -- deska rohová (tři strany, seříznutá)
		["slope/"] = true,
		["slope/_half"] = true,
		["slope/_half_raised"] = true,
		["slope/_inner"] = true,
		["slope/_inner_half"] = true,
		["slope/_inner_half_raised"] = true,
		["slope/_inner_cut"] = true,
		["slope/_inner_cut_half"] = true,
		["slope/_inner_cut_half_raised"] = true,
		["slope/_outer"] = true,
		["slope/_outer_half"] = true,
		["slope/_outer_half_raised"] = true,
		["slope/_outer_cut"] = true,
		["slope/_outer_cut_half"] = true,
		["slope/_cut"] = true,
		["slope/_slab"] = true, -- trojúhelník
		["slope/_tripleslope"] = true,
		["slope/_cut2"] = true, -- šikmá hradba
		["stair/"] = true,
		["stair/_inner"] = true,
		["stair/_outer"] = true,
		["stair/_alt"] = true,
		["stair/_alt_1"] = true,
		["stair/_alt_2"] = true,
		["stair/_alt_4"] = true,
		["stair/_triple"] = true,
		["stair/_chimney"] = true, -- úzký komín
		["stair/_wchimney"] = true, -- široký komín
	},
	slopes_and_slabs = {
		[""] = false,
		["micro/"] = true,
		["slab/"] = true,
		["slab/_quarter"] = true,
		["slab/_three_quarter"] = true,
		["slab/_1"] = true,
		["slab/_2"] = true,
		["slab/_14"] = true,
		["slab/_15"] = true,
		["slope/"] = true,
		["slope/_half"] = true,
		["slope/_half_raised"] = true,
		["slope/_inner"] = true,
		["slope/_inner_half"] = true,
		["slope/_inner_half_raised"] = true,
		["slope/_inner_cut"] = true,
		["slope/_inner_cut_half"] = true,
		["slope/_inner_cut_half_raised"] = true,
		["slope/_outer"] = true,
		["slope/_outer_half"] = true,
		["slope/_outer_half_raised"] = true,
		["slope/_outer_cut"] = true,
		["slope/_outer_cut_half"] = true,
		["slope/_cut"] = true,
		["slope/_slab"] = true,
		["slope/_tripleslope"] = true,
	},
	wool = {
		[""] = false,
		["micro/"] = true,
		["panel/_special"] = true,
		["panel/_l"] = true,
		["panel/"] = true,
		["panel/1"] = true,
		["panel/2"] = true,
		["panel/4"] = true,
		["slab/"] = true,
		["slab/_1"] = true,
		["slab/_2"] = true,
		["slab/_quarter"] = true,
		["slab/_three_quarter"] = true,
		["slab/_14"] = true,
		["slab/_15"] = true,
		["slope/"] = true,
		["slope/_half"] = true,
		["slope/_half_raised"] = true,
		["slope/_slab"] = true,
	},
}

local materials = {
	[""] = "default",
	["default:stone"] = "default",
	["default:wood"] = "all",

	["ch_extras:bright_gravel"] = "slopes_and_slabs",
	["ch_extras:railway_gravel"] = "slopes_and_slabs",
	["default:desert_sand"] = "slopes_and_slabs",
	["default:dirt_with_coniferous_litter"] = "slopes_and_slabs",
	["default:dirt_with_grass"] = "slopes_and_slabs",
	["default:dirt_with_rainforest_litter"] = "slopes_and_slabs",
	["default:dry_dirt"] = "slopes_and_slabs",
	["default:dry_dirt_with_dry_grass"] = "slopes_and_slabs",
	["default:gravel"] = "slopes_and_slabs",
	["default:sand"] = "slopes_and_slabs",
	["default:silver_sand"] = "slopes_and_slabs",
	["default:snowblock"] = "slopes_and_slabs",
	["farming:hemp_block"] = "slopes_and_slabs",
	["farming:straw"] = "slopes_and_slabs",
	["mobs:honey_block"] = "slopes_and_slabs",
	["moretrees:ebony_trunk_allfaces"] = "slopes_and_slabs",
	["moretrees:poplar_trunk_allfaces"] = "slopes_and_slabs",
	["summer:sabbia_mare"] = "slopes_and_slabs",

	["moretrees:chestnut_tree_planks"] = "default",
	["wool:black"] = "wool",
	["wool:blue"] = "wool",
	["wool:brown"] = "wool",
	["wool:cyan"] = "wool",
	["wool:dark_green"] = "wool",
	["wool:dark_grey"] = "wool",
	["wool:green"] = "wool",
	["wool:grey"] = "wool",
	["wool:magenta"] = "wool",
	["wool:orange"] = "wool",
	["wool:pink"] = "wool",
	["wool:purple"] = "wool",
	["wool:red"] = "wool",
	["wool:violet"] = "wool",
	["wool:white"] = "wool",
	["wool:yellow"] = "wool",
}

local custom_list_cache

local function resolve_shape(program, shape)
	local prog = assert(programs[program])
	for i = 1, 16 do
		local result = prog[shape]
		if result == true or result == false then
			return result
		end
		result = prog[""]
		if result == true or result == false then
			return result
		end
		if result == nil then
			return false
		end
		if type(result) ~= "string" then
			error("Invalid type '"..type(result).."'!")
		end
		prog = programs[result]
		if prog == nil then
			error("Program '"..result.."' not found!")
		end
	end
	minetest.log("warning", "Resolve overflow in resolve_shape("..program..", "..shape..")!")
	return false
end

function ch_core.get_stairsplus_custom_shapes(recipeitem)
	if custom_list_cache == nil then
		error("custom_list_cache is not initialized yet!")
	end
	local program_name = materials[recipeitem] or materials[""]
	assert(programs[program_name])
	return custom_list_cache[program_name]
end

function ch_core.init_stairsplus_custom_shapes(defs)
	local set = {}
	local custom_list_shapes = {}
	for category, cdef in pairs(defs) do
		for alternate, _ in pairs(cdef) do
			local key = category.."/"..alternate
			if set[key] == nil then
				set[key] = true
				table.insert(custom_list_shapes, {category, alternate})
			end
		end
	end
	local cache = {}
	for program, _ in pairs(programs) do
		local pcache = {}
		for _, variant in pairs(custom_list_shapes) do
			if resolve_shape(program, variant[1].."/"..variant[2]) then
				table.insert(pcache, variant)
			end
		end
		cache[program] = pcache
	end
	custom_list_cache = cache
end

function ch_core.is_shape_allowed(recipeitem, shape)
	local program_name = materials[recipeitem] or materials[""]
	assert(programs[program_name])
	return resolve_shape(program_name, shape)
end

function ch_core.get_comboblock_index(v1, v2)
	error("not implemented yet")
end

ch_core.close_submod("shapes_db")

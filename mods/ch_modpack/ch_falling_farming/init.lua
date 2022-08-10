
print("[MOD BEGIN] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")

local modname = minetest.get_current_modname()

-- FALLING NODES
local falling_nodes = {
	"building_blocks:fakegrass",
	"charcoal:charcoal_block",
	"darkage:darkdirt",
	"darkage:mud",
	"darkage:silt",
	"default:clay",
	"default:dirt",
	"default:dirt_with_grass",
	"default:dirt_with_dry_grass",
	"default:dirt_with_snow",
	"default:dirt_with_rainforest_litter",
	"default:dirt_with_coniferous_litter",
	"default:dry_dirt",
	"default:default:dry_dirt_with_dry_grass",
	"farming:soil",
	"farming:soil_wet",
	"farming:dry_soil",
	"farming:dry_soil_wet",
	"molehills:molehill",
}

local def, groups, counter
counter = 0
for _, name in ipairs(falling_nodes) do
	def = minetest.registered_nodes[name]
	if def then
		groups = def.groups
		if groups then
			groups.falling_node = 1
		else
			def.groups = {falling_node = 1}
		end
		counter = counter + 1
	end
end
print("["..modname.."] "..counter.." falling nodes added")

print("[MOD END] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")

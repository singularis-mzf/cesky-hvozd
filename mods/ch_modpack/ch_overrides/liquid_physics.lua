-- LIQUID PHYSICS CHANGES
local nodes = {
	"default:water_flowing",
	"default:river_water_flowing",
}

local override = {
	liquid_move_physics = false,
	move_resistance = 0,
}

for _, name in ipairs(nodes) do
	minetest.override_item(name, override)
end

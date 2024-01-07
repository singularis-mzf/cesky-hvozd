local row_table = {
	[0] = 1,
	[1] = 2,
	[2] = 4,
	[3] = 5,
	[4] = 6,
	[5] = 6,
	[6] = 7,
	[7] = 7,
}

local function convert_split_to_color4dir(node)
	local hue = node.name:gsub(".*_", "")
	local new_name = node.name:sub(1, -#hue - 2)
	local new_dir = (node.param2) % 4
	local new_param2
	if hue == "green" then
		new_param2 = new_dir + 172
	elseif hue == "vermilion" then
		new_param2 = new_dir + 196
	elseif hue == "grey" then
		new_param2 = new_dir
	else
		return nil
	end
	return {name = new_name, param = node.param, param2 = new_param2}
end

local prefixes = {
	"techpack_stairway:grating_",
	"techpack_stairway:handrail1_",
	"techpack_stairway:handrail2_",
	"techpack_stairway:handrail3_",
	"techpack_stairway:handrail4_",
	"techpack_stairway:bridge1_",
	"techpack_stairway:bridge2_",
	"techpack_stairway:bridge3_",
	"techpack_stairway:bridge4_",
	"techpack_stairway:stairway_",
	"techpack_stairway:ladder1_",
	"techpack_stairway:ladder2_",
	"techpack_stairway:ladder3_",
	"techpack_stairway:ladder4_",
}

local nodenames = {}
for _, prefix in ipairs(prefixes) do
	table.insert(nodenames, prefix.."green")
	table.insert(nodenames, prefix.."vermilion")
	table.insert(nodenames, prefix.."grey")
end

local function update_lbm(pos, node, dtime_s)
	local new_node = convert_split_to_color4dir(node)
	if new_node ~= nil then
		minetest.set_node(pos, new_node)
		minetest.log("action", "Node "..node.name.."/"..node.param2.." at "..minetest.pos_to_string(pos).." upgraded to "..new_node.name.."/"..new_node.param2..".")
	else
		minetest.log("warning", "Upgrading of node "..node.name.."/"..node.param2.." at "..minetest.pos_to_string(pos).." failed!")
	end
end

minetest.register_lbm{
	label = "Upgrade split-palette nodes",
	name = "techpack_stairway:upgrade_splits",
	nodenames = nodenames,
	run_at_every_load = true,
	action = update_lbm,
}

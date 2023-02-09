
local Ombrellone_n_list = {
	{ "Red Ombrellone_n", "red"},
	{ "Orange Ombrellone_n", "orange"},
    { "Black Ombrellone_n", "black"},
	{ "Yellow Ombrellone_n", "yellow"},
	{ "Green Ombrellone_n", "green"},
	{ "Blue Ombrellone_n", "blue"},
	{ "Violet Ombrellone_n", "violet"},
	{ "White Ombrellone_n", "white"},
}

for i in ipairs(Ombrellone_n_list) do
	local Ombrellone_ndesc = Ombrellone_n_list[i][1]
	local colour = Ombrellone_n_list[i][2]
	
minetest.register_alias_force("summer:Ombrellone_n_"..colour.."", "summer:ombrellone_n_"..colour.."")
minetest.register_alias_force("summer:Ombrellone_n_"..colour.."_ch", "summer:ombrellone_n_"..colour.."_ch")
end

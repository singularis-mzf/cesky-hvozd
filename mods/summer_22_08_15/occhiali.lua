local Occhiali_list = {
	{ "Red Occhiali", "red"},
	{ "Orange Occhiali", "orange"},
    { "Black Occhiali", "black"},
	{ "Yellow Occhiali", "yellow"},
	{ "Green Occhiali", "green"},
	{ "Blue Occhiali", "blue"},
    { "Jam Occhiali", "jam"},
	{ "Violet Occhiali", "violet"},
}

for i in ipairs(Occhiali_list) do
	local Occhialidesc = Occhiali_list[i][1]
	local colour = Occhiali_list[i][2]
minetest.register_alias("occhiali"..colour.."","summer:occhiali"..colour.."")
if minetest.get_modpath("summer") then
	local stats = {
		Occhialidesc = { name=Occhialidesc, armor=1.8, heal=0, use=650 },
        
	}
	--[[local mats = {
		fibra="cannabis:fibra_ingot",
		tessuto="cannabis:tessuto_ingot",
		foglie="cannabis:foglie_ingot",
		high="cannabis:high_performance_ingot",
	}]]
	for k, v in pairs(stats) do
		minetest.register_tool("summer:occhiali_"..colour.."", {
			description = Occhialidesc,
            tiles= "occhiali_"..colour..".png",
			inventory_image = "occhiali_"..colour.."_inv.png",
			groups = {armor_head=math.floor(5*v.armor), armor_heal=v.heal, armor_use=v.use},
			wear = 0,
		})

end
end

	
end

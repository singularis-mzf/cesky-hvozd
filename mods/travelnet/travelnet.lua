
local default_travelnets = {
	-- "default" travelnet box is blue now
	{ nodename="travelnet:travelnet", colorname="žlutá", color="#e0bb2d", dye="dye:yellow", light_source=0 },
	{ nodename="travelnet:travelnet_red", colorname="červená", color="#ce1a1a", dye="dye:red", light_source=0 },
	{ nodename="travelnet:travelnet_orange", colorname="oranžová", color="#e2621b", dye="dye:orange", light_source=0 },
	{ nodename="travelnet:travelnet_blue", colorname="modrá", color="#0051c5", dye="dye:blue", light_source=0, recipe=travelnet.travelnet_recipe },
	{ nodename="travelnet:travelnet_cyan", colorname="tyrkysová", color="#00a6ae", dye="dye:cyan", light_source=0 },
	{ nodename="travelnet:travelnet_green", colorname="světle zelená", color="#53c41c", dye="dye:green", light_source=0 },
	{ nodename="travelnet:travelnet_dark_green", colorname="tmavě zelená", color="#2c7f00", dye="dye:dark_green", light_source=0 },
	{ nodename="travelnet:travelnet_violet", colorname="fialová", color="#660bb3", dye="dye:violet", light_source=0 },
	{ nodename="travelnet:travelnet_pink", colorname="růžová", color="#ff9494", dye="dye:pink", light_source=0 },
	{ nodename="travelnet:travelnet_magenta", colorname="purpurová", color="#d10377", dye="dye:magenta", light_source=0 },
	{ nodename="travelnet:travelnet_brown", colorname="hnědá", color="#572c00", dye="dye:brown", light_source=0 },
	{ nodename="travelnet:travelnet_grey", colorname="šedá", color="#a2a2a2", dye="dye:grey", light_source=0 },
	{ nodename="travelnet:travelnet_dark_grey", colorname="tmavě šedá", color="#3d3d3d", dye="dye:dark_grey", light_source=0 },
	{ nodename="travelnet:travelnet_black", colorname="černá", color="#0f0f0f", dye="dye:black", light_source=0 },
	{ nodename="travelnet:travelnet_white", colorname="bílá", color="#ffffff", dye="dye:white", light_source=minetest.LIGHT_MAX },
}

for _, cfg in ipairs(default_travelnets) do
	travelnet.register_travelnet_box(cfg)
end

underch.jit = {}
local xoff = math.random()
local yoff = math.random()
local zoff = math.random()

function underch.jit.dig_shadow(pos, oldnode, oldmetadata, digger)
	underch.jit.check_neighbours(pos, false)
end

minetest.register_node("underch:bulk", {
	description = "O_O",
	tiles = {"underch_bulk.png"},
	groups = {jit_shadow = 1},
	is_ground_content = true,
	drop = {},
	diggable = false,
	on_punch = function(pos, node, puncher, pointed_thing)
		underch.jit.reveal(pos, true, false)
	end,
	after_dig_node = underch.jit.dig_shadow,
})

minetest.register_node("underch:crust", {
	description = "o_O",
	tiles = {"underch_crust.png"},
	groups = {jit_shadow = 1},
	is_ground_content = true,
	drop = {},
	diggable = false,
	on_punch = function(pos, node, puncher, pointed_thing)
		underch.jit.reveal(pos, true, false)
	end,
	after_dig_node = underch.jit.dig_shadow,
})

underch.c_bulk = minetest.get_content_id("underch:bulk")
underch.c_crust = minetest.get_content_id("underch:crust")

function underch.jit.use_stone(pos, stone)
	local name = minetest.get_node(pos).name
	if name == "underch:bulk" or name == "underch:crust" then
		minetest.set_node(pos, {name = "underch:" .. stone})
	elseif name == "default:cobble" then
		minetest.set_node(pos, {name = "underch:" .. stone .. "_cobble"})
	end
end

function underch.jit.replace(pos, node1, node2)
	if minetest.get_node(pos).name == node1 then
		minetest.set_node(pos, {name = node2})
	end
end

function underch.jit.ore(pos, node1, node2, chance)
	if (node1 == nil or minetest.get_node(pos).name == node1) and math.random() < chance then
		minetest.set_node(pos, {name = node2})
	end
end

function underch.jit.scatter(pos, y_min, y_max, node1, node2, scarcity, period, period2, period3)
	if (pos.y < y_min) or (pos.y > y_max) then
		return
	end
	if node1 ~= nil and minetest.get_node(pos).name ~= node1 then
		return
	end
	
	local xx = math.abs(pos.x + xoff*period2)
	local yy = math.abs(pos.y + yoff*period3)
	local zz = math.abs(pos.z + zoff*period)
	
	local x_ = (xx % period)/period + (yy % period2)/period2 + (zz % period3)/period3 + xoff/10
	local y_ = (yy % period)/period + (zz % period2)/period2 + (xx % period3)/period3 + yoff/10
	local z_ = (zz % period)/period + (xx % period2)/period2 + (yy % period3)/period3 + zoff/10
	local a = math.tan(math.atan(x_*y_))
	local b = math.tan(math.atan(x_*z_))
	local c = math.tan(math.atan(y_*z_))
	
	local t = math.sqrt(a*b/c) + math.sqrt(a*c/b) + math.sqrt(b*c/a) - math.abs(x_) - math.abs(y_) - math.abs(z_)
	if math.abs(t * 1E17) > scarcity then
		minetest.set_node(pos, {name = node2})
	end
end

function underch.jit.blob(pos, y_min, y_max, node1, node2, size2, period, period2, period3)
	if (pos.y < y_min) or (pos.y > y_max) then
		return
	end
	if node1 ~= nil and minetest.get_node(pos).name ~= node1 then
		return
	end
	
	local xx = math.abs(pos.x + xoff*period3)
	local yy = math.abs(pos.y + yoff*period)
	local zz = math.abs(pos.z + zoff*period2)
	local xn = math.fmod(math.floor(xx/period2)*0.56432123 + xoff,1)
	local yn = math.fmod(math.floor(yy/period2)*0.23478634 + yoff,1)
	local zn = math.fmod(math.floor(zz/period2)*0.35487542 + zoff,1)
	local xr = math.fmod(math.floor(xx/period3)*0.76845311,2) + 1
	local yr = math.fmod(math.floor(yy/period3)*0.35735452,2) + 1
	local zr = math.fmod(math.floor(zz/period3)*0.75343545,2) + 1
	local x_ = (xx % period)/period*xr - yn*zn
	local y_ = (yy % period)/period*yr - xn*zn
	local z_ = (zz % period)/period*zr - zn*yn
	local t1 = x_*x_ + y_*y_ + z_*z_
	
	if (t1 < size2) then
		minetest.set_node(pos, {name = node2})
	end
end

underch.jit.biomegen = {
	--dolomite
	[1] = function(pos)
		underch.jit.use_stone(pos, "dolomite")
	end,
	--limestone
	[2] = function(pos)
		underch.jit.use_stone(pos, "limestone")
	end,
	--schist
	[3] = function(pos)
		underch.jit.use_stone(pos, "schist")
	end,
	--andesite
	[4] = function(pos)
		underch.jit.use_stone(pos, "andesite")
	end,
	--phylite
	[5] = function(pos)
		underch.jit.use_stone(pos, "phylite")
	end,
	--quartzite
	[6] = function(pos)
		underch.jit.use_stone(pos, "quartzite")
	end,
	--amphibolite
	[7] = function(pos)
		underch.jit.use_stone(pos, "amphibolite")
	end,
	--slate
	[8] = function(pos)
		underch.jit.use_stone(pos, "slate")
	end,
	--gneiss
	[9] = function(pos)
		underch.jit.use_stone(pos, "gneiss")
	end,
	--phonolite
	[10] = function(pos)
		underch.jit.use_stone(pos, "phonolite")
	end,
	--aplite
	[11] = function(pos)
		underch.jit.use_stone(pos, "aplite")
	end,
	--basalt
	[12] = function(pos)
		underch.jit.use_stone(pos, "basalt")
	end,
	--diorite
	[13] = function(pos)
		underch.jit.use_stone(pos, "diorite")
	end,
	--pegmatite
	[14] = function(pos)
		underch.jit.use_stone(pos, "pegmatite")
	end,
	--granite
	[15] = function(pos)
		underch.jit.use_stone(pos, "granite")
	end,
	--gabbro
	[16] = function(pos)
		underch.jit.use_stone(pos, "gabbro")
	end,
	--cave
	[17] = function(pos)
		underch.jit.use_stone(pos, "dolomite")
		underch.jit.ore(pos, "underch:dolomite", "default:water_source", 1/2000)		
	end,
	--dust
	[18] = function(pos)
		underch.jit.use_stone(pos, "limestone")
	end,
	--coal
	[19] = function(pos)
		underch.jit.use_stone(pos, "amphibolite")
		underch.jit.ore(pos, "underch:amphibolite", "underch:coal_dense_ore", 1/201)
	end,
	--vindesite
	[20] = function(pos)
		underch.jit.use_stone(pos, "vindesite")
		underch.jit.ore(pos, "underch:vindesite", "underch:vindesite_quartz_ore", 1/50)
	end,
	--fungi
	[21] = function(pos)
		underch.jit.use_stone(pos, "phylite")
		underch.jit.ore(pos, "underch:phylite", "default:water_source", 1/2000)		
	end,
	--torchberries
	[22] = function(pos)
		underch.jit.use_stone(pos, "phonolite")
		underch.jit.ore(pos, "underch:phonolite", "default:water_source", 1/2000)		
	end,
	--tubers
	[23] = function(pos)
		underch.jit.use_stone(pos, "schist")
		underch.jit.ore(pos, "underch:schist", "underch:coal_dense_ore", 1/201)
		underch.jit.ore(pos, "underch:schist", "default:water_source", 1/2000)		
	end,
	--black slime
	[24] = function(pos)
		underch.jit.use_stone(pos, "slate")
		underch.jit.blob(pos, -31000, 31000, "underch:slate", "underch:black_slimy_block", 0.7, 17, 18, 19)
		underch.jit.ore(pos, "underch:black_slimy_block", "underch:black_eye_ore", 1/10)
	end,
	--quartz
	[25] = function(pos)
		underch.jit.use_stone(pos, "diorite")
		underch.jit.ore(pos, "underch:diorite", "underch:quartz_ore", 1/50)
		underch.jit.ore(pos, "underch:diorite", "default:water_source", 1/2000)		
	end,
	--emerald
	[26] = function(pos)
		underch.jit.use_stone(pos, "phonolite")
		underch.jit.ore(pos, "underch:phonolite", "underch:emerald_ore", 1/201)
	end,
	--moss
	[27] = function(pos)
		underch.jit.use_stone(pos, "basalt")
		underch.jit.ore(pos, "underch:basalt_cobble", "underch:basalt_mossy_cobble", 3/4)
		underch.jit.ore(pos, "underch:basalt", "default:water_source", 1/2000)		
	end,
	--green slime
	[28] = function(pos)
		underch.jit.use_stone(pos, "green_slimestone")
		underch.jit.blob(pos, -31000, 31000, "underch:green_slimestone", "underch:green_slimy_block", 0.7, 17, 18, 19)
		underch.jit.ore(pos, "underch:green_slimy_block", "underch:green_eye_ore", 1/10)
--		underch.jit.ore(pos, underch.stone.defs["green_slimestone"].base, c_green_slimy_block, 1/1000)
	end,
	--sichamine
	[29] = function(pos)
		underch.jit.use_stone(pos, "sichamine")
		underch.jit.ore(pos, "underch:sichamine", "underch:sichamine_lamp", 1/25)
	end,
	--sichamine shadow
	[30] = function(pos)
		underch.jit.use_stone(pos, "sichamine")
		underch.jit.ore(pos, "underch:sichamine", "underch:dark_sichamine", 1/9)
	end,
	--torchberries + jungle
	[31] = function(pos)
		underch.jit.use_stone(pos, "granite")
		underch.jit.blob(pos, -31000, 31000, "underch:granite", "underch:mossy_dirt", 0.5, 17, 18, 19)
--		underch.jit.ore(vi, data, underch.stone.defs["granite"].base, c_dynamic_mossy_dirt, 1/100)
	end,
	--jungle
	[32] = function(pos)
		underch.jit.use_stone(pos, "andesite")
--		underch.jit.ore(vi, data, underch.stone.defs["andesite"].base, c_dynamic_jungle, 1/100)
		underch.jit.ore(pos, "underch:andesite", "default:water_source", 1/2000)		
	end,
	--lava springs
	[33] = function(pos)
		underch.jit.use_stone(pos, "marble")
		underch.jit.ore(pos, "underch:marble", "default:lava_source", 1/2000)				
	end,
	--flames
	[34] = function(pos)
		underch.jit.use_stone(pos, "phonolite")
	end,
	--fiery vines
	[35] = function(pos)
		underch.jit.use_stone(pos, "schist")
	end,
	--darkness
	[36] = function(pos)
		underch.jit.use_stone(pos, "dark_vindesite")
		underch.jit.ore(pos, "underch:dark_vindesite", "underch:burner", 1/15)
	end,
	--fungi 2
	[37] = function(pos)
		underch.jit.use_stone(pos, "phylite")
		underch.jit.ore(pos, "underch:phylite", "default:water_source", 1/2000)		
	end,
	--omphyrite
	[38] = function(pos)
		underch.jit.use_stone(pos, "omphyrite")
	end,
	--fiery fungi
	[39] = function(pos)
		underch.jit.use_stone(pos, "pegmatite")
	end,
	--purple slime
	[40] = function(pos)
		underch.jit.use_stone(pos, "purple_slimestone")
		underch.jit.blob(pos, -31000, 31000, "underch:purple_slimestone", "underch:purple_slimy_block", 0.7, 17, 18, 19)
		underch.jit.ore(pos, "underch:purple_slimy_block", "underch:purple_eye_ore", 1/10)
	end,
	--mese + saphire
	[41] = function(pos)
		underch.jit.use_stone(pos, "gneiss")
		underch.jit.ore(pos, "underch:gneiss", "underch:saphire_ore", 1/201)
		underch.jit.ore(pos, "underch:gneiss", "default:water_source", 1/2000)		
	end,
	--ruby
	[42] = function(pos)
		underch.jit.use_stone(pos, "granite")
		underch.jit.ore(pos, "underch:granite", "underch:ruby_ore", 1/201)
		underch.jit.ore(pos, "underch:granite", "default:water_source", 1/2000)		
	end,
	--sticks
	[43] = function(pos)
		underch.jit.use_stone(pos, "basalt")
--		underch.jit.ore(vi, data, underch.stone.defs["basalt"].base, c_dynamic_sticks, 1/200)
	end,
	--red slime
	[44] = function(pos)
		underch.jit.use_stone(pos, "red_slimestone")
		underch.jit.blob(pos, -31000, 31000, "underch:red_slimestone", "underch:red_slimy_block", 0.7, 17, 18, 19)
		underch.jit.ore(pos, "underch:red_slimy_block", "underch:red_eye_ore", 1/10)
--		underch.jit.ore(vi, data, underch.stone.defs["red_slimestone"].base, c_red_slimy_block, 1/300)
	end,
	--hot water
	[45] = function(pos)
		underch.jit.use_stone(pos, "sichamine")
		underch.jit.ore(pos, "underch:sichamine", "underch:sichamine_lamp", 1/25)
		underch.jit.ore(pos, "underch:sichamine", "underch:hektorite", 1/50)
		underch.jit.ore(pos, "underch:sichamine", "underch:lava_crack", 1/50)
	end,
	--aquamarine + amethyst
	[46] = function(pos)
		underch.jit.use_stone(pos, "diorite")
		underch.jit.ore(pos, "underch:diorite", "underch:aquamarine_ore", 1/50)
		underch.jit.ore(pos, "underch:diorite", "underch:amethyst_ore", 1/50)
		underch.jit.ore(pos, "underch:diorite", "default:water_source", 1/2000)		
	end,
	--fiery vines + jungle
	[47] = function(pos)
		underch.jit.use_stone(pos, "andesite")
--		underch.jit.ore(pos, "underch:andesite", c_dynamic_jungle, 1/100)
	end,
	--lava + jungle
	[48] = function(pos)
		underch.jit.use_stone(pos, "gabbro")
--		underch.jit.ore(vi, data, underch.stone.defs["gabbro"].base, c_dynamic_jungleg, 1/100)
		underch.jit.ore(pos, "underch:gabbro", "default:lava_source", 1/5000)		
	end,
	--lava cracks
	[49] = function(pos)
		underch.jit.use_stone(pos, "omphyrite")
		underch.jit.ore(pos, "underch:omphyrite", "underch:lava_crack", 1/18)		
		underch.jit.ore(pos, "underch:omphyrite", "default:lava_source", 1/1000)		
	end,
	--diamonds
	[50] = function(pos)
		underch.jit.use_stone(pos, "afualite")
		underch.jit.ore(pos, "underch:afualite", "default:coalblock", 1/18)
		underch.jit.ore(pos, "default:coalblock", "underch:coal_diamond", 1/72)
		underch.jit.ore(pos, "underch:afualite", "default:lava_source", 1/1000)		
	end,
	--vindesite + lava
	[51] = function(pos)
		underch.jit.use_stone(pos, "afualite")
		underch.jit.blob(pos, -31000, 31000, "underch:afualite", "underch:vindesite", 0.5, 17, 18, 19)
		underch.jit.blob(pos, -31000, 31000, "underch:afualite", "underch:dark_vindesite", 0.5, 19, 17, 18)
--		underch.jit.ore(pos, "underch:afualite"].base, c_dynamic_vindesite, 1/300)
--		underch.jit.ore(pos, "underch:afualite"].base, c_dynamic_dark_vindesite, 1/300)		
		underch.jit.ore(pos, "underch:afualite", "default:lava_source", 1/1000)		
	end,
	--copper
	[52] = function(pos)
		underch.jit.use_stone(pos, "gneiss")
		underch.jit.ore(pos, "underch:gneiss", "underch:copper_dense_ore", 1/201)
		underch.jit.ore(pos, "underch:gneiss", "default:lava_source", 1/1000)		
	end,
	--hektorite + lava
	[53] = function(pos)
		underch.jit.use_stone(pos, "hektorite")
		underch.jit.ore(pos, "underch:hektorite", "default:lava_source", 1/1000)		
	end,
	--gold
	[54] = function(pos)
		underch.jit.use_stone(pos, "basalt")
		underch.jit.ore(pos, "underch:basalt", "underch:gold_dense_ore", 1/407)
		underch.jit.ore(pos, "underch:basalt", "default:lava_source", 1/1000)		
	end,
	--quartz + water
	[55] = function(pos)
		underch.jit.use_stone(pos, "sichamine")
		underch.jit.replace(pos, "underch:sichamine", "underch:quartz_block")
		underch.jit.ore(pos, "underch:quartz_block", "underch:aquamarine_block", 1/4)
		underch.jit.ore(pos, "underch:quartz_block", "underch:amethyst_block", 1/3)
		underch.jit.ore(pos, "underch:quartz_block", "underch:sichamine_lamp", 1/25)
	end,
	--iron
	[56] = function(pos)
		underch.jit.use_stone(pos, "granite")
		underch.jit.ore(pos, "underch:granite", "underch:iron_dense_ore", 1/207)
		underch.jit.ore(pos, "underch:granite", "default:lava_source", 1/1000)		
	end,
	--malachite
	[57] = function(pos)
		underch.jit.use_stone(pos, "peridotite")
		underch.jit.blob(pos, -31000, 31000, "underch:peridotite", "underch:malachite", 0.2, 17, 18, 19)
--		underch.jit.ore(pos, "underch:peridotite", c_dynamic_malachite, 1/300)
		underch.jit.ore(pos, "underch:peridotite", "default:lava_source", 1/1000)		
	end,
	--shinestone
	[58] = function(pos)
		underch.jit.use_stone(pos, "hektorite")
		underch.jit.ore(pos, "underch:hektorite", "default:lava_source", 1/300)		
	end,
	--obsidian
	[59] = function(pos)
		underch.jit.use_stone(pos, "afualite")
--		underch.jit.ore(vi, data, underch.stone.defs["afualite"].base, c_dynamic_obsidian, 1/20)		
		underch.jit.ore(pos, "underch:afualite", "default:lava_source", 1/300)		
	end,
	--lava
	[60] = function(pos)
		underch.jit.use_stone(pos, "emutite")
	end,
	--basalt
	[61] = function(pos)
		underch.jit.use_stone(pos, "peridotite")
--		underch.jit.ore(pos, "underch:peridotite", c_dynamic_basalt, 1/200)		
		underch.jit.ore(pos, "underch:peridotite", "default:lava_source", 1/300)		
	end,
	--obscurite
	[62] = function(pos)
		minetest.set_node(pos, {name = "underch:obscurite"})
	end,
}

function underch.jit.gc(pos)
	local node = minetest.get_node(pos).name
	if node == "ignore" then
		return false
	end
	
	local foo = minetest.registered_nodes[node].groups.jit_shadow
	return foo == nil or foo == 0
end

function underch.jit.is_visible(pos)
	return underch.jit.gc({x = pos.x+1, y = pos.y, z = pos.z}) or underch.jit.gc({x = pos.x, y = pos.y+1, z = pos.z}) or underch.jit.gc({x = pos.x, y = pos.y, z = pos.z+1}) or underch.jit.gc({x = pos.x-1, y = pos.y, z = pos.z}) or underch.jit.gc({x = pos.x, y = pos.y-1, z = pos.z}) or underch.jit.gc({x = pos.x, y = pos.y, z = pos.z-1})
end

local node_chulens = {x=3, y=3, z=3}

function underch.jit.reveal(pos, recursive, crust)
	if not underch.jit.is_visible(pos) then
		return false
	end
	
	underch.jit.blob(pos, -31000, 31000, nil, "default:silver_sand", 0.09, 21, 22, 23)
	underch.jit.blob(pos, -31,    31000, nil, "default:dirt", 0.09, 19, 22, 23)
	underch.jit.blob(pos, -31000, 31000, nil, "default:gravel", 0.09, 21, 19, 24)
	underch.jit.blob(pos, -93,    31000, nil, "underch:clay", 0.09, 19, 24, 25)
	underch.jit.blob(pos, -1301,  31000, nil, "underch:mossy_gravel", 0.09, 18, 19, 23)
	underch.jit.blob(pos, -31000, 31000, nil, "default:cobble", 0.09, 20, 21, 19)
	
	underch.jit.scatter(pos, -31000, 64, nil, "default:stone_with_coal", 150, 29, 32, 33)
	underch.jit.scatter(pos, -31000, -20, nil, "default:stone_with_tin", 165, 30, 29, 31)
	underch.jit.scatter(pos, -31000, -20, nil, "default:stone_with_copper", 163, 27, 28, 31)
	underch.jit.scatter(pos, -31000, -40, nil, "default:stone_with_iron", 170, 29, 27, 31)
	underch.jit.scatter(pos, -31000, -250, nil, "default:stone_with_gold", 173, 32, 29, 27)
	underch.jit.scatter(pos, -31000, -500, nil, "default:stone_with_mese", 175, 29, 31, 28)
	underch.jit.scatter(pos, -31000, -500, nil, "default:stone_with_diamond", 180, 32, 31, 29)
	underch.jit.scatter(pos, -31000, -1000, nil, "default:mese", 200, 29, 32, 35)
	
	if underch.have_moreores then
		underch.jit.scatter(pos, -31000, -2, nil, "moreores:mineral_silver", 173, 30, 31, 37)
		underch.jit.scatter(pos, -31000, -512, nil, "moreores:mineral_mithril", 185, 33, 28, 29)
	end
	
	if underch.have_technic_ores then
		underch.jit.scatter(pos, -300, -80, nil, "technic:mineral_uranium", 170, 30, 31, 28)
		underch.jit.scatter(pos, -31000, -80, nil, "technic:mineral_chromium", 170, 28, 31, 33)
		underch.jit.scatter(pos, -31000, -80, nil, "technic:mineral_zinc", 170, 28, 37, 30)
		underch.jit.scatter(pos, -31000, -80, nil, "technic:mineral_lead", 170, 28, 35, 33)
	end
	
	if underch.have_xtraores then
		underch.jit.scatter(pos, -31000, -100, nil, "xtraores:stone_with_platinum", 180, 35, 29, 28)
		underch.jit.scatter(pos, -31000, -1000, nil, "xtraores:stone_with_cobalt", 190, 29, 33, 34)
		underch.jit.scatter(pos, -31000, -2000, nil, "xtraores:stone_with_adamantite", 200, 31, 32, 33)
		underch.jit.scatter(pos, -31000, -5000, nil, "xtraores:stone_with_rarium", 205, 30, 34, 37)
		underch.jit.scatter(pos, -31000, -10000, nil, "xtraores:stone_with_unobtainium", 210, 29, 37, 34)
		underch.jit.scatter(pos, -31000, -15000, nil, "xtraores:stone_with_titanium", 215, 32, 29, 37)
		underch.jit.scatter(pos, -31000, -28000, nil, "xtraores:stone_with_geminitinum", 220, 32, 33, 35)
	end
	
	local darkness = minetest.get_perlin(underch.np_darkness):get_3d(pos)
	local water = minetest.get_perlin(underch.np_water):get_3d(pos)
	local pressure = underch.functions.get_pressure(pos.y, minetest.get_perlin(underch.np_pressure):get_3d(pos))
	
	local biome = underch.functions.get_biome(darkness, water, pressure) + 1
	
	if (biome < 1) or (biome > 62) then
		print(string.format("Wrong biome %i", biome))
		biome = 1
	end
	
	underch.jit.biomegen[biome](pos)
	
	if recursive or (crust and underch.jit.gc(pos)) then
		underch.jit.check_neighbours(pos, crust)
	end
	
	return true
end

function underch.jit.check_neighbours(pos, crust)
	local positions = {}
	
	local i = 1
	local pc = 0
	
	local function add_pos(p)
		positions[pc+1] = {x = p.x+1, y = p.y, z = p.z}
		positions[pc+2] = {x = p.x-1, y = p.y, z = p.z}
		positions[pc+3] = {x = p.x, y = p.y+1, z = p.z}
		positions[pc+4] = {x = p.x, y = p.y-1, z = p.z}
		positions[pc+5] = {x = p.x, y = p.y, z = p.z+1}
		positions[pc+6] = {x = p.x, y = p.y, z = p.z-1}
		pc = pc + 6
	end
	
	add_pos(pos)
	
	while i <= pc do
		local name = minetest.get_node(positions[i]).name
		if name == "underch:bulk" or name == "underch:crust" then
			if underch.jit.reveal(positions[i], false, crust) and (not crust) then
				add_pos(positions[i])
			end
		end
		i = i+1
	end
end

local function add_jit_property(node)
	g = minetest.registered_nodes[node].groups
	g.jit_shadow = 1
	minetest.override_item(node, {groups = g, after_dig_node = underch.jit.dig_shadow})
end

local jit_default = {
	"default:sandstone",
	"default:desert_sandstone",
	"default:silver_sandstone",
	"default:dirt",
	"default:stone",
	"default:cobble",
	"default:desert_stone",
	"default:desert_cobble",
	"default:stone_with_coal",
	"default:stone_with_tin",
	"default:stone_with_copper",
	"default:stone_with_iron",
	"default:stone_with_gold",
	"default:stone_with_mese",
	"default:stone_with_diamond",
}

for _, node in pairs(jit_default) do
	add_jit_property(node)
end

if underch.have_moreores then
	local jit_moreores = {
		"moreores:mineral_silver",
		"moreores:mineral_mithril",
	}

	for _, node in pairs(jit_moreores) do
		add_jit_property(node)
	end
end

if underch.have_technic_ores then
	local jit_technic = {
		"technic:mineral_uranium",
		"technic:mineral_chromium",
		"technic:mineral_zinc",
		"technic:mineral_lead",
	}

	for _, node in pairs(jit_technic) do
		add_jit_property(node)
	end
end

if underch.have_xtraores then
	local jit_xtraores = {
		"xtraores:stone_with_platinum",
		"xtraores:stone_with_cobalt",
		"xtraores:stone_with_adamantite",
		"xtraores:stone_with_rarium",
		"xtraores:stone_with_unobtainium",
		"xtraores:stone_with_titanium",
		"xtraores:stone_with_geminitinum",
	}

	for _, node in pairs(jit_xtraores) do
		add_jit_property(node)
	end
end

minetest.register_lbm{
     	nodenames = {"underch:crust"},
	name = "underch:jit",
	run_at_every_load = true,
	action = function(pos, node)
		if not underch.jit.reveal(pos, false, true) then
			minetest.set_node(pos, {name = "underch:bulk"})
		end
	end,
}

--Override some functions
underch.functions.on_floor = function(x, y, z, vi, area, data, def_floor, def1, def2, chance)
	local bi = area:index(x,y-1,z)
	if (data[bi] == def_floor or data[bi] == underch.c_crust or data[bi] == underch.c_bulk) and data[vi] == def1 and math.random() < chance then
		data[vi] = def2
	end
end

underch.functions.in_floor = function(x, y, z, vi, area, data, def_floor, def1, def2, chance)
	local bi = area:index(x,y+1,z)
	if (data[vi] == def_floor or data[vi] == underch.c_crust or data[bi] == underch.c_bulk) and data[bi] == def1 and math.random() < chance then
		data[vi] = def2
	end
end

underch.functions.on_floor_rr = function(x, y, z, vi, area, data, p2data, def_floor, def1, def2, chance)
	local bi = area:index(x,y-1,z)
	if (data[bi] == def_floor or data[bi] == underch.c_crust or data[bi] == underch.c_bulk) and data[vi] == def1 and math.random() < chance then
		data[vi] = def2
		p2data[vi] = math.floor(4*math.random())
	end
end

underch.functions.on_roof = function(x, y, z, vi, area, data, def_roof, def1, def2, chance, lastlayer)
	local bi = area:index(x,y+1,z)
	if (not lastlayer) and (data[bi] == def_roof or data[bi] == underch.c_crust or data[bi] == underch.c_bulk) and data[vi] == def1 and math.random() < chance then
		data[vi] = def2
	end
end

underch.functions.in_roof = function(x, y, z, vi, area, data, def_floor, def1, def2, chance, lastlayer)
	local bi = area:index(x,y-1,z)
	if (not lastlayer) and (data[vi] == def_floor or data[vi] == underch.c_crust or data[bi] == underch.c_bulk) and data[bi] == def1 and math.random() < chance then
		data[vi] = def2
	end
end

underch.functions.on_wall_f = function(x, y, z, vi, area, data, p2data, def_wall, def1, def2, chance, lastlayer)
	if data[vi] ~= def1 or math.random() > chance then
		return
	end
	
	local dirs = {}
	local dirs_c = 0
	
	local dai = data[area:index(x,y-1,z)]
	if dai == def_wall or dai == underch.c_crust or dai == underch.c_bulk then
		dirs[dirs_c] = 0
		dirs_c = dirs_c + 1
	end

	dai = data[area:index(x,y,z-1)]
	if dai == def_wall or dai == underch.c_crust or dai == underch.c_bulk then
		dirs[dirs_c] = 4
		dirs_c = dirs_c + 1
	end

	dai = data[area:index(x,y,z+1)]
	if dai == def_wall or dai == underch.c_crust or dai == underch.c_bulk then
		dirs[dirs_c] = 8
		dirs_c = dirs_c + 1
	end

	dai = data[area:index(x-1,y,z)]
	if dai == def_wall or dai == underch.c_crust or dai == underch.c_bulk then
		dirs[dirs_c] = 12
		dirs_c = dirs_c + 1
	end

	dai = data[area:index(x+1,y,z)]
	if dai == def_wall or dai == underch.c_crust or dai == underch.c_bulk then
		dirs[dirs_c] = 16
		dirs_c = dirs_c + 1
	end

	dai = data[area:index(x,y+1,z)]
	if (dai == def_wall or dai == underch.c_crust or dai == underch.c_bulk) and (not lastlayer) then
		dirs[dirs_c] = 20
		dirs_c = dirs_c + 1
	end

	if dirs_c == 0 then
		return
	end

	data[vi] = def2
	p2data[vi] = dirs[math.floor(dirs_c*math.random())] + math.floor(4*math.random())
end

underch.functions.on_wall_w = function(x, y, z, vi, area, data, p2data, def_wall, def1, def2, chance, lastlayer)
	if data[vi] ~= def1 or math.random() > chance then
		return
	end
	
	local dirs = {}
	local dirs_c = 0

	local dai = data[area:index(x,y+1,z)]
	if (dai == def_wall or dai == underch.c_crust or dai == underch.c_bulk) and (not lastlayer) then
		dirs[dirs_c] = 0
		dirs_c = dirs_c + 1
	end

	dai = data[area:index(x,y-1,z)]
	if dai == def_wall or dai == underch.c_crust or dai == underch.c_bulk then
		dirs[dirs_c] = 1
		dirs_c = dirs_c + 1
	end

	dai = data[area:index(x+1,y,z)]
	if dai == def_wall or dai == underch.c_crust or dai == underch.c_bulk then
		dirs[dirs_c] = 2
		dirs_c = dirs_c + 1
	end

	dai = data[area:index(x-1,y,z)]
	if dai == def_wall or dai == underch.c_crust or dai == underch.c_bulk then
		dirs[dirs_c] = 3
		dirs_c = dirs_c + 1
	end

	dai = data[area:index(x,y,z+1)]
	if dai == def_wall or dai == underch.c_crust or dai == underch.c_bulk then
		dirs[dirs_c] = 4
		dirs_c = dirs_c + 1
	end

	dai = data[area:index(x,y,z-1)]
	if dai == def_wall or dai == underch.c_crust or dai == underch.c_bulk then
		dirs[dirs_c] = 5
		dirs_c = dirs_c + 1
	end

	if dirs_c == 0 then
		return
	end

	data[vi] = def2
	p2data[vi] = dirs[math.floor(dirs_c*math.random())]
end


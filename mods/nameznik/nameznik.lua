local S = core.get_translator("nameznik")

local nameznik__groups = {dig_immediate=2, not_blocking_trains=1}
local nameznik__simplenodebox = {type = "fixed",fixed = {
            {-0.5, -0.5, -0.1, 0.5, -0.46, 0.1}}}
local nameznik__oldnodebox = {type = "fixed",fixed = {
            {-0.5, -0.5, -0.1, 0.5, -0.49, 0.1},{-0.45, -0.49, -0.075, 0.45, -0.48, 0.075},{-0.4, -0.48, -0.05, 0.4, -0.47, 0.05},{-0.35, -0.47, -0.025, 0.35, -0.46, 0.025}}}
local nameznik__nodebox = {type = "fixed",fixed = {
            {-0.5, -0.5, -0.1, 0.5, -0.496, 0.1},{-0.48, -0.496, -0.09, 0.48, -0.492, 0.09},{-0.46, -0.492, -0.08, 0.46, -0.488, 0.08},{-0.44, -0.488, -0.07, 0.44, -0.484, 0.07},
			{-0.42, -0.484, -0.06, 0.42, -0.48, 0.06},{-0.4, -0.48, -0.05, 0.4, -0.476, 0.05},{-0.38, -0.476, -0.04, 0.38, -0.472, 0.04},{-0.36, -0.472, -0.03, 0.36, -0.468, 0.03},
			{-0.34, -0.468, -0.02, 0.34, -0.464, 0.02},{-0.32, -0.464, -0.01, 0.32, -0.46, 0.01}}}
local nameznik__nodebox_r05 = {type = "fixed",fixed = {
            {0.5+-0.5, -0.5, -0.1, 0.5+0.5, -0.496, 0.1},{0.5+-0.48, -0.496, -0.09, 0.5+0.48, -0.492, 0.09},{0.5+-0.46, -0.492, -0.08, 0.5+0.46, -0.488, 0.08},{0.5+-0.44, -0.488, -0.07, 0.5+0.44, -0.484, 0.07},
			{0.5+-0.42, -0.484, -0.06, 0.5+0.42, -0.48, 0.06},{0.5+-0.4, -0.48, -0.05, 0.5+0.4, -0.476, 0.05},{0.5+-0.38, -0.476, -0.04, 0.5+0.38, -0.472, 0.04},{0.5+-0.36, -0.472, -0.03, 0.5+0.36, -0.468, 0.03},
			{0.5+-0.34, -0.468, -0.02, 0.5+0.34, -0.464, 0.02},{0.5+-0.32, -0.464, -0.01, 0.5+0.32, -0.46, 0.01}}}
local nameznik__nodebox_r1 = {type = "fixed",fixed = {
            {1+-0.5, -0.5, -0.1, 1+0.5, -0.496, 0.1},{1+-0.48, -0.496, -0.09, 1+0.48, -0.492, 0.09},{1+-0.46, -0.492, -0.08, 1+0.46, -0.488, 0.08},{1+-0.44, -0.488, -0.07, 1+0.44, -0.484, 0.07},
			{1+-0.42, -0.484, -0.06, 1+0.42, -0.48, 0.06},{1+-0.4, -0.48, -0.05, 1+0.4, -0.476, 0.05},{1+-0.38, -0.476, -0.04, 1+0.38, -0.472, 0.04},{1+-0.36, -0.472, -0.03, 1+0.36, -0.468, 0.03},
			{1+-0.34, -0.468, -0.02, 1+0.34, -0.464, 0.02},{1+-0.32, -0.464, -0.01, 1+0.32, -0.46, 0.01}}}
local r05h=0.05
local nameznik__nodebox_r05h = {type = "fixed",fixed = {
            {0.5+-0.5, -0.5, -0.1, 0.5+0.5, r05h-0.496, 0.1},{0.5+-0.48, r05h-0.496, -0.09, 0.5+0.48, r05h-0.492, 0.09},{0.5+-0.46, r05h-0.492, -0.08, 0.5+0.46, r05h-0.488, 0.08},{0.5+-0.44, r05h-0.488, -0.07, 0.5+0.44, r05h-0.484, 0.07},
			{0.5+-0.42, r05h-0.484, -0.06, 0.5+0.42, r05h-0.48, 0.06},{0.5+-0.4, r05h-0.48, -0.05, 0.5+0.4, r05h-0.476, 0.05},{0.5+-0.38, -0.476, -0.04, 0.5+0.38, -0.472, 0.04},{0.5+-0.36, -0.472, -0.03, 0.5+0.36, -0.468, 0.03},
			{0.5+-0.34, r05h-0.468, -0.02, 0.5+0.34, r05h-0.464, 0.02},{0.5+-0.32, r05h-0.464, -0.01, 0.5+0.32, r05h-0.46, 0.01}}}
local nameznik__nodebox_r1h = {type = "fixed",fixed = {
            {1+-0.5, -0.5, -0.1, 1+0.5, r05h-0.496, 0.1},{1+-0.48, r05h-0.496, -0.09, 1+0.48, r05h-0.492, 0.09},{1+-0.46, r05h-0.492, -0.08, 1+0.46, r05h-0.488, 0.08},{1+-0.44, r05h-0.488, -0.07, 1+0.44, r05h-0.484, 0.07},
			{1+-0.42, r05h-0.484, -0.06, 1+0.42, r05h-0.48, 0.06},{1+-0.4, r05h-0.48, -0.05, 1+0.4, r05h-0.476, 0.05},{1+-0.38, r05h-0.476, -0.04, 1+0.38, r05h-0.472, 0.04},{1+-0.36, r05h-0.472, -0.03, 1+0.36, r05h-0.468, 0.03},
			{1+-0.34, r05h-0.468, -0.02, 1+0.34, r05h-0.464, 0.02},{1+-0.32, r05h-0.464, -0.01, 1+0.32, r05h-0.46, 0.01}}}
local nameznik__sboxr = {type = "fixed",fixed = {
            {-0.5, -0.5, -0.1, 1, -0.35, 0.1}}}

local function nameznik_regnode(nname, nnum, ndesc, nfront, nside, nback)
	local npalette
	if nname == "nameznik_" then npalette = "nameznik_palette1.png" end
	if nname == "nameznik_konc_" then npalette = "nameznik_palette1.png" end
	if nname == "koncovnik_" then npalette = "nameznik_palette1.png" end
	if nname == "hranicnik" then npalette = "nameznik_palette2.png" end

	minetest.register_node("nameznik:" .. nname .. nnum, {
		description = S(ndesc) .. " " .. nnum,
		tiles = {"nameznik_bpx.png"},
		overlay_tiles = {
			{name = nfront, color = "white"},
			"",
			nside,
			nside,
			{name = nback, color = "white"},
			{name = nfront, color = "white"},
		},
		paramtype="light",
		paramtype2 = "color4dir",
		drawtype = "nodebox",
		node_box = nameznik__nodebox,
		groups = nameznik__groups,
		is_ground_content = false,
		palette = npalette,
	})
end

local function nameznik_regnoder05(nname, nnum, ndesc, nfront, nside, nback)
	local npalette
	if nname == "nameznik_" then npalette = "nameznik_palette1.png" end
	if nname == "nameznik_konc_" then npalette = "nameznik_palette1.png" end
	if nname == "koncovnik_" then npalette = "nameznik_palette1.png" end
	if nname == "hranicnik" then npalette = "nameznik_palette2.png" end

	minetest.register_node("nameznik:r05_" .. nname .. nnum, {
		description = S(ndesc) .. " "..S("right").." +0,5 " .. nnum,
		tiles = {"nameznik_bpx.png"},
		overlay_tiles = {
			{name = nfront, color = "white"},
			"",
			nside,
			nside,
			{name = nback, color = "white"},
			{name = nfront, color = "white"},
		},
		paramtype="light",
		paramtype2 = "color4dir",
		drawtype = "nodebox",
		node_box = nameznik__nodebox_r05,
		selection_box = nameznik__sboxr,
		groups = nameznik__groups,
		is_ground_content = false,
		palette = npalette,
	})
end

local function nameznik_regnoder1(nname, nnum, ndesc, nfront, nside, nback)
	local npalette
	if nname == "hranicnik" then npalette = "nameznik_palette2.png" end

	minetest.register_node("nameznik:r1_" .. nname .. nnum, {
		description = S(ndesc) .. " "..S("right").." +1 ".. nnum,
		tiles = {"nameznik_bpx.png"},
		overlay_tiles = {
			{name = nfront, color = "white"},
			"",
			nside,
			nside,
			{name = nback, color = "white"},
			{name = nfront, color = "white"},
		},
		paramtype="light",
		paramtype2 = "color4dir",
		drawtype = "nodebox",
		node_box = nameznik__nodebox_r1,
		selection_box = nameznik__sboxr,
		groups = nameznik__groups,
		is_ground_content = false,
		palette = npalette,
	})
end

local function nameznik_regnoder05h(nname, nnum, ndesc, nfront, nside, nback)
	local npalette
	if nname == "hranicnik" then npalette = "nameznik_palette2.png" end

	minetest.register_node("nameznik:r05h_" .. nname .. nnum, {
		description = S(ndesc) .. " "..S("right").." +0,5 "..S("higher").." " .. nnum,
		tiles = {"nameznik_bpx.png"},
		overlay_tiles = {
			{name = nfront, color = "white"},
			"",
			nside,
			nside,
			{name = nback, color = "white"},
			{name = nfront, color = "white"},
		},
		paramtype="light",
		paramtype2 = "color4dir",
		drawtype = "nodebox",
		node_box = nameznik__nodebox_r05h,
		selection_box = nameznik__sboxr,
		groups = nameznik__groups,
		is_ground_content = false,
		palette = npalette,
	})
end

local function nameznik_regnoder1h(nname, nnum, ndesc, nfront, nside, nback)
	local npalette
	if nname == "hranicnik" then npalette = "nameznik_palette2.png" end

	minetest.register_node("nameznik:r1h_" .. nname .. nnum, {
		description = S(ndesc) .. " "..S("right").." +1 "..S("higher").." " .. nnum,
		tiles = {"nameznik_bpx.png"},
		overlay_tiles = {
			{name = nfront, color = "white"},
			"",
			nside,
			nside,
			{name = nback, color = "white"},
			{name = nfront, color = "white"},
		},
		paramtype="light",
		paramtype2 = "color4dir",
		drawtype = "nodebox",
		node_box = nameznik__nodebox_r1h,
		selection_box = nameznik__sboxr,
		groups = nameznik__groups,
		is_ground_content = false,
		palette = npalette,
	})
end

nameznik_regnode("nameznik_","1","Fouling point marker","nameznik_over1.png","","nameznik_over1.png")
nameznik_regnode("nameznik_","2","Fouling point marker","nameznik_over2.png","","nameznik_over2.png")
nameznik_regnode("nameznik_","3","Fouling point marker","nameznik_over3.png","nameznik_blpx.png","nameznik_over3.png")
nameznik_regnode("nameznik_","4","Fouling point marker","","","")
nameznik_regnode("nameznik_","5","Fouling point marker","nameznik_over5.png","","nameznik_over5.png")
nameznik_regnode("nameznik_konc_","1","Fouling point marker with end point of train route","nameznik_end1.png^nameznik_over1.png","","nameznik_over1.png")
nameznik_regnode("nameznik_konc_","2","Fouling point marker with end point of train route","nameznik_end1.png^nameznik_over2.png","","nameznik_over2.png")
nameznik_regnode("koncovnik_","1","End point marker of train route","nameznik_end1.png","","")
nameznik_regnode("hranicnik","","Border point marker of railway companies","nameznik_border1.png","","nameznik_border1.png")

nameznik_regnoder05("nameznik_","1","Fouling point marker","nameznik_over1.png","","nameznik_over1.png")
nameznik_regnoder05("nameznik_","2","Fouling point marker","nameznik_05over2.png","","nameznik_05over2.png")
nameznik_regnoder05("nameznik_","3","Fouling point marker","nameznik_05over3.png","nameznik_blpx.png","nameznik_05over3.png")
nameznik_regnoder05("nameznik_","4","Fouling point marker","","","")
nameznik_regnoder05("nameznik_","5","Fouling point marker","nameznik_over5.png","","nameznik_over5.png")
nameznik_regnoder05("nameznik_konc_","1","Fouling point marker with end point of train route","nameznik_05end1.png^nameznik_over1.png","","nameznik_over1.png")
nameznik_regnoder05("nameznik_konc_","2","Fouling point marker with end point of train route","nameznik_05end1.png^nameznik_05over2.png","","nameznik_05over2.png")
nameznik_regnoder05("koncovnik_","1","End point marker of train route","nameznik_05end1.png","","")
nameznik_regnoder05("hranicnik","","Border point marker of railway companies","nameznik_05border1.png","","nameznik_05border1.png")

nameznik_regnoder1("hranicnik","","Border point marker of railway companies","nameznik_border1.png","","nameznik_border1.png")

nameznik_regnoder05h("hranicnik","","Border point marker of railway companies","nameznik_05border1.png","","nameznik_05border1.png")

nameznik_regnoder1h("hranicnik","","Border point marker of railway companies","nameznik_border1.png","","nameznik_border1.png")

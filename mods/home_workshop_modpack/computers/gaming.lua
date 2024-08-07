local S = minetest.get_translator("computers")

-- Sony PlayStation lookalike
computers.register("computers:slaystation", {
	description = S("Pony SlayStation"),
	inventory_image = "computers_ps1_inv.png",
	tiles_off = { top=true },
	node_box = computers.pixelnodebox(32, {
		-- X   Y   Z   W   H   L
		{  0,  0, 11, 32,  6, 21 },   -- Console
		{  1,  0,  1,  4,  2,  9 },   -- Controller 1 L Grip
		{ 10,  0,  1,  4,  2,  9 },   -- Controller 1 R Grip
		{  5,  0,  4,  5,  2,  5 },   -- Controller 1 Center
		{ 18,  0,  1,  4,  2,  9 },   -- Controller 2 L Grip
		{ 27,  0,  1,  4,  2,  9 },   -- Controller 2 R Grip
		{ 22,  0,  4,  5,  2,  5 }   -- Controller 2 Center
	})
})

-- Sony PlayStation 2 lookalike
computers.register("computers:slaystation2", {
	description = S("Pony SlayStation 2"),
	inventory_image = "computers_ps2_inv.png",
	tiles_off = { front=true },
	node_box = computers.pixelnodebox(32, {
		-- X   Y   Z   W   H   L
		{  2,  2, 11, 28,  3, 19 },   -- Console (Upper part)
		{  2,  0, 11, 26,  2, 19 },   -- Console (Lower part)
		{  1,  0,  1,  4,  2,  9 },   -- Controller 1 L Grip
		{ 10,  0,  1,  4,  2,  9 },   -- Controller 1 R Grip
		{  5,  0,  1,  5,  2,  8 },   -- Controller 1 Center
		{ 18,  0,  1,  4,  2,  9 },   -- Controller 2 L Grip
		{ 27,  0,  1,  4,  2,  9 },   -- Controller 2 R Grip
		{ 22,  0,  1,  5,  2,  8 }   -- Controller 2 Center
	})
})

-- Nintendo Wii lookalike
computers.register("computers:wee", {
	description = S("Nientiendo Wee"),
	inventory_image = "computers_wii_inv.png",
	tiles_off = { front=true },
	node_box = computers.pixelnodebox(32, {
		-- X   Y   Z   W   H   L
		{ 11,  0,  3, 10,  6, 26 },   -- Base
		{ 12,  6,  4,  8, 22, 24 }   -- Top
	})
})

for _, item in ipairs({"computers:wee", "computers:wee_off"}) do
	local ndef = minetest.registered_nodes[item]
	local tiles = table.copy(ndef.tiles)
	for i, tile in ipairs(tiles) do
		tiles[i] = "[combine:64x64:0,0=("..tile.."):0,32=("..tile.."):32,0=("..tile.."):32,32=("..tile..")"
	end
	local fixed = table.copy(ndef.node_box.fixed)
	for i, box in ipairs(fixed) do
		for j = 1, 6 do
			box[j] = 0.5 * (box[j] - 0.5)
		end
		--[[
		box[1] = 0.5 * box[1]
		box[2] = 0.5 * (box[2] - 0.5)
		box[3] = 0.5 * box[3]
		box[4] = 0.5 * box[4]
		box[5] = 0.5 * (box[5] - 0.5)
		box[6] = 0.5 * box[6]
		]]
	end
	local node_box = {type = "fixed", fixed = fixed}
	minetest.override_item(item, {tiles = tiles, node_box = node_box, selection_box = node_box})
end

-- XBox lookalike
computers.register("computers:hueg_box", {
	description = S("HUEG Box"),
	tiles_off = { },
	node_box = computers.pixelnodebox(16, {
		-- X   Y   Z   W   H   L
		{  0,  0,  7, 16,  6, 9 },   -- Console
		{  2,  0,  1, 11,  3, 6 },   -- Controller
		{  2,  0,  0,  2,  3, 1 },
		{ 11,  0,  0,  2,  3, 1 },
	})
})



-- Tetris arcade machine

local shapes = {
   {  { x = {0, 1, 0, 1}, y = {0, 0, 1, 1} } },

   {  { x = {1, 1, 1, 1}, y = {0, 1, 2, 3} },
      { x = {0, 1, 2, 3}, y = {1, 1, 1, 1} } },

   {  { x = {0, 0, 1, 1}, y = {0, 1, 1, 2} },
      { x = {1, 2, 0, 1}, y = {0, 0, 1, 1} } },

   {  { x = {1, 0, 1, 0}, y = {0, 1, 1, 2} },
      { x = {0, 1, 1, 2}, y = {0, 0, 1, 1} } },

   {  { x = {1, 2, 1, 1}, y = {0, 0, 1, 2} },
      { x = {0, 1, 2, 2}, y = {1, 1, 1, 2} },
      { x = {1, 1, 0, 1}, y = {0, 1, 2, 2} },
      { x = {0, 0, 1, 2}, y = {0, 1, 1, 1} } },

   {  { x = {1, 1, 1, 2}, y = {0, 1, 2, 2} },
      { x = {0, 1, 2, 0}, y = {1, 1, 1, 2} },
      { x = {0, 1, 1, 1}, y = {0, 0, 1, 2} },
      { x = {0, 1, 2, 2}, y = {1, 1, 1, 0} } },

   {  { x = {1, 0, 1, 2}, y = {0, 1, 1, 1} },
      { x = {1, 1, 1, 2}, y = {0, 1, 2, 1} },
      { x = {0, 1, 2, 1}, y = {1, 1, 1, 2} },
      { x = {0, 1, 1, 1}, y = {1, 0, 1, 2} } } }

local colors = { "computers_cyan.png", "computers_magenta.png", "computers_red.png",
	"computers_blue.png", "computers_green.png", "computers_orange.png", "computers_yellow.png" }

local background = "image[0,0;3.55,6.66;computers_black.png]"
local buttons = "button[3,4.5;0.6,0.6;left;<]"
	.."button[3.6,4.5;0.6,0.6;rotateleft;"..minetest.formspec_escape(S("L")).."]"
	.."button[4.2,4.5;0.6,0.6;down;v]"
	.."button[4.2,5.3;0.6,0.6;drop;V]"
	.."button[4.8,4.5;0.6,0.6;rotateright;"..minetest.formspec_escape(S("R")).."]"
	.."button[5.4,4.5;0.6,0.6;right;>]"
	.."button[3.5,3;2,2;new;"..minetest.formspec_escape(S("New Game")).."]"

local formsize = "size[5.9,5.7]"
local boardx, boardy = 0, 0
local sizex, sizey, size = 0.29, 0.29, 0.31

local comma = ","
local semi = ";"
local close = "]"

local concat = table.concat
local insert = table.insert

local draw_shape = function(id, x, y, rot, posx, posy)
	local d = shapes[id][rot]
	local scr = {}
	local ins = #scr

	for i=1,4 do
		local tmp = { "image[",
			(d.x[i]+x)*sizex+posx, comma,
			(d.y[i]+y)*sizey+posy, semi,
			size, comma, size, semi,
			colors[id], close }

		ins = ins + 1
		scr[ins] = concat(tmp)
	end

	return concat(scr)
end

local function step(pos, fields)
	local meta = minetest.get_meta(pos)
	local t = minetest.deserialize(meta:get_string("tetris"))

	local function new_game(p)
		local nex = math.random(7)

		t = {
			board = {},
			boardstring = "",
			previewstring = draw_shape(nex, 0, 0, 1, 4, 1),
			score = 0,
			cur = math.random(7),
			nex = nex,
			x=4, y=0, rot=1
		}

		local timer = minetest.get_node_timer(p)
		timer:set(0.3, 0)
	end

	local function update_boardstring()
		local scr = {}
		local ins = #scr

		for i, line in pairs(t.board) do
			for _, tile in pairs(line) do
				local tmp = { "image[",
					tile[1]*sizex+boardx, comma,
					i*sizey+boardy, semi,
					size, comma, size, semi,
					colors[tile[2]], close }

				ins = ins + 1
				scr[ins] = concat(tmp)
			end
		end

		t.boardstring = concat(scr)
	end

	local function add()
		local d = shapes[t.cur][t.rot]

		for i=1,4 do
			local l = d.y[i] + t.y
			if not t.board[l] then t.board[l] = {} end
			insert(t.board[l], {d.x[i] + t.x, t.cur})
		end
	end

	local function scroll(l)
		for i=l, 1, -1 do
			t.board[i] = t.board[i-1] or {}
		end
	end

	local function check_lines()
		for i, line in pairs(t.board) do
			if #line >= 10 then
				scroll(i)
				t.score = t.score + 20
			end
		end
	end

	local function check_position(x, y, rot)
		local d = shapes[t.cur][rot]

		for i=1,4 do
			local cx, cy = d.x[i]+x, d.y[i]+y

			if cx < 0 or cx > 9 or cy < 0 or cy > 19 then
				return false
			end

			for _, tile in pairs(t.board[ cy ] or {}) do
				if tile[1] == cx then return false end
			end
		end

		return true
	end

	local function stuck()
		if check_position(t.x, t.y+1, t.rot) then return false end
		return true
	end

	local function tick()
		if stuck() then
			if t.y <= 0 then
				return false end
			add()
			check_lines()
			update_boardstring()
			t.cur, t.nex = t.nex, math.random(7)
			t.x, t.y, t.rot = 4, 0, 1
			t.previewstring = draw_shape(t.nex, 0, 0, 1, 4.1, 0.6)
		else
			t.y = t.y + 1
		end
		return true
	end

	local function move(dx, dy)
		local newx, newy = t.x+dx, t.y+dy
		if not check_position(newx, newy, t.rot) then return end
		t.x, t.y = newx, newy
	end

	local function rotate(dr)
		local no = #(shapes[t.cur])
		local newrot = (t.rot+dr) % no

		if newrot<1 then newrot = newrot+no end
		if not check_position(t.x, t.y, newrot) then return end
		t.rot = newrot
	end

	local function key()
		if fields.left then
			move(-1, 0)
		end
		if fields.rotateleft then
			rotate(-1)
		end
		if fields.down then
			t.score = t.score + 1
			move(0, 1)
		end
		if fields.drop then
		   while not stuck() do
			  t.score = t.score + 2
		      move(0, 1)
		   end
		end
		if fields.rotateright then
			rotate(1)
		end
		if fields.right then
			move(1, 0)
		end
	end

	local run = true

	if fields then
		if fields.new then
			new_game(pos)
		elseif t then
			key(fields)
		end
	elseif t then
		run = tick()
	end

	if t then
	local scr = { formsize, background,
		t.boardstring, t.previewstring,
		draw_shape(t.cur, t.x, t.y, t.rot, boardx, boardy),
		"label[3.8,0.1;"..S("Next...").."]label[3.8,2.7;"..S("Score: "),
		t.score, close, buttons }


		meta:set_string("formspec", concat(scr))
		meta:set_string("tetris", minetest.serialize(t))
	end

	return run
end

minetest.register_node("computers:tetris_arcade", {
	description=S("Tetris Arcade"),
	drawtype = "mesh",
	mesh = "computers_tetris_arcade.obj",
	tiles = {"computers_tetris_arcade.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {snappy=3},
	on_rotate = minetest.get_modpath("screwdriver") and screwdriver.rotate_simple or nil,
	selection_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5, 0.5, 1.5, 0.5}
	},
	collision_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5, 0.5, 1.5, 0.5}
	},
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", formsize
			.."button[2,2.5;2,2;new;"..minetest.formspec_escape(S("New Game")).."]")
	end,
	on_timer = function(pos)
		return step(pos, nil)
	end,
	on_receive_fields = function(pos, formanme, fields, sender)
		step(pos, fields)
	end,
	on_place = function(itemstack, placer, pointed_thing)
		local pos = pointed_thing.above
		if minetest.is_protected(pos, placer:get_player_name()) or
			minetest.is_protected({x=pos.x, y=pos.y+1, z=pos.z}, placer:get_player_name()) then
			return itemstack
		end
		if minetest.get_node({x=pos.x, y=pos.y+1, z=pos.z}).name ~= "air" then
			minetest.chat_send_player(placer:get_player_name(), S("No room for place the Arcade!"))
			return itemstack
		end
		local dir = placer:get_look_dir()
		local node = {name="computers:tetris_arcade", param1=0, param2 = minetest.dir_to_facedir(dir)}
		minetest.set_node(pos, node)
		itemstack:take_item()
		return itemstack
	end
})

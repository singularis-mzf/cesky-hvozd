fireworkz = {}

--Variables
local modname = "fireworkz"
local modpath = minetest.get_modpath(modname)
local S = minetest.get_translator(minetest.get_current_modname())

--Settings
fireworkz.settings = {}
local settings = Settings(modpath .. "/fireworkz.conf")
fireworkz.settings.igniter = settings:get("igniter") or "default:torch"
fireworkz.settings.ignition_time = tonumber(settings:get("ignition_time")) or 3
fireworkz.settings.max_hear_distance_fuse = tonumber(settings:get("max_hear_distance_fuse")) or 5
fireworkz.settings.max_hear_distance_launch = tonumber(settings:get("max_hear_distance_launch")) or 13
fireworkz.settings.max_hear_distance_bang = tonumber(settings:get("max_hear_distance_bang")) or 90

local variant_list = {
	--{colour = "default", figure = "", form = "", desc = ""},
	{colour = "red", figure = "default", form = "", desc = S("Red")},
	{colour = "green", figure = "default", form = "", desc = S("Green")},
	{colour = "blue", figure = "default", form = "", desc = S("Blue")},
	{colour = "yellow", figure = "default", form = "", desc = S("Yellow")},
	{colour = "white", figure = "default", form = "", desc = S("White")},
	{colour = "red", figure = "ball", form = "", desc = S("Red")},
	{colour = "green", figure = "ball", form = "", desc = S("Green")},
	{colour = "blue", figure = "ball", form = "", desc = S("Blue")},
	{colour = "yellow", figure = "ball", form = "", desc = S("Yellow")},
	{colour = "white", figure = "ball", form = "", desc = S("White")},
	{colour = "red", figure = "custom", form = "love", desc = S("Red")},
	{colour = "blue_white_red", figure = "ball_default_love", form = "", desc = S("Blue-White-Love"),
		rdt = {
			{color = "blue", figure = "ball", form = ""},
			{color = "yellow", figure = "default", form = ""},
			--{color = "red", figure = "custom", form = "love"},
		}
	},
	{colour = "green_yellow_red", figure = "ball_default_love", form = "", desc = S("Green-Yellow-Love"),
		rdt = {
			{color = "green", figure = "ball", form = ""},
			{color = "yellow", figure = "default", form = ""},
			{color = "red", figure = "custom", form = "love"},
		}
	},
}

--Functions

local function default_figure(r)
	local tab = {}
	local num = 1
	for x=-r, r, 0.02 do
		for y=-r, r, 0.02 do
			for z=-r, r, 0.02 do
				if x*x + y*y + z*z <= r*r then
					local v = math.random(21,35) --velocity
					if math.random(1,2) > 1 then
						local xrand = math.random(-5, 5) * 0.001
						local yrand = math.random(-5, 5) * 0.001
						local zrand = math.random(-5, 5) * 0.001
						tab[num] = {x=x+xrand, y=y+yrand, z=z+zrand, v=v}
					end
					num = num + 1
				end
			end
		end
	end
	return tab
end

local function ball_figure(r)
	local tab = {}
	local num = 1
	for x= -r, r, 0.01 do
		for y= -r, r, 0.01 do
			for z= -r, r, 0.01 do
				if x*x + y*y + z*z <= r*r and x*x + y*y + z*z >= (r-0.005) * (r-0.005) then
					if math.random(1,4) > 1 then
						local xrand = math.random(-3, 3) * 0.001
						local yrand = math.random(-3, 3) * 0.001
						local zrand = math.random(-3, 3) * 0.001
						tab[num] = {x= x+xrand, y= y+yrand, z= z+zrand, v= 43}
					end
					num = num + 1
				end
			end
		end
	end
	return tab
end

local function custom_figure(form)
	local tab = {}
		if form == "love" then
			tab[1] = {x=0,y=0,z=0,v=60}
			tab[2] = {x=0,y=0,z=-0.02,v=60}
			tab[3] = {x=0.01,y=0,z=-0.03,v=60}
			tab[4] = {x=0.02,y=0,z=-0.04,v=60}
			tab[5] = {x=0.03,y=0,z=-0.04,v=60}
			tab[6] = {x=0.04,y=0,z=-0.03,v=60}
			tab[7] = {x=0.05,y=0,z=-0.02,v=60}
			tab[8] = {x=0.05,y=0,z=-0.01,v=60}
			tab[9] = {x=0.04,y=0,z=0,v=60}
			tab[10] = {x=0.04,y=0,z=0.01,v=60}
			tab[11] = {x=0.03,y=0,z=0.02,v=60}
			tab[12] = {x=0.02,y=0,z=0.03,v=60}
			tab[13] = {x=0.01,y=0,z=0.04,v=60}
			tab[14] = {x=0,y=0,z=0.05,v=60}
			tab[15] = {x=-0.01,y=0,z=0.04,v=60}
			tab[16] = {x=-0.02,y=0,z=0.03,v=60}
			tab[17] = {x=-0.03,y=0,z=0.02,v=60}
			tab[18] = {x=-0.04,y=0,z=0.01,v=60}
			tab[19] = {x=-0.04,y=0,z=0,v=60}
			tab[20] = {x=-0.05,y=0,z=-0.01,v=60}
			tab[21] = {x=-0.05,y=0,z=-0.02,v=60}
			tab[22] = {x=-0.04,y=0,z=-0.03,v=60}
			tab[23] = {x=-0.03,y=0,z=-0.04,v=60}
			tab[24] = {x=-0.02,y=0,z=-0.04,v=60}
			tab[25] = {x=-0.01,y=0,z=-0.03,v=60}
		else
			tab[1] = {x=0,y=0,z=0,v=0}
		end
	return tab
end

-- Activate fireworks

local function partcl_gen(pos, tab, size_min, size_max, colour)
	for _,i in pairs(tab) do
		minetest.add_particle({
			pos = {x=pos.x, y=pos.y, z=pos.z},
			velocity = {x= i.x*i.v, y= i.y*i.v, z= i.z*i.v},
			acceleration = {x=0, y=-1.5, z=0},
			expirationtime = 3,
			size = math.random(size_min, size_max),
			--collisiondetection = true,
			--collision_removal = false,
			vertical = false,
			animation = {type="vertical_frames", aspect_w=9, aspect_h=9, length = 3.5,},
			glow = 30,
			texture = "anim_"..colour.."_star.png",
		})
	end
end


-- Entity Definition
local rocket = {
	physical = true, --collides with things
	wield_image = "rocket_default.png",
	collisionbox = {0, -0.5 ,0 ,0 ,0.5 ,0},
	visual = "sprite",
	textures = {"rocket_default.png"},
	timer = 0,
	rocket_firetime = 0,
	rocket_flytime = 0,
	rdt = {} -- rocket data table
}

--Entity Registration
minetest.register_entity("fireworkz:rocket", rocket)

function rocket:on_activate(staticdata)
	minetest.sound_play("fireworkz_rocket", {pos=self.object:getpos(), max_hear_distance = fireworkz.settings.max_hear_distance_launch, gain = 1,})
	self.rocket_flytime = math.random(13,15)/10
	self.object:setvelocity({x=0, y=9, z=0})
	self.object:setacceleration({x= math.random(-5, 5), y= 33, z= math.random(-5, 5)})
end

-- Called periodically
function rocket:on_step(dtime)
	self.timer = self.timer + dtime
	self.rocket_firetime = self.rocket_firetime + dtime
	if self.rocket_firetime > 0.1 then
		local pos = self.object:getpos()
		self.rocket_firetime = 0
		local xrand = math.random(-15, 15) / 10
		minetest.add_particle({
			pos = {x=pos.x, y=pos.y - 0.4, z=pos.z},
			velocity = {x=xrand, y=-3, z=xrand},
			acceleration = {x=0, y=0, z=0},
			expirationtime = 1.5,
			size = 3,
			collisiondetection = true,
			vertical = false,
			animation = {type="vertical_frames", aspect_w=9, aspect_h=9, length = 1.6,},
			glow = 10,
			texture = "anim_white_star.png",
		})
	end
	if self.timer > self.rocket_flytime then
		if #self.rdt > 0 then
			minetest.sound_play("fireworkz_bang", {pos= self.object:get_pos(), max_hear_distance = fireworkz.settings.max_hear_distance_bang, gain = 3,})
			for _, i in pairs(self.rdt) do
				local pos = self.object:getpos()
				if i.figure == "ball" then
					partcl_gen(pos, ball_figure(0.1), 4, 4, i.color)
				elseif i.figure == "default" then
					partcl_gen(pos, default_figure(0.1), 2, 4, i.color)
				elseif i.figure == "custom" then
					partcl_gen(pos, custom_figure(i.form), 7, 7, i.color)
				end
			end
		end
		self.object:remove()
	end
end

--Nodes
for _, i in pairs(variant_list) do
	local figure_desc = ""
	if i.figure == "default" then
		figure_desc = S("Default")
	elseif i.figure == "ball" then
		figure_desc = S("Ball")
	elseif i.figure == "ball_default_love" then
		figure_desc = S("Love Ball")
	elseif i.figure == "custom" then
		figure_desc = S("Custom")
	end
	local inv_image = "rocket_"
	if not(i.figure == "") then
		inv_image = inv_image .. i.figure .. "_"
	end
	inv_image = inv_image .. i.colour .. ".png"

	local rdt = i.rdt or {{color = i.colour, figure = i.figure, form = i.form},}

	minetest.register_node("fireworkz:rocket_"..i.figure.."_"..i.colour, {
		description = S("Rocket").." (".. i.desc .. "|"..figure_desc..")",
		drawtype = "plantlike",
		light_source = 5,
		inventory_image = inv_image,
		tiles = {"rocket_default.png"},
		wield_image = "rocket_default.png",
		paramtype = "light",
		sunlight_propagates = true,
		walkable = false,
		is_ground_content = false,
		groups = {choppy = 3, explody = 1, firework = 1},

		on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
			local wielded_item = clicker:get_wielded_item()
			local wielded_item_name = wielded_item:get_name()
			if wielded_item_name == fireworkz.settings.igniter then
				minetest.sound_play("fireworkz_fuse", {pos= pos, fireworkz.settings.max_hear_distance_fuse, gain = 1,})
				minetest.after(fireworkz.settings.ignition_time, function(node, pos)
					local rocket_node = minetest.get_node(pos)
					if rocket_node.name == node.name then
						minetest.remove_node(pos)
						fireworkz.launch(pos, rdt)
					end
				end, node, pos)
			end
		end,

		on_use = function(itemstack, user, pointed_thing)
			local pos = minetest.get_pointed_thing_position(pointed_thing, true)
			if pos then
				 fireworkz.launch(pos, rdt)
			end
		end,

		on_construct = function(pos)
			local meta = minetest.get_meta(pos)
			meta:set_string("firework:rdt",  minetest.serialize(rdt))
		end,
	})
end

fireworkz.launch = function(pos, rdt)
	local obj = minetest.add_entity(pos, "fireworkz:rocket") --activate
	local obj_ent = obj:get_luaentity()
	obj_ent.rdt = rdt
end

-- Craffitems

minetest.register_craft({
	output = "fireworkz:rocket_default",
	recipe = {
		{"tnt:gunpowder"},
		{"default:paper"},
		{"default:coal_lump"}
	},
})

minetest.register_craft({
	output = "fireworkz:rocket_default_red",
	recipe = {
		{"default:tin_lump", "tnt:gunpowder", "dye:red"},
		{"", "default:paper", ""},
		{"", "default:coal_lump", ""}
	},
})

minetest.register_craft({
	output = "fireworkz:rocket_default_green",
	recipe = {
		{"default:tin_lump", "tnt:gunpowder", "dye:green"},
		{"", "default:paper", ""},
		{"", "default:coal_lump", ""}
	},
})

minetest.register_craft({
	output = "fireworkz:rocket_default_blue",
	recipe = {
		{"default:tin_lump", "tnt:gunpowder", "dye:blue"},
		{"", "default:paper", ""},
		{"", "default:coal_lump", ""}
	},
})

minetest.register_craft({
	output = "fireworkz:rocket_default_yellow",
	recipe = {
		{"default:tin_lump", "tnt:gunpowder", "dye:yellow"},
		{"", "default:paper", ""},
		{"", "default:coal_lump", ""}
	},
})

minetest.register_craft({
	output = "fireworkz:rocket_default_white",
	recipe = {
		{"default:tin_lump", "tnt:gunpowder", "dye:white"},
		{"", "default:paper", ""},
		{"", "default:coal_lump", ""}
	},
})

minetest.register_craft({
	output = "fireworkz:rocket_ball_red",
	recipe = {
		{"default:iron_lump", "tnt:gunpowder", "dye:red"},
		{"", "default:paper", ""},
		{"", "default:coal_lump", ""}
	},
})

minetest.register_craft({
	output = "fireworkz:rocket_ball_green",
	recipe = {
		{"default:iron_lump", "tnt:gunpowder", "dye:green"},
		{"", "default:paper", ""},
		{"", "default:coal_lump", ""}
	},
})

minetest.register_craft({
	output = "fireworkz:rocket_ball_blue",
	recipe = {
		{"default:iron_lump", "tnt:gunpowder", "dye:blue"},
		{"", "default:paper", ""},
		{"", "default:coal_lump", ""}
	},
})

minetest.register_craft({
	output = "fireworkz:rocket_ball_yellow",
	recipe = {
		{"default:iron_lump", "tnt:gunpowder", "dye:yellow"},
		{"", "default:paper", ""},
		{"", "default:coal_lump", ""}
	},
})

minetest.register_craft({
	output = "fireworkz:rocket_ball_white",
	recipe = {
		{"default:iron_lump", "tnt:gunpowder", "dye:white"},
		{"", "default:paper", ""},
		{"", "default:coal_lump", ""}
	},
})

minetest.register_craft({
	output = "fireworkz:rocket_ball_default_love_blue_white_red",
	recipe = {
		{"default:mese_crystal", "tnt:gunpowder", "dye:blue"},
		{"dye:white", "default:paper", ""},
		{"", "default:coal_lump", ""}
	},
})

minetest.register_craft({
	output = "fireworkz:rocket_ball_default_love_green_yellow_red",
	recipe = {
		{"default:diamond", "tnt:gunpowder", "dye:green"},
		{"dye:yellow", "default:paper", "dye:red"},
		{"", "default:coal_lump", ""}
	},
})

--Mesecons Support

if minetest.get_modpath("mesecons") ~= nil then
	minetest.register_node("fireworkz:launcher", {
		description = S("Firework Rocket Launcher"),
		tiles = {"fireworkz_rocket_launcher.png"},
		is_ground_content = false,
		groups = {cracky = 2, stone = 1},
		sounds = default.node_sound_stone_defaults(),
		mesecons = {effector = {
			action_on = function (pos, node)
				pos.y = pos. y + 1
				local node = minetest.get_node_or_nil(pos)
				if node then
					if node.name:sub(1, 16) == "fireworkz:rocket" then
						local meta = minetest.get_meta(pos)
						local rdt = minetest.deserialize(meta:get_string("firework:rdt"))
						minetest.remove_node(pos)
						fireworkz.launch(pos, rdt)
					end
				end
			end,
		}}
	})
	minetest.register_craft({
		output = "fireworkz:launcher",
		type = "shaped",
		recipe = {
			{"", "tnt:gunpowder", ""},
			{"", "default:mese", ""},
			{"", "default:steelblock", ""}
		},
	})
end

local function is_water(pos)
	local nn = minetest.get_node(pos).name
	return minetest.get_item_group(nn, "water") ~= 0
end


local function get_sign(i)
	if i == 0 then
		return 0
	else
		return i / math.abs(i)
	end
end


local function get_velocity(v, yaw, y)
	local x = -math.sin(yaw) * v
	local z =  math.cos(yaw) * v
	return {x = x, y = y, z = z}
end


local function get_v(v)
	return math.sqrt(v.x ^ 2 + v.z ^ 2)
end
local function reg_barca(color, popis)

	local barca_item_name = "summer:barca_"..color.."_item"
	local barca_ent_name = "summer:barca_"..color.."_entity"

--
-- Boat entity
--

local barca = {
	initial_properties = {
		physical = true,
		collisionbox = {-2.5, -0.5, -2.5, 2.5, 0.3, 2.5},
		visual = "mesh",
		mesh = "barca.x",--"barcal.obj",
		textures = {"barca_"..color..".png" },
	},

	driver = nil,
	v = 0,
	last_v = 0,
	removed = false
}


function barca.on_rightclick(self, clicker)
	if not clicker or not clicker:is_player() then
		return
	end
	local name = clicker:get_player_name()
	if self.driver and clicker == self.driver then
		self.driver = nil
		clicker:set_detach()
		default.player_attached[name] = false
		default.player_set_animation(clicker, "stand" , 30)
		local pos = clicker:get_pos()
		pos = {x = pos.x, y = pos.y + 0.2, z = pos.z}
		minetest.after(0.1, function()
			clicker:set_pos(pos)
		end)
	elseif not self.driver then
		local attach = clicker:get_attach()
		if attach and attach:get_luaentity() then
			local luaentity = attach:get_luaentity()
			if luaentity.driver then
				luaentity.driver = nil
			end
			clicker:set_detach()
		end
		self.driver = clicker
		clicker:set_attach(self.object, "",
			{x = 0, y = 11, z = -3}, {x = 0, y = 0, z = 0})
		default.player_attached[name] = true
		minetest.after(0.2, function()
			default.player_set_animation(clicker, "sit" , 30)
		end)
		self.object:set_yaw(clicker:get_look_horizontal() - math.pi / 2)
	end
end


function barca.on_activate(self, staticdata, dtime_s)
	self.object:set_armor_groups({immortal = 1})
	if staticdata then
		self.v = tonumber(staticdata)
	end
	self.last_v = self.v
end


function barca.get_staticdata(self)
	return tostring(self.v)
end


function barca.on_punch(self, puncher)
	if not puncher or not puncher:is_player() or self.removed then
		return
	end
	if self.driver and puncher == self.driver then
		self.driver = nil
		puncher:set_detach()
		default.player_attached[puncher:get_player_name()] = false
	end
	if not self.driver then
		self.removed = true
		-- delay remove to ensure player is detached
		minetest.after(0.1, function()
			self.object:remove()
		end)
		if not minetest.is_creative_enabled(puncher:get_player_name()) then
			local inv = puncher:get_inventory()
			if inv:room_for_item("main", "summer:barca_"..color.."_item") then
				inv:add_item("main", "summer:barca_"..color.."_item")
			else
				minetest.add_item(self.object:get_pos(), barca_item_name)
			end
		end
	end
end


function barca.on_step(self, dtime)
	self.v = get_v(self.object:get_velocity()) * get_sign(self.v)
	if self.driver then
		local ctrl = self.driver:get_player_control()
		local yaw = self.object:get_yaw()
		if ctrl.up then
			self.v = self.v + 0.1
		elseif ctrl.down then
			self.v = self.v - 0.1
		end
		if ctrl.left then
			if self.v < 0 then
				self.object:set_yaw(yaw - (1 + dtime) * 0.03)
			else
				self.object:set_yaw(yaw + (1 + dtime) * 0.03)
			end
		elseif ctrl.right then
			if self.v < 0 then
				self.object:set_yaw(yaw + (1 + dtime) * 0.03)
			else
				self.object:set_yaw(yaw - (1 + dtime) * 0.03)
			end
		end
	end
	local velo = self.object:get_velocity()
	if self.v == 0 and velo.x == 0 and velo.y == 0 and velo.z == 0 then
		self.object:set_pos(self.object:get_pos())
		return
	end
	local s = get_sign(self.v)
	self.v = self.v - 0.02 * s
	if s ~= get_sign(self.v) then
		self.object:set_velocity({x = 0, y = 0, z = 0})
		self.v = 0
		return
	end
	if math.abs(self.v) > 5 then
		self.v = 5 * get_sign(self.v)
	end

	local p = self.object:get_pos()
	p.y = p.y - 0.5
	local new_velo = {x = 0, y = 0, z = 0}
	local new_acce = {x = 0, y = 0, z = 0}
	if not is_water(p) then
		local nodedef = minetest.registered_nodes[minetest.get_node(p).name]
		if (not nodedef) or nodedef.walkable then
			self.v = 0
			new_acce = {x = 0, y = 2, z = 0}
		else
			new_acce = {x = 0, y = -1.8, z = 0}
		end
		new_velo = get_velocity(self.v, self.object:get_yaw(),
			self.object:get_velocity().y)
		self.object:set_pos(self.object:get_pos())
	else
		p.y = p.y + 1
		if is_water(p) then
			local y = self.object:get_velocity().y
			if y >= 7 then
				y = 7
			elseif y < 0 then
				new_acce = {x = 0, y = 50, z = 0}
			else
				new_acce = {x = 0, y = 7, z = 0}
			end
			new_velo = get_velocity(self.v, self.object:get_yaw(), y)
			self.object:set_pos(self.object:get_pos())
		else
			new_acce = {x = 0, y = 0, z = 0}
			if math.abs(self.object:get_velocity().y) < 1 then
				local pos = self.object:get_pos()
				pos.y = math.floor(pos.y) + 1.
				self.object:set_pos(pos)
				new_velo = get_velocity(self.v, self.object:get_yaw(), 0)
			else
				new_velo = get_velocity(self.v, self.object:get_yaw(),
					self.object:get_velocity().y)
				self.object:set_pos(self.object:get_pos())
			end
		end
	end
	self.object:set_velocity(new_velo)
	self.object:set_acceleration(new_acce)
end


minetest.register_entity("summer:barca_"..color.."", barca)


minetest.register_craftitem(barca_item_name, {
	description = popis,
	inventory_image = "barca_"..color.."_inv.png",
	wield_image = "barca_"..color.."_inv.png",
	wield_scale = {x = 2, y = 2, z = 1},
	liquids_pointable = true,

	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			return
		end
		if not is_water(pointed_thing.under) then
			return
		end
		pointed_thing.under.y = pointed_thing.under.y + 0.5
		minetest.add_entity(pointed_thing.under, "summer:barca_"..color.."")
		if not minetest.is_creative_enabled(placer:get_player_name()) then
			itemstack:take_item()
		end
		return itemstack
	end,
})


if minetest.get_modpath("cannabis") then
minetest.register_craft({
	output = barca_item_name,
	recipe = {
		{""                       , ""                       , ""                       },
		{"cannabis:canapa_plastic", "wool:"..color,            "cannabis:canapa_plastic"},
		{"cannabis:canapa_plastic", "cannabis:canapa_plastic", "cannabis:canapa_plastic"},
	},
})
end
minetest.register_craft({
	output = barca_item_name,
	recipe = {
		{""     , ""   , ""   },
		{"group:wood", "wool:"..color, "group:wood"},
		{"group:wood","group:wood","group:wood"},
	},
})	
end
local barca_colors = {
	black = "černý člun",
	red = "červený člun",
	green = "zelený člun",
	blue = "modrý člun",
	yellow = "žlutý člun",
	violet = "fialový člun",
	orange = "oranžový člun",
}

for color, desc in pairs(barca_colors) do
	reg_barca(color, desc)
end


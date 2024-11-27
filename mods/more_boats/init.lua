ch_base.open_mod(minetest.get_current_modname())
local S = minetest.get_translator("more_boats")
local modpath = minetest.get_modpath("more_boats")

local function is_water(pos)
	local nn = minetest.get_node(pos).name
	return minetest.get_item_group(nn, "water") ~= 0
end

local function get_velocity(v, yaw, y)
	local x = -math.sin(yaw) * v
	local z =  math.cos(yaw) * v
	return {x = x, y = y, z = z}
end

local function get_v(v)
	return math.sqrt(v.x ^ 2 + v.z ^ 2)
end

local entity_def = {
	initial_properties = {
		physical = true,
		-- Warning: Do not change the position of the collisionbox top surface,
		-- lowering it causes the boat to fall through the world if underwater
		collisionbox = {-0.5, -0.35, -0.5, 0.5, 0.3, 0.5},
		visual = "mesh",
		mesh = "boats_boat.obj",
		textures = {"default_wood.png"},
	},
	driver = nil,
	v = 0,
	last_v = 0,
	removed = false,
	auto = false,
}

function entity_def.on_rightclick(self, clicker)
	if not clicker or not clicker:is_player() then
		return
	end
	local name = clicker:get_player_name()
	if self.driver and name == self.driver then
		-- Cleanup happens in entity_def.on_detach_child
		clicker:set_detach()

		player_api.set_animation(clicker, "stand", 30)
		local pos = clicker:get_pos()
		pos = {x = pos.x, y = pos.y + 0.2, z = pos.z}
		minetest.after(0.1, function()
			clicker:set_pos(pos)
		end)
	elseif not self.driver then
		clicker:set_attach(self.object, "",
			{x = 0.5, y = 1, z = -3}, {x = 0, y = 0, z = 0})

		self.driver = name
		player_api.player_attached[name] = true

		minetest.after(0.2, function()
			player_api.set_animation(clicker, "sit", 30)
		end)
		clicker:set_look_horizontal(self.object:get_yaw())
	end
end


-- If driver leaves server while driving boat
function entity_def.on_detach_child(self, child)
	if child and child:get_player_name() == self.driver then
		player_api.player_attached[child:get_player_name()] = false

		self.driver = nil
		self.auto = false
	end
end


function entity_def.on_activate(self, staticdata, dtime_s)
	self.object:set_armor_groups({immortal = 1})
	if staticdata then
		self.v = tonumber(staticdata)
	end
	self.last_v = self.v
end


function entity_def.get_staticdata(self)
	return tostring(self.v)
end


local function on_punch(self, puncher, item_name)
	if not puncher or not puncher:is_player() or self.removed then
		return
	end

	local name = puncher:get_player_name()
	if self.driver and name == self.driver then
		self.driver = nil
		puncher:set_detach()
		player_api.player_attached[name] = false
	end
	if not self.driver then
		self.removed = true
		local inv = puncher:get_inventory()
		if not minetest.is_creative_enabled(name)
				or not inv:contains_item("main", item_name) then
			local leftover = inv:add_item("main", item_name)
			-- if no room in inventory add a replacement boat to the world
			if not leftover:is_empty() then
				minetest.add_item(self.object:get_pos(), leftover)
			end
		end
		-- delay remove to ensure player is detached
		minetest.after(0.1, function()
			self.object:remove()
		end)
	end
end

function entity_def.on_step(self, dtime)
	self.v = get_v(self.object:get_velocity()) * math.sign(self.v)
	if self.driver then
		local driver_objref = minetest.get_player_by_name(self.driver)
		if driver_objref then
			local ctrl = driver_objref:get_player_control()
			if ctrl.up and ctrl.down then
				if not self.auto then
					self.auto = true
					minetest.chat_send_player(self.driver, S("Boat cruise mode on"))
				end
			elseif ctrl.down then
				self.v = self.v - dtime * 2.0
				if self.auto then
					self.auto = false
					minetest.chat_send_player(self.driver, S("Boat cruise mode off"))
				end
			elseif ctrl.up or self.auto then
				self.v = self.v + dtime * 2.0
			end
			if ctrl.left then
				if self.v < -0.001 then
					self.object:set_yaw(self.object:get_yaw() - dtime * 0.9)
				else
					self.object:set_yaw(self.object:get_yaw() + dtime * 0.9)
				end
			elseif ctrl.right then
				if self.v < -0.001 then
					self.object:set_yaw(self.object:get_yaw() + dtime * 0.9)
				else
					self.object:set_yaw(self.object:get_yaw() - dtime * 0.9)
				end
			end
		end
	end
	local velo = self.object:get_velocity()
	if not self.driver and
			self.v == 0 and velo.x == 0 and velo.y == 0 and velo.z == 0 then
		self.object:set_pos(self.object:get_pos())
		return
	end
	-- We need to preserve velocity sign to properly apply drag force
	-- while moving backward
	local drag = dtime * math.sign(self.v) * (0.01 + 0.0796 * self.v * self.v)
	-- If drag is larger than velocity, then stop horizontal movement
	if math.abs(self.v) <= math.abs(drag) then
		self.v = 0
	else
		self.v = self.v - drag
	end

	local p = self.object:get_pos()
	p.y = p.y - 0.5
	local new_velo
	local new_acce = {x = 0, y = 0, z = 0}
	if not is_water(p) then
		local nodedef = minetest.registered_nodes[minetest.get_node(p).name]
		if (not nodedef) or nodedef.walkable then
			self.v = 0
			new_acce = {x = 0, y = 1, z = 0}
		else
			new_acce = {x = 0, y = -9.8, z = 0}
		end
		new_velo = get_velocity(self.v, self.object:get_yaw(),
			self.object:get_velocity().y)
		self.object:set_pos(self.object:get_pos())
	else
		p.y = p.y + 1
		if is_water(p) then
			local y = self.object:get_velocity().y
			if y >= 5 then
				y = 5
			elseif y < 0 then
				new_acce = {x = 0, y = 20, z = 0}
			else
				new_acce = {x = 0, y = 5, z = 0}
			end
			new_velo = get_velocity(self.v, self.object:get_yaw(), y)
			self.object:set_pos(self.object:get_pos())
		else
			new_acce = {x = 0, y = 0, z = 0}
			if math.abs(self.object:get_velocity().y) < 1 then
				local pos = self.object:get_pos()
				pos.y = math.floor(pos.y) + 0.5
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

local function on_place(itemstack, placer, pointed_thing, entity_name)
	local under = pointed_thing.under
	local node = minetest.get_node(under)
	local udef = minetest.registered_nodes[node.name]
	if udef and udef.on_rightclick and
			not (placer and placer:is_player() and
			placer:get_player_control().sneak) then
		return udef.on_rightclick(under, node, placer, itemstack,
			pointed_thing) or itemstack
	end

	if pointed_thing.type ~= "node" then
		return itemstack
	end
	if not is_water(pointed_thing.under) then
		return itemstack
	end
	pointed_thing.under.y = pointed_thing.under.y + 0.5
	local boat = minetest.add_entity(pointed_thing.under, entity_name)
	if boat then
		if placer then
			boat:set_yaw(placer:get_look_horizontal())
		end
		local player_name = placer and placer:get_player_name() or ""
		if not minetest.is_creative_enabled(player_name) then
			itemstack:take_item()
		end
	end
	return itemstack
end

local function register_boat(boat_name, boat_def)
	-- boat_name = "aspen_boat"
	-- description = S("Aspen Boat")
	-- name = "aspen"
	-- textures = {"default_aspen_wood.png"}
	-- wood_item = "default:aspen_wood"
	local def = table.copy(entity_def)
	def.on_punch = function(self, puncher)
		return on_punch(self, puncher, "more_boats:"..boat_name)
	end
	def.initial_properties = table.copy(entity_def.initial_properties)
	def.initial_properties.textures = boat_def.textures or {"default_wood.png"}
	minetest.register_entity("more_boats:"..boat_name, def)
	def = {
		description = boat_def.description or S("Boat"),
		inventory_image = boat_def.inventory_image or ("more_boats_"..boat_def.name.."_inv.png"),
		wield_image = boat_def.wield_image or ("more_boats_"..boat_def.name.."_wield.png"),
		wield_scale = {x = 2, y = 2, z = 1},
		liquids_pointable = true,
		groups = {flammable = 2},
		on_place = function(itemstack, placer, pointed_thing)
			return on_place(itemstack, placer, pointed_thing, "more_boats:"..boat_name)
		end,
	}
	minetest.register_craftitem("more_boats:"..boat_name, def)
	def = {
		{"", "", ""},
		{boat_def.wood_item, "", boat_def.wood_item},
		{boat_def.wood_item, boat_def.wood_item, boat_def.wood_item},
	}
	minetest.register_craft({
		output = "more_boats:"..boat_name,
		recipe = def,
	})
	minetest.register_craft({
		type = "fuel",
		recipe = "more_boats:"..boat_name,
		burntime = boat_def.burntime or 20,
	})
end

register_boat("aspen_boat", {
	name = "aspen",
	boat_name = "aspen_boat",
	description = S("Aspen Boat"),
	textures = {"default_aspen_wood.png"},
	wood_item = "default:aspen_wood",
})

register_boat("acacia_boat", {
	name = "acacia",
	boat_name = "acacia_boat",
	description = S("Acacia Boat"),
	textures = {"default_acacia_wood.png"},
	wood_item = "default:acacia_wood",
})

register_boat("jungle_boat", {
	name = "jungle",
	boat_name = "jungle_boat",
	description = S("Jungle Boat"),
	textures = {"default_junglewood.png"},
	wood_item = "default:junglewood",
})

register_boat("pine_boat", {
	name = "pine",
	boat_name = "pine_boat",
	description = S("Pine Boat"),
	textures = {"default_pine_wood.png"},
	wood_item = "default:pine_wood",
})
ch_base.close_mod(minetest.get_current_modname())

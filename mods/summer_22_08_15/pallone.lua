--pallone
local CALCIO = 0.1

local function reg_ball(color, popis)

	local ball_item_name = "summer:ball_"..color.."_item"
	local ball_ent_name = "summer:ball_"..color.."_entity"

	minetest.register_entity(ball_ent_name, {
		initial_properties = {
			physical = true,
			visual = "mesh",
			mesh = "ball.obj",
			hp_max = 1000,
			liquids_pointable = true,
			groups = { immortal = true },
			textures = { "ball_"..color..".png" },
			use_texture_alpha = "opaque",
			collisionbox = { -0.2, -0.2, -0.2, 0.2, 0.2, 0.2 }, --{ -1, -1, -1, 1, 1, 1 },
		},

		timer = 0,

		on_step = function(self, dtime)
			self.timer = self.timer + dtime
			if self.timer >= CALCIO then
				self.object:set_acceleration({x=0, y=-10, z=0})
				self.timer = 0
				local vel = self.object:get_velocity()
				local p = self.object:get_pos();
				p.y = p.y - 0.5
				if minetest.registered_nodes[minetest.get_node(p).name].walkable then
					vel.x = vel.x * 0.85
					if vel.y < 0 then vel.y = vel.y * -0.65 end
					vel.z = vel.z * 0.90
				end
				if  (math.abs(vel.x) < 0.1)
				 and (math.abs(vel.z) < 0.1) then
					vel.x = 0
					vel.z = 0
				end
				self.object:set_velocity(vel)
				local pos = self.object:get_pos()
				local objs = minetest.get_objects_inside_radius(pos, 1)
				local player_count = 0
				local final_dir = { x=0, y=0, z=0 }
				for _,obj in ipairs(objs) do
					if obj:is_player() then
						local objdir = obj:get_look_dir()
						local mul = 1
						if (obj:get_player_control().sneak) then
							mul = 3
						end
						final_dir.x = final_dir.x + (objdir.x * mul)
						final_dir.y = final_dir.y + (objdir.y * mul)
						final_dir.z = final_dir.z + (objdir.z * mul)
						player_count = player_count + 1
					end
				end
				if final_dir.x ~= 0 or final_dir.y ~= 0 or final_dir.z ~= 0 then
					final_dir.x = (final_dir.x * 5) / player_count
					final_dir.y = (final_dir.y * 5) / player_count
					final_dir.z = (final_dir.z * 5) / player_count
					self.object:set_velocity(final_dir)
				end
			end
		end,

		on_punch = function(self, puncher)
			if puncher and puncher:is_player() then
				local inv = puncher:get_inventory()
				inv:add_item("main", ItemStack(ball_item_name))
				self.object:remove()
			end
		end,

		is_moving = function(self)
			local v = self.object:get_velocity()
			if  (math.abs(v.x) <= 0.1)
			 and (math.abs(v.z) <= 0.1) then
				v.x = 0
				v.z = 0
				self.object:set_velocity(v)
				return false
			end
			return true
		end,
	})

	minetest.register_craftitem(ball_item_name,{
		description = popis,
		inventory_image = "summer_ball_"..color.."_inv.png",

		on_place = function(itemstack, placer, pointed_thing)
			local pos = pointed_thing.above
			--pos = { x=pos.x+0.5, y=pos.y, z=pos.z+0.5 }
			local ent = minetest.add_entity(pos, ball_ent_name)
			ent:set_velocity({x=0, y=-15, z=0})
			itemstack:take_item()
			return itemstack
		end,
	})

	minetest.register_craft({
		output = ball_item_name,
		recipe = {
			{ "basic_materials:plastic_strip", "basic_materials:plastic_strip", "basic_materials:plastic_strip" },
			{ "basic_materials:plastic_strip", "dye:"..color, "basic_materials:plastic_strip" },
			{ "basic_materials:plastic_strip", "basic_materials:plastic_strip", "basic_materials:plastic_strip" },
		},
	})
end

local pallone_colors = {
	black = "černý míč",
	red = "červený míč",
	green = "zelený míč",
	blue = "modrý míč",
	yellow = "žlutý míč",
	violet = "fialový míč",
	orange = "oranžový míč",
}

for color, desc in pairs(pallone_colors) do
	reg_ball(color, desc)
end

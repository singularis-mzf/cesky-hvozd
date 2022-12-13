local S = ...

local scale_model = 3.3
local visual_size = {x=petz.settings.visual_size.x*scale_model, y=petz.settings.visual_size.y*scale_model}

minetest.register_entity("petz:wagon",{
	hp = 10,
	visual = 'mesh',
	visual_size = visual_size,
	mesh = 'petz_wagon.b3d',
	textures = {'petz_wagon.png'},
	collide_with_objects = true,
	physical= true,
	collisionbox = {-0.5, -1.5, -1.75, 0.5, -0.25, -3.0},
	hitbox = {-0.5, -1.5, -1.5, 0.5, -0.25, -3.0},
	on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir, damage)
		if self.object:get_hp() - damage <= 0 then
			kitz.drop_item(self, ItemStack("petz:wagon 1"))
		end
	end,
})

petz.animate_wagon = function(self, ani_type)
	if ani_type == "stand" then
		self.wagon:set_animation({x=1, y=1}, 25, 0.0, true)
	elseif ani_type == "roll" then
		self.wagon:set_animation({x=1, y=11}, 20, 0.0, true)
	else
		return
	end
end

minetest.register_craftitem("petz:wagon", {
	description = S("One-Pony Open Wagon"),
	inventory_image = "petz_wagon_inv.png",
	groups = {wagon = 1},
	stack_max = 1,
	on_use = function (itemstack, user, pointed_thing)
		if pointed_thing.type ~= "node" then
			return
		end
        local pt_above = pointed_thing.above
		local pos2 = {
			x = pt_above.x,
			y = pt_above.y+1,
			z = pt_above.z,
		}
		minetest.add_entity(pos2, "petz:wagon", nil)
		itemstack:take_item()
		return itemstack
	end,
})

minetest.register_craft({
	type = "shaped",
	output = "petz:wagon",
	recipe = {
		{"", "group:stair", ""},
		{"group:wood", "group:wood", "group:wood"},
		{"petz:wagon_wheel", "", "petz:wagon_wheel"},
	}
})

minetest.register_craftitem("petz:wagon_wheel", { -- register new spawn egg containing mob information
	description = S("Wagon Wheel"),
	inventory_image = "petz_wagon_wheel.png",
	groups = {wagon = 1, wheel = 1},
})

minetest.register_craft({
	type = "shaped",
	output = "petz:wagon_wheel",
	recipe = {
		{"group:wood", "group:wood", "group:wood"},
		{"group:wood", "default:iron_lump", "group:wood"},
		{"group:wood", "group:wood", "group:wood"},
	}
})

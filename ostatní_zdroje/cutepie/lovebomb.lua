--Love Bomb created by Napiophelios


   local MOD_NAME = minetest.get_current_modname()
   local MOD_PATH = minetest.get_modpath(MOD_NAME)
   local Vec3 = dofile(MOD_PATH.."/lib/Vec3_1-0.lua")

lovebomb = {}

minetest.register_craftitem('cutepie:lovebomb', {
	description = 'Love Bomb',
	inventory_image = 'heart.png',
on_use = minetest.item_eat(20),
on_place = function(itemstack, user, pointed_thing)
 itemstack:take_item()
  		minetest.sound_play("pop", {gain = 1.0})
			minetest.add_particlespawner(300, 0.2,
				pointed_thing.above, pointed_thing.above,
				{x=1, y= 2, z=1}, {x=-1, y= 2, z=-1},
				{x=0.2, y=0.2, z=0.2}, {x=-0.2, y=0.5, z=-0.2},
				5, 10,
				1, 3,
				false, "heart.png")
  			minetest.add_particlespawner(200, 0.2,
				pointed_thing.above, pointed_thing.above,
				{x=2, y=0.2, z=2}, {x=-2, y=0.5, z=-2},
				{x=0, y=-6, z=0}, {x=0, y=-10, z=0},
				0.5, 2,
				0.2, 5,
				true, "heart.png")

				local dir = Vec3(user:get_look_dir()) *20
				minetest.add_particle(
				{x=user:getpos().x, y=user:getpos().y+1.5, z=user:getpos().z}, {x=dir.x, y=dir.y, z=dir.z}, {x=0, y=-10, z=0}, 0.2,
					6, false, "heart.png")
			return itemstack

		end,
	})

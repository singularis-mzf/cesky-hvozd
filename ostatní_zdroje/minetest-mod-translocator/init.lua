local throwed = {}

core.register_tool("translocator:translocator", {
  wield_scale = {x=1.5,y=1.5,z=0.8},
  description = "Translocator",
  inventory_image = "translocator.png",
  on_use = function(itemstack, player, pointed_thing)
	local name = player:get_player_name()
	local creative = core.check_player_privs(name, {creative = true})
	local pos = player:get_pos()
	local dir = player:get_look_dir()
	if pos and dir and not throwed[name] then
		pos.y = pos.y + 1.5
		local obj = core.add_entity(pos, "translocator:disk")
		if obj then
			obj:set_velocity({x=dir.x * 15, y=dir.y * 15, z=dir.z * 15})
			obj:set_acceleration({x=0,z=0,y=-4})
			throwed[name] = obj
		end
	elseif throwed[name] then
		local obj = throwed[name]
		local pos = obj:get_pos()
		if pos then
			player:set_pos(pos)
		end
		obj:remove()
		throwed[name] = nil
		if not creative then
			itemstack:add_wear(655.35)
		end
		if core.get_modpath("tpr") then
			core.sound_play("tpr_warp",{to_player = name})
		end
	end
	return itemstack
end})

local disk = {
	armor_groups = {immortal = true},
	physical = true,
	timer = 0,
	visual = "mesh",
	mesh = "translocator_disk.obj",
	visual_size = {x=2.5, y=2.5,},
	textures = {"translocator_disk.png"},
	pointable = false,
	collisionbox = {-0.24,-0.05,-0.24,0.24,0.05,0.24},
	collide_with_objects = false,
}

disk.on_step = function(self, dtime, moveresult)
	self.timer = self.timer + dtime
	local vel = self.object:get_velocity()
	if self.timer >= 60 then
		self.object:remove()
	end
	if moveresult.touching_ground == true then
		self.object:set_velocity({x=0.3^dtime*vel.x,y=vel.y,z=0.3^dtime*vel.z})
	end
end

core.register_entity("translocator:disk", disk)

core.register_craft({
	output = "translocator:translocator",
	recipe = {
		{"default:steel_ingot","default:steel_ingot","dye:red"},
		{"","default:mese_crystal","default:steel_ingot"},
		{"default:steel_ingot","default:steel_ingot","dye:red"}
	}
})

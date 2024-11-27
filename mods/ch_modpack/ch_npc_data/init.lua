ch_base.open_mod(minetest.get_current_modname())

local function x(n, v)
	local result = {}
	for i = 1,n,1 do
		result[i] = v
	end
	return result
end

local offset_010 = vector.new(0,1,0)
local mobs_character_offset = vector.new(0, 0.5, 0)
local mobs_character_collisionbox = {-0.35,-1.0,-0.35, 0.35,0.8,0.35}

ch_npc.register_npc("baby", "mobs_character.b3d", {"mobs_npc_baby.png"}, mobs_character_offset, mobs_character_collisionbox)
ch_npc.register_npc("doctor1", "Doctor.b3d", x(11, "texturenordoctor.png"), mobs_character_offset, mobs_character_collisionbox)
ch_npc.register_npc("igor6", "mobs_character.b3d", {"mobs_igor6.png"}, mobs_character_offset, mobs_character_collisionbox)
ch_npc.register_npc("igor8", "mobs_character.b3d", {"mobs_igor8.png"}, mobs_character_offset, mobs_character_collisionbox)
ch_npc.register_npc("npc1", "mobs_character.b3d", {"mobs_npc.png"}, mobs_character_offset, mobs_character_collisionbox)
ch_npc.register_npc("npc2", "mobs_character.b3d", {"mobs_npc2.png"}, mobs_character_offset, mobs_character_collisionbox)
ch_npc.register_npc("npc3", "mobs_character.b3d", {"mobs_npc3.png"}, mobs_character_offset, mobs_character_collisionbox)
ch_npc.register_npc("npc4", "mobs_character.b3d", {"mobs_npc4.png"}, mobs_character_offset, mobs_character_collisionbox)
ch_npc.register_npc("trader1", "mobs_character.b3d", {"mobs_trader.png"}, mobs_character_offset, mobs_character_collisionbox)
ch_npc.register_npc("trader2", "mobs_character.b3d", {"mobs_trader2.png"}, mobs_character_offset, mobs_character_collisionbox)
ch_npc.register_npc("trader3", "mobs_character.b3d", {"mobs_trader3.png"}, mobs_character_offset, mobs_character_collisionbox)
ch_npc.register_npc("villager1", "Villager.b3d", x(10, "texturearavillager.png"), mobs_character_offset, mobs_character_collisionbox)
ch_npc.register_npc("villager2", "Villager.b3d", x(10, "textureewevillager.png"), mobs_character_offset, mobs_character_collisionbox)
ch_npc.register_npc("villager3", "Villager.b3d", x(10, "texturemedvillager.png"), mobs_character_offset, mobs_character_collisionbox)
ch_npc.register_npc("villager4", "Villager.b3d", x(10, "texturenorvillager.png"), mobs_character_offset, mobs_character_collisionbox)
ch_npc.register_npc("villager5", "Villager.b3d", x(10, "texturepapvillager.png"), mobs_character_offset, mobs_character_collisionbox)


ch_base.close_mod(minetest.get_current_modname())

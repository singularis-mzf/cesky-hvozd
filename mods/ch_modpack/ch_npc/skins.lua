local internal = ...

-- MODELS FROM SKINSDB:

for id, skin in pairs(skins.meta) do
	if string.match(id, "^character_") then
		-- function ch_npc.register_npc(id, model, textures, offset, collisionbox)
		local main_texture = skin:get_texture()
		ch_npc.register_npc(id, "skinsdb_3d_armor_character_5.b3d", {main_texture, "blank.png", "blank.png", "blank.png"}, vector.new(0, -0.5, 0), {-0.3, 0.0, -0.3, 0.3, 1.7, 0.3})
	end
end

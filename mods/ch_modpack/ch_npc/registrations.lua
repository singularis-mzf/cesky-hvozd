local internal = ...

ch_npc.registered_npcs = {
	default = {
		mesh = "npc.b3d",
		textures = {"folks_default.png"},
		offset = vector.new(0, -0.5, 0),
		collisionbox = nil,
	},
}

function ch_npc.register_npc(id, model, textures, offset, collisionbox)
	if ch_npc.registered_npcs[id] then
		minetest.log("warning", "ch_npc: registered NPC "..id.." redefined!")
	end
	ch_npc.registered_npcs[id] = {
		mesh = model,
		textures = textures,
		offset = offset or vector.zero,
		collisionbox = collisionbox,
	}
	return id
end

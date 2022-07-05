local S = mobs.intllib_npc

-- check for simple_dialogs mod and setup
local context = {}
local useDialogs = "N"

minetest.register_on_leaveplayer(function(player)
	context[player:get_player_name()] = nil
end)

if minetest.get_modpath("simple_dialogs") then

	useDialogs = "Y"

	simple_dialogs.register_varloader(function(npcself,playername)
		simple_dialogs.save_dialog_var(npcself, "NPCNAME", npcself.nametag, playername)
		simple_dialogs.save_dialog_var(npcself, "STATE", npcself.state, playername)
		simple_dialogs.save_dialog_var(npcself, "FOOD", npcself.food, playername)
		simple_dialogs.save_dialog_var(npcself, "HEALTH", npcself.health, playername)
		simple_dialogs.save_dialog_var(npcself, "owner", npcself.owner, playername)
	end)

	simple_dialogs.register_hook(function(npcself,playername,hook)

		if hook.func == "TELEPORT" then

			if npcself.owner then

				--check to see if the player has 'bring' teleport privliges
				local player_privs = minetest.get_player_privs(npcself.owner)

				if player_privs["bring"] then

					--validate x,y,z coords
					if hook.parm and hook.parmcount and hook.parmcount > 2 then

						local pos = {
							x = tonumber(hook.parm[1]),
							y = tonumber(hook.parm[2]),
							z = tonumber(hook.parm[3])
						}

						if pos.x and pos.y and pos.z
						and pos.x > -31500 and pos.x < 31500
						and pos.y > -31500 and pos.y < 31500
						and pos.z > -31500 and pos.z < 31500 then

							local player = minetest.get_player_by_name(playername)

							if player then
								player:set_pos(pos) end
						end
					end
				end
			end
			return "EXIT"
		end
	end)
end


-- Npc by TenPlus1

mobs.npc_drops = {
	{"default:pick_steel", 2}, "mobs:meat", {"default:sword_steel", 2},
	{"default:shovel_steel", 2}, "farming:bread", "bucket:bucket_water",
	"default:sapling", "default:tree", "mobs:leather", "default:coral_orange",
	{"default:mese_crystal_fragment", 3}, "default:clay", {"default:sign_wall", 2},
	"default:ladder", "default:copper_lump", "default:blueberries",
	"default:aspen_sapling", "default:permafrost_with_moss"
}

mobs:register_mob("mobs_npc:npc", {
	type = "npc",
	passive = false,
	damage = 3,
	attack_type = "dogfight",
	attacks_monsters = true,
	attack_npcs = false,
	owner_loyal = true,
	pathfinding = true,
	hp_min = 10,
	hp_max = 20,
	armor = 100,
	collisionbox = {-0.35,-1.0,-0.35, 0.35,0.8,0.35},
	visual = "mesh",
	mesh = "mobs_character.b3d",
	drawtype = "front",
	textures = {
		{"mobs_npc.png"},
		{"mobs_npc2.png"}, -- female by nuttmeg20
		{"mobs_npc3.png"}, -- male by swagman181818
		{"mobs_npc4.png"} -- female by Sapphire16
	},
	child_texture = {
		{"mobs_npc_baby.png"} -- derpy baby by AmirDerAssassine
	},
	makes_footstep_sound = true,
	sounds = {},
	walk_velocity = 2,
	run_velocity = 3,
	jump = true,
	drops = {
		{name = "default:wood", chance = 1, min = 1, max = 3},
		{name = "default:apple", chance = 2, min = 1, max = 2},
		{name = "default:axe_stone", chance = 5, min = 1, max = 1}
	},
	water_damage = 0,
	lava_damage = 2,
	light_damage = 0,
	follow = {"farming:bread", "mobs:meat", "default:diamond"},
	view_range = 15,
	owner = "",
	order = "follow",
	fear_height = 3,
	animation = {
		speed_normal = 30,
		speed_run = 30,
		stand_start = 0,
		stand_end = 79,
		walk_start = 168,
		walk_end = 187,
		run_start = 168,
		run_end = 187,
		punch_start = 200,
		punch_end = 219
	},

	on_rightclick = function(self, clicker)

		self.id = set_npc_id(self)

		-- feed to heal npc
		if mobs:feed_tame(self, clicker, 8, true, true) then return end

		-- capture npc with net or lasso
		if mobs:capture_mob(self, clicker, nil, 5, 80, false, nil) then return end

		-- protect npc with mobs:protector
		if mobs:protect(self, clicker) then return end

		local item = clicker:get_wielded_item()
		local name = clicker:get_player_name()

		-- right clicking with gold lump drops random item from mobs.npc_drops
		if item:get_name() == "default:gold_lump" then

			if not mobs.is_creative(name) then
				item:take_item()
				clicker:set_wielded_item(item)
			end

			local pos = self.object:get_pos()
			local drops = self.npc_drops or mobs.npc_drops
			local drop = drops[math.random(#drops)]
			local chance = 1

			if type(drop) == "table" then
				chance = drop[2]
				drop = drop[1]
			end

			if not minetest.registered_items[drop]
			or math.random(chance) > 1 then
				drop = "default:clay_lump"
			end

			local obj = minetest.add_item(pos, {name = drop})
			local dir = clicker:get_look_dir()

			obj:set_velocity({x = -dir.x, y = 1.5, z = -dir.z})

			return
		end

		-- by right-clicking owner can switch npc between follow, wander and stand
		if self.owner and self.owner == name then

			minetest.show_formspec(name, "mobs_npc:controls",
					get_npc_controls_formspec(name, self))

		elseif useDialogs == "Y" then
			simple_dialogs.show_dialog_formspec(name, self)
		end
	end
})


if not mobs.custom_spawn_npc then
mobs:spawn({
	name = "mobs_npc:npc",
	nodes = {"default:brick"},
	neighbors = {"default:grass_3"},
	min_light = 10,
	chance = 10000,
	active_object_count = 1,
	min_height = 0,
	day_toggle = true
})
end


mobs:register_egg("mobs_npc:npc", S("Npc"), "default_brick.png", 1)

-- compatibility
mobs:alias_mob("mobs:npc", "mobs_npc:npc")


-- Kilarin's formspec functions
function get_npc_controls_formspec(name,self)

	local currentordermode = self.order
	local npcId = self.id
	local orderArray = {"wander", "stand", "follow"}
	local currentorderidx = 1

	for i = 1, 3 do  --this seems like a clumsy way to do this
		if orderArray[i] == currentordermode then
			currentorderidx = i
			break
		end
	end

	-- Make npc controls formspec
	local text = "Ovládací panel nehráčské postavy"
	local size = useDialogs == "Y" and "size[15,10]" or "size[3.85,2.8]"
	local formspec = {
		size,
		"label[0.375,0.5;", minetest.formspec_escape(text), "]",
		"dropdown[0.375,1.25; 3,0.6;ordermode;procházet se,stát na místě,následovat mě;", currentorderidx, "]",
		"button[0.375,2;3,0.8;exit;Zavřít]"
	}

	if useDialogs == "Y" then
		simple_dialogs.add_dialog_control_to_formspec(name, self, formspec, 0.375, 3.4)
	end

	table.concat(formspec, "")

	--store npc id in local context so we can use it when the form is returned
	context[name] = npcId

	return table.concat(formspec, "")
end


minetest.register_on_player_receive_fields(function(player, formname, fields)

	local pname = player:get_player_name()

	if formname ~= "mobs_npc:controls" then

		if context[pname] then context[pname] = nil end

		return
	end

	local npcId = context[pname] or nil --get the npc id from local context
	local npcself = get_npcself_from_id(npcId)

	if npcself ~= nil then

		if fields["exit"] then

			minetest.close_formspec(pname, "mobs_npc:controls")

		elseif fields["ordermode"] then

--			minetest.chat_send_all("received ordermode")

			local pname = player:get_player_name()

			npcself.order = fields["ordermode"]

			if fields["ordermode"] == "procházet se" then
                npcself.order = "wander"
				minetest.chat_send_player(pname, S("NPC will wander."))

			elseif fields["ordermode"] == "stát na místě" then
                npcself.order = "stand"
				npcself.state = "stand"
				npcself.attack = nil
				npcself:set_animation("stand")
				npcself:set_velocity(0)

				minetest.chat_send_player(pname, S("NPC stands still."))

			elseif fields["ordermode"] == "následovat mě" then
                npcself.order = "follow"
				minetest.chat_send_player(pname, S("NPC will follow you."))
			end
		end

		if useDialogs == "Y" then
			simple_dialogs.process_simple_dialog_control_fields(pname, npcself, fields)
		end
	end
end)


-- check if npc has id set otherwise create one
function set_npc_id(npcself)

	if not npcself.id then
		npcself.id = (math.random(1, 1000) * math.random(1, 10000))
			.. npcself.name .. (math.random(1, 1000) ^ 2)
	end

	return npcself.id
end


--this function finds an npcself in the luaentities list given an npcId
function get_npcself_from_id(npcId)

	if npcId == nil then return nil end

	for k, v in pairs(minetest.luaentities) do

		if v.object and v.id and v.id == npcId then
			return v
		end
	end
end

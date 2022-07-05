
-- Realistic Torch mod by TenPlus1

print("[MOD BEGIN] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")
real_torch = {}
real_torch.S = minetest.get_translator("real_torch")
local S = real_torch.S

-- check for timer settings or use defaults
real_torch.min_duration = tonumber(minetest.settings:get("torch_min_duration")) or 1200
real_torch.max_duration = tonumber(minetest.settings:get("torch_max_duration")) or 1800


-- check which torch(es) are available in minetest version
if minetest.registered_nodes["default:torch_ceiling"] then

	dofile(minetest.get_modpath("real_torch") .. "/3d.lua")
else
	dofile(minetest.get_modpath("real_torch") .. "/2d.lua")
end


-- start timer on any already placed torches
minetest.register_lbm({
	name = "real_torch:convert_torch_to_node_timer",
	nodenames = {"default:torch", "default:torch_wall", "default:torch_ceiling"},
	action = function(pos)

		if not minetest.get_node_timer(pos):is_started() then

			minetest.get_node_timer(pos):start(
					math.random(real_torch.min_duration, real_torch.max_duration))
		end
	end
})


-- creative check
local creative_mode_cache = minetest.settings:get_bool("creative_mode")

function is_creative(name)
	return creative_mode_cache or minetest.check_player_privs(name, {creative = true})
end


-- coal powder
minetest.override_item("technic:coal_dust", {
	on_use = function(itemstack, user, pointed_thing)

		if not pointed_thing or pointed_thing.type ~= "node" then
			return
		end

		local pos = pointed_thing.under
		local nod = minetest.get_node(pos)
		local rep = false

		if nod.name == "real_torch:torch" then
			nod.name = "default:torch"
			rep = true

		elseif nod.name == "real_torch:torch_wall" then
			nod.name = "default:torch_wall"
			rep = true

		elseif nod.name == "real_torch:torch_ceiling" then
			nod.name = "default:torch_ceiling"
			rep = true
		end

		if rep then
			minetest.set_node(pos, {name = nod.name, param2 = nod.param2})

			if not is_creative(user:get_player_name()) then
				itemstack:take_item()
			end
		end

		return itemstack
	end
})

--[[
minetest.register_craftitem("real_torch:coal_powder", {
	description = S("Coal Powder"),
	inventory_image = "real_torch_coal_powder.png",

	-- punching unlit torch with coal powder relights
	on_use = function(itemstack, user, pointed_thing)

		if not pointed_thing or pointed_thing.type ~= "node" then
			return
		end

		local pos = pointed_thing.under
		local nod = minetest.get_node(pos)
		local rep = false

		if nod.name == "real_torch:torch" then
			nod.name = "default:torch"
			rep = true

		elseif nod.name == "real_torch:torch_wall" then
			nod.name = "default:torch_wall"
			rep = true

		elseif nod.name == "real_torch:torch_ceiling" then
			nod.name = "default:torch_ceiling"
			rep = true
		end

		if rep then
			minetest.set_node(pos, {name = nod.name, param2 = nod.param2})

			if not is_creative(user:get_player_name()) then
				itemstack:take_item()
			end
		end

		return itemstack
	end
})

-- use coal powder as furnace fuel
minetest.register_craft({
	type = "fuel",
	recipe = "real_torch:coal_powder",
	burntime = 8
})

-- 2x coal lumps = 12x coal powder
minetest.register_craft({
	output = "real_torch:coal_powder 12",
	recipe = {{"default:coal_lump", "default:coal_lump"}}
})

-- coal powder can make black dye
minetest.register_craft({
	output = "dye:black",
	recipe = {{"real_torch:coal_powder"}}
})

-- add coal powder to burnt out torch to relight
minetest.register_craft({
	output = "default:torch",
	recipe = {{"real_torch:torch", "real_torch:coal_powder"}}
})
]]

-- 4x burnt out torches = 1x stick
minetest.register_craft({
	output = "default:stick",
	recipe = {
		{"real_torch:torch", "real_torch:torch"},
		{"real_torch:torch", "real_torch:torch"}
	}
})


-- particle effects
local function add_effects(pos, radius)

	minetest.add_particle({
		pos = pos,
		velocity = vector.new(),
		acceleration = vector.new(),
		expirationtime = 0.5,
		size = radius * 10,
		collisiondetection = false,
		vertical = false,
		texture = "tnt_boom.png",
		glow = 15
	})

	minetest.add_particlespawner({
		amount = 16,
		time = 0.5,
		minpos = vector.subtract(pos, radius / 2),
		maxpos = vector.add(pos, radius / 2),
		minvel = {x = -2, y = -2, z = -2},
		maxvel = {x = 2, y = 2, z = 2},
		minacc = vector.new(),
		maxacc = vector.new(),
		minexptime = 1,
		maxexptime = 2.5,
		minsize = radius * 3,
		maxsize = radius * 5,
		texture = "tnt_smoke.png"
	})

	minetest.sound_play("tnt_explode",
			{pos = pos, gain = 0.1, max_hear_distance = 5}, true)
end


-- override tnt:gunpowder to explode when used on torch,
-- will also re-light torches and cause player damage when used on lit torch.
if minetest.get_modpath("tnt") then

minetest.override_item("tnt:gunpowder", {

	on_use = function(itemstack, user, pointed_thing)

		if not pointed_thing or pointed_thing.type ~= "node" then
			return
		end

		local pos = pointed_thing.under
		local nod = minetest.get_node(pos)

		local rep = false

		if nod.name == "real_torch:torch" then
			nod.name = "default:torch"
			rep = true

		elseif nod.name == "real_torch:torch_wall" then
			nod.name = "default:torch_wall"
			rep = true

		elseif nod.name == "real_torch:torch_ceiling" then
			nod.name = "default:torch_ceiling"
			rep = true
		end

		if rep then

			minetest.set_node(pos, {name = nod.name, param2 = nod.param2})

			add_effects(pos, 1)

			if not is_creative(user:get_player_name()) then
				itemstack:take_item()
			end

			return itemstack
		end

		if nod.name == "default:torch"
		or nod.name == "default:torch_wall"
		or nod.name == "default:torch_ceiling" then

			-- small delay to fix dupe bug
			minetest.after(0.1, function(user)
				user:set_hp(user:get_hp() - 2)
			end, user)

			add_effects(pos, 1)

			if not is_creative(user:get_player_name()) then
				itemstack:take_item()
			end
		end

		return itemstack
	end
})
end
print("[MOD END] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")

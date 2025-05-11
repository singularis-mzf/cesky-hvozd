local S = core.get_translator 'bonified'

-- Strength is the chance (0-1) to instantly advance a growth stage
-- For crops this is rerolled until failure or 5 times, whichever is lower
-- For saplings this value is halved
function bonified.apply_fertilizer (strength)
	return function (itemstack, player, pointed)
		if core.is_protected(player: get_player_name(), pointed.under) then
			core.record_protection_violation(player: get_player_name(), pointed.under)
			return itemstack
		end
		
		if pointed.type == 'node' then
			local name = core.get_node(pointed.under).name
		
			if core.get_item_group(name, 'sapling') ~= 0 then
				itemstack: take_item()
				
				if math.random() <= strength * 0.5 then
					default.grow_sapling(pointed.under)
					
					for i = 1, math.random(6,12) do
						core.add_particle {
							pos = pointed.under + vector.new((math.random() - 0.5) * 2, (math.random() - 0.66) * 0.3, (math.random() - 0.5) * 2),
							velocity = vector.new(0, 3, 0),
							acceleration = vector.new(0, -5, 0),
							expirationtime = 0.35,
							glow = 5,
							size = 1,
							texture = 'bonified_fertilize_particle.png'
						}
					end
				end
				
				return itemstack
			end
			
			if (core.get_item_group(name, 'plant') ~= 0 or core.get_item_group(name, 'seed') ~= 0)
			and core.registered_nodes[name].next_plant then
				itemstack: take_item()
				
				local rolls = 0
				while math.random() <= strength and rolls < 6 do
					farming.grow_plant(pointed.under)
					
					for i = 1, math.random(3,5) do
						core.add_particle {
							pos = pointed.under + vector.new(math.random() - 0.5, (math.random() - 0.66) * 0.3, math.random() - 0.5),
							velocity = vector.new(0, 3, 0),
							acceleration = vector.new(0, -5, 0),
							expirationtime = 0.35,
							glow = 5,
							size = 1,
							texture = 'bonified_fertilize_particle.png'
						}
					end
					
					rolls = rolls + 1
				end
				
				return itemstack
			end
		end
	end
end

core.register_craftitem('bonified:bone_meal', {
	description = S 'Bone Meal',
	inventory_image = 'bonified_bone_meal.png',
	on_use = bonified.apply_fertilizer(core.settings: get 'bonified.bone_meal_strength' or 0.25)
})

core.register_craft {
	type = 'shapeless',
	output = 'bonified:bone_meal 4',
	recipe = {'bonified:bone'}
}

if core.get_modpath 'dye' then
	core.register_craft {
		type = 'shapeless',
		output = 'dye:white',
		recipe = {'bonified:bone_meal'}
	}
end

core.register_craftitem('bonified:fertilizer', {
	description = S 'Fertilizer',
	inventory_image = 'bonified_fertilizer.png',
	on_use = bonified.apply_fertilizer(core.settings: get 'bonified.fertilizer_strength' or 0.65)
})

if core.get_modpath 'flowers' then
		core.register_craft {
			type = 'shapeless',
			output = 'bonified:fertilizer 4',
			recipe = {'bonified:bone_meal', 'bonified:bone_meal', 'group:leaves', 'flowers:mushroom_brown'}
		}
else
	core.register_craft {
		type = 'shapeless',
		output = 'bonified:fertilizer 4',
		recipe = {'bonified:bone_meal', 'bonified:bone_meal', 'group:leaves', 'default:clay'}
	}
end

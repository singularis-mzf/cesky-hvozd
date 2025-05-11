
local S = core.get_translator 'bonified'

if core.settings: get_bool('bonified.enable_bone_tools', true) then
	-- Bone bundle item
	core.register_craftitem('bonified:bone_bundle', {
		description = S 'Bundle of Bones',
		inventory_image = 'bonified_bone_bundle.png'
	})
	
	if core.get_modpath 'farming' then
		core.register_craft {
			output = 'bonified:bone_bundle',
			recipe = {
				{'bonified:bone', 'farming:string', 'bonified:bone'},
				{'bonified:bone', 'farming:string', 'bonified:bone'}
			}
		}
	else
		core.register_craft {
			output = 'bonified:bone_bundle',
			recipe = {
				{'bonified:bone', 'group:grass', 'bonified:bone'},
				{'bonified:bone', 'group:grass', 'bonified:bone'}
			}
		}
	end
	
	-- Bone armor
	armor: register_armor('bonified:armor_helmet_bone', {
		description = S 'Bone Skullmet',
		inventory_image = 'bonified_helmet_bone_inv.png',
		groups = {armor_head=1, armor_heal=5.5, armor_use=350},
		armor_groups = {fleshy=8},
		damage_groups = {cracky=3, snappy=2, choppy=2, crumbly=1, level=2},
	})
	
	core.register_craft {
		output = 'bonified:armor_helmet_bone',
		recipe = {
			{'bonified:bone', 'bonified:bone_bundle', 'bonified:bone'},
			{'bonified:bone_bundle', '', 'bonified:bone_bundle'}
		}
	}
	
	armor: register_armor('bonified:armor_chestplate_bone', {
		description = S 'Bone Sternumplate',
		inventory_image = 'bonified_chestplate_bone_inv.png',
		groups = {armor_torso=1, armor_heal=5.5, armor_use=350},
		armor_groups = {fleshy=13},
		damage_groups = {cracky=3, snappy=2, choppy=2, crumbly=1, level=2},
	})
	
	core.register_craft {
		output = 'bonified:armor_chestplate_bone',
		recipe = {
			{'bonified:bone', '', 'bonified:bone'},
			{'bonified:bone_bundle', 'bonified:bone_bundle', 'bonified:bone_bundle'},
			{'bonified:bone', 'bonified:bone_bundle', 'bonified:bone'}
		}
	}
	
	armor: register_armor('bonified:armor_leggings_bone', {
		description = S 'Bone Patellarmor',
		inventory_image = 'bonified_leggings_bone_inv.png',
		groups = {armor_legs=1, armor_heal=5.5, armor_use=350},
		armor_groups = {fleshy=13},
		damage_groups = {cracky=3, snappy=2, choppy=2, crumbly=1, level=2},
	})
	
	core.register_craft {
		output = 'bonified:armor_leggings_bone',
		recipe = {
			{'bonified:bone', 'bonified:bone', 'bonified:bone'},
			{'bonified:bone_bundle', '', 'bonified:bone_bundle'},
			{'bonified:bone_bundle', '', 'bonified:bone_bundle'}
		}
	}
	
	armor: register_armor('bonified:armor_boots_bone', {
		description = S 'Bone Shinguards',
		inventory_image = 'bonified_boots_bone_inv.png',
		groups = {armor_feet=1, armor_heal=5.5, armor_use=350},
		armor_groups = {fleshy=8},
		damage_groups = {cracky=3, snappy=2, choppy=2, crumbly=1, level=2},
	})
	
	core.register_craft {
		output = 'bonified:armor_boots_bone',
		recipe = {
			{'bonified:bone', '', 'bonified:bone'},
			{'bonified:bone_bundle', '', 'bonified:bone_bundle'}
		}
	}
	
	-- Bone shield
	if core.get_modpath 'shields' then
		armor:register_armor('bonified:armor_shield_bone', {
			description = S 'Bone Shield',
			inventory_image = 'bonified_shield_bone_inv.png',
			groups = {armor_shield=1, armor_heal=5, armor_use=350},
			armor_groups = {fleshy=8},
			damage_groups = {cracky=2, snappy=3, choppy=2, crumbly=1, level=2},
			reciprocate_damage = true
		})
		
		core.register_craft {
			output = 'bonified:armor_shield_bone',
			recipe = {
				{'bonified:bone', 'bonified:bone', 'bonified:bone'},
				{'bonified:bone', 'bonified:bone_bundle', 'bonified:bone'},
				{'', 'bonified:bone_bundle', ''}
			}
		}
	end
end

-- Fossil armor
if core.settings: get_bool('bonified.enable_fossil_tools', true) then
	-- Fossil plate item
	core.register_craftitem('bonified:fossil_plate', {
		description = S 'Ancient Plating',
		inventory_image = 'bonified_fossil_plate.png'
	})

	core.register_craft {
		output = 'bonified:fossil_plate',
		recipe = {
			{'bonified:fossil', 'default:bronze_ingot', 'bonified:fossil'}
		}
	}
	
	-- Fossil armor
	armor: register_armor('bonified:armor_helmet_fossil', {
		description = S 'Ancient Helm',
		inventory_image = 'bonified_helmet_fossil_inv.png',
		groups = {armor_head=1, armor_heal=10, armor_use=400},
		armor_groups = {fleshy=15},
		damage_groups = {cracky=2, snappy=1, choppy=2, level=3},
	})
	
	core.register_craft {
		output = 'bonified:armor_helmet_fossil',
		recipe = {
			{'default:bronze_ingot', 'bonified:fossil_plate', 'default:bronze_ingot'},
			{'bonified:fossil_plate', '', 'bonified:fossil_plate'}
		}
	}
	
	armor: register_armor('bonified:armor_chestplate_fossil', {
		description = S 'Ancient Cuirass',
		inventory_image = 'bonified_chestplate_fossil_inv.png',
		groups = {armor_torso=1, armor_heal=10, armor_use=400},
		armor_groups = {fleshy=18},
		damage_groups = {cracky=2, snappy=1, choppy=2, level=3},
	})
	
	core.register_craft {
		output = 'bonified:armor_chestplate_fossil',
		recipe = {
			{'default:bronze_ingot', '', 'default:bronze_ingot'},
			{'bonified:fossil_plate', 'bonified:fossil_plate', 'bonified:fossil_plate'},
			{'bonified:fossil_plate', 'bonified:fossil_plate', 'bonified:fossil_plate'}
		}
	}
	
	armor: register_armor('bonified:armor_leggings_fossil', {
		description = S 'Ancient Cuisses',
		inventory_image = 'bonified_leggings_fossil_inv.png',
		groups = {armor_legs=1, armor_heal=10, armor_use=400},
		armor_groups = {fleshy=18},
		damage_groups = {cracky=2, snappy=1, choppy=2, level=3},
	})
	
	core.register_craft {
		output = 'bonified:armor_leggings_fossil',
		recipe = {
			{'default:bronze_ingot', 'bonified:fossil_plate', 'default:bronze_ingot'},
			{'bonified:fossil_plate', '', 'bonified:fossil_plate'},
			{'bonified:fossil_plate', '', 'bonified:fossil_plate'}
		}
	}
	
	armor: register_armor('bonified:armor_boots_fossil', {
		description = S 'Ancient Greaves',
		inventory_image = 'bonified_boots_fossil_inv.png',
		groups = {armor_feet=1, armor_heal=10, armor_use=400},
		armor_groups = {fleshy=15},
		damage_groups = {cracky=2, snappy=1, choppy=2, level=3},
	})
	
	core.register_craft {
		output = 'bonified:armor_boots_fossil',
		recipe = {
			{'default:bronze_ingot', '', 'default:bronze_ingot'},
			{'bonified:fossil_plate', '', 'bonified:fossil_plate'}
		}
	}
	
	-- Fossil shield
	if core.get_modpath 'shields' then
		armor:register_armor('bonified:armor_shield_fossil', {
			description = S 'Ancient Shield',
			inventory_image = 'bonified_shield_fossil_inv.png',
			groups = {armor_shield=1, armor_heal=10, armor_use=400},
			armor_groups = {fleshy=12},
			damage_groups = {cracky=2, snappy=1, choppy=2, level=3},
			reciprocate_damage = true
		})
		
		core.register_craft {
			output = 'bonified:armor_shield_fossil',
			recipe = {
				{'bonified:fossil_plate', 'default:bronze_ingot', 'bonified:fossil_plate'},
				{'bonified:fossil_plate', 'bonified:fossil_plate', 'bonified:fossil_plate'},
				{'', 'default:bronze_ingot', ''}
			}
		}
	end
end

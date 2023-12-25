
visionLib.Material={}

visionLib.Materials={}

visionLib._sMaterials={
	["iron"]=function()
		visionLib.Material.create("iron", "Iron", "hard", "b0b0b0a0")
		if minetest.get_modpath("default") then
			visionLib.Common.SmartOverrideItem("default:steel_ingot", {description="Iron Ingot", groups={ingot_iron=1, ingot=1, iron=1, metal=1}})
			visionLib.Common.SmartOverrideItem("default:steelblock", {description="Iron Block", groups={block_iron=1, iron=1, metal_block=1}})
			visionLib.Common.SmartOverrideItem("default:stone_with_iron", {groups={ore_iron=1, iron=1}})
			visionLib.Common.SmartOverrideItem("default:iron_lump", {groups={ore_iron=1, lump_iron=1, iron=1}})
			minetest.register_alias_force("vision_lib:iron_ingot", "default:steel_ingot")
			minetest.register_alias_force("vision_lib:iron_lump", "default:iron_lump")
			minetest.register_alias_force("default:iron_ingot", "default:steel_ingot")
			minetest.register_alias_force("vision_lib:iron_block", "default:steelblock")
			if minetest.get_modpath("technic") then
				visionLib.Common.SmartOverrideItem("technic:wrought_iron_dust", {groups={dust_iron=1,iron=1,dust=1, metal=1}})
				minetest.register_alias_force("vision_lib:iron_dust", "technic:wrought_iron_dust")
			end
		end
	end,
	["copper"]=function()
		visionLib.Material.create("copper", "Copper", "soft", "ff7000a0")
		if minetest.get_modpath("default") then
			visionLib.Common.SmartOverrideItem("default:copper_ingot", {groups={ingot_copper=1, ingot=1, copper=1, metal=1}})
			visionLib.Common.SmartOverrideItem("default:copperblock", {groups={block_copper=1, copper=1, metal_block=1}})
			visionLib.Common.SmartOverrideItem("default:stone_with_copper", {groups={ore_copper=1, copper=1}})
			visionLib.Common.SmartOverrideItem("default:copper_lump", {groups={ore_copper=1, lump_copper=1,copper=1}})
			minetest.register_alias_force("vision_lib:copper_ingot", "default:copper_ingot")
			minetest.register_alias_force("vision_lib:copper_block", "default:copperblock")
			minetest.register_alias_force("vision_lib:copper_lump", "default:copper_lump")
			if minetest.get_modpath("technic") then
				visionLib.Common.SmartOverrideItem("technic:copper_dust", {groups={dust_copper=1,copper=1,dust=1, metal=1}})
				visionLib.Common.SmartOverrideItem("technic:copper_plate", {groups={plate_copper=1,copper=1,plate=1, metal=1}})
				minetest.register_alias_force("vision_lib:copper_dust", "technic:copper_dust")
				minetest.register_alias_force("vision_lib:copper_plate", "technic:copper_plate")
			end
		end
	end,
	["tin"]=function()
		visionLib.Material.create("tin", "Tin", "hard", "b0b0b850")
		if minetest.get_modpath("default") then
			visionLib.Common.SmartOverrideItem("default:tin_ingot", {groups={ingot_tin=1, ingot=1, tin=1, metal=1}})
			visionLib.Common.SmartOverrideItem("default:tinblock", {groups={block_tin=1, tin=1, metal_block=1}})
			visionLib.Common.SmartOverrideItem("default:stone_with_tin", {groups={ore_tin=1, tin=1}})
			visionLib.Common.SmartOverrideItem("default:tin_lump", {groups={ore_tin=1, lump_tin=1,tin=1}})
			minetest.register_alias_force("vision_lib:tin_ingot", "default:tin_ingot")
			minetest.register_alias_force("vision_lib:tin_block", "default:tinblock")
			minetest.register_alias_force("vision_lib:tin_lump", "default:tin_lump")
			if minetest.get_modpath("technic") then
				visionLib.Common.SmartOverrideItem("technic:tin_dust", {groups={dust_tin=1,tin=1,dust=1, metal=1}})
				minetest.register_alias_force("vision_lib:tin_dust", "technic:tin_dust")
			end
		end
	end,
	["gold"]=function()
		visionLib.Material.create("gold", "Gold", "soft", "ffd90050")
		if minetest.get_modpath("default") then
			visionLib.Common.SmartOverrideItem("default:gold_ingot", {groups={ingot_gold=1, ingot=1, gold=1, metal=1}})
			visionLib.Common.SmartOverrideItem("default:goldblock", {groups={block_gold=1, gold=1, metal_block=1}})
			visionLib.Common.SmartOverrideItem("default:stone_with_gold", {groups={ore_gold=1, gold=1}})
			visionLib.Common.SmartOverrideItem("default:gold_lump", {groups={ore_gold=1, lump_gold=1,gold=1}})
			minetest.register_alias_force("vision_lib:gold_ingot", "default:gold_ingot")
			minetest.register_alias_force("vision_lib:gold_block", "default:goldblock")
			minetest.register_alias_force("vision_lib:gold_lump", "default:gold_lump")
			if minetest.get_modpath("technic") then
				visionLib.Common.SmartOverrideItem("technic:gold_dust", {groups={dust_gold=1,gold=1,dust=1, metal=1}})
				minetest.register_alias_force("vision_lib:gold_dust", "technic:gold_dust")
			end
		end
	end,
	["bronze"]=function()
		visionLib.Material.create("bronze", "Bronze", "hard", "ff990095", true)
		if minetest.get_modpath("default") then
			visionLib.Common.SmartOverrideItem("default:bronze_ingot", {groups={ingot_bronze=1, ingot=1, bronze=1, metal=1}})
			visionLib.Common.SmartOverrideItem("default:bronzeblock", {groups={block_bronze=1, bronze=1, metal_block=1}})
			minetest.register_alias_force("vision_lib:bronze_ingot", "default:bronze_ingot")
			minetest.register_alias_force("vision_lib:bronze_block", "default:bronzeblock")
			if minetest.get_modpath("technic") then
				visionLib.Common.SmartOverrideItem("technic:bronze_dust", {groups={dust_bronze=1,bronze=1,dust=1, metal=1}})
				minetest.register_alias_force("vision_lib:bronze_dust", "technic:bronze_dust")
			end
		end
	end,
	["diamond"]=function()
		visionLib.Material.create("diamond", "Diamond", "fragile", "9999ffd0")
		if minetest.get_modpath("default") then
			visionLib.Common.SmartOverrideItem("default:diamond", {groups={gem_diamond=1, gem=1, diamond=1}})
			visionLib.Common.SmartOverrideItem("default:diamondblock", {groups={block_diamond=1, diamond=1, gem_block=1}})
			visionLib.Common.SmartOverrideItem("default:stone_with_diamond", {groups={ore_diamond=1, diamond=1}})
			minetest.register_alias_force("vision_lib:diamond_gem", "default:diamond")
			minetest.register_alias_force("vision_lib:diamond_block", "default:diamondblock")
		end
	end,
	["mese"]=function()
		visionLib.Material.create("mese", "Mese", "fragile", "ffff00e0")
		if minetest.get_modpath("default") then
			visionLib.Common.SmartOverrideItem("default:mese_crystal", {groups={gem_mese=1, gem=1, mese=1}})
			visionLib.Common.SmartOverrideItem("default:mese_crystal_fragment", {groups={shard_mese=1, shard=1, mese=1}})
			visionLib.Common.SmartOverrideItem("default:mese", {groups={block_mese=1, mese=1, gem_block=1}})
			visionLib.Common.SmartOverrideItem("default:stone_with_mese", {groups={ore_mese=1, mese=1}})
			minetest.register_alias_force("vision_lib:mese_gem", "default:mese_crystal")
			minetest.register_alias_force("vision_lib:mese_shard", "default:mese_crystal_fragment")
			minetest.register_alias_force("vision_lib:mese_block", "default:mese")
		end
	end,
	["obsidian"]=function()
		visionLib.Material.create("obsidian", "Obsidian", "fragile", "200020e0")
		if minetest.get_modpath("default") then
			visionLib.Common.SmartOverrideItem("default:obsidian_shard", {groups={shard_obsidian=1, shard=1, obsidian=1}})
			visionLib.Common.SmartOverrideItem("default:obsidian", {groups={block_obsidian=1, obsidian=1, gem_block=1}})
			visionLib.Common.SmartOverrideItem("default:obsidianbrick", {groups={block_obsidian=1, obsidian=1, gem_block=1}})
			visionLib.Common.SmartOverrideItem("default:obsidian_block", {groups={block_obsidian=1, obsidian=1, gem_block=1}})
			visionLib.Common.SmartOverrideItem("default:obsidian_glass", {groups={block_obsidian=1, obsidian=1, gem_block=1}})
			minetest.register_alias_force("vision_lib:obsidian_gem", "default:obsidian")
			minetest.register_alias_force("vision_lib:obsidian_shard", "default:obsidian_shard")
		end
	end,
	["coal"]=function()
		if minetest.get_modpath("default") then
			visionLib.Common.SmartOverrideItem("default:coal_lump", {groups={gem_coal=1, gem=1, coal=1}})
			visionLib.Common.SmartOverrideItem("default:coalblock", {groups={block_coal=1, coal=1, gem_block=1}})
			visionLib.Common.SmartOverrideItem("default:stone_with_coal", {groups={ore_coal=1, coal=1}})
			if minetest.get_modpath("technic") then
				visionLib.Common.SmartOverrideItem("technic:coal_dust", {groups={dust_coal=1,coal=1,dust=1}})
				minetest.register_alias_force("vision_lib:coal_dust", "technic:coal_dust")
			end
		end
	end,
	["luminium"]=function()
		if minetest.get_modpath("ocular_networks") then
			visionLib.Common.SmartOverrideItem("ocular_networks:luminium_bar", {groups={ingot_luminium=1, ingot=1, luminium=1, metal=1}})
			visionLib.Common.SmartOverrideItem("ocular_networks:plate_luminium", {groups={plate_luminium=1, plate=1, luminium=1, metal=1}})
			visionLib.Common.SmartOverrideItem("ocular_networks:dust_luminium", {groups={dust_luminium=1, dust=1, luminium=1, metal=1}})
			visionLib.Common.SmartOverrideItem("ocular_networks:luminium_block", {groups={block_luminium=1, luminium=1, metal_block=1}})
			visionLib.Common.SmartOverrideItem("ocular_networks:luminium_ore", {groups={ore_luminium=1, luminium=1}})
			visionLib.Common.SmartOverrideItem("ocular_networks:luminium_lump", {groups={ore_luminium=1, lump_luminium=1,luminium=1}})
			visionLib.Common.SmartOverrideItem("ocular_networks:luminium_chip", {groups={nugget_luminium=1, nugget=1, luminium=1}})
		else
			visionLib.Material.create("luminium", "Luminium", "hard", "76abffa0")
		end
	end,
	["lumigold"]=function()
		if minetest.get_modpath("ocular_networks") then
			visionLib.Common.SmartOverrideItem("ocular_networks:luminium_bar_3", {groups={ingot_lumigold=1, ingot=1, lumigold=1, metal=1}})
			visionLib.Common.SmartOverrideItem("ocular_networks:lumigold_block", {groups={block_lumigold=1, lumigold=1, metal_block=1}})
			visionLib.Common.SmartOverrideItem("ocular_networks:plate_lumigold", {groups={plate_lumigold=1, plate=1, lumigold=1, metal=1}})
			visionLib.Common.SmartOverrideItem("ocular_networks:lumigold_rod", {groups={rod_lumigold=1, rod=1, lumigold=1, metal=1}})
			visionLib.Common.SmartOverrideItem("ocular_networks:dust_lumigold", {groups={dust_lumigold=1, dust=1, lumigold=1, metal=1}})
		else
			visionLib.Material.create("lumigold", "Lumigold", "hard", "e6e18aa0", true)
		end
	end,
	["hekatonium"]=function()
		if minetest.get_modpath("ocular_networks") then
			visionLib.Common.SmartOverrideItem("ocular_networks:hekatonium_bar", {groups={ingot_hekatonium=1, ingot=1, hekatonium=1, metal=1}})
			visionLib.Common.SmartOverrideItem("ocular_networks:hekatonium_block", {groups={block_hekatonium=1, hekatonium=1, metal_block=1}})
			visionLib.Common.SmartOverrideItem("ocular_networks:hekatonium_ore", {groups={ore_hekatonium=1, hekatonium=1}})
			visionLib.Common.SmartOverrideItem("ocular_networks:hekatonium_chunk", {groups={ore_hekatonium=1, lump_hekatonium=1,hekatonium=1}})
		else
			visionLib.Material.create("hekatonium", "hekatonium", "hard", "3a00a7c0")
		end
	end,
	["angmallen"]=function()
		if minetest.get_modpath("ocular_networks") then
			visionLib.Common.SmartOverrideItem("ocular_networks:angmallen_bar", {groups={ingot_angmallen=1, ingot=1, angmallen=1, metal=1}})
			visionLib.Common.SmartOverrideItem("ocular_networks:angmallen_block", {groups={block_angmallen=1, angmallen=1, metal_block=1}})
			visionLib.Common.SmartOverrideItem("ocular_networks:dust_angmallen", {groups={dust_angmallen=1, dust=1, angmallen=1, metal=1}})
		else
			visionLib.Material.create("angmallen", "Angmallen", "hard", "ec9600a0", true)
		end
	end,
	["silicotin"]=function()
		if minetest.get_modpath("ocular_networks") then
			visionLib.Common.SmartOverrideItem("ocular_networks:silicotin_bar", {groups={ingot_silicotin=1, ingot=1, silicotin=1, metal=1}})
			visionLib.Common.SmartOverrideItem("ocular_networks:silicotin_block", {groups={block_silicotin=1, silicotin=1, metal_block=1}})
			visionLib.Common.SmartOverrideItem("ocular_networks:plate_silicotin", {groups={plate_silicotin=1, plate=1, silicotin=1, metal=1}})
			visionLib.Common.SmartOverrideItem("ocular_networks:dust_silicotin", {groups={dust_silicotin=1, dust=1, silicotin=1, metal=1}})
		else
			visionLib.Material.create("silicotin", "Silicotin", "hard", "262c76d4", true)
		end		
	end,
	["zweinium"]=function()
		if minetest.get_modpath("ocular_networks") then
			visionLib.Common.SmartOverrideItem("ocular_networks:zweinium_crystal", {groups={gem_zweinium=1, gem=1, zweinium=1}})
			visionLib.Common.SmartOverrideItem("ocular_networks:zweinium_block", {groups={block_zweinium=1, zweinium=1, gem_block=1}})
			visionLib.Common.SmartOverrideItem("ocular_networks:zweinium_ore", {groups={ore_zweinium=1, zweinium=1}})
			visionLib.Common.SmartOverrideItem("ocular_networks:dust_zweinium", {groups={dust_zweinium=1, dust=1, zweinium=1}})
		else
			visionLib.Material.create("zweinium", "Zweinium", "fragile", "00ff7190", true)
		end
	end,
	["shimmering"]=function()
		if minetest.get_modpath("ocular_networks") then
			visionLib.Common.SmartOverrideItem("ocular_networks:shimmering_bar", {groups={ingot_shimmering=1, ingot=1, shimmering=1, metal=1}})
			visionLib.Common.SmartOverrideItem("ocular_networks:shimmering_block", {groups={block_shimmering=1, shimmering=1, metal_block=1}})
			visionLib.Common.SmartOverrideItem("ocular_networks:plate_shimmering", {groups={plate_shimmering=1, plate=1, shimmering=1, metal=1}})
			visionLib.Common.SmartOverrideItem("ocular_networks:dust_shimmering", {groups={dust_shimmering=1, dust=1, shimmering=1, metal=1}})
		else
			visionLib.Material.create("shimmering", "Shimmering", "hard", "ffffffa0", true)
		end
	end,
	["mithril"]=function()
		if minetest.get_modpath("moreores") then
			visionLib.Material.create("mithril", "Mithril", "hard", "0203f8a0")
			visionLib.Common.SmartOverrideItem("moreores:mithril_ingot", {groups={ingot_mithril=1, ingot=1, mithril=1, metal=1}})
			visionLib.Common.SmartOverrideItem("moreores:mithril_block", {groups={block_mithril=1, mithril=1, metal_block=1}})
			visionLib.Common.SmartOverrideItem("moreores:mineral_mithril", {groups={ore_mithril=1, mithril=1}})
			visionLib.Common.SmartOverrideItem("moreores:mithril_lump", {groups={ore_mithril=1, lump_mithril=1,mithril=1}})
			minetest.register_alias_force("vision_lib:mithril_ingot", "moreores:mithril_ingot")
			minetest.register_alias_force("vision_lib:mithril_block", "moreores:mithril_block")
			minetest.register_alias_force("vision_lib:mithril_lump", "moreores:mithril_lump")
			if minetest.get_modpath("technic") then
				visionLib.Common.SmartOverrideItem("technic:mithril_dust", {groups={dust_mithril=1,mithril=1,dust=1, metal=1}})
				minetest.register_alias_force("vision_lib:mithril_dust", "technic:mithril_dust")
			end
		end
	end,
	["silver"]=function()
		visionLib.Material.create("silver", "Silver", "hard", "0000ff20")
		if minetest.get_modpath("moreores") then
			visionLib.Common.SmartOverrideItem("moreores:silver_ingot", {groups={ingot_silver=1, ingot=1, silver=1, metal=1}})
			visionLib.Common.SmartOverrideItem("moreores:silver_block", {groups={block_silver=1, silver=1, metal_block=1}})
			visionLib.Common.SmartOverrideItem("moreores:mineral_silver", {groups={ore_silver=1, silver=1}})
			visionLib.Common.SmartOverrideItem("moreores:silver_lump", {groups={ore_silver=1, lump_silver=1,silver=1}})
			minetest.register_alias_force("vision_lib:silver_ingot", "moreores:silver_ingot")
			minetest.register_alias_force("vision_lib:silver_block", "moreores:silver_block")
			minetest.register_alias_force("vision_lib:silver_lump", "moreores:silver_lump")
			if minetest.get_modpath("technic") then
				visionLib.Common.SmartOverrideItem("technic:silver_dust", {groups={dust_silver=1,silver=1,dust=1, metal=1}})
				minetest.register_alias_force("vision_lib:silver_dust", "technic:silver_dust")
			end
		end
	end,
	["brass"]=function()
		visionLib.Material.create("brass", "Brass", "hard", "ffd90033", true)
		if minetest.get_modpath("basic_materials") then
			visionLib.Common.SmartOverrideItem("basic_materials:brass_ingot", {groups={ingot_brass=1, ingot=1, brass=1, metal=1}})
			visionLib.Common.SmartOverrideItem("basic_materials:brass_block", {groups={block_brass=1, brass=1, metal_block=1}})
			minetest.register_alias_force("vision_lib:brass_ingot", "basic_materials:brass_ingot")
			minetest.register_alias_force("vision_lib:brass_block", "basic_materials:brass_block")
			if minetest.get_modpath("technic") then
				visionLib.Common.SmartOverrideItem("technic:brass_dust", {groups={dust_brass=1,brass=1,dust=1, metal=1}})
				minetest.register_alias_force("vision_lib:brass_dust", "technic:brass_dust")
			end
		end
	end,
	["carbon_steel"]=function()
		visionLib.Material.create("carbon_steel", "Carbon Steel", "hard", "0001f933", true)
		if minetest.get_modpath("technic") then
			visionLib.Common.SmartOverrideItem("technic:carbon_steel_ingot", {groups={ingot_carbon_steel=1, ingot=1, carbon_steel=1, metal=1}})
			visionLib.Common.SmartOverrideItem("technic:carbon_steel_block", {groups={block_carbon_steel=1, carbon_steel=1, metal_block=1}})
			visionLib.Common.SmartOverrideItem("technic:carbon_steel_dust", {groups={dust_carbon_steel=1, dust=1, carbon_steel=1, metal=1}})
			minetest.register_alias_force("vision_lib:carbon_steel_ingot", "technic:carbon_steel_ingot")
			minetest.register_alias_force("vision_lib:carbon_steel_block", "technic:carbon_steel_block")
			minetest.register_alias_force("vision_lib:carbon_steel_dust", "technic:carbon_steel_dust")
		end
	end,
	["cast_iron"]=function()
		visionLib.Material.create("cast_iron", "Cast Iron", "hard", "0000a035", true)
		if minetest.get_modpath("technic") then
			visionLib.Common.SmartOverrideItem("technic:cast_iron_ingot", {groups={ingot_cast_iron=1, ingot=1, cast_iron=1, metal=1}})
			visionLib.Common.SmartOverrideItem("technic:cast_iron_block", {groups={block_cast_iron=1, cast_iron=1, metal_block=1}})
			visionLib.Common.SmartOverrideItem("technic:cast_iron_dust", {groups={dust_cast_iron=1, dust=1, cast_iron=1, metal=1}})
			minetest.register_alias_force("vision_lib:cast_iron_ingot", "technic:cst_iron_ingot")
			minetest.register_alias_force("vision_lib:cast_iron_block", "technic:cast_iron_block")
			minetest.register_alias_force("vision_lib:cast_iron_dust", "technic:cast_iron_dust")
		end
	end,
	["chromium"]=function()
		visionLib.Material.create("chromium", "Chromium", "hard", "0203f815")
		if minetest.get_modpath("technic") then
			visionLib.Common.SmartOverrideItem("technic:chromium_ingot", {groups={ingot_chromium=1, ingot=1, chromium=1, metal=1}})
			visionLib.Common.SmartOverrideItem("technic:chromium_block", {groups={block_chromium=1, chromium=1, metal_block=1}})
			visionLib.Common.SmartOverrideItem("technic:chromium_dust", {groups={dust_chromium=1, dust=1, chromium=1, metal=1}})
			visionLib.Common.SmartOverrideItem("technic:mineral_chromium", {groups={ore_chromium=1, chromium=1}})
			visionLib.Common.SmartOverrideItem("technic:chromium_lump", {groups={ore_chromium=1, lump_chromium=1,chromium=1}})
			minetest.register_alias_force("vision_lib:chromium_ingot", "technic:chromium_ingot")
			minetest.register_alias_force("vision_lib:chromium_block", "technic:chromium_block")
			minetest.register_alias_force("vision_lib:chromium_dust", "technic:chromium_dust")
			minetest.register_alias_force("vision_lib:chromium_lump", "technic:chromium_lump")
		end
	end,
	["lead"]=function()
		visionLib.Material.create("lead", "Lead", "soft", "40108063")
		if minetest.get_modpath("technic") then
			visionLib.Common.SmartOverrideItem("technic:lead_ingot", {groups={ingot_lead=1, ingot=1, lead=1, metal=1}})
			visionLib.Common.SmartOverrideItem("technic:lead_block", {groups={block_lead=1, lead=1, metal_block=1}})
			visionLib.Common.SmartOverrideItem("technic:lead_dust", {groups={dust_lead=1, dust=1, lead=1, metal=1}})
			visionLib.Common.SmartOverrideItem("technic:mineral_lead", {groups={ore_lead=1, lead=1}})
			visionLib.Common.SmartOverrideItem("technic:lead_lump", {groups={ore_lead=1, lump_lead=1,lead=1}})
			minetest.register_alias_force("vision_lib:lead_ingot", "technic:lead_ingot")
			minetest.register_alias_force("vision_lib:lead_block", "technic:lead_block")
			minetest.register_alias_force("vision_lib:lead_dust", "technic:lead_dust")
			minetest.register_alias_force("vision_lib:lead_lump", "technic:lead_lump")
		end
	end,
	["stainless_steel"]=function()
		visionLib.Material.create("stainless_steel", "Stainless Steel", "hard", "00010320", true)
		if minetest.get_modpath("technic") then
			visionLib.Common.SmartOverrideItem("technic:stainless_steel_ingot", {groups={ingot_stainless_steel=1, ingot=1, stainless_steel=1, metal=1}})
			visionLib.Common.SmartOverrideItem("technic:stainless_steel_block", {groups={block_stainless_steel=1, stainless_steel=1, metal_block=1}})
			visionLib.Common.SmartOverrideItem("technic:stainless_steel_dust", {groups={dust_stainless_steel=1, dust=1, stainless_steel=1, metal=1}})
			minetest.register_alias_force("vision_lib:stainless_steel_ingot", "technic:stainless_steel_ingot")
			minetest.register_alias_force("vision_lib:stainless_steel_block", "technic:stainless_steel_block")
			minetest.register_alias_force("vision_lib:stainless_steel_dust", "technic:stainless_steel_dust")
		end
	end,
	["zinc"]=function()
		visionLib.Material.create("zinc", "Zinc", "hard", "56f6ff60")
		if minetest.get_modpath("technic") then
			visionLib.Common.SmartOverrideItem("technic:zinc_ingot", {groups={ingot_zinc=1, ingot=1, zinc=1, metal=1}})
			visionLib.Common.SmartOverrideItem("technic:zinc_block", {groups={block_zinc=1, zinc=1, metal_block=1}})
			visionLib.Common.SmartOverrideItem("technic:zinc_dust", {groups={dust_zinc=1, dust=1, zinc=1, metal=1}})
			visionLib.Common.SmartOverrideItem("technic:mineral_zinc", {groups={ore_zinc=1, zinc=1}})
			visionLib.Common.SmartOverrideItem("technic:zinc_lump", {groups={ore_zinc=1, lump_zinc=1,zinc=1}})
			minetest.register_alias_force("vision_lib:zinc_ingot", "technic:zinc_ingot")
			minetest.register_alias_force("vision_lib:zinc_block", "technic:zinc_block")
			minetest.register_alias_force("vision_lib:zinc_dust", "technic:zinc_dust")
			minetest.register_alias_force("vision_lib:zinc_lump", "technic:zinc_lump")
		end
	end,
	["sulfur"]=function()
		visionLib.Material.create("sulfur", "Sulfur", "powder", "fff200a0")
		if minetest.get_modpath("technic") then
			visionLib.Common.SmartOverrideItem("technic:sulfur_dust", {groups={dust_sulfur=1, dust=1, sulfur=1}})
			visionLib.Common.SmartOverrideItem("technic:mineral_sulfur", {groups={ore_sulfur=1, sulfur=1}})
			visionLib.Common.SmartOverrideItem("technic:sulfur_lump", {groups={ore_sulfur=1, lump_sulfur=1,sulfur=1}})
			minetest.register_alias_force("vision_lib:sulfur_dust", "technic:sulfur_dust")
		end
	end,
	["uranium"]=function()
		visionLib.Material.create("uranium", "Uranium", "strange", "03ff0170")
		if minetest.get_modpath("technic") then
			visionLib.Common.SmartOverrideItem("technic:uranium_ingot", {groups={ingot_uranium=1, ingot=1, uranium=1, metal=1}})
			visionLib.Common.SmartOverrideItem("technic:uranium_block", {groups={block_uranium=1, uranium=1, metal_block=1}})
			visionLib.Common.SmartOverrideItem("technic:uranium_dust", {groups={dust_uranium=1, dust=1, uranium=1, metal=1}})
			visionLib.Common.SmartOverrideItem("technic:uranium0_ingot", {groups={ingot_uranium=1, ingot=1, uranium=1, metal=1}})
			visionLib.Common.SmartOverrideItem("technic:uranium0_block", {groups={block_uranium=1, uranium=1, metal_block=1}})
			visionLib.Common.SmartOverrideItem("technic:uranium0_dust", {groups={dust_uranium=1, dust=1, uranium=1, metal=1}})
			visionLib.Common.SmartOverrideItem("technic:uranium35_ingot", {groups={ingot_uranium=1, ingot=1, uranium=1, metal=1}})
			visionLib.Common.SmartOverrideItem("technic:uranium35_block", {groups={block_uranium=1, uranium=1, metal_block=1}})
			visionLib.Common.SmartOverrideItem("technic:uranium35_dust", {groups={dust_uranium=1, dust=1, uranium=1, metal=1}})
			visionLib.Common.SmartOverrideItem("technic:mineral_uranium", {groups={ore_uranium=1, uranium=1}})
			visionLib.Common.SmartOverrideItem("technic:uranium_lump", {groups={ore_uranium=1, lump_uranium=1,uranium=1}})
			minetest.register_alias_force("vision_lib:uranium_ingot", "technic:uranium_ingot")
			minetest.register_alias_force("vision_lib:uranium_block", "technic:uranium_block")
			minetest.register_alias_force("vision_lib:uranium_dust", "technic:uranium_dust")
			minetest.register_alias_force("vision_lib:uranium_lump", "technic:uranium_lump")
		end
	end,
	["steel"]=function()
		visionLib.Material.create("steel", "Steel", "hard", "a0a0a070", true)
	end,
	["nickel"]=function()
		visionLib.Material.create("nickel", "Nickel", "hard", "c6c78fa0")
	end,
	["osmium"]=function()
		visionLib.Material.create("osmium", "Osmium", "hard", "0002f080")
	end,
	["aluminium"]=function()
		visionLib.Material.create("aluminium", "Aluminium", "soft", "d1d4d070")
	end,
	["platinum"]=function()
		visionLib.Material.create("platinum", "Platinum", "soft", "00000020")
	end,
	["titanium"]=function()
		visionLib.Material.create("titanium", "Titanium", "hard", "00000000")
	end,
	["tantalum"]=function()
		visionLib.Material.create("tantalum", "Tantalum", "hard", "000023b0")
	end,
	["neodymium"]=function()
		visionLib.Material.create("neodymium", "Neodymium", "brittle", "ecffa290")
	end,
	["cobalt"]=function()
		visionLib.Material.create("cobalt", "Cobalt", "hard", "00059080")
	end,
	["antimony"]=function()
		visionLib.Material.create("antimony", "Antimony", "soft", "0f0f0f90")
	end,
	["tungsten"]=function()
		visionLib.Material.create("tungsten", "Tungsten", "brittle", "0f0f0f90")
	end,
	["kenthess"]=function()
		visionLib.Material.create("kenthess", "Kenthess", "hard", "000020a0", true)
	end,
	["thorium"]=function()
		visionLib.Material.create("thorium", "Thorium", "strange", "00005090")
	end,
	["arsenic"]=function()
		visionLib.Material.create("arsenic", "Arsenic", "brittle", "fff20023")
	end,
	["boron"]=function()
		visionLib.Material.create("boron", "Boron", "brittle", "86643450")
	end,
	["adamantine"]=function()
		visionLib.Material.create("adamantine", "Adamantine", "hard", "ff000080")
	end,
	["orichalcum"]=function()
		visionLib.Material.create("orichalcum", "Orichalkos", "hard", "20684080", true)
	end,
	["blood_steel"]=function()
		visionLib.Material.create("blood_steel", "Haemic Steel", "hard", "89000080", true)
	end,
	["serouin"]=function()
		visionLib.Material.create("serouin", "Serouin Alloy", "hard", "89890080", true)
	end,
	["emerald"]=function()
		visionLib.Material.create("emerald", "Emerald", "fragile", "00ff60c0")
	end,
	["jasper"]=function()
		visionLib.Material.create("jasper", "Jasper", "fragile", "882510a0")
	end,
	["opal"]=function()
		visionLib.Material.create("opal", "Opal", "fragile", "00a0f0a0")
	end,
	["ruby"]=function()
		visionLib.Material.create("ruby", "Ruby", "fragile", "a00000c0")
	end,
	["garnet"]=function()
		visionLib.Material.create("garnet", "Garnet", "fragile", "600000c0")
	end,
	["sapphire"]=function()
		visionLib.Material.create("sapphire", "Sapphire", "fragile", "0000b0a0")
	end,
	["jade"]=function()
		visionLib.Material.create("jade", "Jade", "fragile", "208050c0")
	end,
	["topaz"]=function()
		visionLib.Material.create("topaz", "Topaz", "fragile", "fa7000a0")
	end,
	["amethyst"]=function()
		visionLib.Material.create("amethyst", "Amethyst", "fragile", "7010dba0")
	end,
}

visionLib.Material.using={}

function visionLib.Material.require(r)
	for k,v in pairs(r) do
		if v=="all" then 
			for _,vv in pairs(visionLib._sMaterials) do
				visionLib.Material.using[_]=true
			end
		end
		if visionLib._sMaterials[v] then
			visionLib.Material.using[v]=true
		end
	end
end

function visionLib.Material.generate()
	for k,v in pairs(visionLib.Material.using) do
		visionLib.Materials[k]={}
		if visionLib._sMaterials[k] then
			visionLib._sMaterials[k]()
		else
			print("[visionLib]/ERROR: A registered vLib material is missing information: "..k)
		end
	end
end

minetest.after(0, visionLib.Material.generate)

function visionLib.Material.create(name, desc, ish, color, alloy)
	if ish=="fragile" then
		minetest.register_craftitem(":vision_lib:"..name.."_gem", {
			description = desc.." ",
			inventory_image = "(visionlib_gem.png^[colorize:#"..color..")^visionlib_gemshine.png",
			groups={["gem_"..name]=1, [name]=1, gem=1},
		})

		minetest.register_craftitem(":vision_lib:"..name.."_gem2", {
			description = "Polished "..desc,
			inventory_image = "(visionlib_gem2.png^[colorize:#"..color..")^visionlib_gemshine2.png",
			groups={["gem_"..name]=1, [name]=1, gem=1},
		})
		
		minetest.register_craftitem(":vision_lib:"..name.."_shard", {
			description = desc.." Shard",
			inventory_image = "visionlib_shard.png^[colorize:#"..color,
			groups={["shard_"..name]=1, [name]=1, shard=1},
		})
		
		minetest.register_craftitem(":vision_lib:"..name.."_dust", {
			description = desc.." Powder",
			inventory_image = "visionlib_dust.png^[colorize:#"..color,
			groups={["dust_"..name]=1, [name]=1, dust=1},
		})
		
		minetest.register_node(":vision_lib:"..name.."_block", {
			description=desc.." Block",
			tiles={"visionlib_gemblock.png^[colorize:#"..color},
			is_ground_content=false,
			groups={cracky=2, ["block_"..name]=1, [name]=1, gem_block=1},
			sounds=visionLib.Sound.Glass(),
		})
		
		minetest.register_node(":vision_lib:"..name.."_dust_block", {
			description=desc.." Dust Block",
			tiles={"visionlib_dustblock.png^[colorize:#"..color},
			is_ground_content=false,
			groups={crumbly=2, ["dust_block_"..name]=1, [name]=1, dust_block=1, falling_node=1},
			sounds=visionLib.Sound.Sand(),
		})
		
		minetest.register_craft({
			type="shapeless",
			output="vision_lib:"..name.."_shard 9",
			recipe={"vision_lib:"..name.."_gem"}
		})
		
		minetest.register_craft({
			output="vision_lib:"..name.."_gem",
			recipe={
				{"vision_lib:"..name.."_shard", "vision_lib:"..name.."_shard", "vision_lib:"..name.."_shard"},
				{"vision_lib:"..name.."_shard", "vision_lib:"..name.."_shard", "vision_lib:"..name.."_shard"},
				{"vision_lib:"..name.."_shard", "vision_lib:"..name.."_shard", "vision_lib:"..name.."_shard"}
			}
		})
		
		minetest.register_craft({
			type="shapeless",
			output="vision_lib:"..name.."_gem 9",
			recipe={"vision_lib:"..name.."_block"}
		})
		
		minetest.register_craft({
			output="vision_lib:"..name.."_block",
			recipe={
				{"vision_lib:"..name.."_gem", "vision_lib:"..name.."_gem", "vision_lib:"..name.."_gem"},
				{"vision_lib:"..name.."_gem", "vision_lib:"..name.."_gem", "vision_lib:"..name.."_gem"},
				{"vision_lib:"..name.."_gem", "vision_lib:"..name.."_gem", "vision_lib:"..name.."_gem"}
			}
		})

		minetest.register_craft({
			type="shapeless",
			output="vision_lib:"..name.."_dust 9",
			recipe={"vision_lib:"..name.."_dust_block"}
		})
		
		minetest.register_craft({
			output="vision_lib:"..name.."_dust_block",
			recipe={
				{"vision_lib:"..name.."_dust", "vision_lib:"..name.."_dust", "vision_lib:"..name.."_dust"},
				{"vision_lib:"..name.."_dust", "vision_lib:"..name.."_dust", "vision_lib:"..name.."_dust"},
				{"vision_lib:"..name.."_dust", "vision_lib:"..name.."_dust", "vision_lib:"..name.."_dust"}
			}
		})
		
	elseif ish=="powder" then
		minetest.register_craftitem(":vision_lib:"..name.."_dust", {
			description = desc.." Powder",
			inventory_image = "visionlib_dust.png^[colorize:#"..color,
			groups={["dust_"..name]=1, [name]=1, dust=1},
		})

		minetest.register_node(":vision_lib:"..name.."_dust_block", {
			description=desc.." Dust Block",
			tiles={"visionlib_dustblock.png^[colorize:#"..color},
			is_ground_content=false,
			groups={cracky=2, ["dust_block_"..name]=1, [name]=1, dust_block=1, falling_node=1},
			sounds=visionLib.Sound.Sand(),
		})
		
		minetest.register_craft({
			type="shapeless",
			output="vision_lib:"..name.."_dust 9",
			recipe={"vision_lib:"..name.."_dust_block"}
		})
		
		minetest.register_craft({
			output="vision_lib:"..name.."_dust_block",
			recipe={
				{"vision_lib:"..name.."_dust", "vision_lib:"..name.."_dust", "vision_lib:"..name.."_dust"},
				{"vision_lib:"..name.."_dust", "vision_lib:"..name.."_dust", "vision_lib:"..name.."_dust"},
				{"vision_lib:"..name.."_dust", "vision_lib:"..name.."_dust", "vision_lib:"..name.."_dust"}
			}
		})
		
	elseif ish=="brittle" then
		minetest.register_craftitem(":vision_lib:"..name.."_ingot", {
			description = desc.." Ingot",
			inventory_image = "visionlib_ingot.png^[colorize:#"..color,
			groups={["ingot_"..name]=1, [name]=1, ingot=1, metal=1},
		})
		
		if not alloy then
		minetest.register_craftitem(":vision_lib:"..name.."_lump", {
			description = desc.." Lump",
			inventory_image = "visionlib_lump.png^[colorize:#"..color,
			groups={["lump_"..name]=1, [name]=1, lump=1, metal=1},
		})
		
		minetest.register_craft({
			type="cooking",
			output="vision_lib:"..name.."_ingot",
			recipe="vision_lib:"..name.."_lump"
		})
		end
		
		minetest.register_craftitem(":vision_lib:"..name.."_nugget", {
			description = desc.." Chip",
			inventory_image = "visionlib_nugget.png^[colorize:#"..color,
			groups={["nugget_"..name]=1, [name]=1, nugget=1, metal=1},
		})
		
		minetest.register_craftitem(":vision_lib:"..name.."_dust", {
			description = desc.." Dust",
			inventory_image = "visionlib_dust.png^[colorize:#"..color,
			groups={["dust_"..name]=1, [name]=1, dust=1, metal=1},
		})
		
		minetest.register_node(":vision_lib:"..name.."_dust_block", {
			description=desc.." Dust Block",
			tiles={"visionlib_dustblock.png^[colorize:#"..color},
			is_ground_content=false,
			groups={crumbly=2, ["dust_block_"..name]=1, [name]=1, dust_block=1, falling_node=1},
			sounds=visionLib.Sound.Sand(),
		})
		
		minetest.register_craftitem(":vision_lib:"..name.."_rod", {
			description = desc.." Rod",
			inventory_image = "visionlib_rod.png^[colorize:#"..color,
			groups={["rod_"..name]=1, [name]=1, rod=1, metal=1},
		})

		minetest.register_node(":vision_lib:"..name.."_block", {
			description=desc.." Block",
			tiles={"visionlib_metalblock.png^[colorize:#"..color},
			is_ground_content=false,
			groups={cracky=2, metal=1, [name]=1, ["block_"..name]=1, metal_block=1},
			sounds=visionLib.Sound.Metal(),
		})
		
		minetest.register_craft({
			type="shapeless",
			output="vision_lib:"..name.."_nugget 9",
			recipe={"vision_lib:"..name.."_ingot"}
		})
		
		minetest.register_craft({
			output="vision_lib:"..name.."_ingot",
			recipe={
				{"vision_lib:"..name.."_nugget", "vision_lib:"..name.."_nugget", "vision_lib:"..name.."_nugget"},
				{"vision_lib:"..name.."_nugget", "vision_lib:"..name.."_nugget", "vision_lib:"..name.."_nugget"},
				{"vision_lib:"..name.."_nugget", "vision_lib:"..name.."_nugget", "vision_lib:"..name.."_nugget"}
			}
		})
		
		minetest.register_craft({
			type="shapeless",
			output="vision_lib:"..name.."_ingot 9",
			recipe={"vision_lib:"..name.."_block"}
		})
		
		minetest.register_craft({
			output="vision_lib:"..name.."_block",
			recipe={
				{"vision_lib:"..name.."_ingot", "vision_lib:"..name.."_ingot", "vision_lib:"..name.."_ingot"},
				{"vision_lib:"..name.."_ingot", "vision_lib:"..name.."_ingot", "vision_lib:"..name.."_ingot"},
				{"vision_lib:"..name.."_ingot", "vision_lib:"..name.."_ingot", "vision_lib:"..name.."_ingot"}
			}
		})
		
		minetest.register_craft({
			output="vision_lib:"..name.."_rod 3",
			recipe={
				{"vision_lib:"..name.."_ingot"},
				{"vision_lib:"..name.."_ingot"},
				{"vision_lib:"..name.."_ingot"}
			}
		})
		
		minetest.register_craft({
			type="shapeless",
			output="vision_lib:"..name.."_dust 9",
			recipe={"vision_lib:"..name.."_dust_block"}
		})
		
		minetest.register_craft({
			output="vision_lib:"..name.."_dust_block",
			recipe={
				{"vision_lib:"..name.."_dust", "vision_lib:"..name.."_dust", "vision_lib:"..name.."_dust"},
				{"vision_lib:"..name.."_dust", "vision_lib:"..name.."_dust", "vision_lib:"..name.."_dust"},
				{"vision_lib:"..name.."_dust", "vision_lib:"..name.."_dust", "vision_lib:"..name.."_dust"}
			}
		})

	elseif ish=="hard" then
		minetest.register_craftitem(":vision_lib:"..name.."_ingot", {
			description = desc.." Ingot",
			inventory_image = "visionlib_ingot.png^[colorize:#"..color,
			groups={["ingot_"..name]=1, [name]=1, ingot=1, metal=1},
		})
		
		if not alloy then
		minetest.register_craftitem(":vision_lib:"..name.."_lump", {
			description = desc.." Lump",
			inventory_image = "visionlib_lump.png^[colorize:#"..color,
			groups={["lump_"..name]=1, [name]=1, lump=1, metal=1},
		})
		
		minetest.register_craft({
			type="cooking",
			output="vision_lib:"..name.."_ingot",
			recipe="vision_lib:"..name.."_lump"
		})
		
		end
		
		minetest.register_craftitem(":vision_lib:"..name.."_nugget", {
			description = desc.." Chip",
			inventory_image = "visionlib_nugget.png^[colorize:#"..color,
			groups={["nugget_"..name]=1, [name]=1, nugget=1, metal=1},
		})
		
		minetest.register_craftitem(":vision_lib:"..name.."_dust", {
			description = desc.." Filings",
			inventory_image = "visionlib_dust.png^[colorize:#"..color,
			groups={["dust_"..name]=1, [name]=1, dust=1, metal=1},
		})
		
		minetest.register_node(":vision_lib:"..name.."_dust_block", {
			description=desc.." Dust Block",
			tiles={"visionlib_dustblock.png^[colorize:#"..color},
			is_ground_content=false,
			groups={crumbly=2, ["dust_block_"..name]=1, [name]=1, dust_block=1, falling_node=1},
			sounds=visionLib.Sound.Sand(),
		})
		
		minetest.register_craftitem(":vision_lib:"..name.."_plate", {
			description = desc.." Plate",
			inventory_image = "visionlib_plate.png^[colorize:#"..color,
			groups={["plate_"..name]=1, [name]=1, plate=1, metal=1},
		})
		
		minetest.register_craftitem(":vision_lib:"..name.."_rod", {
			description = desc.." Rod",
			inventory_image = "visionlib_rod.png^[colorize:#"..color,
			groups={["rod_"..name]=1, [name]=1, rod=1, metal=1},
		})
		
		minetest.register_craftitem(":vision_lib:"..name.."_gear", {
			description = desc.." Gear",
			inventory_image = "visionlib_gear.png^[colorize:#"..color,
			groups={["gear_"..name]=1, [name]=1, gear=1, metal=1},
		})
		
		minetest.register_node(":vision_lib:"..name.."_block", {
			description=desc.." Block",
			tiles={"visionlib_metalblock.png^[colorize:#"..color},
			is_ground_content=false,
			groups={cracky=2, metal=1, [name]=1, ["block_"..name]=1, metal_block=1},
			sounds=visionLib.Sound.Metal(),
		})
		
		minetest.register_craftitem(":vision_lib:"..name.."_wire", {
			description = desc.." Wire",
			inventory_image = "visionlib_wire.png^[colorize:#"..color,
			groups={["wire_"..name]=1, [name]=1, wire=1, metal=1},
		})

		minetest.register_craft({
			type="shapeless",
			output="vision_lib:"..name.."_wire 4",
			recipe={"vision_lib:"..name.."_nugget"}
		})
		
		
		minetest.register_craft({
			type="shapeless",
			output="vision_lib:"..name.."_nugget 9",
			recipe={"vision_lib:"..name.."_ingot"}
		})
		
		minetest.register_craft({
			output="vision_lib:"..name.."_ingot",
			recipe={
				{"vision_lib:"..name.."_nugget", "vision_lib:"..name.."_nugget", "vision_lib:"..name.."_nugget"},
				{"vision_lib:"..name.."_nugget", "vision_lib:"..name.."_nugget", "vision_lib:"..name.."_nugget"},
				{"vision_lib:"..name.."_nugget", "vision_lib:"..name.."_nugget", "vision_lib:"..name.."_nugget"}
			}
		})
		
		minetest.register_craft({
			type="shapeless",
			output="vision_lib:"..name.."_ingot 9",
			recipe={"vision_lib:"..name.."_block"}
		})
		
		minetest.register_craft({
			output="vision_lib:"..name.."_block",
			recipe={
				{"vision_lib:"..name.."_ingot", "vision_lib:"..name.."_ingot", "vision_lib:"..name.."_ingot"},
				{"vision_lib:"..name.."_ingot", "vision_lib:"..name.."_ingot", "vision_lib:"..name.."_ingot"},
				{"vision_lib:"..name.."_ingot", "vision_lib:"..name.."_ingot", "vision_lib:"..name.."_ingot"}
			}
		})
		
		minetest.register_craft({
			output="vision_lib:"..name.."_plate 3",
			recipe={
				{"vision_lib:"..name.."_ingot", "vision_lib:"..name.."_ingot", "vision_lib:"..name.."_ingot"}
			}
		})
		
		minetest.register_craft({
			output="vision_lib:"..name.."_gear",
			recipe={
				{"", "vision_lib:"..name.."_ingot", ""},
				{"vision_lib:"..name.."_ingot", "", "vision_lib:"..name.."_ingot"},
				{"", "vision_lib:"..name.."_ingot", ""}
			}
		})
		
		minetest.register_craft({
			output="vision_lib:"..name.."_rod 3",
			recipe={
				{"vision_lib:"..name.."_ingot"},
				{"vision_lib:"..name.."_ingot"},
				{"vision_lib:"..name.."_ingot"}
			}
		})
		
		minetest.register_craft({
			type="shapeless",
			output="vision_lib:"..name.."_dust 9",
			recipe={"vision_lib:"..name.."_dust_block"}
		})
		
		minetest.register_craft({
			output="vision_lib:"..name.."_dust_block",
			recipe={
				{"vision_lib:"..name.."_dust", "vision_lib:"..name.."_dust", "vision_lib:"..name.."_dust"},
				{"vision_lib:"..name.."_dust", "vision_lib:"..name.."_dust", "vision_lib:"..name.."_dust"},
				{"vision_lib:"..name.."_dust", "vision_lib:"..name.."_dust", "vision_lib:"..name.."_dust"}
			}
		})
		
	elseif ish=="soft" then
		minetest.register_craftitem(":vision_lib:"..name.."_ingot", {
			description = desc.." Bar",
			inventory_image = "visionlib_ingot.png^[colorize:#"..color,
			groups={["ingot_"..name]=1, [name]=1, ingot=1, metal=1},
		})
		
		if not alloy then
		minetest.register_craftitem(":vision_lib:"..name.."_lump", {
			description = desc.." Lump",
			inventory_image = "visionlib_lump.png^[colorize:#"..color,
			groups={["lump_"..name]=1, [name]=1, lump=1, metal=1},
		})
		
		minetest.register_craft({
			type="cooking",
			output="vision_lib:"..name.."_ingot",
			recipe="vision_lib:"..name.."_lump"
		})
		
		end
		
		minetest.register_craftitem(":vision_lib:"..name.."_nugget", {
			description = desc.." Chunk",
			inventory_image = "visionlib_nugget.png^[colorize:#"..color,
			groups={["nugget_"..name]=1, [name]=1, nugget=1, metal=1},
		})
		
		minetest.register_craftitem(":vision_lib:"..name.."_dust", {
			description = desc.." Dust",
			inventory_image = "visionlib_dust.png^[colorize:#"..color,
			groups={["dust_"..name]=1, [name]=1, dust=1, metal=1},
		})
		
		minetest.register_node(":vision_lib:"..name.."_dust_block", {
			description=desc.." Dust Block",
			tiles={"visionlib_dustblock.png^[colorize:#"..color},
			is_ground_content=false,
			groups={crumbly=2, ["dust_block_"..name]=1, [name]=1, dust_block=1, falling_node=1},
			sounds=visionLib.Sound.Sand(),
		})
		
		minetest.register_craftitem(":vision_lib:"..name.."_sheet", {
			description = desc.." Sheet",
			inventory_image = "visionlib_sheet.png^[colorize:#"..color,
			groups={["sheet_"..name]=1, [name]=1, sheet=1, metal=1},
		})
		
		minetest.register_craftitem(":vision_lib:"..name.."_wire", {
			description = desc.." Wire",
			inventory_image = "visionlib_wire.png^[colorize:#"..color,
			groups={["wire_"..name]=1, [name]=1, wire=1, metal=1},
		})

		minetest.register_craft({
			type="shapeless",
			output="vision_lib:"..name.."_wire 4",
			recipe={"vision_lib:"..name.."_nugget"}
		})

		minetest.register_node(":vision_lib:"..name.."_block", {
			description=desc.." Block",
			tiles={"visionlib_softerblock.png^[colorize:#"..color},
			is_ground_content=false,
			groups={cracky=3, metal=1, [name]=1, ["block_"..name]=1, metal_block=1},
			sounds=visionLib.Sound.Plastic(),
		})
		
		
		minetest.register_craft({
			type="shapeless",
			output="vision_lib:"..name.."_nugget 9",
			recipe={"vision_lib:"..name.."_ingot"}
		})
		
		minetest.register_craft({
			output="vision_lib:"..name.."_ingot",
			recipe={
				{"vision_lib:"..name.."_nugget", "vision_lib:"..name.."_nugget", "vision_lib:"..name.."_nugget"},
				{"vision_lib:"..name.."_nugget", "vision_lib:"..name.."_nugget", "vision_lib:"..name.."_nugget"},
				{"vision_lib:"..name.."_nugget", "vision_lib:"..name.."_nugget", "vision_lib:"..name.."_nugget"}
			}
		})
		
		minetest.register_craft({
			type="shapeless",
			output="vision_lib:"..name.."_ingot 9",
			recipe={"vision_lib:"..name.."_block"}
		})
		
		minetest.register_craft({
			output="vision_lib:"..name.."_block",
			recipe={
				{"vision_lib:"..name.."_ingot", "vision_lib:"..name.."_ingot", "vision_lib:"..name.."_ingot"},
				{"vision_lib:"..name.."_ingot", "vision_lib:"..name.."_ingot", "vision_lib:"..name.."_ingot"},
				{"vision_lib:"..name.."_ingot", "vision_lib:"..name.."_ingot", "vision_lib:"..name.."_ingot"}
			}
		})
		
		minetest.register_craft({
			output="vision_lib:"..name.."_sheet 6",
			recipe={
				{"vision_lib:"..name.."_ingot", "vision_lib:"..name.."_ingot", "vision_lib:"..name.."_ingot"}
			}
		})

		minetest.register_craft({
			type="shapeless",
			output="vision_lib:"..name.."_dust 9",
			recipe={"vision_lib:"..name.."_dust_block"}
		})
		
		minetest.register_craft({
			output="vision_lib:"..name.."_dust_block",
			recipe={
				{"vision_lib:"..name.."_dust", "vision_lib:"..name.."_dust", "vision_lib:"..name.."_dust"},
				{"vision_lib:"..name.."_dust", "vision_lib:"..name.."_dust", "vision_lib:"..name.."_dust"},
				{"vision_lib:"..name.."_dust", "vision_lib:"..name.."_dust", "vision_lib:"..name.."_dust"}
			}
		})
	elseif ish=="strange" then
		minetest.register_craftitem(":vision_lib:"..name.."_ingot", {
			description = desc.." Ingot",
			inventory_image = "visionlib_ingot.png^[colorize:#"..color,
			groups={["ingot_"..name]=1, [name]=1, ingot=1, metal=1},
		})
		
		if not alloy then
		minetest.register_craftitem(":vision_lib:"..name.."_lump", {
			description = desc.." Lump",
			inventory_image = "visionlib_lump.png^[colorize:#"..color,
			groups={["lump_"..name]=1, [name]=1, lump=1, metal=1},
		})
		
		minetest.register_craft({
			type="cooking",
			output="vision_lib:"..name.."_ingot",
			recipe="vision_lib:"..name.."_lump"
		})
		
		end
		
		minetest.register_craftitem(":vision_lib:"..name.."_nugget", {
			description = desc.." Chip",
			inventory_image = "visionlib_nugget.png^[colorize:#"..color,
			groups={["nugget_"..name]=1, [name]=1, nugget=1, metal=1},
		})
		
		minetest.register_craftitem(":vision_lib:"..name.."_dust", {
			description = desc.." Filings",
			inventory_image = "visionlib_dust.png^[colorize:#"..color,
			groups={["dust_"..name]=1, [name]=1, dust=1, metal=1},
		})
		
		minetest.register_node(":vision_lib:"..name.."_dust_block", {
			description=desc.." Dust Block",
			tiles={"visionlib_dustblock.png^[colorize:#"..color},
			is_ground_content=false,
			groups={crumbly=2, ["dust_block_"..name]=1, [name]=1, dust_block=1, falling_node=1},
			sounds=visionLib.Sound.Sand(),
		})

		minetest.register_craftitem(":vision_lib:"..name.."_rod", {
			description = desc.." Rod",
			inventory_image = "visionlib_rod.png^[colorize:#"..color,
			groups={["rod_"..name]=1, [name]=1, rod=1, metal=1},
		})
		
		minetest.register_node(":vision_lib:"..name.."_block", {
			description=desc.." Block",
			tiles={"visionlib_metalblock.png^[colorize:#"..color},
			is_ground_content=false,
			groups={cracky=2, metal=1, [name]=1, ["block_"..name]=1, metal_block=1},
			sounds=visionLib.Sound.Metal(),
		})
		
				
		minetest.register_craft({
			type="shapeless",
			output="vision_lib:"..name.."_nugget 9",
			recipe={"vision_lib:"..name.."_ingot"}
		})
		
		minetest.register_craft({
			output="vision_lib:"..name.."_ingot",
			recipe={
				{"vision_lib:"..name.."_nugget", "vision_lib:"..name.."_nugget", "vision_lib:"..name.."_nugget"},
				{"vision_lib:"..name.."_nugget", "vision_lib:"..name.."_nugget", "vision_lib:"..name.."_nugget"},
				{"vision_lib:"..name.."_nugget", "vision_lib:"..name.."_nugget", "vision_lib:"..name.."_nugget"}
			}
		})
		
		minetest.register_craft({
			type="shapeless",
			output="vision_lib:"..name.."_ingot 9",
			recipe={"vision_lib:"..name.."_block"}
		})
		
		minetest.register_craft({
			output="vision_lib:"..name.."_block",
			recipe={
				{"vision_lib:"..name.."_ingot", "vision_lib:"..name.."_ingot", "vision_lib:"..name.."_ingot"},
				{"vision_lib:"..name.."_ingot", "vision_lib:"..name.."_ingot", "vision_lib:"..name.."_ingot"},
				{"vision_lib:"..name.."_ingot", "vision_lib:"..name.."_ingot", "vision_lib:"..name.."_ingot"}
			}
		})
		
		minetest.register_craft({
			output="vision_lib:"..name.."_rod 3",
			recipe={
				{"vision_lib:"..name.."_ingot"},
				{"vision_lib:"..name.."_ingot"},
				{"vision_lib:"..name.."_ingot"}
			}
		})
		
		minetest.register_craft({
			type="shapeless",
			output="vision_lib:"..name.."_dust 9",
			recipe={"vision_lib:"..name.."_dust_block"}
		})
		
		minetest.register_craft({
			output="vision_lib:"..name.."_dust_block",
			recipe={
				{"vision_lib:"..name.."_dust", "vision_lib:"..name.."_dust", "vision_lib:"..name.."_dust"},
				{"vision_lib:"..name.."_dust", "vision_lib:"..name.."_dust", "vision_lib:"..name.."_dust"},
				{"vision_lib:"..name.."_dust", "vision_lib:"..name.."_dust", "vision_lib:"..name.."_dust"}
			}
		})
		
	end
end

if minetest.get_modpath("default") then
visionLib.Material.require({"iron", "copper", "tin", "gold", "bronze", "diamond", "mese", "obsidian", "coal"})
end
if minetest.get_modpath("moreores") then
visionLib.Material.require({"mithril", "silver"})
end
if minetest.get_modpath("technic") then
visionLib.Material.require({"carbon_steel", "cast_iron", "chromium", "lead", "stainless_steel", "zinc", "sulfur", "uranium"})
end
if minetest.get_modpath("basic_materials") then
visionLib.Material.require({"brass"})
end

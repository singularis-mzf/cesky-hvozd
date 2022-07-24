

---
---Mask
---

if minetest.get_modpath("3d_armor") then
  
  armor:register_armor("mask:mask", {
		description = ("Mask"),
		inventory_image = "mask_inv_mask.png",
		groups = {armor_head=1, armor_heal=12, armor_use=10, armor_fire=1},
		armor_groups = {fleshy=15},
		damage_groups = {cracky=2, snappy=1, level=3},
	})
end


---
---Craft
---

minetest.register_craft({
	output = "mask:mask",
	recipe = {
		{"", "", ""},
		{"farming:string", "default:paper", "farming:string"},
		{"", "", ""},
	}
})
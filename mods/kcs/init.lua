print("[MOD BEGIN] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")

minetest.register_craftitem("kcs:h", {
	description = "haléř československý",
	inventory_image = "kcs_1h.png",
	stack_max = 10000,
})
minetest.register_craftitem("kcs:kcs", {
	description = "koruna československá (Kčs)",
	inventory_image = "kcs_1kcs.png",
	stack_max = 10000,
})
minetest.register_craftitem("kcs:zcs", {
	description = "zlatka československá (Zčs)",
	inventory_image = "kcs_1zcs.png",
	stack_max = 10000,
})

print("[MOD END] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")

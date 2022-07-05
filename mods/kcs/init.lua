print("[MOD BEGIN] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")
local coins = {
	{"h01", "1h", "1 haléř československý", 5},
	{"h05", "5h", "5 haléřů československých", 2},
	{"h10", "10h", "10 haléřů československých", 5},
	{"h50", "50h", "50 haléřů československých", 2},
	{"kcs01", "1kcs", "1 koruna československá", 5},
	{"kcs05", "5kcs", "5 korun československých", 9},
	{"kcs45", "1zcs", "1 zlatka českosloveská", 0},
}

local pokracovat = true

local zopakuj = function(pocet, co)
	local i = 1
	local t = {}
	while pocet >= i do
		t[i] = co
		i = i + 1
	end
	return t
end

local i = 1
repeat
	local id, texture_id, desc, pocet = unpack(coins[i])
	minetest.register_craftitem("kcs:mince_"..id, {
		description = desc,
		inventory_image = "kcs_"..texture_id..".png",
		stack_max = 10000,
	})
	if i > 1 then
		-- vyrobit jednu tuto minci z N předchozích
		minetest.register_craft({
			output = "kcs:mince_"..id,
			type = "shapeless",
			recipe = zopakuj(coins[i - 1][4], "kcs:mince_"..coins[i - 1][1])
		})
		-- vyrobit N přechozích mincí z jedné této
		minetest.register_craft({
			output = "kcs:mince_"..coins[i - 1][1].." "..coins[i - 1][4],
			recipe = {{"kcs:mince_"..id}},
		})
	end
	i = i + 1
until not coins[i]
print("[MOD END] " .. minetest.get_current_modname() .. "(" .. os.clock() .. ")")

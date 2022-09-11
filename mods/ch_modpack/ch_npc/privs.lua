-- PRIVILEGE
local def = {
	description = "Umožňuje nastavovat, vyvolávat a skrývat nehráčské postavy.",
	give_to_singleplayer = true,
	give_to_admin = true,
}
minetest.register_privilege("spawn_npc", def)

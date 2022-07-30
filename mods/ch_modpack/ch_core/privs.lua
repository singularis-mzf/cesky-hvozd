-- právo značící registrovanou postavu
minetest.register_privilege("ch_registered_player", "Odlišuje registrované postavy od čerstvě založených.")

-- kouzelníci/ce nesmí vkládat do cizích inventářů
minetest.override_chatcommand("give", {privs = {give = true, protection_bypass = true, interact = true}})

ch_core.submod_loaded("privs")

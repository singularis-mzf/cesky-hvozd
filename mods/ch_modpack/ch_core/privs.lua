ch_core.open_submod("privs")
minetest.register_privilege("ch_events_moderator", "Rozšiřuje možnosti práce s oznámeními.")
-- právo značící registrovanou postavu
minetest.register_privilege("ch_registered_player", "Odlišuje registrované postavy od čerstvě založených.")
minetest.register_privilege("ch_trustful_player", "Poskytuje postavám důvěryhodných hráčů/ek výhody.")
minetest.register_privilege("ch_switchable_creative", "Umožňuje postavě si zapínat a vypínat právo usnadnění hry podle potřeby.")

-- kouzelníci/ce nesmí vkládat do cizích inventářů
minetest.override_chatcommand("give", {privs = {give = true, protection_bypass = true, interact = true}})

ch_core.close_submod("privs")

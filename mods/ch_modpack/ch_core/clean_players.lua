ch_core.open_submod("clean_players", {data = true, lib = true, privs = true})

function ch_core.clean_players()
    local all_players = ch_core.get_last_logins(false, {})
    local count = 0

    for _, data in ipairs(all_players) do
        if
         -- podmínky pro smazání postavy:
         -- 1) postava se nejmenuje Administrace
             data.player_name ~= "Administrace"
         -- 2) postava nemá právo server nebo ch_registered_player
             and not minetest.check_player_privs(data.player_name, "server") and not minetest.check_player_privs(data.player_name, "ch_registered_player")
         -- 3) postava nemá naplánovanou registraci jinou než "new"
             and (data.pending_registration_type or "new") == "new"
         -- 4) postava nemá odehráno 1.0 hodin nebo víc
             and (data.played_hours_total < 1.0)
         -- 5) postava není ve hře
             and not data.is_in_game
         -- 6) poslední přihlášení bylo alespoň před 60 dny
             and data.last_login_before >= 60
         then
             minetest.log("action", "Old player "..data.player_name.." is going to be DELETED because of inactivity!\n"..dump2({data}))
             -- 1) Odstranit offline_charinfo
             local r = ch_core.delete_offline_charinfo(data.player_name)
             if not r then
                 minetest.log("error", "Removing offline charinfo of "..data.player_name.." failed!")
             else
                 minetest.log("action", "- Offline charinfo of "..data.player_name.." successfully removed.")
             end
             -- 2) Odstranit hráčské informace
             r = minetest.remove_player(data.player_name)
             if r == 0 then
                 minetest.log("action", "- Player data of "..data.player_name.." successfully removed.")
             else
                 minetest.log("error", "Removing of player data of "..data.player_name.." failed: "..(r or "nil"))
             end
             -- 3) Odstranit přihlašovací údaje
             r = minetest.remove_player_auth(data.player_name)
             if r then
                 minetest.log("action", "- Authentication data of "..data.player_name.." successfully removed.")
             else
                 minetest.log("error", "Removing of authentication data of "..data.player_name.." failed: "..(r or "nil"))
             end
             -- 4) Zkontrolovat, že postava byla opravdu smazána.
             r = minetest.player_exists(data.player_name)
             if not r then
                 minetest.log("action", "Player "..data.player_name.." was removed.")
                 count = count + 1
             else
                 minetest.log("error", "Player "..data.player_name.." was not removed.")
             end
         end
    end

    if count > 0 then
        minetest.log("action", "[ch_core/clean_players] "..count.." players was removed.")
    end
    return count
end

minetest.register_on_mods_loaded(function() minetest.after(10, ch_core.clean_players) end)

ch_core.close_submod("clean_players")

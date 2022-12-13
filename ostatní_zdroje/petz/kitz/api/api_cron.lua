function kitz.cron_clear(cron_time, modname)
	if cron_time > 0 then
		minetest.after(cron_time, function()
			kitz.cron_clear_mobs(cron_time, modname)
		end, cron_time, modname)
	end
end

function kitz.cron_clear_mobs(cron_time, modname)
	for _, player in ipairs(minetest.get_connected_players()) do
		local player_pos = player:get_pos()
		kitz.clear_mobs(player_pos, modname)
	end
	kitz.cron_clear(cron_time, modname)
end

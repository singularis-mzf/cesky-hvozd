local modname = ...

--Server Cron Calls
if petz.settings.clear_mobs_time > 0 then
	kitz.cron_clear(petz.settings.clear_mobs_time, modname)
end

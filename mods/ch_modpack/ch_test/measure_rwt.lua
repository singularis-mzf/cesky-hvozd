if minetest.get_modpath("advtrains_line_automation") and advtrains ~= nil and advtrains.lines ~= nil and advtrains.lines.rwt ~= nil then
    local rwt = advtrains.lines.rwt
    local i = 0
    local rwtime_base, ustime_base
    local f
    local get_us_time = assert(minetest.get_us_time)
    f = function()
        core.after(60, f)
        local rwtime = rwt.to_secs(rwt.get_time())
        local ustime = get_us_time()
        local rwtime_diff, ustime_diff
        --[[ if ustime == nil then
            print("DEBUG: [i="..i.."] get_us_time() returned nil!!!")
        end ]]
        if i == 0 then
            rwtime_base, ustime_base = rwtime, ustime
            rwtime_diff, ustime_diff = 0, 0
        else
            rwtime_diff = rwtime - rwtime_base
            ustime_diff = ustime - ustime_base
        end
        -- print("DEBUG: "..dump2({i = i, rwtime_base = rwtime_base, rwtime = rwtime, ustime = ustime, ustime_base = ustime_base}))
        core.log("action", "[DEBUG rwtime] "..tostring(i)..";"..tostring(rwtime_diff)..";"..tostring(ustime_diff)..
            ";"..tostring(rwtime)..";"..tostring(ustime))
        i = i + 1
    end
    core.after(6, f)
end

-- This is a reimplementation of https://github.com/MilesBDyson/dumpnodes from scratch under LGPLv2.1+
-- improved to catch most of textures used on Český hvozd server.

local worldpath = minetest.get_worldpath()

local function e(s)
    return s == nil or s == ""
end

local function dumpnodes(admin_name, param)
    local count = 0
    local nodes_by_mod = {}
    local mods = {}
    for itemname, ndef in pairs(minetest.registered_nodes) do
        local mod, name = itemname:match("(.*):(.*)")
        if not e(mod) and not e(name) then
            local set = nodes_by_mod[mod]
            if set == nil then
                table.insert(mods, mod)
                set = {}
                nodes_by_mod[mod] = set
            end
            set[name] = ndef
        end
    end
    table.sort(mods)
    local f, err = io.open(worldpath.."/nodes_dump.txt", "wb")
    if f == nil then
        return false, "Selhalo: "..(err or "")
    end
    for _, mod in ipairs(mods) do
        local set = nodes_by_mod[mod]
        local nodes = {}
        for name, _ in pairs(set) do
            table.insert(nodes, name)
        end
        table.sort(nodes)
        f:write("# "..mod.."\n")
        for _, name in ipairs(nodes) do
            local ndef = set[name]
            if ndef.drawtype ~= "airlike" then
                local tile = ndef.tiles
                if type(tile) ~= "string" then
                    if type(tile[1]) == "string" then
                        tile = tile[1]
                    else
                        tile = tile[1].name
                    end
                end
                if not e(tile) then
                    tile = tile:gsub("^%(*", "")
                    local x = tile:match("^%[combine:[^=]*=%(*([^^:\\)]+)%)*[:^\\]")
                    if x ~= nil then
                        tile = x
                    else
                        x = tile:match("^[^^]+%^%[multiply:#([0123456789AaBbCcDdEeFf][0123456789AaBbCcDdEeFf][0123456789AaBbCcDdEeFf][0123456789AaBbCcDdEeFf][0123456789AaBbCcDdEeFf][0123456789AaBbCcDdEeFf])")
                        if x == nil then
                            tile = tile:gsub("[\\^].*", "")
                        else
                            -- fixed color:
                            tile = "&"..tonumber("0x"..x:sub(1, 2)).."&"..tonumber("0x"..x:sub(3, 4)).."&"..tonumber("0x"..x:sub(5, 6))
                        end
                    end
                    assert(tile)
                    f:write(mod..":"..name.." "..tile.."\n")
                end
                count = count + 1
            end
        end
        f:write("\n")
    end
    f:close()
    return true, count.." nodes dumped."
end

minetest.register_chatcommand("dumpnodes", {
    params = "",
    description = "Zaznamená textury bloků pro použití k tvorbě map.",
    privs = {server = true},
    func = dumpnodes,
})

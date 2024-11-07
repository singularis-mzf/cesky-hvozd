-- This is a reimplementation of https://github.com/MilesBDyson/dumpnodes from scratch under LGPLv2.1+

local worldpath = minetest.get_worldpath()

local function e(s)
    return s == nil or s == ""
end

local function dumpnodes(admin_name, param)
    local count = 0
    local nodes_by_mod = {}
    for itemname, ndef in pairs(minetest.registered_nodes) do
        local mod, name = itemname:match("(.*):(.*)")
        if not e(mod) and not e(name) then
            local set = nodes_by_mod[mod]
            if set == nil then
                set = {}
                nodes_by_mod[mod] = set
            end
            set[name] = ndef
        end
    end
    local f, err = io.open(worldpath.."/nodes_dump.txt", "wb")
    if f == nil then
        return false, "Selhalo: "..(err or "")
    end
    for mod, set in pairs(nodes_by_mod) do
        f:write("# "..mod.."\n")
        for name, ndef in pairs(set) do
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
                    tile = tile:gsub("[\\^].*", "")
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

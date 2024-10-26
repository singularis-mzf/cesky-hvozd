for name, ndef in pairs(minetest.registered_nodes) do
    local t = type(ndef.tiles)
    if t == "nil" then
        if ndef.drawtype ~= "airlike" then
            minetest.log("warning", "[verify_tiles] "..name..": no tiles (drawtype = "..(ndef.drawtype or "nil")..")")
        end
    elseif t == "string" then
        minetest.log("warning", "[verify_tiles] "..name..": string tiles ("..ndef.tiles..")")
    elseif t ~= "table" then
        minetest.log("warning", "[verify_tiles] "..name..": invalid tiles (type = "..t..")")
    else
        for k, tile in pairs(ndef.tiles) do
            local tt = type(tile)
            if type(k) ~= "number" or k < 1 or k > 6 then
                minetest.log("warning", "[verify_tiles] "..name..": invalid tile index ("..tostring(k)..")")
                break
            elseif tt == "string" then
                -- ok
            elseif tt ~= "table" then
                minetest.log("warning", "[verify_tiles] "..name..": invalid tile type ("..tt..")")
            elseif type(tile.name) ~= "string" then
                minetest.log("warning", "[verify_tiles] "..name..": invalid tile #"..k)
            end
        end
    end
end

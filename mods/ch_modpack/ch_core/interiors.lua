ch_core.open_submod("interiors", {})

local normal = 0
local passable = 1
local evadable = 2

minetest.register_on_mods_loaded(function()
    local passable_drawtypes = {
        airlike = true,
        firelike = true,
        flowingliquid = true,
        liquid = true,
        plantlike = true,
        plantlike_rooted = true,
        signlike = true,
        torchlike = true,
    }
    for _, ndef in pairs(minetest.registered_nodes) do
		if passable_drawtypes[ndef.drawtype or "normal"] then -- or ndef.sunlight_propagates == true
            ndef._ch_interior = passable
		else
			local groups = ndef.groups
            if groups == nil then
                ndef._ch_interior = normal
            elseif groups.leaves then
                ndef._ch_interior = passable
			elseif groups.tree then
                ndef._ch_interior = evadable
            else
                ndef._ch_interior = normal
			end
		end
	end
end)

local get_node = minetest.get_node
local registered_nodes = minetest.registered_nodes

local function has_passable_neighbour(pos)
    local ndef
	pos.x = pos.x - 1 -- -x
    ndef = registered_nodes[get_node(pos).name]
	if ndef ~= nil and ndef._ch_interior == passable then
		return true
	end
	pos.z = pos.z - 1 -- -x -z
    ndef = registered_nodes[get_node(pos).name]
	if ndef ~= nil and ndef._ch_interior == passable then
		return true
	end
	pos.x = pos.x + 1 -- -z
    ndef = registered_nodes[get_node(pos).name]
	if ndef ~= nil and ndef._ch_interior == passable then
		return true
	end
	pos.x = pos.x + 1 -- +x -z
    ndef = registered_nodes[get_node(pos).name]
	if ndef ~= nil and ndef._ch_interior == passable then
		return true
	end
	pos.z = pos.z + 1 -- +x
    ndef = registered_nodes[get_node(pos).name]
	if ndef ~= nil and ndef._ch_interior == passable then
		return true
	end
	pos.z = pos.z + 1 -- +x +z
    ndef = registered_nodes[get_node(pos).name]
	if ndef ~= nil and ndef._ch_interior == passable then
		return true
	end
	pos.x = pos.x - 1 -- +z
    ndef = registered_nodes[get_node(pos).name]
	if ndef ~= nil and ndef._ch_interior == passable then
		return true
	end
	pos.x = pos.x - 1 -- -x +z
    ndef = registered_nodes[get_node(pos).name]
	if ndef ~= nil and ndef._ch_interior == passable then
		return true
	end
	return false
end

--[[
    Prozkoumá, zda se zadaná pozice jeví být v interiéru.
    Při použití na hráčskou postavu (player:get_pos()) je potřeba k souřadnici y přičíst 0.5.
]]
function ch_core.is_in_interior(pos)
    local nlight = minetest.get_natural_light(pos, 0.5) or 0
    if nlight <= 0 then
        return true
    elseif nlight >= minetest.LIGHT_MAX then
        return false
    else
        local ndef, ntype
        local ray = minetest.raycast(pos, vector.offset(pos, 0, 20, 0), false, false)
        for pointed_thing in ray do
            if pointed_thing.type == "node" then
                ndef = registered_nodes[get_node(pointed_thing.under)]
                if ndef == nil then
                    return true -- under unknown node => interior
                end
                ntype = ndef._ch_interior
                if ntype ~= passable then
                    if ntype == evadable then
                        local pos2 = vector.offset(pointed_thing.under, 0, 1, 0)
                        ndef = registered_nodes[get_node(pos2).name]
                        if ndef == nil or ndef._ch_interior == evadable then
                            return true -- under two evadable nodes => interior
                        end
                        pos2.y = pointed_thing.under.y
                        if not has_passable_neighbour(pointed_thing.under) then
                            return true -- under evadable node with no passable neighbour => interior
                        end
                    else
                        return true -- under full node => interior
                    end
                end
            end
        end
        return false
    end
end

ch_core.close_submod("interiors")

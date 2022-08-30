ch_core.open_submod("vgroups")

local vgroups = {}
local private_vgroups = {}

function ch_core.create_private_vgroup(vgroup, tbl)
	if vgroups[vgroup] then
		error("Vgroup "..vgroup.." demanded as private already exists!")
	end
	local result = tbl or {}
	vgroups[vgroup] = result
	private_vgroups[vgroup] = true
	return result
end

function ch_core.get_shared_vgroup(vgroup)
	if private_vgroups[vgroup] then
		error("Vgroup "..vgroup.." is private!")
	end
	local result = vgroups[vgroup]
	if not result then
		result = {}
		vgroups[vgroup] = result
	end
	return result
end

function ch_core.try_read_vgroup(vgroup)
	return vgroups[vgroup]
end

ch_core.close_submod("vgroups")

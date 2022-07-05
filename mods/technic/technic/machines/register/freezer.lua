
local S = technic.getter

function technic.register_freezer(data)
	data.typename = "freezing"
	data.machine_name = "freezer"
	data.machine_desc = S("@1 Freezer", "%s")
	technic.register_base_machine(data)
end

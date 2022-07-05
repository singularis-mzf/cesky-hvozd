
local S = technic.getter

function technic.register_grinder(data)
	data.typename = "grinding"
	data.machine_name = "grinder"
	data.machine_desc = S("@1 Grinder", "%s")
	technic.register_base_machine(data)
end

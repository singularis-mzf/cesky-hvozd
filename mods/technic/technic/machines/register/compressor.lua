
local S = technic.getter

function technic.register_compressor(data)
	data.typename = "compressing"
	data.machine_name = "compressor"
	data.machine_desc = S("@1 Compressor", "%s")
	technic.register_base_machine(data)
end

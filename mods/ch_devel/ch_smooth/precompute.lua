local ch_smooth = ...

--[[
	Úkolem tohoto kódu je vygenerovat dvě pole:

	material_to_shapes -- Používá se pro převod z vzorce tvaru a materiálu na konkétní sadu bloků.
	nodename_to_material -- Používá se pro převod z konkrétního bloku na vzorec tvaru a materiál. Tzn. opačný převod.
]]

local assert_is_shape = assert(ch_smooth.assert_is_shape)
local general_shapes = assert(ch_smooth.general_shapes)
local ifthenelse = ch_core.ifthenelse
local shape_id = assert(ch_smooth.shape_id)
local rotate_shape = assert(ch_smooth.rotate_shape)

-- vzorec tvaru (=shape_id) => {shapedef = generic shape def, param2 = odpovídající otočení}
local vzorec_to_shape = {}
local vzorec_to_shape_pocet = 0

for i, shape in ipairs(general_shapes) do
	assert_is_shape(shape)
	for param2 = 0,3 do
		local vzorec = shape_id(rotate_shape(shape, param2))
		if vzorec_to_shape[vzorec] == nil then
			vzorec_to_shape[vzorec] = {shape = shape, param2 = param2}
			vzorec_to_shape_pocet = vzorec_to_shape_pocet + 1
		else
			minetest.log("warning", "duplicity at key <"..vzorec..">: existing: "..dump2(vzorec_to_shape[vzorec])..", new = "..dump2({shape = shape, param2 = param2}))
		end

		if param2 == 0 and shape.vxmzm == shape.vxpzm and shape.vxpzm == shape.vxpzp and shape.vxpzp == shape.vxmzp and shape.vxmzp == shape.vxmzm then
			-- print("break at key "..vzorec..", because it is a slab")
			break
		end
	end
end

ch_smooth.vzorec_to_shape = vzorec_to_shape -- vzorec => {shape, param2}
ch_smooth.vzorec_to_shape_pocet = vzorec_to_shape_pocet
print("LADĚNÍ: vygenerováno "..vzorec_to_shape_pocet.." vzorců")

local function get_or_add(t, k)
	local result = t[k]
	if t[k] == nil then
		result = {}
		t[k] = result
	end
	return result
end

-- ==========================================================================
-- [Itemstring materiálu] => {
-- 		[vzorec tvaru] => {type, node, [node_above], [node_above2], shape = shapedef}
-- }
local material_to_shapes = {}

-- [Itemstring libovolného tvaru] =>
--     a) {item = itemstring materiálu, shape = shapedef}
--     b) {test_below = {[nodename] = {item = ..., shape = ...}, ... }, test_below2 = {totéž} [, default = {item = ..., shape = ...}]}
-- Používá se pro analýzu tvaru konkrétní sady bloků.
local nodename_to_material = {}

local debug_counter = 0 -- ?

for _, material in ipairs(ch_smooth.materials) do
	local item = assert(material.item)
	local modname, subname = item:match("^(.*):(.*)$")
	if (modname or subname) == nil then
		error("Invalid item: "..item.."!")
	end
	if material.prefix == nil then
		material.prefix = ifthenelse(modname ~= "default", modname..":", "moreblocks:")
	end
	if material.name == nil then
		material.name = subname
	end

	local matshapes = {}
	for vzorec, shape_info in pairs(vzorec_to_shape) do
		local shape, param2 = shape_info.shape, shape_info.param2
		local nodename
		if shape.prefix == "" and shape.suffix == "" then
			nodename = material.item
		else
			nodename = material.prefix..shape.prefix..material.name..shape.suffix
		end
		if minetest.registered_nodes[nodename] ~= nil then
			local data = {
				type = assert(shape.type),
				shape = shape,
				node = { name = nodename, param2 = param2 },
			}
			--[[
			if shape.suffix == "_inner_cut_half_raised" and shape.prefix == "slope_" and shape.type == "normal" and material.item == "desert:sand" then
				debug_counter = debug_counter + 1
				if debug_counter >= 2 then
					error("watch: "..dump2({vzorec = vzorec, material = material}))
				end
			end
			]]
			if shape.type == "normal" or shape.type == "bank" then
				local ntm = nodename_to_material[nodename]
				if ntm == nil then
					nodename_to_material[nodename] = {item = material.item, shape = shape}
					print("DEBUG: will register ["..nodename.."] = "..material.item.." ("..shape_id(shape)..")")
				elseif (ntm.test_below ~= nil or ntm.test_below2 ~= nil) and ntm.default == nil then
					print("DEBUG: will register for ["..nodename.."] a default = "..material.item.." ("..shape_id(shape)..")")
					ntm.default = {item = material.item, shape = shape}
				elseif
					(ntm.default == nil and (ntm.item ~= material.item or shape_id(ntm.shape) ~= shape_id(shape) or ntm.shape.type ~= shape.type)) or
					(ntm.default ~= nil and (ntm.default.item ~= material.item or shape_id(ntm.default.shape) ~= shape_id(shape) or ntm.default.shape.type ~= shape.type))
				then
					minetest.log("warning", "[ch_smooth] nodename_to_material conflict (nodename == "..nodename..", material = "..
						dump2({old = nodename_to_material[nodename], new = {
							item = material.item,
							shape = shape,
						}, vzorec = vzorec, shape_info = shape_info})..")!")
					-- else: already registered (is expected)
				end
			--[[ elseif shape.type == "bank" then
				if nodename_to_material[nodename] ~= nil then
					minetest.log("warning", "[ch_smooth] nodename_to_material conflict (nodename == "..nodename..")!")
				end
				nodename_to_material[nodename] = {
					item = material.item,
					shape = shape,
				} ]]
			elseif shape.type == "double" or shape.type == "double_bank" then
				local upper_nodename = material.prefix..shape.upper_prefix..material.name..shape.upper_suffix
				local upper_ntm = nodename_to_material[upper_nodename]
				if upper_ntm == nil then
					print("DEBUG: will create a new registration for [upper="..upper_nodename.."]")
					upper_ntm = {}
				elseif upper_ntm.test_below == nil and upper_ntm.test_below2 == nil then
					print("DEBUG: will upgrade a registration for [upper="..upper_nodename.."] = {default = "..upper_ntm.item.." // "..shape_id(upper_ntm.shape).."}")
					upper_ntm = {default = upper_ntm}
				end
				nodename_to_material[upper_nodename] = upper_ntm
				local test_key = ifthenelse(shape.type == "double", "test_below", "test_below2")
				--[[ if upper_ntm.shape ~= nil then
					error("[ch_smooth] nodename_to_material conflict (upper nodename == "..upper_nodename..", nodename == "..nodename..")!")
				end ]]
				local t = get_or_add(upper_ntm, test_key)
				if t[nodename] == nil then
					print("DEBUG: will register [upper="..upper_nodename.."]."..test_key.."["..nodename.."] = "..material.item.." ("..shape_id(shape)..")")
					t[nodename] = {
						item = material.item,
						shape = shape,
					}
				elseif t[nodename].item ~= material.item or shape_id(t[nodename].shape) ~= shape_id(shape) or t[nodename].shape.type ~= shape.type then
					minetest.log("warning", "[ch_smooth] nodename_to_material conflict (nodename == "..nodename..") in test (shape.type == "..shape.type.."), upper nodename == "..upper_nodename..", material = "..dump2({old = nodename_to_material[nodename], new = {
						item = material.item,
						shape = shape,
						}, vzorec = vzorec, shape_info = shape_info}).."!")
				-- else: already defined (expected)
				end
				if shape.type == "double" then
					data.node_above = { name = upper_nodename, param2 = param2 }
				else -- double_bank
					data.node_above  = { name = "air", param2 = 0 }
					data.node_above2 = { name = upper_nodename, param2 = param2 }
				end
			else
				error("Invalid shape type: "..shape.type)
			end
			matshapes[vzorec] = data
		end
	end
	material_to_shapes[material.item] = matshapes
end

ch_smooth.material_to_shapes = material_to_shapes
ch_smooth.nodename_to_material = nodename_to_material

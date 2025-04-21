local pole_texture = "advtrains_signals_japan_mast.png"
local signal_face_texture = "advtrains_hud_bg.png^[colorize:#000000:255"
local pole_radius = 1/16
local pole_box = {-pole_radius,-1/2,-pole_radius,pole_radius,1/2,pole_radius}
local light_radius = 1/20
local signal_width = 6*light_radius
local signal_thickness = pole_radius*3
local signal_height = {}
local signal_box = {}
local light_red = "advtrains_hud_bg.png^[colorize:red:255"
local light_yellow = "advtrains_hud_bg.png^[colorize:orange:255"
local light_green = "advtrains_hud_bg.png^[colorize:lime:255"
local light_purple = "advtrains_hud_bg.png^[colorize:purple:255"
local light_distant = light_purple
local light_off = signal_face_texture

do
	local model_path_prefix = table.concat({minetest.get_modpath("advtrains_signals_japan"), "models", "advtrains_signals_japan_"}, DIR_DELIM)

	local function vertex(x, y, z)
		return string.format("v %f %f %f", x, y, z)
	end
	local function texture(u, v)
		return string.format("vt %f %f", u, v)
	end
	local function face_element(v, vt)
		if vt then
			return string.format("%d/%d", v, vt)
		end
		return tonumber(v)
	end
	local function face_elements(...)
		local st = {"f"}
		local args = {...}
		local len = #args
		for i = 1, len, 2 do
			st[(i+3)/2] = face_element(args[i], args[i+1])
		end
		return table.concat(st, " ")
	end
	local function sequential_elements(v0, vt0, count)
		local st = {}
		for i = 1, count do
			st[i] = face_element(v0+i, vt0+i)
		end
		return table.concat(st, " ")
	end
	local function mod_lower(min, a, b)
		return min + (a-min)%b
	end
	local function connect_circular(v0, vt0, count)
		return "f " .. sequential_elements(v0, vt0, count)
	end
	local function connect_cylindrical(v0, vt0, count)
		local st = {}
		for i = 0, count-1 do
			local j = (i+1)%count
			local v1 = v0+i+1
			local v2 = v1+count
			local v3 = v0+j+1
			local v4 = v3+count
			local vt1 = vt0+i+1
			local vt2 = vt1+count+1
			st[i+1] = face_elements(v1, vt1, v3, vt1+1, v4, vt2+1, v2, vt2)
		end
		return table.concat(st, "\n")
	end
	local function circular_textures(u0, v0, r, count, total, angular_offset, direction)
		local st = {}
		if not angular_offset then
			angular_offset = 0
		end
		if not total then
			total = count
		end
		if not direction then
			direction = 1
		end
		for i = 0, count-1 do
			local theta = angular_offset + direction*i/total*2*math.pi
			local u, v = r*math.cos(theta), r*math.sin(theta)
			st[i+1] = texture(u0+u, v0+v)
		end
		return table.concat(st, "\n")
	end
	local function rectangular_textures(u0, v0, u1, v1, count)
		local st = {}
		local width = u1-u0
		for i = 0, count do
			local u = u0+i/count*width
			st[i+1] = texture(u, v0)
			st[i+count+2] = texture(u, v1)
		end
		return table.concat(st, "\n")
	end

	-- generate pole model
	local pole_npolygon = 32
	local pole_vertex_count = pole_npolygon*2
	local pole_uv_count = pole_npolygon*3+2
	local pole_vertices = {}
	local pole_objdef = {
		"g pole",
		"usemtl pole",
		connect_circular(0, 0, pole_npolygon),
		connect_circular(pole_npolygon, 0, pole_npolygon),
		connect_cylindrical(0, pole_npolygon, pole_npolygon),
	}
	local pole_uv = {
		circular_textures(0.5, 0.5, 0.5, pole_npolygon),
		rectangular_textures(0, 0, 1, 1, pole_npolygon),
	}
	for i = 0, pole_npolygon-1 do
		local theta = i*2/pole_npolygon*math.pi
		local r = pole_radius
		local x, z = r*math.sin(theta), r*math.cos(theta)
		local lower_index = i+1
		local upper_index = lower_index+pole_npolygon
		pole_vertices[lower_index] = vertex(x, -0.5, z)
		pole_vertices[upper_index] = vertex(x, 0.5, z)
	end
	pole_vertices = table.concat(pole_vertices, "\n")
	pole_objdef = table.concat(pole_objdef, "\n")
	pole_uv = table.concat(pole_uv, "\n")
	minetest.safe_file_write(model_path_prefix .. "pole.obj", table.concat({pole_vertices, pole_uv, pole_objdef}, "\n"))

	-- generate signals
	for lightcount = 5, 6 do
		for rotname, rot in pairs {["0"] = 0, ["30"] = 26.5, ["45"] = 45, ["60"] = 63.5} do
			local rot = math.rad(rot)
			local lightradius = 0.05
			local lightspacing = 0.04
			local halfwidth = signal_width/2
			local halfheight = (2+lightcount)*lightradius+(lightcount-1)*lightspacing/2
			local halfthickness = signal_thickness/2
			local half_npolygon = pole_npolygon/2
			local quarter_npolygon = pole_npolygon/4
			local boxside = math.max(halfwidth, halfthickness*2)
			signal_height[lightcount] = halfheight*2
			signal_box[lightcount] = {-boxside, -halfheight, -boxside, boxside, halfheight, boxside}

			local _vertex = vertex
			local rv = vector.new(0, rot, 0)
			local function vertex(x, y, z)
				local v = vector.rotate(vector.new(x, y, z), rv)
				return _vertex(v.x, v.y, v.z)
			end

			-- generate signal face
			local face_vertices = {}
			local face_uv = {
				circular_textures(0.5, 0.5+halfheight-3*lightradius, halfwidth, half_npolygon+1, pole_npolygon),
				circular_textures(0.5, 0.5-halfheight+3*lightradius, halfwidth, half_npolygon+1, pole_npolygon, math.pi),
				rectangular_textures(0, 0, 1, 1, 2+pole_npolygon),
			}
			local face_objdef = {
				"g face",
				"usemtl face",
				connect_circular(pole_vertex_count+2+pole_npolygon, pole_uv_count, 2+pole_npolygon),
				connect_circular(pole_vertex_count, pole_uv_count, 2+pole_npolygon),
				connect_cylindrical(pole_vertex_count, pole_uv_count+2+pole_npolygon, 2+pole_npolygon),
			}
			local face_vertex_count = 4*half_npolygon+4
			local face_uv_count = 2*(half_npolygon+1) + 2*(pole_npolygon+3)
			for i = 0, half_npolygon do
				local theta = i/half_npolygon*math.pi
				local r = halfwidth
				local x, y = r*math.cos(theta), halfheight-3*lightradius+r*math.sin(theta)
				face_vertices[i+1] = vertex(x, y, -halfthickness)
				face_vertices[i+2+half_npolygon] = vertex(-x, -y, -halfthickness)
				face_vertices[i+3+2*half_npolygon] = vertex(x, y, halfthickness)
				face_vertices[i+4+3*half_npolygon] = vertex(-x, -y, halfthickness)
			end

			-- generate lights
			local light_vertices = {}
			local light_vertex_count = 8*(half_npolygon+1)+pole_npolygon
			local light_uv = {rectangular_textures(0, 0, 1, 1, half_npolygon)}
			local light_uv_count = 2*(half_npolygon+1)+pole_npolygon*lightcount
			local light_objdef_face = {}
			local light_objdef_main = {
				"g light",
				"usemtl light",
			}
			for i = 1, lightcount do
				local x0, y0 = 0, -halfheight + (2*i+1)*lightradius + (i-1)*lightspacing
				local v0 = light_vertex_count*(i-1)
				for j = 0, half_npolygon do
					local theta = j/half_npolygon*math.pi
					local xs, ys = math.cos(theta), math.sin(theta)
					for k, v in pairs {
						{xm = -1, ym = 1, rm = 1, z = 1},
						{xm = 1, ym = 1, rm = 0.8, z = 1},
						{xm = -1, ym = 1, rm = 1, z = 2},
						{xm = 1, ym = 1, rm = 0.8, z = 2},
						{xm = 1, ym = -1, rm = 1, z = 1},
						{xm = -1, ym = -1, rm = 0.8, z = 1},
						{xm = 1, ym = -1, rm = 1, z = 1.5},
						{xm = -1, ym = -1, rm = 0.8, z = 1.5},
					} do
						local x = x0+xs*lightradius*v.xm*v.rm
						local y = y0+ys*lightradius*v.ym*v.rm
						light_vertices[v0+(k-1)*(half_npolygon+1)+j+1] = vertex(x, y, -halfthickness*v.z)
					end
				end
				for j = 0, pole_npolygon-1 do
					local theta = j/pole_npolygon*2*math.pi
					local x, y = math.cos(theta), math.sin(theta)
					light_vertices[v0+8*(half_npolygon+1)+1+j] = vertex(x0+lightradius*x, y0+lightradius*y, -halfthickness*1.05)
				end
				local v0 = pole_vertex_count+face_vertex_count+v0
				local vt0 = pole_uv_count + face_uv_count
				local ostep = 2*half_npolygon+2
				for j = 1, half_npolygon do
					local dv = 2*(half_npolygon+1)
					local v0 = v0 + dv
					local vn = v0 + dv
					light_objdef_face[i*ostep-j+1] = face_elements(v0+j, vt0+j, v0+j+1, vt0+j+1, vn-j, vt0+half_npolygon+2+j, vn-j+1, vt0+half_npolygon+1+j)
					local v0 = vn + dv
					local vn = v0 + dv
					light_objdef_face[i*ostep-half_npolygon-j+1] = face_elements(v0+j, vt0+j, v0+j+1, vt0+j+1, vn-j, vt0+half_npolygon+2+j, vn-j+1, vt0+half_npolygon+1+j)
				end
				local vt0 = vt0 + 2*(half_npolygon+1) + (i-1)*pole_npolygon
				light_uv[i+1] = circular_textures(0.5, (i-1/2)/lightcount, 0.4/lightcount, pole_npolygon)
				light_objdef_face[(i-1)*ostep+1] = connect_cylindrical(v0, pole_uv_count+2+pole_npolygon, 2+pole_npolygon)
				light_objdef_face[(i-1)*ostep+2] = connect_cylindrical(v0+4*(half_npolygon+1), pole_uv_count+2+pole_npolygon, 2+pole_npolygon)
				light_objdef_main[2+i] = connect_circular(v0+8*(half_npolygon+1), vt0, pole_npolygon)
			end

			-- write file
			face_vertices = table.concat(face_vertices, "\n")
			face_uv = table.concat(face_uv, "\n")
			face_objdef = table.concat(face_objdef, "\n")
			minetest.safe_file_write(model_path_prefix .. lightcount .. "_" .. rotname .. ".obj", table.concat({
				pole_vertices,
				face_vertices,
				table.concat(light_vertices, "\n"),
				pole_uv,
				face_uv,
				table.concat(light_uv, "\n"),
				pole_objdef,
				face_objdef,
				table.concat(light_objdef_face, "\n"),
				table.concat(light_objdef_main, "\n"),
			}, "\n"))
		end
	end
end

local S = attrans

minetest.register_node("advtrains_signals_japan:pole_0", {
	description = S("Japanese signal pole"),
	drawtype = "mesh",
	mesh = "advtrains_signals_japan_pole.obj",
	tiles = {pole_texture},

	paramtype = "light",
	sunlight_propagates = true,

	paramtype2 = "none",
	selection_box = {
		type = "fixed",
		fixed = {pole_box},
	},
	collision_box = {
		type = "fixed",
		fixed = {pole_box},
	},
	groups = {
		cracky = 2,
		not_blocking_trains = 1,
		not_in_creative_inventory = 0,
	},
	drop = "advtrains_signals_japan:pole_0",
})

--[[
advtrains.interlocking.aspect.register_group {
	name = "advtrains_signals_japan:5a",
	label = S("Japanese signal"),
	aspects = {
		danger = {
			label = S"Danger (halt)",
			main = 0,
		},
		restrictedspeed = {
			label = S"Restricted speed",
		},
		caution = {
			label = S"Caution",
		},
		reducedspeed = {
			label = S"Reduced speed",
		},
		clear = {
			label = S"Clear (proceed)",
		},
		"clear",
		"reducedspeed",
		"caution",
		"restrictedspeed",
		"danger",
	}
}]]

local sigdefs = {}
local lightcolors = {
	red = "red",
	green = "lime",
	yellow = "orange",
	distant = "purple",
}
local function process_signal(name, sigdata, isrpt)
	local def = {}
	local tx = {}
	def.textures = tx
	def.desc = sigdata.desc
	def.isdst = isrpt
	def.aspects = sigdata.aspects
	local lights = sigdata.lights
	local lightcount = #lights
	if isrpt then
		lightcount = lightcount+1
	end
	def.lightcount = lightcount
	def.suppasp_names = {}
	for idx, asp in ipairs(sigdata.aspects) do
		local aspname = asp.name
		local tt = {
			string.format("[combine:1x%d", lightcount),
			string.format("0,0=(advtrains_hud_bg.png\\^[resize\\:1x%d\\^[colorize\\:#000)", lightcount),
		}
		for _, i in pairs(asp.lights) do
			local color = lightcolors[lights[i]]
			tt[#tt+1] = string.format("0,%d=(advtrains_hud_bg.png\\^[colorize\\:%s)", i-1, color)
		end
		if isrpt then
			local color = lightcolors.distant
			tt[#tt+1] = string.format("0,%d=(advtrains_hud_bg.png\\^[colorize\\:%s)", lightcount-1, color)
		end
		tx[aspname] = table.concat(tt, ":")
		def.suppasp_names[idx] = aspname
	end
	local invimg = {
		string.format("[combine:%dx%d", lightcount*4+1, lightcount*4+1),
		string.format("%d,0=(advtrains_hud_bg.png\\^[resize\\:5x%d\\^[colorize\\:#000)", lightcount*2-2, lightcount*4+1),
	}
	for i, c in pairs(lights) do
		local color = lightcolors[c]
		invimg[i+2] = string.format("%d,%d=(advtrains_hud_bg.png\\^[resize\\:3x3\\^[colorize\\:%s)", 2*lightcount-1, 4*i-3, color)
	end
	if isrpt then
		invimg[lightcount+2] = string.format("%d,%d=(advtrains_hud_bg.png\\^[resize\\:3x3\\^[colorize\\:%s)", 2*lightcount-1, 4*lightcount-3, lightcolors.distant)
	end
	def.inventory_image = table.concat(invimg, ":")
	return def
end
for sigtype, sigdata in pairs {
	["5a"] = {
		desc = "5A",
		lights = {"yellow", "yellow", "red", "yellow", "green"},
		aspects = {
			{name = "clear", description = S"Clear (proceed)", lights = {5}, main = -1},
			{name = "reducedspeed", description = S"Reduced speed", lights = {2, 5}, main = 12},
			{name = "caution", description = S"Caution", lights = {4}},
			{name = "restrictedspeed", description = S"Restricted speed", lights = {1, 4}, main = 6},
			{name = "danger", description = S"Danger (halt)", lights = {3}, main = 0},
		}
	}
} do
	sigdefs["main_"..sigtype] = process_signal(sigtype, sigdata)
	-- TODO re-enable this once ready
	--sigdefs["rpt_"..sigtype] = process_signal(sigtype, sigdata, true)
end

for _, rtab in ipairs {
	{rot = "0", ici = true},
	{rot = "30"},
	{rot = "45"},
	{rot = "60"},
} do
	local rot = rtab.rot
	for sigtype, siginfo in pairs(sigdefs) do
		local lightcount = siginfo.lightcount
		for asp, texture in pairs(siginfo.textures) do
			minetest.register_node("advtrains_signals_japan:"..sigtype.."_"..asp.."_"..rot, {
				description = attrans(string.format("Japanese%s signal (type %s)", siginfo.isdst and " repeating" or "", siginfo.desc)),
				drawtype = "mesh",
				mesh = string.format("advtrains_signals_japan_%d_%s.obj", lightcount, rot),
				tiles = {pole_texture, signal_face_texture, texture},
				paramtype = "light",
				sunlight_propagates = true,
				light_source = 4,
				paramtype2 = "facedir",
				selection_box = {
					type = "fixed",
					fixed = {pole_box, signal_box[lightcount]},
				},
				collision_box = {
					type = "fixed",
					fixed = {pole_box, signal_box[lightcount]},
				},
				groups = {
					cracky = 2,
					advtrains_signal = 2,
					not_blocking_trains = 1,
					save_in_at_nodedb = 1,
					not_in_creative_inventory = rtab.ici and asp == "danger" and 0 or 1,
				},
				inventory_image = siginfo.inventory_image,
				drop = "advtrains_signals_japan:"..sigtype.."_danger_0",
				advtrains = {
					main_aspects = siginfo.aspects,
					apply_aspect = function(pos, node, main_aspect, rem_aspect, rem_aspinfo)
						local asp_name = main_aspect and main_aspect.name or "danger"
						-- if this signal is clear and remote signal is restrictive (<= 10) then degrade to caution aspect
						if not main_aspect or main_aspect.halt then
							asp_name = "danger"
						elseif main_aspect.name == "clear" and rem_aspinfo and rem_aspinfo.main and rem_aspinfo.main >= 0 and rem_aspinfo.main <= 10 then
							asp_name = "caution"
						end
						advtrains.ndb.swap_node(pos, {name="advtrains_signals_japan:"..sigtype.."_"..asp_name.."_"..rot, param2 = node.param2})
					end,
					get_aspect_info = function(pos, main_aspect)
						if main_aspect.halt then
							return { main = 0 } -- generic halt
						end
						return {
							main = main_aspect.main,
							proceed_as_main = true,
						}
					end,
					route_role = "main_distant",
				--[[
					supported_aspects = {
						group = "advtrains_signals_japan:5a",
						name = siginfo.suppasp_names,
						dst_shift = siginfo.isdst and 0,
						main = (not siginfo.isdst) and {} or false
					},
					get_aspect = function()
						local main
						if siginfo.isdst then
							main = false
						end
						return {group = "advtrains_signals_japan:5a", name = asp, main = main}
					end,
					set_aspect = function(pos, node, asp)
						advtrains.ndb.swap_node(pos, {name = "advtrains_signals_japan:"..sigtype.."_"..(asp.name).."_"..rot, param2 = node.param2})
					end,
				]]
				},
				on_rightclick = advtrains.interlocking.signal.on_rightclick,
				can_dig = advtrains.interlocking.signal.can_dig,
				after_dig_node = advtrains.interlocking.signal.after_dig,
			})
			--advtrains.trackplacer.add_worked("advtrains_signals_japan:"..sigtype, asp, "_"..rot)
		end
	end
end

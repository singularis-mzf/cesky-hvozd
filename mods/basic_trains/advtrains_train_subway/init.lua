ch_base.open_mod(minetest.get_current_modname())
local S = attrans

-- Function from Classic Coaches mod by Marnack (AGPLv3)
local function apply_wagon_livery_textures(player, wagon, textures)
	if wagon and textures and textures[1] then
		local data = advtrains.wagons[wagon.id]
		data.livery = textures[1]
		wagon:set_textures(data)
	end
end

-- Function from Classic Coaches mod by Marnack (AGPLv3)
local function update_livery(wagon, puncher, mod_name)
	local itemstack = puncher:get_wielded_item()
	local item_name = itemstack:get_name()
	if item_name == advtrains_livery_designer.tool_name then
		advtrains_livery_designer.activate_tool(puncher, wagon, mod_name)
		return true
	end
	return false
end

-- Function from Classic Coaches mod by Marnack (AGPLv3)
local function set_textures(wagon, data)
	if data.livery then
		wagon.object:set_properties({textures={data.livery}})
	end
end

local wagon = {
	mesh="advtrains_subway_wagon.b3d",
	textures = {"advtrains_subway_wagon.png"},
	set_textures = set_textures,
	drives_on={default=true},
	max_speed=3,
	seats = {
		{
			name=S("Driver stand"),
			attach_offset={x=0, y=0, z=0},
			view_offset={x=0, y=0, z=0},
			group="dstand",
		},
		{
			name="1",
			attach_offset={x=-4, y=-2, z=8},
			view_offset={x=0, y=0, z=0},
			group="pass",
		},
		{
			name="2",
			attach_offset={x=4, y=-2, z=8},
			view_offset={x=0, y=0, z=0},
			group="pass",
		},
		{
			name="3",
			attach_offset={x=-4, y=-2, z=-8},
			view_offset={x=0, y=0, z=0},
			group="pass",
		},
		{
			name="4",
			attach_offset={x=4, y=-2, z=-8},
			view_offset={x=0, y=0, z=0},
			group="pass",
		},
	},
	seat_groups = {
		dstand={
			name = S("Driver Stand"),
			access_to = {"pass"},
			require_doors_open=true,
			driving_ctrl_access=true,
		},
		pass={
			name = S("Passenger area"),
			access_to = {"dstand"},
			require_doors_open=true,
		},
	},
	assign_to_seat_group = {"pass", "dstand"},
	coupler_types_front = {chain=true},
	coupler_types_back = {chain=true},
	doors={
		open={
			[-1]={frames={x=0, y=20}, time=1},
			[1]={frames={x=40, y=60}, time=1},
			sound = "advtrains_subway_dopen",
		},
		close={
			[-1]={frames={x=20, y=40}, time=1},
			[1]={frames={x=60, y=80}, time=1},
			sound = "advtrains_subway_dclose",
		}
	},
	door_entry={-1, 1},
	visual_size = {x=1, y=1},
	wagon_span=2,
	--collisionbox = {-1.0,-0.5,-1.8, 1.0,2.5,1.8},
	collisionbox = {-1.0,-0.5,-1.0, 1.0,2.5,1.0},
	is_locomotive=true,
	drops={"default:steelblock 4"},
	horn_sound = "advtrains_subway_horn",
	--[[
	custom_on_velocity_change = function(self, velocity, old_velocity, dtime)
		if not velocity or not old_velocity then return end
		if old_velocity == 0 and velocity > 0 then
			minetest.sound_play("advtrains_subway_depart", {object = self.object})
		end
		if velocity < 2 and (old_velocity >= 2 or old_velocity == velocity) and not self.sound_arrive_handle then
			self.sound_arrive_handle = minetest.sound_play("advtrains_subway_arrive", {object = self.object})
		elseif (velocity > old_velocity) and self.sound_arrive_handle then
			minetest.sound_stop(self.sound_arrive_handle)
			self.sound_arrive_handle = nil
		end
		if velocity > 0 and (self.sound_loop_tmr or 0)<=0 then
			self.sound_loop_handle = minetest.sound_play({name="advtrains_subway_loop", gain=0.3}, {object = self.object})
			self.sound_loop_tmr=3
		elseif velocity>0 then
			self.sound_loop_tmr = self.sound_loop_tmr - dtime
		elseif velocity==0 then
			if self.sound_loop_handle then
				minetest.sound_stop(self.sound_loop_handle)
				self.sound_loop_handle = nil
			end
			self.sound_loop_tmr=0
		end
	end,
	]]
	--[[
	custom_on_step = function(self, dtime, data, train)
		--set line number
		local line = nil
		if train.line and self.line_cache ~= train.line then
			self.line_cache=train.line
			local lint = train.line
			if string.sub(train.line, 1, 1) == "S" then
				lint = string.sub(train.line,2)
			end
			if string.len(lint) == 1 then
				if lint=="X" then line="X" end
				line = tonumber(lint)
			elseif string.len(lint) == 2 then
				if tonumber(lint) then
					line = lint
				end
			end
			if line then
				local new_line_tex="advtrains_subway_wagon.png"
				if type(line)=="number" or line == "X" then
					new_line_tex = new_line_tex.."^advtrains_subway_wagon_line"..line..".png"
				else
					local num = tonumber(line)
					local red = math.fmod(line*67+101, 255)
					local green = math.fmod(line*97+109, 255)
					local blue = math.fmod(line*73+127, 255)
					new_line_tex = new_line_tex..string.format("^(advtrains_subway_wagon_line.png^[colorize:#%X%X%X%X%X%X)^(advtrains_subway_wagon_line%s_.png^advtrains_subway_wagon_line_%s.png", math.floor(red/16), math.fmod(red,16), math.floor(green/16), math.fmod(green,16), math.floor(blue/16), math.fmod(blue,16), string.sub(line, 1, 1), string.sub(line, 2, 2))
					if red + green + blue > 512 then
						new_line_tex = new_line_tex .. "^[colorize:#000)"
					else
						new_line_tex = new_line_tex .. ")"
					end
				end
				self.object:set_properties({
						textures={new_line_tex},
				})
			elseif self.line_cache~=nil and line==nil then
				self.object:set_properties({
						textures=self.initial_properties.textures,
				})
				self.line_cache=nil
			end
		end	
	end,
	]]
}

if core.get_modpath("advtrains_livery_designer") then
	advtrains_livery_designer.register_mod("basic_trains", apply_wagon_livery_textures)
	wagon.custom_may_destroy = function(wgn, puncher, time_from_last_punch, tool_capabilities, direction)
		return not update_livery(wgn, puncher, "basic_trains")
	end
end

advtrains.register_wagon("subway_wagon", wagon, "vůz lanové dráhy", "advtrains_subway_wagon_inv.png")

if core.get_modpath("advtrains_livery_database") then
	advtrains_livery_database.register_mod("basic_trains")
	advtrains_livery_database.register_wagon("advtrains:subway_wagon", "basic_trains")
	advtrains_livery_database.add_livery_template(
		"advtrains:subway_wagon", -- wagon_type
		"bez čísla linky", -- template name
		{"advtrains_subway_wagon.png"}, -- base_texture
		"basic_trains", -- mod_name
		1, -- number of overlays
		"Singularis", -- template designer
		"CC-BY-SA-3.0", -- texture license
		"orwell96,Singularis", -- texture creators
		"" -- notes
	)
	advtrains_livery_database.add_livery_template_overlay(
		"advtrains:subway_wagon", -- wagon_type
		"bez čísla linky", -- template name
		1, -- overlay_id (pořadové číslo)
		"karoserie", -- overlay_name
		1, -- overlay_slot_index (?)
		"advtrains_subway_wagon_livery.png", -- overlay_texture
		140 -- overlay_alpha (0..255 or nil)
	)
	for i = 0, 9 do
		advtrains_livery_database.add_livery_template(
			"advtrains:subway_wagon", -- wagon_type
			"linka "..i, -- template name
			{"advtrains_subway_wagon.png^advtrains_subway_wagon_line"..i..".png"}, -- base_texture
			"basic_trains", -- mod_name
			1, -- number of overlays
			"Singularis", -- template designer
			"CC-BY-SA-3.0", -- texture license
			"orwell96,Singularis", -- texture creators
			"" -- notes
		)
		advtrains_livery_database.add_livery_template_overlay(
			"advtrains:subway_wagon", -- wagon_type
			"linka "..i, -- template name
			1, -- overlay_id (pořadové číslo)
			"karoserie", -- overlay_name
			1, -- overlay_slot_index (?)
			"advtrains_subway_wagon_livery.png^(advtrains_subway_wagon_line1.png^[colorize:#ffffff:255)^[makealpha:255,255,255", -- overlay_texture
			140 -- overlay_alpha (0..255 or nil)
		)
	end
end

--[[
wagon = table.copy(wagon)
wagon.textures = {"advtrains_subway_wagon_green.png"}
advtrains.register_wagon("subway_wagon_green", wagon, S("Green Subway Passenger Wagon"), "advtrains_subway_wagon_green_inv.png")
]]
core.register_alias("advtrains:subway_wagon_green", "advtrains:subway_wagon")

core.register_craft({
	output = 'advtrains:subway_wagon',
	recipe = {
		{'default:steelblock', 'default:steelblock', 'default:steelblock'},
		{'default:steelblock', 'dye:grey', 'default:steelblock'},
		{'ropes:ropesegment', 'ropes:ropesegment', 'ropes:ropesegment'},
	},
})

--[[
minetest.register_craft({
	output = 'advtrains:subway_wagon_green',
	recipe = {
		{'default:steelblock', 'default:steelblock', 'default:steelblock'},
		{'default:steelblock', 'dye:dark_green', 'default:steelblock'},
		{'default:steelblock', 'default:steelblock', 'default:steelblock'},
	},
})
]]

ch_base.close_mod(minetest.get_current_modname())

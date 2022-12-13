--
--Helper Functions
--

petz.set_properties = function(self, properties)
	if type(self) == 'table' then
		self = self.object
	end
	self:set_properties(properties)
end

function petz.is_night()
	local timeofday = minetest.get_timeofday()
	if timeofday == nil then --can be nil if world not loaded!!!
		return nil
	end
	timeofday = timeofday  * 24000
	if (timeofday < 4500) or (timeofday > 19500) then
		return true
	else
		return false
	end
end

function petz.isinliquid(self)
	local pos = self.object:get_pos()
	local pos_under = vector.new(pos.x, pos.y-0.5, pos.z)
	local node_under = kitz.nodeatpos(pos_under)
	local pos_above = vector.new(pos.x, pos.y+0.5, pos.z)
	local node_above = kitz.nodeatpos(pos_above)
	if (node_under and (node_under.drawtype == 'liquid' or node_under.drawtype == 'flowingliquid'))
		or (node_above and (node_above.drawtype == 'liquid' or node_above.drawtype == 'flowingliquid')) then
			return true
	else
		return false
	end
end

function petz.round(x)
	return x>=0 and math.floor(x+0.5) or math.ceil(x-0.5)
end

function petz.truncate(number, decimals)
    local power = 10^decimals
    return math.floor(number * power) / power
end

function petz.vartostring(var)
	if var or var == 1 or var == "true" then
		return "true"
	elseif not(var) or var == nil or var == 0 or var == "false" then
		return "false"
	else
		return "false"
	end
end

function petz.set_list(list)
  local set = {}
  for _, l in ipairs(list) do set[l] = true end
  return set
end

petz.pos_front_player = function(player)
	local pos = player:get_pos()
	local yaw = player:get_look_horizontal()
	local dir_x = -math.sin(yaw) + 0.5
	local dir_z = math.cos(yaw) + 0.5
	local pos_front_player = {	-- what is in front of mob?
		x = pos.x + dir_x,
		y = pos.y + 0.5,
		z = pos.z + dir_z
	}
	return pos_front_player
end

petz.first_to_upper = function(str)
    return (str:gsub("^%l", string.upper))
end

petz.str_is_empty = function(str)
	return str == nil or str == ''
end

petz.is_pos_nan = function(pos)
	if minetest.is_nan(pos.x) or minetest.is_nan(pos.y) or minetest.is_nan(pos.z) then
		return true
	else
		return false
	end
end

petz.str_remove_spaces = function(str)
	str = str:gsub("%s+", "")
	return str
end

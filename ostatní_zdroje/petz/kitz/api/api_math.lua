function kitz.delimit_number(number, range)
	if not tonumber(number) then
		return nil
	end
	if number < range.min then
		number = range.min
	elseif number > range.max then
		number = range.max
	end
	return number
end

function kitz.round(x)
	return x>=0 and math.floor(x+0.5) or math.ceil(x-0.5)
end

--Trigonometric Functions

--converts yaw to degrees
function kitz.degrees(yaw)
	return(yaw * 180.0 / math.pi)
end

function kitz.degrees_to_radians(degrees)
	return(degrees/180.0*math.pi)
end

--converts yaw to degrees
function kitz.yaw_to_degrees(yaw)
	return(yaw*180.0/math.pi)
end

--rounds it up to an integer
function kitz.degree_round(degree)
	return(degree + 0.5 - (degree + 0.5) % 1)
end

--turns radians into degrees - not redundant
--doesn't add math.pi
function kitz.radians_to_degrees(radians)
	return(radians*180.0/math.pi)
end


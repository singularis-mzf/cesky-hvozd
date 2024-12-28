local internal = ...

local ifthenelse = assert(ch_core.ifthenelse)
local c_width, c_height = internal.container_width, internal.container_height
local x_min, y_min, z_min = internal.x_min, internal.y_min. internal.z_min
local x_scale, y_scale, z_scale = internal.x_scale, internal.y_scale, internal.z_scale
local x_count, y_count, z_count = internal.x_count, internal.y_count, internal.z_count
local total_count = x_count * y_count * z_count
local storage = assert(internal.storage)

local STATUS_NONE = 0
local STATUS_EMERGING = 1
local STATUS_EMERGED = 2

--[[
	container_width = 64, -- vnitřní šířka/hloubka kontejneru (měla by být dělitelná 16)
	container_height = 64, -- vnitřní výška kontejneru (měla by být dělitelná 16)
	-- *_min udává pozici prvního kontejneru v mřížce:
	x_min = -3840,
	y_min = 3488,
	z_min = -3840,
	-- *_scale udává, jak daleko bude každý následující kontejner od předchozího:
	x_scale = 96,
	y_scale = 256,
	z_scale = 96,
	-- *_count udává, kolik kontejnerů se může vytvořit podél každé osy:
	x_count = 80,
	y_count = 2,
	z_count = 80,

Formát ve 'storage':
string {container_id}_owner -- vlastník/ice kontejneru (je-li pole prázdné, kontejner neexistuje)
int {container_id}_status -- udává, zda byl kontejner vytvořen v mapě

]]

local function divrem(a, b)
    local rem = a % b
    return (a - rem) / b, rem
end

local function get_container_id(pos)
    pos = vector.round(pos)
    if
        x_min <= pos.x and pos.x <= x_min + (x_count - 1) * x_scale + container_width - 1 and
        z_min <= pos.z and pos.z <= z_min + (z_count - 1) * z_scale + container_width - 1 and
        y_min <= pos.y and pos.y <= y_min + (y_count - 1) * y_scale + container_height - 1
    then
        local i_x, r_x = divrem(pos.x - x_min, x_scale)
        local i_y, r_y = divrem(pos.y - y_min, y_scale)
        local i_z, r_z = divrem(pos.z - z_min, z_scale)
        if r_x < c_width and r_y < c_height and r_z < c_width then
            return string.format("c%03d%03d%03d", i_x, i_y, i_z)
        end
    end
end

local function get_container_by_id(container_id)
    local x, y, z = container_id:match("^c(%d%d%d)(%d%d%d)(%d%d%d)$")
    if x == nil then
        return nil
    end
    x, y, z = tonumber(x), tonumber(y), tonumber(z)
    assert(x)
    assert(y)
    assert(z)
    if x < x_count and y < y_count and z < z_count then
        local begin = vector.new(x_min + x * x_scale, y_min + y * y_scale, z_min + z * z_scale)
        return begin, vector.offset(begin, container_width - 1, container_height - 1, container_width - 1)
    else
        return nil
    end
end

local function emerge_container(container_id)
    local begin = get_container_by_id(container_id)
    if begin == nil then
        return
    end
    core.emerge_area(vector.offset(begin, -1, -1, -1), vector.offset(begin, container_width, container_height, container_width))
    core.after(0.2,)
end

local function is_emerged(container_id)
end

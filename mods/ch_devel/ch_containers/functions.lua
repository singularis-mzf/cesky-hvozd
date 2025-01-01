local internal = ...

local ifthenelse = assert(ch_core.ifthenelse)
local c_width, c_height = internal.container_width, internal.container_height
local x_min, y_min, z_min = internal.x_min, internal.y_min. internal.z_min
local x_scale, y_scale, z_scale = internal.x_scale, internal.y_scale, internal.z_scale
local x_count, y_count, z_count = internal.x_count, internal.y_count, internal.z_count
local total_count = x_count * y_count * z_count
local storage = assert(internal.storage)
local free_queue_length = 10

local STATUS_NONE = 0
local STATUS_EMERGING = 1
local STATUS_EMERGED = 2

local container_data = {--[[
    Data kontejnerů v paměti:
    [owner] = {
        {
            id = string,
            name = string, -- popis kontejneru
            public_until = int or nil, -- neperzistentní, ukládá hodnotu podle get_us_time()
        }, ...
    },
]]}

local function add_container_owner(new_owner)
    assert(new_owner ~= nil and new_owner ~= "" and container_data[new_owner] == nil)
    local owners = storage:get_string("owners")
    if owners ~= "" then
        owners = owners..new_owner.."|"
    else
        owners = "|"..new_owner.."|" -- first owner
    end
    storage:set_string("owners")
    local result = {}
    container_data[new_owner] = result
    return result
end

local function save_container_data(owner)
    if owner == nil then
        -- uložit vše:
        for xowner, _ in pairs(container_data) do
            save_container_data(xowner)
            return
        end
    end
    assert(owner ~= "")
    local containers = {}
    if container_data[owner] ~= nil and container_data[owner][1] ~= nil then
        for i, cdata in ipairs(container_data[owner]) do
            containers[i] = {id = cdata.id, name = cdata.name}
        end
    end
    storage:set_string("cdata_"..owner, assert(core.serialize(containers)))
end

local function load_container_data()
    local owners = storage:get_string("owners"):split("|", false)
    local new_data = {}
    local owner_count, total_count = 0, 0
    for _, owner in ipairs(owners) do
        local t = assert(core.deserialize(storage:get_string("cdata_"..owner)))
        assert(type(t) == "table")
        new_data[owner] = t
        owner_count = owner_count + 1
        total_count = total_count + #t
    end
    container_data = new_data
    core.log("action", "[ch_containers] "..total_count.." containers of "..owner_count.." owners loaded.")
end

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
string {container_id}_next_free -- je-li kontejner prázdný, udává ID následujícího prázdného kontejneru ve frontě
string next_free -- udává ID prvního prázdného kontejneru ve frontě
]]

local function divrem(a, b)
    local rem = a % b
    return (a - rem) / b, rem
end

local function get_random_container_id()
    return string.format("c%03d%03d%03d", math.random(0, x_count), math.random(0, y_count), math.random(0, z_count))
end

function internal.get_container_id(pos)
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
local get_container_id = internal.get_container_id

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

local function get_emerged_queue()
    local result = {}
    local s = storage:get_string("next_free")
    while s ~= "" do
        table.insert(result, s)
        s = storage:get_string(s.."_next_free")
    end
    return result
end

local function add_emerged(container_id)
    local old_queue = get_emerged_queue()
    if old_queue[1] ~= nil then
        local last_free = old_queue[#old_queue]
        storage:set_string(last_free.."_next_free", container_id)
    else
        storage:set_string("next_free", container_id)
    end
end

local function emerge_new(container_id)
    if storage:get_string(container_id.."_owner") ~= "" then
        error("Existing container "..container_id.." set to be emerged!")
    end
    local begin = get_container_by_id(container_id)
    if begin == nil then
        return
    end
    core.emerge_area(vector.offset(begin, -16, -16, -16), vector.offset(begin, container_width + 15, container_height + 15, container_width + 15))
    core.after(10, add_emerged, container_id)
end

-- => container_id, cont_min, cont_max
local function pop_emerged()
    -- emerge a new container to add to the queue:
    local new_id = get_random_container_id()
    while storage:get_string(new_id.."_owner") ~= "" do
        new_id = get_random_container_id()
    end
    emerge_new(new_id)

    -- fetch a container from the queue:
    local next_id = storage:get_string("next_free")
    if next_id == "" then
        core.log("error", "pop_emerged() called, but no free container is available in the queue!")
        return nil, nil, nil -- no available container!
    end
    local minp, maxp = get_container_by_id(next_id)
    storage:set_string("next_free", storage:get_string(next_id.."_next_free"))
    storage:set_string(next_id.."_next_free", "")
    return next_id, minp, maxp
end

-- At startup, 10 containers should be always emerged.
core.register_on_mods_loaded(function()
    local queue = get_emerged_queue()
    if #queue < free_queue_length then
        local set = {}
        for i = 1, free_queue_length - #queue do
            local new_id = get_random_container_id()
            while storage:get_string(new_id.."_owner") ~= "" or set[new_id] do
                new_id = get_random_container_id()
            end
            core.after(i, emerge_new, new_id)
            set[new_id] = true
        end
    end
end)

function internal.create_new_container(new_owner)
    assert(owner and owner ~= "")
    local id, minp, maxp = pop_emerged()
    if id == nil then
        return nil, "Vytváření kontejneru selhalo."
    end
    local ceiling_nodes = {}
    local floor_nodes = {}
    local wall_nodes = {}
    local cp_nodes = {}
    for x = minp.x, maxp.x do
        for z = minp.z, maxp.z do
            table.insert(ceiling_nodes, vector.new(x, maxp.y + 1, z))
            table.insert(floor_nodes, vector.new(x, minp.y - 1, z))
        end
    end
    for x in ipairs({minp.x - 1, maxp.x + 1}) do
        for z = minp.z - 1, maxp.z + 1 do
            for y = minp.y - 1, minp.y + 2 do
                table.insert(cp_nodes, vector.new(x, y, z))
            end
            for y = minp.y + 3, maxp.y + 1 do
                table.insert(wall_nodes, vector.new(x, y, z))
            end
        end
    end
    for z in ipairs({minp.z, maxp.z}) do
        for x = minp.x - 1, maxp.x + 1 do
            for y = minp.y - 1, minp.y + 2 do
                table.insert(cp_nodes, vector.new(x, y, z))
            end
            for y = minp.y + 3, maxp.y + 1 do
                table.insert(wall_nodes, vector.new(x, y, z))
            end
        end
    end
    core.bulk_set_node(ceiling_nodes, {name = "ch_containers:ceiling"})
    core.bulk_set_node(floor_nodes, {name = "ch_containers:floor"})
    core.bulk_set_node(wall_nodes, {name = "ch_containers:wall"})
    core.bulk_set_node(cp_nodes, {name = "ch_containers:control_panel"})
    storage:set_string(id.."_owner", new_owner)
    return id, minp, maxp
end

function internal.get_container_list(owner)
    local result = {}
    if owner ~= nil then
        local containers = container_data[owner]
        if containers ~= nil and containers[1] ~= nil then
            for i, container in ipairs(containers) do
                result[i] = {id = container.id, name = container.name, owner = owner}
            end
        end
    else
        -- TODO
    end
    return result
end

function internal.get_basic_info(container_id)
    local owner = storage:get_string(container_id.."_owner")
    if owner == "" then
        return nil -- kontejner neexistuje
    end
    for i, cdata in ipairs(container_data[owner] or {}) do
        if cdata.id == container_id then
            return {
                index = i,
                id = container_id,
                name = cdata.name,
                pos = assert(get_container_by_id(container_id)),
            }
        end
    end
    core.log("warning", "[ch_containers] Container "..container_id.." is not known, but has owner '"..owner.."'!")
    return nil -- kontejner nenalezen
end

function internal.get_full_info(container_id)
    local owner = storage:get_string(container_id.."_owner")
    if owner == "" then
        return nil -- kontejner neexistuje
    end
    for i, cdata in ipairs(container_data[owner] or {}) do
        if cdata.id == container_id then
            return {
                index = i,
                id = container_id,
                name = cdata.name,
                pos = assert(get_container_by_id(container_id)),
                -- TODO...
            }
        end
    end
    core.log("warning", "[ch_containers] Container "..container_id.." is not known, but has owner '"..owner.."'!")
    return nil -- kontejner nenalezen
end

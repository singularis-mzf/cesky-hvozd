local internal = ...

local ifthenelse = assert(ch_core.ifthenelse)
local c_width, c_height = internal.container_width, internal.container_height
local x_min, y_min, z_min = internal.x_min, internal.y_min, internal.z_min
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
        }, ...
    },
]]}

local public_containers = {--[[
    {
        id = string,
        name = string,
        owner = string,
        public_until = int, -- hodnota podle get_us_time()
    }, ...
]]}

local function get_public_containers(id_to_find)
    if public_containers[1] == nil then
        return public_containers, nil -- žádné veřejné kontejnery
    end
    local now = core.get_us_time()
    local n = #public_containers
    local found_index
    local i = 1
    while i < #public_containers do
        local record = public_containers[i]
        if record.public_until <= now then
            -- záznam vypršel, nutno uklidit
            table.remove(public_containers, i)
        else
            if record.id == id_to_find then
                found_index = i
            end
            i = i + 1
        end
    end
    return public_containers, found_index
end

--[[
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
]]

local function get_container_data(owner)
    assert(owner ~= nil and owner ~= "")
    local result = container_data[owner]
    if result == nil and ch_core.offline_charinfo[owner] ~= nil then
        local owners = storage:get_string("owners")
        if owners ~= "" then
            owners = owners..owner.."|"
        else
            owners = "|"..owner.."|" -- first owner
        end
        storage:set_string("owners", owners)
        result = {}
        container_data[owner] = result
    end
    return result
end
internal.get_container_data = get_container_data

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
internal.save_container_data = save_container_data

function internal.load_container_data()
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

    Metadata kontejnerů:
        string {container_id}_owner -- vlastník/ice kontejneru
        string {container_id}_next_free
            -- je-li kontejner prázdný, udává ID následujícího prázdného kontejneru ve frontě
            -- poslední prázdný kontejner ve frontě má toto pole nastaveno na hodnotu ";"
        string next_free -- udává ID prvního prázdného kontejneru ve frontě
        int ap_x, ap_y, ap_z -- pozice posledního umístěného přístupového terminálu (pro návrat z kontejnerů)
]]

local function divrem(a, b)
    local rem = a % b
    return (a - rem) / b, rem
end

function internal.get_random_container_id()
    return string.format("c%03d%03d%03d", math.random(0, x_count), math.random(0, y_count), math.random(0, z_count))
end
local get_random_container_id = internal.get_random_container_id

function internal.get_container_id(pos)
    pos = vector.round(pos)
    if
        x_min <= pos.x and pos.x <= x_min + (x_count - 1) * x_scale + c_width - 1 and
        z_min <= pos.z and pos.z <= z_min + (z_count - 1) * z_scale + c_width - 1 and
        y_min <= pos.y and pos.y <= y_min + (y_count - 1) * y_scale + c_height - 1
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
        return begin, vector.offset(begin, c_width - 1, c_height - 1, c_width - 1)
    else
        return nil
    end
end

function internal.is_container_emerged(container_id)
    local minp, maxp = get_container_by_id(container_id)
    if minp == nil or maxp == nil then
        return nil
    end
    core.load_area(vector.offset(minp, -1, -1, -1), vector.offset(maxp, 1, 1, 1))
    local pos = vector.zero()
    for x = minp.x - 1, maxp.x + 1, 16 do
        pos.x = x
        for z = minp.z - 1, maxp.z + 1, 16 do
            pos.z = z
            for y = minp.y - 1, maxp.y + 1, 16 do
                pos.y = y
                if core.get_node_or_nil(pos) == nil then
                    return false, pos
                end
            end
        end
    end
    return true
end

function internal.get_emerged_queue()
    local result = {}
    local s = storage:get_string("next_free")
    while s ~= "" and s ~= ";" do
        table.insert(result, s)
        s = storage:get_string(s.."_next_free")
    end
    return result
end

local function add_emerged(container_id, attempt_index)
    if attempt_index == nil then
        attempt_index = 1
    end
    if internal.is_container_emerged(container_id) then
        storage:set_string(container_id.."_next_free", ";")
        local old_queue = internal.get_emerged_queue()
        core.log("action", "[ch_containers] container "..container_id.." emerged, will put it to the queue (old queue length was "..#old_queue..")")
        if old_queue[1] ~= nil then
            -- neprázdná fronta, přidat na konec
            local last_free = old_queue[#old_queue]
            storage:set_string(last_free.."_next_free", container_id)
        else
            storage:set_string("next_free", container_id)
        end
    elseif attempt_index < 10 then
        core.log("warning", "Container "..container_id.." not emerged (attempt "..attempt_index.."), will try again after 10 seconds.")
        core.after(10, add_emerged, container_id, attempt_index + 1)
    else
        core.log("error", "Container "..container_id.." not emerged after 10 attempts!")
    end
end

function internal.emerge_new(container_id)
    print("DEBUG: emerge_new("..container_id..")")
    if storage:get_string(container_id.."_owner") ~= "" then
        error("Existing container "..container_id.." set to be emerged!")
    end
    local begin = get_container_by_id(container_id)
    if begin == nil then
        return
    end
    local min, max = vector.offset(begin, -16, -16, -16), vector.offset(begin, c_width + 15, c_height + 15, c_width + 15)
    core.log("action", "[ch_containers] starting emerging area: x("..min.x..".."..max.x.."), y("..min.y..".."..max.y.."), z("..
        min.z..".."..max.z..") for container "..container_id)
    core.emerge_area(min, max)
    core.after(10, add_emerged, container_id)
end

function internal.create_new_container(new_owner, container_name)
    assert(new_owner ~= nil and new_owner ~= "")
    local containers = get_container_data(new_owner)
    if containers == nil then
        return nil, "Neplatná uživatelská data" -- pravděpodobně chybné uživatelské jméno
    end

    -- naplánovat vygenerování dalšího kontejneru do fronty:
    local new_id = get_random_container_id()
    while storage:get_string(new_id.."_owner") ~= "" or storage:get_string(new_id.."_next_free") ~= "" do
        new_id = get_random_container_id()
    end
    internal.emerge_new(new_id)

    -- vzít kontejner z fronty:
    new_id = storage:get_string("next_free")
    if new_id == "" then
        core.log("error", "pop_emerged() called, but no free container is available in the queue!")
        return nil, "Vytváření kontejneru selhalo" -- žádný dostupný kontejner!
    end
    local minp, maxp = get_container_by_id(new_id)
    assert(minp)
    assert(maxp)
    storage:set_string("next_free", storage:get_string(new_id.."_next_free"))
    storage:set_string(new_id.."_owner", new_owner)
    storage:set_string(new_id.."_next_free", "")

    -- vygenerovat stěny kontejneru:
    print("DEBUG: WILL GENERATE CONTAINER "..core.pos_to_string(minp)..".."..core.pos_to_string(maxp))
    local ceiling_nodes = {}
    local floor_nodes = {}
    local wall_nodes = {}
    local cp_nodes = {}
    local pos
    local limit_min, limit_max = vector.offset(minp, -1, -1, -1), vector.offset(maxp, 1, 1, 1)
    for x = minp.x - 1, maxp.x + 1 do
        for z = minp.z - 1, maxp.z + 1 do
            pos = vector.new(x, maxp.y + 1, z)
            assert(vector.in_area(pos, limit_min, limit_max))
            table.insert(ceiling_nodes, pos)
            pos = vector.new(x, minp.y - 1, z)
            assert(vector.in_area(pos, limit_min, limit_max))
            table.insert(floor_nodes, pos)
        end
    end
    for _, x in ipairs({minp.x - 1, maxp.x + 1}) do
        for z = minp.z, maxp.z do
            for y = minp.y, maxp.y do
                pos = vector.new(x, y, z)
                assert(vector.in_area(pos, limit_min, limit_max))
                if y ~= minp.y + 1 then
                    table.insert(wall_nodes, pos)
                else
                    table.insert(cp_nodes, pos)
                end
            end
        end
    end
    for _, z in ipairs({minp.z - 1, maxp.z + 1}) do
        for x = minp.x - 1, maxp.x + 1 do
            for y = minp.y, maxp.y do
                pos = vector.new(x, y, z)
                assert(vector.in_area(pos, limit_min, limit_max))
                if y ~= minp.y + 1 then
                    table.insert(wall_nodes, pos)
                else
                    table.insert(cp_nodes, pos)
                end
            end
        end
    end
    core.bulk_set_node(ceiling_nodes, {name = "ch_containers:ceiling"})
    core.bulk_set_node(floor_nodes, {name = "ch_containers:floor"})
    core.bulk_set_node(wall_nodes, {name = "ch_containers:wall"})
    core.bulk_set_node(cp_nodes, {name = "ch_containers:control_panel"})
    -- zapsat kontejner do seznamu:
    table.insert(containers, {id = new_id, name = container_name or ""})
    save_container_data(new_owner)
    print("DEBUG: create_new_container("..new_owner..", "..(container_name or "nil").." finished.")
    return new_id, minp, maxp
end

function internal.get_container_count(owner)
    if owner ~= nil then
        local containers = get_container_data(owner)
        if containers ~= nil then
            return #containers
        else
            return 0
        end
    else
        local result = 0
        for owner, containers in pairs(container_data) do
            result = result + #containers
        end
        return result
    end
end

function internal.get_container_list(owner, include_public_containers)
    local result = {}
    if owner ~= nil then
        local containers = get_container_data(owner)
        if containers ~= nil and containers[1] ~= nil then
            for i, container in ipairs(containers) do
                result[i] = {id = container.id, name = container.name, owner = owner}
            end
        end
    else
        for owner, containers in pairs(container_data) do
            for _, container in ipairs(containers) do
                table.insert(result, {id = container.id, name = container.name, owner = owner})
            end
        end
    end
    return result
end

--[[
    Vrací:
    {
        id = string, -- container_id
        name = string, -- jméno kontejneru
        owner = string, -- vlastník/ice kontejneru,
        index = int, -- index kontejneru v owner_data,
        pos = vector, -- základní (minp) pozice kontejneru
        is_public = int or nil, -- index do public_containers, je-li kontejner veřejný
    }
]]
function internal.get_basic_info(container_id)
    local owner = storage:get_string(container_id.."_owner")
    if owner == "" then
        print("DEBUG: get_basic_info() called for '"..container_id.."' that has no _owner set!")
        return nil -- kontejner neexistuje
    end
    for i, cdata in ipairs(get_container_data(owner) or {}) do
        if cdata.id == container_id then
            local _public_containers, is_public = get_public_containers(container_id)
            return {
                id = container_id,
                name = cdata.name,
                owner = owner,
                index = i,
                pos = assert(get_container_by_id(container_id)),
                is_public = is_public
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
    for i, cdata in ipairs(get_container_data(owner) or {}) do
        if cdata.id == container_id then
            local _public_containers, is_public = get_public_containers(container_id)
            return {
                id = container_id,
                name = cdata.name,
                owner = owner,
                index = i,
                pos = assert(get_container_by_id(container_id)),
                is_public = is_public,
                -- TODO...
            }
        end
    end
    core.log("warning", "[ch_containers] Container "..container_id.." is not known, but has owner '"..owner.."'!")
    return nil -- kontejner nenalezen
end

function internal.enter_container(container_id, player, teleport_options)
    if player == nil then
        return false, "Vnitřní chyba: hráčská postava není nastavena"
    end
    if not core.is_player(player) then
        print("DEBUG: "..dump2({player = player, x = "x", is_player = {core.is_player(player)}}))
        return false, "Hráčská postava není platná."
    end
    if player:get_attach() ~= nil then
        print("DEBUG: "..dump2({player:get_attach()}))
        return false, "Hráčská postava je vázaná na jiný objekt."
    end
    local container_pos = get_container_by_id(container_id)
    if container_pos == nil then
        return false, "Neplatný kontejner"
    end
    if type(teleport_options) == "table" then
        teleport_options = table.copy(teleport_options)
    else
        teleport_options = {}
    end
    teleport_options.type = "player"
    teleport_options.player = player
    teleport_options.target_pos = container_pos
    return ch_core.teleport_player(teleport_options)
end

function internal.leave_container(player, teleport_options)
    if player == nil or not core.is_player(player) or player:get_attach() ~= nil then
        return false, "Hráčská postava není platná nebo je vázaná na jiný objekt."
    end
    if type(teleport_options) == "table" then
        teleport_options = table.copy(teleport_options)
    else
        teleport_options = {}
    end

    local pos = vector.new(storage:get_int("ap_x"), storage:get_int("ap_y"), storage:get_int("ap_z"))
    teleport_options.type = "player"
    teleport_options.player = player
    teleport_options.target_pos = pos
    return ch_core.teleport_player(teleport_options)
end

function internal.release_container(container_id)
    local minp, maxp = internal.get_container_by_id(container_id)
    if minp == nil or maxp == nil then
        return false, "Neplatný kontejner."
    end
    local owner = storage:get_string(container_id.."_owner")
    if owner == "" then
        if storage:get_string(container_id.."_next_free") == "" then
            return false, "Kontejner neexistuje."
        else
            return false, "Kontejner již je volný."
        end
    end
    local data = internal.get_container_data(owner)
    if data ~= nil then
        for i, record in ipairs(data) do
            if record.id == container_id then
                table.remove(data, i)
                break
            end
        end
    else
        core.log("warning", "Releasing container '"..container_id.."' of '"..owner.."' that has no owner data!")
    end
    storage:set_string(container_id.."_owner", "")
    storage:set_string(container_id.."_next_free", storage:get_string("next_free"))
    storage:set_string("next_free", container_id)
    internal.save_container_data(owner)
    core.log("action", "[ch_containers] Container "..container_id.." has been released as free.")
    return true
end

--[[
    container_id = string, -- ID kontejneru
    properties = {
        name = string or nil, -- nové jméno pro kontejner
        owner = string or nil, -- nový vlastník/ice pro kontejner (selže, pokud neexistuje); musí být uveden v přihlašovacím tvaru
        public_until = int or nil, -- učiní kontejner veřejným nebo prodlouží/zkrátí jeho zveřejnění
    },
    player_name = string or nil, -- volitelně: jméno postavy pro kontrolu oprávnění
    ---
    vrací: success (bool), error_message (string or nil)
]]
function internal.set_properties(container_id, properties, player_name)
    local info = internal.get_basic_info(assert(container_id))
    if info == nil then
        return false, "Kontejner neexistuje!"
    end
    if player_name ~= nil and ch_core.get_player_role(player_name) ~= "admin" then
        -- zkontrolovat oprávnění:
        if info.owner ~= player_name or (properties.owner ~= nil and properties.owner ~= info.owner) then
            return false, "Nedostatečné oprávnění!"
        end
    end

    local owner_data = internal.get_container_data(info.owner)
    local owner_to_save_1, owner_to_save_2
    local will_change_name = properties.name ~= nil and properties.name ~= info.name
    local will_change_owner = properties.owner ~= nil and properties.owner ~= info.owner
    local new_owner_data

    if will_change_owner then
        if ch_core.offline_charinfo[properties.owner] == nil then
            return false, "Postava '"..properties.owner.."' neexistuje!"
        end
        new_owner_data = internal.get_container_data(properties.owner)
        if new_owner_data == nil then
            return false, "Nepodařilo se načíst data kontejnerů postavy '"..properties.owner.."'!"
        end
    end

    -- name
    if will_change_name then
        owner_data[info.index].name = properties.name
        info.name = properties.name
        owner_to_save_1 = info.owner
    end

    -- owner
    if will_change_owner then
        local record = owner_data[info.index]
        table.insert(new_owner_data, record)
        table.remove(owner_data, info.index)
        owner_to_save_1 = info.owner
        info.owner = properties.owner
        owner_to_save_2 = info.owner
        storage:set_string(container_id.."_owner", properties.owner)
        -- update public_containers:
        for _, record in ipairs(public_containers) do
            if record.id == container_id then
                record.owner = info.owner
                break
            end
        end
    end

    -- public_until
    if properties.public_until ~= nil then
        local now = core.get_us_time()
        local pc_i = info.is_public
        if not pc_i then
            if properties.public_until > now then
                -- add to the list:
                table.insert(public_containers, {id = container_id, name = info.name, owner = info.owner, public_until = properties.public_until})
            end
        elseif properties.public_until <= now then
            -- remove from the list:
            table.remove(public_containers, pc_i)
        else
            -- change the value in the list:
            public_containers[pc_i].public_until = properties.public_until
        end
    end

    -- save data
    if owner_to_save_1 then
        internal.save_container_data(owner_to_save_1)
    end
    if owner_to_save_2 then
        internal.save_container_data(owner_to_save_2)
    end
    return true
end

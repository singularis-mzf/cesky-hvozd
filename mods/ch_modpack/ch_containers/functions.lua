local internal = ...

local c_width, c_height = internal.container_width, internal.container_height
local x_min, y_min, z_min = internal.x_min, internal.y_min, internal.z_min
local x_scale, y_scale, z_scale = internal.x_scale, internal.y_scale, internal.z_scale
local x_count, y_count, z_count = internal.x_count, internal.y_count, internal.z_count
local storage = assert(internal.storage)
local free_queue_length = assert(internal.free_queue_length)

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

-- MÍSTNÍ FUNKCE
-- ========================================================================
--[[
    Vrátí výsledek celočíselného dělení a jeho zbytek.
] ]
local function divrem(a, b)
    local rem = a % b
    return (a - rem) / b, rem
end
]]

--[[
    Vrátí seznam 'public_containers' poté, co z něj odklidí kontejnery, jejichž zveřejnění již vypršelo.
    Jako druhou hodnotu vrací výstup core.get_us_time() použitý při posuzování, zda zveřejnění kontejnerů již vypršelo.
]]
local function get_public_containers()
    local n = #public_containers
    local now = core.get_us_time()
    if n > 0 then
        for i = n, 1, -1 do
            if public_containers[i].public_until <= now then
                table.remove(public_containers, i)
            end
        end
    end
    return public_containers, now
end

--[[
    Je-li zadaný kontejner právě veřejný, vrátí požadovaný result_type:
    "index" => int (index do pole public_containers)
    "record" => table (záznam v poli public_containers)
    "ttl" => float (desetinný počet sekund, jak dlouho kontejner ještě bude veřejný)
    "bool" => true
    Není-li zadaný kontejner veřejný, vrací nil.
]]
local function find_public_container(container_id, result_type)
    assert(container_id ~= nil and container_id ~= "")
    if public_containers[1] == nil then
        return nil -- žádné veřejné kontejnery
    end
    local pc, now = get_public_containers()
    for i, record in ipairs(pc) do
        if record.id == container_id then
            if result_type == "bool" or result_type == nil then
                return true
            elseif result_type == "index" then
                return i
            elseif result_type == "record" then
                return record
            elseif result_type == "ttl" then
                return (record.public_until - now) / 1000000
            else
                return record
            end
        end
    end
end

--[[
    container_id = string,
    Je-li zadané ID platné (kontejner nemusí existovat), vrátí jeho minp a maxp,
    jinak vrátí nil.
]]
local function get_container_by_id(container_id)
    local x, y, z = container_id:match("^c(%x%x%x)(%x%x%x)(%x%x%x)$")
    if x == nil then
        return nil
    end
    x = 16 * assert(tonumber("0x"..x)) - 32768
    y = 16 * assert(tonumber("0x"..y)) - 32768
    z = 16 * assert(tonumber("0x"..z)) - 32768
    if
        x_min <= x and x <= x_min + x_scale * (x_count - 1) and
        y_min <= y and y <= y_min + y_scale * (y_count - 1) and
        z_min <= z and z <= z_min + z_scale * (z_count - 1)
    then
        return vector.new(x, y, z), vector.new(x + c_width - 1, y + c_height - 1, z + c_width - 1)
    else
        return nil
    end
end

--[[
    container_id = string,
    attempt_index = int, -- při prvním volání musí mít hodnotu 1
    insert_first = bool or nil, -- zda vložit na začátek fronty (true), nebo na konec (false, nil)

    Pomocná funkce, která zkontroluje, zda je oblast zadaného kontejneru vygenerována,
    a pokud ano, vloží ho do fronty prázdných (připravených) kontejnerů.
]]
local function add_emerged(container_id, attempt_index, insert_first)
    if internal.is_container_emerged(container_id) then
        storage:set_string(container_id.."_next_free", ";")
        local old_queue = internal.get_emerged_queue()
        core.log("action", "[ch_containers] container "..container_id.." emerged, will put it to the queue (old queue length was "..#old_queue..")")
        if old_queue[1] == nil then
            -- prázdná fronta, speciální případ
            storage:set_string("next_free", container_id)
        elseif insert_first then
            -- neprázdná fronta, přidat na začátek
            storage:set_string(container_id.."_next_free", old_queue[1])
            storage:set_string("next_free", container_id)
        else
            -- neprázdná fronta, přidat na konec
            storage:set_string(old_queue[#old_queue].."_next_free", container_id)
        end
    elseif attempt_index < 10 then
        core.log("warning", "Container "..container_id.." not emerged (attempt "..attempt_index.."), will try again after 10 seconds.")
        core.after(10, add_emerged, container_id, attempt_index + 1, insert_first)
    else
        core.log("error", "Container "..container_id.." not emerged after 10 attempts!")
    end
end

local emerge_new_set = {}

-- Na náhodné nové pozici zadá operaci 'emerge'. Později se pozice přidá do fronty připravených kontejnerů.
-- Vrací vygenerované ID.
local function emerge_new()
    local container_id
    repeat
        container_id = internal.get_random_container_id()
    until not emerge_new_set[container_id] and storage:get_string(container_id.."_owner") == ""
    emerge_new_set[container_id] = true
    local minp, maxp = get_container_by_id(container_id)
    if minp == nil then
        core.log("error", "emerge_new() failed for container_id '"..container_id.."'!")
        return -- error!
    end
    minp.x = minp.x - 16
    minp.y = minp.y - 16
    minp.z = minp.z - 16
    maxp.x = maxp.x + 16
    maxp.y = maxp.y + 16
    maxp.z = maxp.z + 16
    core.log("action", "[ch_containers] starting emerging area: x("..minp.x..".."..maxp.x.."), y("..minp.y..".."..maxp.y.."), z("..
        minp.z..".."..maxp.z..") for container "..container_id)
    core.emerge_area(minp, maxp)
    core.after(10, add_emerged, container_id, 1)
    return container_id
end

--[[
    Na zadané pozici zadá operaci 'emerge'. Později se pozice přidá na začátek(!) fronty připravených kontejnerů.
    Vrací:
    success, error_message
]]
local function emerge(container_id)
    assert(container_id)
    local minp, maxp = get_container_by_id(container_id)
    if minp == nil then
        return false, "Není platné container_id!"
    end
    if storage:get_string(container_id.."_owner") ~= "" then
        return false, "Kontejner již existuje a patří postavě "..ch_core.prihlasovaci_na_zobrazovaci(storage:get_string(container_id.."_owner"))
    end
    if storage:get_string(container_id.."_next_free") ~= "" then
        return false, "Kontejner již je ve frontě připravených kontejnerů."
    end
    if emerge_new_set[container_id] then
        return false, "Operace emerge na daný kontejner již byla spuštěna!"
    end
    emerge_new_set[container_id] = true
    minp.x = minp.x - 16
    minp.y = minp.y - 16
    minp.z = minp.z - 16
    maxp.x = maxp.x + 16
    maxp.y = maxp.y + 16
    maxp.z = maxp.z + 16
    core.log("action", "[ch_containers] starting emerging area: x("..minp.x..".."..maxp.x.."), y("..minp.y..".."..maxp.y.."), z("..
        minp.z..".."..maxp.z..") for container "..container_id)
    core.emerge_area(minp, maxp)
    core.after(5, add_emerged, container_id, 1, true)
    return container_id
end

--[[
    Je-li fronta připravených kontejnerů příliš krátká, zavolá emerge_new() pro její prodloužení.
    Toto opakuje každou sekundu, dokud se nedosáhne požadované délky.
]]
local function ensure_free_queue_length()
    local queue = internal.get_emerged_queue()
    if #queue >= free_queue_length then
        return
    end
    local new_id = emerge_new()
    if new_id == nil then
        return -- error
    end
    core.log("action", "[ch_containers] ensure_free_queue_length() will emerge container '"..new_id..
        "', because the queue length is only "..#queue)
    core.after(1, ensure_free_queue_length)
end

--[[
    Pomocná funkce, která se spouští před zahájením běhu světa.
    Načítá perzistentní data.
]]
local function on_mods_loaded()
    core.after(1, ensure_free_queue_length)
    local owners = storage:get_string("owners"):split("|", false)
    local new_data = {}
    local owner_count, total_count = 0, 0
    for _, owner in ipairs(owners) do
        local data = storage:get_string("cdata_"..owner)
        if data ~= "" then
            local t = core.deserialize(data)
            if t == nil then
                core.log("error", "[ch_containers] Data from 'cdata_"..owner.."' not deserialized: >>>"..data.."<<<")
            else
                assert(type(t) == "table")
                new_data[owner] = t
                owner_count = owner_count + 1
                total_count = total_count + #t
                for _, record in ipairs(t) do
                    if storage:get_string(record.id.."_owner") ~= owner then
                        core.log("error", "Owner inconsistency for container '"..record.id..": '"..storage:get_string(record.id.."_owner")..
                            "' in metadata, but '"..owner.."' in a table!")
                    end
                end
            end
        end
    end
    container_data = new_data
    core.log("action", "[ch_containers] "..total_count.." containers of "..owner_count.." owners loaded.")
end
core.register_on_mods_loaded(on_mods_loaded)



-- INTERNÍ FUNKCE
-- =================================================

--[[
    owner = string,

    Vrací seznam dat kontejnerů dané postavy.
    Je v podstatě bezpečným obalem nad: container_data[owner].
    Pokud takový seznam dosud neexistuje, vytvoří ho.
]]
function internal.get_containers(owner)
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
local get_containers = internal.get_containers

--[[
    owner = string or nil,

    Uloží data kontejnerů dané postavy, nebo všech postav.
]]
function internal.save_container_data(owner)
    if owner == nil then
        -- uložit vše:
        for xowner, _ in pairs(container_data) do
            internal.save_container_data(xowner)
        end
        return
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
local save_container_data = internal.save_container_data

-- Vrátí platné ID náhodného kontejneru. Kontejner může a nemusí existovat.
function internal.get_random_container_id()
    return string.format("c%03x%03x%03x",
        (x_min + x_scale * math.random(0, x_count - 1) + 32768) / 16,
        (y_min + y_scale * math.random(0, y_count - 1) + 32768) / 16,
        (z_min + z_scale * math.random(0, z_count - 1) + 32768) / 16)
end

-- Je-li pozice uvnitř některého kontejneru (nemusí existovat), vrátí jeho ID, jinak vrátí nil.
function internal.get_container_id(pos, arg)
    local x, y, z = math.floor(pos.x), math.floor(pos.y), math.floor(pos.z)
    local rx, ry, rz = (x - x_min) % x_scale, (y - y_min) % y_scale, (z - z_min) % z_scale
    if
        x_min <= x and x < x_min + x_scale * x_count and
        y_min <= y and y < y_min + y_scale * y_count and
        z_min <= z and z < z_min + z_scale * z_count and
        rx < c_width and
        ry < c_height and
        rz < c_width
    then
        x = (x - rx + 32768) / 16
        y = (y - ry + 32768) / 16
        z = (z - rz + 32768) / 16
        assert(x == math.floor(x))
        assert(y == math.floor(y))
        assert(z == math.floor(z))
        assert(0 <= x and x <= 0xfff)
        assert(0 <= y and y <= 0xfff)
        assert(0 <= z and z <= 0xfff)
        return string.format("c%03x%03x%03x", x, y, z)
    end
end

--[[ Self-test:
if true then
    local minp, maxp = get_container_by_id("c7108da710")
    assert(minp.x == -3840)
    assert(minp.y == 3488)
    assert(minp.z == -3840)
    local id = internal.get_container_id(minp)
    assert(id == "c7108da710")
end
for i = 1, 4 do
    local id = internal.get_random_container_id()
    local minp, maxp = get_container_by_id(id)
    local id1 = internal.get_container_id(minp, "id1")
    local id2 = internal.get_container_id(maxp, "id2")
    local id3 = internal.get_container_id(vector.offset(maxp, 63/64, 63/64, 63/64), "id3")
    local id4 = internal.get_container_id(vector.offset(maxp, 1, 1, 1), "id4")
    assert(id ~= nil)
    assert(id1 == id)
    assert(id2 == id)
    assert(id3 == id)
    assert(id4 == nil)
end
]]


--[[
    Vrací:
    - true, pokud je oblast zadaného kontejneru zcela dostupná (načtená a vygenerovaná).
    - false, pokud není
    - nil, pokud zadané ID nepojmenovává platný kontejner
]]
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

-- Vrátí seznam (table) s ID nových kontejnerů připravených k použití.
function internal.get_emerged_queue()
    local result = {}
    local s = storage:get_string("next_free")
    while s ~= "" and s ~= ";" do
        table.insert(result, s)
        s = storage:get_string(s.."_next_free")
    end
    return result
end

--[[
    new_owner = string, -- Vlastník/ice pro nový kontejner.
    container_name = string or nil, -- Název nového kontejneru (nil => použije se prázdný název).

    Vytvoří kompletní, okamžitě použitelný kontejner a nastaví mu vlastníka/ici a název.

    V případě úspěchu vrací:
    - container_id = string,
    - minp = vector,
    - maxp = vector,

    V případě neúspěchu vrací:
    - nil
    - error_message = string or nil
]]
function internal.create_new_container(new_owner, container_name)
    assert(new_owner ~= nil and new_owner ~= "")
    local containers = get_containers(new_owner)
    if containers == nil then
        return nil, "Neplatná uživatelská data" -- pravděpodobně chybné uživatelské jméno
    end

    -- naplánovat vygenerování dalšího kontejneru do fronty:
    emerge_new()

    -- vzít kontejner z fronty:
    local new_id = storage:get_string("next_free")
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
    -- print("WILL GENERATE CONTAINER "..new_id.." at "..core.pos_to_string(minp)..".."..core.pos_to_string(maxp))
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
    core.bulk_set_node(floor_nodes, {name = "ch_containers:floor", param2 = 247})
    core.bulk_set_node(wall_nodes, {name = "ch_containers:wall", param2 = 247})
    core.bulk_set_node(cp_nodes, {name = "ch_containers:control_panel", param2 = 156})
    -- zapsat kontejner do seznamu:
    table.insert(containers, {id = new_id, name = container_name or ""})
    save_container_data(new_owner)
    -- print("create_new_container("..new_owner..", "..(container_name or "nil").." finished.")
    return new_id, minp, maxp
end

--[[
    owner = string or nil,

    Vrátí počet kontejnerů daného vlastníka/ice, nebo celkový počet všech vlastněných kontejnerů.
]]
function internal.get_container_count(owner)
    if owner ~= nil then
        local containers = get_containers(owner)
        if containers ~= nil then
            return #containers
        else
            return 0
        end
    else
        local result = 0
        for _, containers in pairs(container_data) do
            result = result + #containers
        end
        return result
    end
end

--[[
    owner = string or nil, -- konkrétní vlastník/ice; není-li zadán, vrátí všechny kontejnery
    include_public_containers = bool or nil, -- je-li true, přidá také veřejné kontejnery ostatních vlastníků/ic
        (platí pouze, pokud owner == nil)

    Vrací seznam, kde každá položka obsahuje:
    {
        id = string, -- ID kontejneru
        name = string, -- název kontejneru
        owner = string, -- vlastník/ice kontejneru
        index = int, -- index v seznamu daného vlastníka/ice
        ttl = float or nil, -- pro veřejné kontejnery: jak dlouho ještě budou veřejné (v sekundách)
    }
]]
function internal.get_container_list(owner, include_public_containers)
    local result = {}
    if owner ~= nil then
        local containers = get_containers(owner)
        if containers ~= nil then
            for i, container in ipairs(containers) do
                result[i] = {
                    id = container.id,
                    name = container.name,
                    owner = owner,
                    index = i,
                }
            end
        end
        if include_public_containers then
            local pc, now = get_public_containers()
            for _, record in ipairs(pc) do
                if record.owner ~= owner then
                    local index = 0
                    local other_containers = get_containers(record.owner)
                    if other_containers ~= nil then
                        for i, container in ipairs(other_containers) do
                            if container.id == record.id then
                                index = i
                                break
                            end
                        end
                    end
                    table.insert(result, {
                        id = record.id,
                        name = record.name,
                        owner = record.owner,
                        index = index,
                        ttl = (record.public_until - now) / 1000000,
                    })
                end
            end
        end
    else
        for xowner, containers in pairs(container_data) do
            for i, container in ipairs(containers) do
                table.insert(result, {
                    id = container.id,
                    name = container.name,
                    owner = xowner,
                    index = i,
                })
            end
        end
    end
    return result
end

--[[
    Vrátí, zda container_id označuje veřejný kontejner s alespoň zadanou dobou životnosti.
]]
function internal.is_public_container(container_id, min_ttl)
    if container_id == nil or container_id == "" then
        return false
    end
    local ttl = find_public_container(container_id, "ttl")
    return ttl and (min_ttl == nil or ttl >= min_ttl)
end

--[[
    Vrací základní informace o daném kontejneru:
    {
        id = string, -- container_id
        name = string, -- jméno kontejneru
        owner = string, -- vlastník/ice kontejneru,
        index = int, -- index kontejneru v owner_data,
        pos = vector, -- základní (minp) pozice kontejneru
        is_public = int or nil, -- je-li kontejner veřejný, index do public_containers
    }
    Pokud kontejner neexistuje, vrátí nil.
]]
function internal.get_basic_info(container_id)
    local owner = storage:get_string(container_id.."_owner")
    if owner == "" then
        return nil -- kontejner neexistuje
    end
    for i, cdata in ipairs(get_containers(owner) or {}) do
        if cdata.id == container_id then
            return {
                id = container_id,
                name = cdata.name,
                owner = owner,
                index = i,
                pos = assert(get_container_by_id(container_id)),
                is_public = find_public_container(container_id, "index"),
            }
        end
    end
    core.log("warning", "[ch_containers] Container "..container_id.." is not known, but has owner '"..owner.."'!")
    return nil -- kontejner nenalezen
end

--[[
    Vrací podrobné informace o daném kontejneru.
    (Zatím totéž, co get_basic_info().)
]]
function internal.get_full_info(container_id)
    local owner = storage:get_string(container_id.."_owner")
    if owner == "" then
        return nil -- kontejner neexistuje
    end
    for i, cdata in ipairs(get_containers(owner) or {}) do
        if cdata.id == container_id then
            return {
                id = container_id,
                name = cdata.name,
                owner = owner,
                index = i,
                pos = assert(get_container_by_id(container_id)),
                is_public = find_public_container(container_id, "index"),
                -- TODO...
            }
        end
    end
    core.log("warning", "[ch_containers] Container "..container_id.." is not known, but has owner '"..owner.."'!")
    return nil -- kontejner nenalezen
end

--[[
    container_id = string, -- ID kontejneru
    player = PlayerRef, -- hráčská postava
    teleport_options = table or nil, -- nastavení pro ch_core.teleport_player()

    Přenese zadanou postavu do zadaného kontejneru, pokud ten existuje.

    Vrací true v případě úspěchu; nil, error_message v případě selhání.
]]
function internal.enter_container(container_id, player, teleport_options)
    if player == nil then
        return false, "Vnitřní chyba: hráčská postava není nastavena"
    end
    if not core.is_player(player) then
        return false, "Hráčská postava není platná."
    end
    if player:get_attach() ~= nil then
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

--[[
    player = PlayerRef, -- hráčská postava
    teleport_options = table or nil, -- nastavení pro ch_core.teleport_player()

    Přenese zadanou postavu na uloženou pozici přístupového bodu.

    Vrací true v případě úspěchu; nil, error_message v případě selhání.
]]
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

--[[
    Uvolní zadaný kontejner od jeho vlastníka/ice a vloží ho do fronty k použití jako prázdný.
    Kontejner nesmí být v té chvíli veřejný.
]]
function internal.release_container(container_id)
    local minp, maxp = internal.get_container_by_id(container_id)
    if minp == nil or maxp == nil then
        return false, "Neplatný kontejner."
    end
    if find_public_container(container_id, "bool") then
        return false, "Kontejner je veřejný."
    end
    local owner = storage:get_string(container_id.."_owner")
    if owner == "" then
        if storage:get_string(container_id.."_next_free") == "" then
            return false, "Kontejner neexistuje."
        else
            return false, "Kontejner již je volný."
        end
    end
    local data = internal.get_containers(owner)
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

    local owner_data = internal.get_containers(info.owner)
    local owner_to_save_1, owner_to_save_2
    local will_change_name = properties.name ~= nil and properties.name ~= info.name
    local will_change_owner = properties.owner ~= nil and properties.owner ~= info.owner
    local new_owner_data

    if will_change_owner then
        if ch_core.offline_charinfo[properties.owner] == nil then
            return false, "Postava '"..properties.owner.."' neexistuje!"
        end
        new_owner_data = internal.get_containers(properties.owner)
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
        for _, pc_record in ipairs(public_containers) do
            if pc_record.id == container_id then
                pc_record.owner = info.owner
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

local def = {
    params = "<id_kontejneru>",
    description = "Zadá k vytvoření požadovaný kontejner. Pouze pro účely testování a ladění serveru.",
    privs = {server = true},
    func = function(player_name, param)
        return emerge(param)
    end,
}

core.register_chatcommand("vytvořkontejner", def)
core.register_chatcommand("vytvorkontejner", def)

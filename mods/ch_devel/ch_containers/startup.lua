local internal = ...

local storage = assert(internal.storage)
local free_queue_length = 20

-- At startup, 10 containers should be always emerged.
core.register_on_mods_loaded(function()
    local queue = internal.get_emerged_queue()
    if #queue < free_queue_length then
        local set = {}
        for i = 1, free_queue_length - #queue do
            local new_id = internal.get_random_container_id()
            while storage:get_string(new_id.."_owner") ~= "" or set[new_id] do
                new_id = internal.get_random_container_id()
            end
            core.after(i, internal.emerge_new, new_id)
            set[new_id] = true
        end
    end
    internal.load_container_data()
end)


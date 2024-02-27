
-- Register wrench support for technic_chests

local splitstacks = wrench.has_pipeworks and wrench.META_TYPE_INT

local chests_meta = {
	iron = {
		infotext = wrench.META_TYPE_STRING,
		formspec = wrench.META_TYPE_STRING,
		sort_mode = wrench.META_TYPE_INT,
		splitstacks = splitstacks,
	},
	copper = {
		infotext = wrench.META_TYPE_STRING,
		formspec = wrench.META_TYPE_STRING,
		sort_mode = wrench.META_TYPE_INT,
		autosort = wrench.META_TYPE_INT,
		splitstacks = splitstacks,
	},
	silver = {
		infotext = wrench.META_TYPE_STRING,
		formspec = wrench.META_TYPE_STRING,
		sort_mode = wrench.META_TYPE_INT,
		autosort = wrench.META_TYPE_INT,
		splitstacks = splitstacks,
	},
	gold = {
		infotext = wrench.META_TYPE_STRING,
		formspec = wrench.META_TYPE_STRING,
		sort_mode = wrench.META_TYPE_INT,
		autosort = wrench.META_TYPE_INT,
		splitstacks = splitstacks,
		color = wrench.META_TYPE_INT,
	},
	mithril = {
		infotext = wrench.META_TYPE_STRING,
		formspec = wrench.META_TYPE_STRING,
		sort_mode = wrench.META_TYPE_INT,
		autosort = wrench.META_TYPE_INT,
		channel = wrench.META_TYPE_STRING,
		send_put = wrench.META_TYPE_INT,
		send_take = wrench.META_TYPE_INT,
		send_inject = wrench.META_TYPE_INT,
		send_pull = wrench.META_TYPE_INT,
		send_overflow = wrench.META_TYPE_INT,
		splitstacks = splitstacks,
	},
}

local function with_owner_field(metas)
	local result = table.copy(metas)
	result.owner = wrench.META_TYPE_STRING
	result.owner2 = wrench.META_TYPE_STRING
	return result
end

local function register_chests(material, color)
	local lists_ignore = (material ~= "iron" and material ~= "copper") and {"quickmove"} or nil
	wrench.register_node("technic:"..material.."_chest"..color, {
		lists = {"main"},
		lists_ignore = lists_ignore,
		metas = chests_meta[material],
	})
	wrench.register_node("technic:"..material.."_protected_chest"..color, {
		lists = {"main"},
		lists_ignore = lists_ignore,
		metas = chests_meta[material],
	})
	wrench.register_node("technic:"..material.."_locked_chest"..color, {
		lists = {"main"},
		lists_ignore = lists_ignore,
		metas = with_owner_field(chests_meta[material]),
		owned = true,
	})
end

for material in pairs(chests_meta) do
	register_chests(material, "")
end

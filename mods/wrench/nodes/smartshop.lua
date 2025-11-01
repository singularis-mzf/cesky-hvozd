-- Register nodes from smartshop

local shops = {
	"smartshop:shop",
	"smartshop:shop_admin",
	"smartshop:shop_empty",
	"smartshop:shop_full",
	"smartshop:shop_used",
}

local shop_def = {
	lists = {
		"main",
		"give1", "give2", "give3", "give4", "give5", "give6", "give7", "give8", "give9", "give10",
		"pay1", "pay2", "pay3", "pay4", "pay5", "pay6", "pay7", "pay8", "pay9", "pay10",
	},
	metas = {
		autoprices = wrench.META_TYPE_INT,
		constructed_at = wrench.META_TYPE_IGNORE,
		freebies = wrench.META_TYPE_INT,
		icons = wrench.META_TYPE_INT,
		infotext = wrench.META_TYPE_STRING,
		item_refill = wrench.META_TYPE_STRING,
		item_send = wrench.META_TYPE_STRING,
		owner = wrench.META_TYPE_STRING,
		purchase_history = wrench.META_TYPE_STRING,
		refund = wrench.META_TYPE_STRING,
		shared = wrench.META_TYPE_INT,
		shop_title = wrench.META_TYPE_STRING,
		strict_meta = wrench.META_TYPE_INT,
		unlimited = wrench.META_TYPE_INT,
		upgraded = wrench.META_TYPE_STRING,
	},
	owned = true,
}

for _, name in ipairs(shops) do
	wrench.register_node(name, shop_def)
end

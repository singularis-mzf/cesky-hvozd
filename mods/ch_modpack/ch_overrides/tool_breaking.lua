--[[
TOOL BREAKING
]]

local empty_table = {}
local counter = 0

local function tool_after_use(itemstack, user, node, digparams)
	local player_name = user and user:get_player_name()
	if player_name ~= nil and player_name ~= "" and not minetest.is_creative_enabled(player_name) then
		local old_wear = itemstack:get_wear()
		if old_wear > 62000 or old_wear + 7 * digparams.wear > 65535 then
			local ndef = minetest.registered_tools[itemstack:get_name()]
			if ndef and ndef.sound and ndef.sound.breaks then
				minetest.sound_play(ndef.sound.breaks, {to_player = player_name, gain = math.min(1.0, math.max(0.0, (old_wear + digparams.wear - 62000) / 3535))}, true)
			end
			ch_core.systemovy_kanal(player_name, "* Váš nástroj se začíná rozpadat. Opravte ho, než bude pozdě!")
		end
		itemstack:add_wear(digparams.wear)
	end
	return itemstack
end

local override = {after_use = tool_after_use}

for k, def in pairs(minetest.registered_tools) do
	if k:sub(1,8) == "default:" or k:sub(1,8) == "farming:" or k:sub(1,10) == "ch_extras:" or k:sub(1,9) == "moreores:" then
		local groups = def.groups or empty_table
		if groups.sword or groups.axe or groups.pickaxe or groups.shovel or groups.hoe or groups.sickle or groups.multitool then
			if def.after_use ~= nil then
				minetest.log("warning", "tool "..k.." already has .after_use() callback!")
			else
				minetest.override_item(k, override)
				counter = counter + 1
			end
		end
	end
end

local tdef = minetest.registered_tools["farming:scythe_mithril"]
if tdef ~= nil then
	local old_on_use = tdef.on_use
	override = {
		on_use = function(itemstack, user, pointed_thing)
			if pointed_thing.type == "node" then
				tool_after_use(ItemStack(itemstack), user, minetest.get_node(pointed_thing.under), {wear = 437}) -- 437 = 150 uses
			end
			return old_on_use(itemstack, user, pointed_thing)
		end,
	}
	minetest.override_item("farming:scythe_mithril", override)
	counter = counter + 1
end

print("[ch_overrides/tool_breaking] "..counter.." tools overriden.")

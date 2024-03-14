local internal = ...

local has_pipeworks = minetest.get_modpath("pipeworks")
local has_unifieddyes = minetest.get_modpath("unifieddyes")

--[[
	on_construct = internal.on_construct,
	preserve_metadata = internal.preserve_metadata,
	after_place_node = internal.after_place_node,
	after_dig_node = internal.after_dig_node,
	can_dig = internal.can_dig,
	on_rightclick = internal.on_rightclick,
	allow_metadata_inventory_move = internal.allow_metadata_inventory_move,
	allow_metadata_inventory_put = internal.allow_metadata_inventory_put,
	allow_metadata_inventory_take = internal.allow_metadata_inventory_take,
	on_metadata_inventory_move = internal.on_metadata_inventory_move,
	on_metadata_inventory_put = internal.on_metadata_inventory_put,
	on_metadata_inventory_take = internal.on_metadata_inventory_take,
]]

local right_to_index = {
	view = 1,
	sort = 4,
	put = 7,
	take = 10,
	dig = 13,
	set = 16,
}

function internal.check_right(meta, player_name, right)
	-- TODO: optimize
	local rights = internal.get_rights(meta, player_name)
	return rights[right]
end

function internal.get_rights(meta, player_name)
	local is_owner, is_group

	if meta:get_int("ch_given") ~= 0 then
		is_owner = meta:get_string("ch_given_by") == player_name or meta:get_string("ch_given_to") == player_name
	else
		is_owner = meta:get_string("owner") == player_name
	end

	if not is_owner then
		is_group = string.find(meta:get_string("agroup"), "|"..string.lower(player_name).."|") ~= nil
	end

	local player_role = ch_core.get_player_role(player_name)
	if player_role == "new" then
		return {
			view = false,
			sort = false,
			put = false,
			take = false,
			dig = false,
			set = false,

			admin = false,
			owner = is_owner,
			group = is_group,
		}
	elseif player_role == "admin" then
		return {
			view = true,
			sort = true,
			put = true,
			take = true,
			dig = true,
			set = true,

			admin = true,
			owner = is_owner,
			group = is_group,
		}
	else
		local s = meta:get_string("rights")
		if not is_owner then
			local i = ifthenelse(is_group, 2, 3)
			s = s:sub(i, -1)
		end
		return {
			view = s:sub(1, 1) == '1',
			sort = s:sub(4, 4) == '1',
			put = s:sub(7, 7) == '1',
			take = s:sub(10, 10) == '1',
			dig = s:sub(13, 13) == '1',
			set = s:sub(16, 16) == '1',
			admin = false,
			owner = is_owner,
			group = is_group,
		}
	end
end

function ch_chest.init(pos, node, width, height, title)
end

--[[

Dokumentace metadat:

inventory main — hlavní inventář truhly, může mít libovolnou velikost; výchozí velikost je 8*4
inventory qmove — speciální inventář sloužící k rychlému přesunu dávek stejného typu, velikost 1

int width — šířka inventáře pro zobrazení; >= 1
int height — výška inventáře pro zobrazení; >= 1
int splitstacks — pro mód pipeworks: dovolí dělení dávek při vstupu z rour
int autosort — je povoleno automatické řazení? 0 = ne, 1 = ano
int sort_mode — režim řazení (0 = výchozí režim)
int ch_given — 0 = truhla není darovaná; 1 = truhla je darovaná neanonymně; 2 = darovaná anonymně
string owner — postava s plnými právy k truhle; v případě darované truhly obdarovaná postava
string agroup_raw — seznam postav ve skupině, jak ho zadal vlastník/ice
string agroup — seznam postav ve skupině v normalizovaném tvaru (|postava1|postava2|)
string uuid — jedinečné ID truhly (textové)
string rights — řetězec, kde jednotlivé znaky reprezentují přístupová práva
string title — název truhly
string infotext
string ch_given_by — u darované truhly obsahuje jméno darující postavy
string ch_given_to — u darované truhly obsahuje jméno obdarované postavy

pořadí práv:
1,2,3 view (zobrazit)
4,5,6 sort (řadit)
7,8,9 put (vkládat)
10,11,12 take (brát)
13,14,15 dig (vytěžit)
16,17,18 set (nastavit)

]]

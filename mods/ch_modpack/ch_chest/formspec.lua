local internal = ...

local ifthenelse = ch_core.ifthenelse
local has_moreores = minetest.get_modpath("moreores")
local has_pipeworks = minetest.get_modpath("pipeworks")
local has_unifieddyes = minetest.get_modpath("unifieddyes")
local F = minetest.formspec_escape

local NOT_GIVEN = 0
local GIVEN_OPENLY = 1
local GIVEN_ANONYMOUSLY = 2

--[[

Dokumentace metadat:

inventory main — hlavní inventář truhly, může mít libovolnou velikost; výchozí velikost je 8*4
inventory qmove — speciální inventář sloužící k rychlému přesunu dávek stejného typu, velikost 1
inventory upgrades — obsahuje kovové bloky pro zvýšení kapacity truhly (velikost 5)

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

--[[
	custom_state = {
		pos = pos,
		player_name = string,
		bag = int, -- 0 = hl. inventář, -1 = žádný inventář, 1..6 = batoh 1 až 6
		page = int, -- 0 = inventář, 1 = nastavení
	}
]]

function internal.get_formspec(custom_state)
	local pos = custom_state.pos
	local player_name = custom_state.player_name
	local player = minetest.get_player_by_name(player_name)
	local node = minetest.get_node(pos)
	local meta = minetest.get_meta(pos)
	if minetest.get_item_group(node.name, "ch_chest") == 0 or player == nil then
		return nil
	end
	local is_admin = ch_core.get_player_role(player_name) == "admin"
	local player_rights = internal.get_rights(meta, player_name)
	local player_bags = unified_inventory.get_bags_info(player)
	local chest_title = meta:get_string("title")
	local chest_width = math.max(1, meta:get_int("width"))
	local chest_height = math.max(1, meta:get_int("height"))
	local chest_inv = "nodemeta:"..pos.x.."\\,"..pos.y.."\\,"..pos.z
	local formspec = {
		ch_core.formspec_header{
			formspec_version = 6,
			size = {26, 16},
			auto_background = true,
		},
		-- settings taken from Technic Chests mod:
		"style_type[list;spacing=0.2,0.2]",
		"listcolors[#7b7b7b;#909090;#000000;#6e823c;#ffffff]",
	}
	local function a(s)
		table.insert(formspec, s)
	end
	if player_rights.set then
		a("button[10.75,0.25;2,0.75;sw_obsah;obsah truhly]"..
		  "button[13,0.25;2,0.75;sw_nastaveni;nastavení]")
	end

	a("item_image[0.25,0.25;1,1;"..F(node.name).."]")
	if custom_state.page == 0 then
		-- obsah truhly
		a("label[1.5,0.75;"..F(chest_title).." — obsah truhly]")

		if chest_height > 6 then
			a("scroll_container[0.25,1.5;25,7.25;sb;vertical]")
		else
			a("container[0.25,1.5]")
		end
		--box[0,0;50,50;#ff0000]
		a("list["..chest_inv..";main;0,0;"..chest_width..","..chest_height..";0]")
		if chest_height > 6 then
			a("scroll_container_end[]"..
			  "scrollbaroptions[max=50]".. -- [ ] TODO!
			 "scrollbar[25.25,1.5;0.5,7.25;vertical;sb;0]")
		else
			a("container_end[]")
		end
		a("button[1.75,9.5;3.5,1;tochestex;Přesunout do truhly věci\\,\njaké už tam jsou]"..
		  "label[1.8,11;Přesunout konkrétní:\n(pusťte pro přesun)]"..
		  "list["..chest_inv..";qmove;4,10.75;1,1;0]"..
		  "button[1.75,12.0;3.5,1;tochest;Vše z inventáře do truhly ⇈]"..
		  "button[1.75,13.25;3.5,1;fromchest;Vše z truhly do inventáře ⇊]")

	elseif custom_state.page == 1 and player_rights.set then
		-- nastavení
		a("label[1.5,0.75;"..F(chest_title).." — nastavení truhly]"..
		  "label[0.25,1.75;kapacita:]"..
		  "list["..chest_inv..";upgrades;0.25,2;1,"..(#internal.upgrades)..";0]")
		for i, upgrade in ipairs(internal.upgrades) do
			a("item_image[1.4,"..(0.75 + 1.25*i)..";0.5,0.5;"..F(upgrade.items[1]).."]"..
			  "label[1.425,"..(1.5 + 1.25 * i)..";"..upgrade.width.."×"..upgrade.height.."]")
		end
		a("field[3,1.9;4,0.5;title;název truhly:;"..F(chest_title).."]"..
		  "button[7.25,1.8;2,0.75;set_title;nastavit]"..
		  "label[3,3;režim řazení:]"..
		  "dropdown[3,3.2;4,0.5;sort_mode;výchozí režim;1;true]"..
		  "checkbox[3,4;autosort;automatické řazení]"..
		  "checkbox[3,4.5;splitstacks;povolit dělení dávek při vstupu z rour]")

		if player_rights.admin or player_rights.owner then
			a("box[9.75,1.25;4.5,8;#0000ff99]"..
			  "label[10,1.75;přístupová práva:]"..
			  "label[11.5,2.25;vlas.]"..
			  "label[12.25,2.25;skup.]"..
			  "label[13,2.25;ost.]"..

			  "label[10,2.75;zobrazit]"..
			  "label[10,3.25;řadit]"..
			  "label[10,3.75;vkládat]"..
			  "label[10,4.25;brát]"..
			  "label[10,4.75;vytěžit]"..
			  "label[10,5.25;nastavit]")

			local s = meta:get_string("rights")
			for x = 0, 2 do
				for y = 0, 5 do
					local i = 3 * y + x + 1
					a("checkbox["..(11.5 + x * 0.75)..","..(2.75 + y * 0.5)..";right_"..i..";;"..ifthenelse(s:sub(i, i) == "1", "true", "false").."]")
				end
			end
			a("textarea[10,6;4,3;group_members;skupina:;"..F(meta:get_string("agroup_raw")).."]")

			local given_state = meta:get_int("ch_given")
			if player_rights.admin then
				-- zobrazení pro Administraci:
				-- [ ] TODO
			elseif given_state == NOT_GIVEN then
				-- nedarovaná truhla, vlastník/ice ji může darovat
				a("label[14.5,1.75;darovat:]"..
				  "field[14.5,2.25;3,0.5;darovat_komu;komu:;]"..
				  "checkbox[14.5,3;darovat_anonym;anonymně;false]"..
				  "tooltip[anonymne;zaškrtnete-li toto pole, vaše jméno na truhle nebude zobrazeno\\,\ntakže adresát/ka nebude vědět\\, od koho truhlu dostal/a]"..
				  "button[14.5,3.25;3,0.75;darovat;darovat]") -- /přijmout/zrušit
			elseif player_name == meta:get_string("ch_given_by") then
				-- darovaná truhla; původní vlastník/ice může darování zrušit
				-- [ ] TODO
			else
				-- darovaná truhla; adresát/ka ji může přijmout
				a("label[14.5,1.75;tato truhla vám byla darována]")
				if given_state == GIVEN_OPENLY then
					a("label[14.5,2.25;darováno od: "..F(ch_core.prihlasovaci_na_zobrazovaci(meta:get_string("ch_given_by"))).."]")
				end
				a("button[14.5,3.25;3,0.75;dar_prijmout;přijmout]") -- /přijmout/zrušit
			end








	end

	if custom_state.bag == 0 then
		-- hlavní inventář
		a("list[current_player;main;5.5,9.5;8,4;0]"..
		  "listring[current_player;main]")
	elseif custom_state.bag >= 1 and custom_state.bag <= 6 and player_bags["bag"..custom_state.bag] ~= nil then
		-- batoh
		local current_bag = player_bags["bag"..custom_state.bag]
		a("list[current_player;bag"..custom_state.bag.."contents;5.5,9.5;9,5;0]"..
		  "listright[current_player;bag"..custom_state.bag.."contents]")
	end

	a("button[15.5,9.5;4,0.75;hlinventar;hlavní inventář]")
	for i = 1, 6 do
		local current_bag = player_bags["bag"..i]
		if current_bag ~= nil then
			local x, y
			if i < 4 then
				x = "15.5"
				y = tostring(9.5 + i)
			else
				x = "20"
				y = tostring(5.5 + i)
			end
			a("button["..x..","..y..";4,0.75;batoh"..i..";"..F(current_bag.title).."]")
		end
	end
	a("button[20,12.5;4,0.75;zadnyinv;žádný inventář]")
	a("button_exit[25,0.25;0.75,0.75;zavrit;x]")
	return table.concat(formspec)
end

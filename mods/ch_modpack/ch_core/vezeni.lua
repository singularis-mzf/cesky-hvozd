ch_core.require_submod("vezeni", "chat")
ch_core.require_submod("vezeni", "data")
ch_core.require_submod("vezeni", "lib")
ch_core.require_submod("vezeni", "privs")
ch_core.require_submod("vezeni", "hud")

local trest_min = -100
local trest_max = 1000000

local vezeni_data = ch_core.vezeni_data

local prohledavane_inventare = {
	"main",
	"craft",
	"bag1", "bag2", "bag3", "bag4", "bag5", "bag6", "bag7", "bag8",
}

local povolene_krumpace = {}

for _, n in ipairs({"default:pick_steel", "default:pick_bronze",
                    "moreores:pick_silver", "moreores:pick_mithril", "default:pick_mese", "default:pick_diamond"}) do
	povolene_krumpace[n] = ItemStack(n)
end

local function nacist_vezeni()
	local offline_charinfo = ch_core.get_offline_charinfo("Administrace")
	local s = offline_charinfo.data_vezeni
	if s and s ~= "" then
		ch_core.vezeni_data = minetest.deserialize(s, true)
		vezeni_data = ch_core.vezeni_data
	end
	return offline_charinfo
end
nacist_vezeni()

local function ulozit_vezeni()
	local offline_charinfo = ch_core.get_offline_charinfo("Administrace")
	offline_charinfo.data_vezeni = minetest.serialize(ch_core.vezeni_data)
	ch_core.save_offline_charinfo("Administrace", "data_vezeni")
	return offline_charinfo
end

function ch_core.umistit_vezeni(volajici, pos1, pos2, stred)
	local pos_min, pos_max = ch_core.positions_to_area(pos1, pos2)
	if not ch_core.pos_in_area(stred, pos_min, pos_max) then
		if volajici and volajici ~= "" then
			ch_core.systemovy_kanal(volajici, "Pozice středu leží mimo nastavovanou oblast vězení!")
		end
		return false
	end

	vezeni_data.min = pos_min
	vezeni_data.max = pos_max
	vezeni_data.stred = stred
	ulozit_vezeni()
	if volajici and volajici ~= "" then
		ch_core.systemovy_kanal(volajici, "Nastaveno.")
	end
	return true
end

function ch_core.je_ve_vezeni(pos)
	return ch_core.pos_in_area(pos, vezeni_data.min, vezeni_data.max)
end

function ch_core.vezeni_kontrola_krumpace(player)
	if not player:is_player() then
		return false
	end
	local inv = player:get_inventory()
	if not inv then
		return false
	end
	for _, listname in ipairs(prohledavane_inventare) do
		for itemname, stack in pairs(povolene_krumpace) do
			if inv:contains_item(listname, stack, false) then
				minetest.log("action", "Player "..player:get_player_name().." already has a pickaxe "..itemname.." in the inventory list "..listname..".")
				return true
			end
		end
	end
	player:set_wielded_item(povolene_krumpace["default:pick_steel"])
	minetest.log("action", "Player "..player:get_player_name().." was given a steel pickaxe at a prison check.")
	return true
end

-- PRISON STONE
local box = {
	type = "fixed",
	fixed = {-0.4, -0.5, -0.4, 0.4, 0.4, 0.4}
}
local def = {
	description = "vězeňský kámen",
	drawtype = "nodebox",
	node_box = box,
	selection_box = box,
	tiles = {"default_stone.png"},
	paramtype2 = "none",
	groups = {cracky = 1},
	drop = "default:stone",
	sounds = default.node_sound_stone_defaults(),

	after_placenode = function(pos, placer)
		local meta = minetest.get_meta(pos)
		meta:set_string("infotext", "Vězeňský kámen. Těžte tento kámen železným nebo lepším krumpáčem pro odpykání si trestu.")
	end,

	can_dig = function(pos, player)
		if not ch_core.je_ve_vezeni(pos) or minetest.check_player_privs(player, "server") then
			return default.can_interact_with_node(player, pos)
		end
		local player_name = player:get_player_name()
		local tool = player:get_wielded_item():get_name() or ""

		-- require a pickaxe
		if not povolene_krumpace[tool] then
			ch_core.systemovy_kanal(player_name, "Ke snížení trestu musíte tento kámen odtěžit železným nebo lepším krumpáčem!")
			return false
		end

		local offline_charinfo = ch_core.get_offline_charinfo(player_name)
		local trest_old = offline_charinfo.trest
		ch_core.trest("", player_name, -1)
		local trest_new = offline_charinfo.trest
		if trest_new ~= trest_old then
			ch_core.systemovy_kanal(player_name, "Váš trest: "..trest_old.." >> "..trest_new)
		end
		return false
	end
}
minetest.register_node("ch_core:prison_stone", def)

local prison_bar_icon = "default_snowball.png"
local prison_bar_bgicon = nil
local prison_bar_bar = "hudbars_bar_prison.png"

local function update_hudbar(online_charinfo, trest)
	local player = minetest.get_player_by_name(online_charinfo.player_name)
	if not player then
		return false
	end
	local hudbar_id = online_charinfo.prison_hudbar
	if not hudbar_id then
		return false
	end
	if trest < 0 then
		trest = 0
	end
	local old_max = online_charinfo.last_hudbar_trest_max
	local new_max
	if not old_max or trest > old_max then
		new_max = trest
	end
	return hb.change_hudbar(player, hudbar_id, trest, new_max)
end

-- přesune online postavu do vězení
local function do_vezeni(player_name, online_charinfo)
	-- announcement
	local offline_charinfo = ch_core.offline_charinfo[player_name] or {}
	ch_core.set_temporary_titul(player_name, "ve vězení", true)
	ch_core.systemovy_kanal(player_name, "Jste ve výkonu trestu odnětí svobody. Těžte vězeňský kámen železným nebo lepším krumpáčem pro odpykání si trestu. Současná výše trestu: "..(offline_charinfo.trest or 0))

	-- teleport
	local player = minetest.get_player_by_name(player_name)
	if player and not ch_core.je_ve_vezeni(player:get_pos()) then
		player:set_pos(vezeni_data.stred)
	end

	-- HUD
	local hudbar_id = online_charinfo.prison_hudbar
	if not hudbar_id then
		hudbar_id = ch_core.try_alloc_hudbar(player)
		if hudbar_id then
			online_charinfo.prison_hudbar = hudbar_id
		end
	end
	if hudbar_id then
		online_charinfo.last_hudbar_trest_max = offline_charinfo.trest or 0
		hb.change_hudbar(player, hudbar_id, online_charinfo.last_hudbar_trest_max, online_charinfo.last_hudbar_trest_max, prison_bar_icon, prison_bar_bgicon, prison_bar_bar, "trest", 0xFFFFFF)
		update_hudbar(online_charinfo, offline_charinfo.trest or 0)
		hb.unhide_hudbar(player, hudbar_id)
	end

	-- close the door
	local door = vezeni_data.dvere and doors.get(vezeni_data.dvere)
	if door then
		minetest.after(0.5, function()
			door:close(nil)
		end)
	end
end

local function propustit_z_vezeni(player_name, online_charinfo)
	ch_core.set_temporary_titul(player_name, "ve vězení", false)
	ch_core.hide_prison_hud(minetest.get_player_by_name(player_name), online_charinfo)
	ch_core.systemovy_kanal(player_name, "Byl/a jste propuštěn/a z vězení. Nyní se můžete volně pohybovat a používat teleportační příkazy.")

	local hudbar_id = online_charinfo.prison_hudbar
	if hudbar_id then
		local player = minetest.get_player_by_name(player_name)
		if player then
			ch_core.free_hudbar(player, hudbar_id)
		end
		online_charinfo.prison_hudbar = nil
	end

	local door = vezeni_data.dvere and doors.get(vezeni_data.dvere)
	if door then
		door:open(nil)
	end
end

local function on_joinplayer(player, last_login)
	local player_name = player:get_player_name()
	local online_charinfo = ch_core.get_joining_online_charinfo(player_name)
	local offline_charinfo = ch_core.get_offline_charinfo(player_name)
	local trest = tonumber(offline_charinfo.trest or 0)

	if trest > 0 then
		do_vezeni(player_name, online_charinfo)
	end
end

minetest.register_on_joinplayer(on_joinplayer)

-- volajici = komu vypsat hlášení; "" = provést změnu potichu
function ch_core.trest(volajici, jmeno, vyse_trestu)
	local message = nil
	local result = false

	if type(vyse_trestu) ~= "number" then
		minetest.log("error", "Invalid call to ch_core.trest() with vyse_trestu of type "..type(vyse_trestu))
		return result
	end
	jmeno = ch_core.jmeno_na_prihlasovaci(jmeno)
	if not minetest.player_exists(jmeno) then
		chyba = "Postava "..jmeno.." neexistuje!"
	else
		local offline_charinfo = ch_core.get_offline_charinfo(jmeno)
		local trest = offline_charinfo.trest
		local nova_vyse = math.round(trest + vyse_trestu)
		if nova_vyse < trest_min then
			nova_vyse = trest_min
		elseif nova_vyse > trest_max then
			nova_vyse = trest_max
		end
		if trest == nova_vyse then
			message = "Aktuální výše trestu postavy "..ch_core.prihlasovaci_na_zobrazovaci(jmeno)..": "..trest
		else
			message = "Výše trestu postavy "..ch_core.prihlasovaci_na_zobrazovaci(jmeno).." změněna: "..trest.." => "..nova_vyse
			offline_charinfo.trest = nova_vyse
			ch_core.save_offline_charinfo(jmeno, "trest")
			minetest.log("action", message)

			local online_charinfo = ch_core.online_charinfo[jmeno]
			if online_charinfo then
				update_hudbar(online_charinfo, nova_vyse)

				if trest > 0 and nova_vyse <= 0 then
					propustit_z_vezeni(jmeno, online_charinfo)
				elseif trest <= 0 and nova_vyse > 0 then
					do_vezeni(jmeno, online_charinfo)
				end
			end
		end
		result = true
	end

	if message and volajici and volajici ~= "" then
		ch_core.systemovy_kanal(volajici, message)
	end
	return result
end

-- /trest
def = {
	params = "<Jméno_Postavy> <výše_trestu>",
	privs = {ban = true},
	description = "Uloží nebo promine postavě trest",
	func = function(player_name, param)
		local jmeno, vyse = param:match("^(%S+) ([-]?%d+)$")
		if not jmeno then
			return false, "Neplatný formát parametrů!"
		end
		vyse = tonumber(vyse)
		return ch_core.trest(player_name, jmeno, vyse)
	end,
}
minetest.register_chatcommand("trest", def)

-- /umístit_vězení
def = {
	params = "(<X1>, <Y1>, <Z1>) (<X2>, <Y2>, <Z2>)",
	privs = {server = true},
	description = "Nastaví pozici vězení. Při nastavování musíte stát uvnitř nastavované oblasti.",
	func = function(player_name, param)
		local pos1, pos2 = minetest.string_to_area(param)
		if not pos1 then
			return false, "Neplatný formát parametrů!"
		end
		local player = minetest.get_player_by_name(player_name)
		local stred = player:get_pos()
		return ch_core.umistit_vezeni(player_name, pos1, pos2, stred)
	end,
}
minetest.register_chatcommand("umístit_vězení", def)
minetest.register_chatcommand("umistit_vezeni", def)

-- /dveře_vězení
def = {
	params = "",
	privs = {server = true},
	description = "Nastaví pozici vězeňských dveří",
	func = function(player_name, param)
		local player = minetest.get_player_by_name(player_name)
		if not player then
			return false, "postava nenalezena!"
		end
		local pos = player:get_pos()
		if not pos then
			return false, "pozice nenalezena!"
		end
		pos = vector.round(pos)
		local door = doors.get(pos)
		if not door then
			return false, "CHYBA: na pozici "..minetest.pos_to_string(pos).." nejsou dveře!"
		end
		vezeni_data.dvere = pos
		ulozit_vezeni()
		return true, "Pozice dveří vězení nastavena na "..minetest.pos_to_string(pos)
	end
}
minetest.register_chatcommand("dveře_vězení", def)
minetest.register_chatcommand("dvere_vezeni", def)

ch_core.submod_loaded("vezeni")

ch_base.open_mod(core.get_current_modname())

local storage = core.get_mod_storage()
local time_shift = storage:get_int("time_shift")
local epoch  = 1577836800 -- 1. 1. 2020 UTC
-- local epoch2 = 2208988800 -- 1. 1. 2040 UTC

local time_speed_during_day, time_speed_during_night
local rwtime_callback

ch_time = {}

local dst_points_03 = {
	[2022] = 1648342800,
	[2023] = 1679792400,
	[2024] = 1711846800,
	[2025] = 1743296400,
	[2026] = 1774746000,
	[2027] = 1806195600,
	[2028] = 1837645200,
	[2029] = 1869094800,
	[2030] = 1901149200,
}
local dst_points_10 = {
	[2022] = 1667091600, -- 2 => 1
	[2023] = 1698541200,
	[2024] = 1729990800,
	[2025] = 1761440400,
	[2026] = 1792890000,
	[2027] = 1824944400,
	[2028] = 1856394000,
	[2029] = 1887843600,
	[2030] = 1919293200,
}

local nazvy_mesicu = {
	{"leden", "ledna", "led", "LED"},
	{"únor", "února", "úno", "ÚNO"},
	{"březen", "března", "bře", "BŘE"},
	{"duben", "dubna", "dub", "DUB"},
	{"květen", "května", "kvě", "KVĚ"},
	{"červen", "června", "čer", "ČER"},
	{"červenec", "července", "čvc", "ČVC"},
	{"srpen", "srpna", "srp", "SRP"},
	{"září", "září", "zář", "ZÁŘ"},
	{"říjen", "října", "říj", "ŘÍJ"},
	{"listopad", "listopadu", "lis", "LIS"},
	{"prosinec", "prosince", "pro", "PRO"},
}

local dny_v_tydnu = {
	"pondělí",
	"úterý",
	"středa",
	"čtvrtek",
	"pátek",
	"sobota",
	"neděle",
}

local jmeniny_cr, jmeniny_sr = dofile(core.get_modpath(core.get_current_modname()).."/jmeniny.lua")

assert(jmeniny_cr)
assert(jmeniny_sr)

local function ifthenelse(cond, t, f)
	if cond then return t else return f end
end


-- Nastavení
-- ===================================
function ch_time.get_time_shift()
	return time_shift
end

function ch_time.set_time_shift(new_shift)
	storage:set_int("time_shift", new_shift)
	time_shift = storage:get_int("time_shift")
end

function ch_time.get_time_speed_during_day()
	return time_speed_during_day
end

function ch_time.get_time_speed_during_night()
	return time_speed_during_night
end

function ch_time.set_time_speed_during_day(new_value)
	time_speed_during_day = new_value
end

function ch_time.set_time_speed_during_night(new_value)
	time_speed_during_night = new_value
end

function ch_time.get_rwtime_callback()
	return rwtime_callback
end

function ch_time.set_rwtime_callback(new_callback)
	--[[ callback musí vracet strukturu v tomto formátu:
		secs = int,
		string = string,
		string_extended = string,
	]]
	rwtime_callback = new_callback
end

local Cas = {}

function Cas:den_v_tydnu_cislo()
	local n = self.lt.wday - 1
	return ifthenelse(n == 0, 7, n)
end

function Cas:den_v_tydnu_nazev()
	return dny_v_tydnu[self:den_v_tydnu_cislo()]
end

function Cas:nazev_mesice(pad)
	return nazvy_mesicu[self.lt.month][pad]
end

function Cas:den_v_roce()
	return self.lt.yday
end

function Cas:posun_cislo()
	return ifthenelse(self.je_letni_cas, 2, 1)
end

function Cas:posun_text()
	return ifthenelse(self.je_letni_cas, "+02:00", "+01:00")
end

function Cas:znamka32()
	return ch_time.znamka32(self.time)
end

function Cas:YYYY_MM_DD()
	return string.format("%04d-%02d-%02d", self.rok, self.mesic, self.den)
end

function Cas:YYYY_MM_DD_HH_MM_SS()
	return string.format("%04d-%02d-%02d %02d:%02d:%02d", self.rok, self.mesic, self.den, self.hodina, self.minuta, self.sekunda)
end

function Cas:YYYY_MM_DD_HH_MM_SS_ZZZ()
	return string.format("%04d-%02d-%02d %02d:%02d:%02d %s",
		self.rok, self.mesic, self.den, self.hodina, self.minuta, self.sekunda, self:posun_text())
end

function Cas:YYYY_MM_DD_HH_MM_SSZZZ()
	return string.format("%04d-%02d-%02d %02d:%02d:%02d%s",
		self.rok, self.mesic, self.den, self.hodina, self.minuta, self.sekunda, self:posun_text())
end

function Cas:YYYY_MM_DDTHH_MM_SSZZZ()
	return string.format("%04d-%02d-%02dT%02d:%02d:%02d%s",
		self.rok, self.mesic, self.den, self.hodina, self.minuta, self.sekunda, self:posun_text())
end

function Cas:HH_MM_SS()
	return string.format("%02d:%02d:%02d", self.hodina, self.minuta, self.sekunda)
end

function Cas:UTC_YYYY_MM_DD()
	local u = self.utc
	return string.format("%04d-%02d-%02d", u.year, u.month, u.day)
end

function Cas:UTC_YYYY_MM_DD_HH_MM_SS()
	local u = self.utc
	return string.format("%04d-%02d-%02d %02d:%02d:%02d", u.year, u.month, u.day, u.hour, u.min, u.sec)
end

function Cas:za_n_sekund(n)
	return ch_time.na_strukturu(self.time + n)
end

function Cas:jmeniny(country)
	local t
	if country == "cz" then
		t = jmeniny_cr[self.mesic]
	elseif country == "sk" then
		t = jmeniny_sr[self.mesic]
	end
	return t and t[self.den]
end

-- API
-- ============================================

-- Zformátuje čas stejným způsobem jako os.time(), ale podle českého locale.
function ch_time.date(format, time)
	if format == nil then return nil end
	local st = ch_time.na_strukturu(time)
	local dvt_nazev = st:den_v_tydnu_nazev()
	local values = {
		["%a"] = dvt_nazev:sub(1, 2),
		["%A"] = dvt_nazev,
		["%b"] = nazvy_mesicu[st.mesic][3],
		["%B"] = nazvy_mesicu[st.mesic][1],
		["%c"] = st:YYYY_MM_DD_HH_MM_SS(),
		["%d"] = string.format("%02d", st.den),
		["%H"] = string.format("%02d", st.hodina),
		["%I"] = string.format("%02d", st.hodina % 12),
		["%M"] = string.format("%02d", st.minuta),
		["%m"] = string.format("%02d", st.mesic),
		["%p"] = ifthenelse(st.hodina < 12, "dop", "odp"),
		["%S"] = string.format("%02d", st.sekunda),
		["%w"] = tostring(st:den_v_tydnu_cislo()),
		["%x"] = st:YYYY_MM_DD(),
		["%X"] = st:HH_MM_SS(),
		["%Y"] = tostring(st.rok),
		["%y"] = string.format("%02d", st.rok % 100),
		["%%"] = "%",
	}
	format = string.gsub(format, "%%[aAbBcdHImMpSwxXyY%%]", values)
	return format
end

-- Vrací počet sekund od začátku epochy, posunutý o nastavený time_shift.
function ch_time.time()
	return os.time() + time_shift
end

--[[
	Vrátí strukturu popisující zadaný časový okamžik.
	time = int, -- čas vrácený z ch_time.time() nebo posunutý
]]
function ch_time.na_strukturu(time)
	if time == nil then
		time = ch_time.time()
	end
	local utc_time = os.date("!*t", time)
	local je_letni_cas
	if utc_time.month < 7 then
		local dst_point = dst_points_03[utc_time.year]
		je_letni_cas = dst_point ~= nil and time >= dst_point
	else
		local dst_point = dst_points_10[utc_time.year]
		je_letni_cas = dst_point ~= nil and time < dst_point
	end
	local lt = os.date("!*t", time + 3600 * ifthenelse(je_letni_cas, 2, 1))
	local result = {
		time = time,
		utc = utc_time, -- year, month, day, hour, min, sec, yday
		lt = lt, -- local time
		rok = lt.year,
		mesic = lt.month,
		den = lt.day,
		hodina = lt.hour,
		minuta = lt.min,
		sekunda = lt.sec,
		je_letni_cas = je_letni_cas,
	}
	return setmetatable(result, {__index = Cas})
end

--[[
	Vrátí strukturu popisující aktuální časový okamžik.
]]
function ch_time.aktualni_cas()
	return ch_time.na_strukturu(ch_time.time())
end

--[[
	Vrátí časovou známku v rozsahu typu 'int32_t' jako počet sekund od 1. 1. 2020 UTC.
	Rozsah je od 1951-12-13 20:45:53 UTC do 2088-01-19 03:14:07 UTC.
	Není-li zadaný čas, použije aktuální čas.
]]
function ch_time.znamka32(time)
	if time == nil then
		time = ch_time.time()
	end
	local result = time - epoch
	if result > 2147483647 then
		return 2147483647
	elseif result < -2147483647 then
		return -2147483647
	else
		return result
	end
end

--[[
	Převede časovou známku ve formátu vraceném funkcí ch_time.znamka32() zpět
	na formát vracený funkcí ch_time.time(). Pro nil vrací nil.
]]
function ch_time.znamka32_to_time(tm32)
	if tm32 ~= nil then
		return tm32 + epoch
	end
end

--[[
Vrátí herní čas ve struktuře:
{
	day_count = int -- návratová hodnota funkce minetest.get_day_count()
	timeofday = float -- hodnota podle funkce minetest.get_timeofday()
	hodina = int (0..23) -- hodina ve hře (celá)
	minuta = int (0..59) -- minuta ve hře (celá)
	sekunda = int (0..59) -- sekunda ve hře (celá)
	daynight_ratio = float
	natural_light = int (0..15)
	time_speed = float -- návratová hodnota core.settings:get("time_speed")
}
]]
function ch_time.herni_cas()
	local timeofday = core.get_timeofday()
	if timeofday == nil then return nil end
	local sekundy_celkem = math.floor(timeofday * 86400)
	local minuty_celkem = math.floor(sekundy_celkem / 60)
	local hodiny_celkem = math.floor(minuty_celkem / 60)
	local result = {
		day_count = core.get_day_count(),
		timeofday = timeofday,
		hodina = hodiny_celkem,
		minuta = minuty_celkem % 60,
		sekunda = sekundy_celkem % 60,
		time_speed = tonumber(core.settings:get("time_speed")),
	}
	if type(result.time_speed) ~= "number" then
		core.log("warning", "ch_time.herni_cas(): invalid type of time_speed!")
	end

	if 367 < minuty_celkem and minuty_celkem < 1072 then
		-- den
		result.day_night_ratio, result.natural_light = 1, 15
	elseif minuty_celkem < 282 or minuty_celkem > 1158 then
		-- noc
		result.day_night_ratio, result.natural_light = 0, 2
	elseif minuty_celkem < 500 then
		-- úsvit
		result.day_night_ratio = (minuty_celkem - 282) / 86.0
		if minuty_celkem < 295 then
			result.natural_light = 3
		elseif minuty_celkem < 305 then
			result.natural_light = 4
		elseif minuty_celkem < 312 then
			result.natural_light = 5
		elseif minuty_celkem < 319 then
			result.natural_light = 6
		elseif minuty_celkem < 325 then
			result.natural_light = 7
		elseif minuty_celkem < 331 then
			result.natural_light = 8
		elseif minuty_celkem < 336 then
			result.natural_light = 9
		elseif minuty_celkem < 341 then
			result.natural_light = 10
		elseif minuty_celkem < 346 then
			result.natural_light = 11
		elseif minuty_celkem < 351 then
			result.natural_light = 12
		elseif minuty_celkem < 359 then
			result.natural_light = 13
		elseif minuty_celkem < 367 then
			result.natural_light = 14
		else
			result.natural_light = 15
		end
	else
		-- soumrak
		result.day_night_ratio = (1158 - minuty_celkem) / 86.0
		if minuty_celkem < 1080 then
			result.natural_light = 14
		elseif minuty_celkem < 1088 then
			result.natural_light = 13
		elseif minuty_celkem < 1093 then
			result.natural_light = 12
		elseif minuty_celkem < 1098 then
			result.natural_light = 11
		elseif minuty_celkem < 1103 then
			result.natural_light = 10
		elseif minuty_celkem < 1108 then
			result.natural_light = 9
		elseif minuty_celkem < 1114 then
			result.natural_light = 8
		elseif minuty_celkem < 1120 then
			result.natural_light = 7
		elseif minuty_celkem < 1127 then
			result.natural_light = 6
		elseif minuty_celkem < 1134 then
			result.natural_light = 5
		elseif minuty_celkem < 1144 then
			result.natural_light = 4
		elseif minuty_celkem < 1157 then
			result.natural_light = 3
		else
			result.natural_light = 2
		end
	end
	return result
end

--[[
Nastaví herní čas na hodnotu uvedenou ve formátu hodin, minut a sekund.
]]
function ch_time.herni_cas_nastavit(h, m, s)
	assert(h)
	assert(m)
	assert(s)
	local novy_timeofday = (3600 * h + 60 * m + s) / 86400.0
	if novy_timeofday < 0 then
		novy_timeofday = 0.0
	elseif novy_timeofday > 1 then
		novy_timeofday = 1.0
	end
	local puvodni = ch_time.herni_cas()
	local puvodni_timeofday = puvodni.timeofday
	core.set_timeofday(novy_timeofday)
	local byla_noc = puvodni_timeofday < 0.2292 or puvodni_timeofday > 0.791666
	local je_noc = novy_timeofday < 0.2292 or novy_timeofday > 0.791666
	if byla_noc and not je_noc then
		-- Ráno
		if time_speed_during_day ~= nil then
			core.settings:set("time_speed", tostring(time_speed_during_day))
		end
	elseif not byla_noc and je_noc then
		-- Noc
		if time_speed_during_night ~= nil then
			core.settings:set("time_speed", tostring(time_speed_during_night))
		end
	end
	local novy = ch_time.herni_cas()
	core.log("action", string.format("Time of day set from ((%d):%d:%d:%d => (%d):%d:%d:%d); speed: %f => %f\n",
		puvodni.day_count, puvodni.hodina, puvodni.minuta, puvodni.sekunda, novy.day_count, novy.hodina, novy.minuta, novy.sekunda,
		puvodni.time_speed or 0.0, novy.time_speed or 0.0))
	return novy
end

-- Příkazy v četu
-- ========================================================

local def = {
	description = "Nastaví posun zobrazovaného času.",
	privs = {server = true},
	func = function(player_name, param)
		local n = tonumber(param)
		if not n then
			return false, "Chybné zadán!!"
		end
		n = math.round(n)
		ch_time.set_time_shift(n)
		core.chat_send_player(player_name, "*** Posun nastaven: "..n)
	end,
}

core.register_chatcommand("posunčasu", def)
core.register_chatcommand("posuncasu", def)
-- core.register_chatcommand("set_time_shift", def)

local vypsat_cas_param_table = {
	u = function()
		local cas = ch_time.aktualni_cas()
		return string.format("%02d:%02d UTC", cas.utc.hour, cas.utc.min)
	end,
	["u+"] = function()
		local cas = ch_time.aktualni_cas()
		return cas:UTC_YYYY_MM_DD_HH_MM_SS().." UTC"
	end,
	m = function()
		local cas = ch_time.aktualni_cas()
		return cas:HH_MM_SS().." "..cas:posun_text()
	end,
	["m+"] = function()
		local cas = ch_time.aktualni_cas()
		return cas:YYYY_MM_DD_HH_MM_SS_ZZZ()
	end,
	h = function()
		local cas = ch_time.herni_cas()
		return string.format("%02d:%02d herního času", cas.hodina, cas.minuta)
	end,
	["h+"] = function()
		local cas = ch_time.herni_cas()
		return string.format("%02d:%02d:%02d herního času (herní den %d)", cas.hodina, cas.minuta, cas.sekunda, cas.day_count)
	end,
	["ž"] = function()
		if rwtime_callback == nil then
			return "železniční čas není dostupný"
		else
			local rwtime = rwtime_callback()
			return "železniční čas: "..assert(rwtime.string)
		end
	end,
	["ž+"] = function()
		if rwtime_callback == nil then
			return "železniční čas není dostupný"
		else
			local rwtime = rwtime_callback()
			return "železniční čas: "..rwtime.string_extended.." ("..rwtime.secs..")"
		end
	end,
}
vypsat_cas_param_table[""] = vypsat_cas_param_table["h"]
vypsat_cas_param_table["utc"] = vypsat_cas_param_table["u"]
vypsat_cas_param_table["utc+"] = vypsat_cas_param_table["u+"]
vypsat_cas_param_table["místní"] = vypsat_cas_param_table["m"]
vypsat_cas_param_table["mistni"] = vypsat_cas_param_table["m"]
vypsat_cas_param_table["místní+"] = vypsat_cas_param_table["m+"]
vypsat_cas_param_table["mistni+"] = vypsat_cas_param_table["m+"]
vypsat_cas_param_table["herni"] = vypsat_cas_param_table["h"]
vypsat_cas_param_table["herní"] = vypsat_cas_param_table["h"]
vypsat_cas_param_table["herni+"] = vypsat_cas_param_table["h+"]
vypsat_cas_param_table["herní+"] = vypsat_cas_param_table["h+"]
vypsat_cas_param_table["železniční"] = vypsat_cas_param_table["ž"]
vypsat_cas_param_table["zeleznicni"] = vypsat_cas_param_table["ž"]
vypsat_cas_param_table["železniční+"] = vypsat_cas_param_table["ž+"]
vypsat_cas_param_table["zeleznicni+"] = vypsat_cas_param_table["ž+"]

local function vypsat_cas(player_name, param)
	if type(player_name) == "table" then
		-- API hack:
		local t = player_name
		if t[1] ~= nil then
			ch_core.systemovy_kanal(t[1], t[2])
		end
		return t[3], t[4]
	end
	local f = vypsat_cas_param_table[param]
	if f ~= nil then
		ch_core.systemovy_kanal(player_name, f())
		return true
	else
		return false, "Nerozpoznaný parametr: "..param
	end
end

def = {
	params = "[utc|utc+|m[ístní]|m[ístní]+|h[erní]|h[erní]+|ž[elezniční]|ž[elezniční]+]",
	description = "Vypíše požadovaný druh času (a případně data). Výchozí je „h“ (herní čas).",
	privs = {},
	func = vypsat_cas,
}
core.register_chatcommand("čas", def)
core.register_chatcommand("cas", def)

ch_base.close_mod(core.get_current_modname())

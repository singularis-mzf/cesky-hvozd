# Veřejné funkce

## Nastavení a callbacky

  ch_time.get_time_shift() -> int
  ch_time.set_time_shift(new_shift)

Získá/nastaví časový posun v sekundách, který se přičítá k výstupu os.time() k získání správné aktuální časové známky.
Výchozí posun je 0.

  ch_time.get_time_speed_during_day()
  ch_time.set_time_speed_during_day(new_value)

Získá/nastaví rychlost plynutí herního času během dne. Hodnota může být nil, v takovém případě se při úsvitu rychlost času nemění.
Výchozí hodnota je nil.

    ch_time.get_time_speed_during_night()
    ch_time.set_time_speed_during_night(new_value)

Získá/nastaví rychlost plynutí herního času během noci. Hodnota může být nil, v takovém případě se při soumraku rychlost času nemění.
Výchozí hodnota je nil.

  ch_time.get_rwtime_callback()
  ch_time.set_rwtime_callback(new_callback)

Získá/nastaví callback volaný pro získání aktuálního železničního času. Je-li nil, železniční čas není dostupný. Výchozí hodnota je nil.
Callback se bude volat bez parametrů a musí vracet tabulku v tomto formátu:

{
    secs = int, -- železniční čas v číselné formě (to_secs())
    string = string, -- železniční čas v textové formě bez cyklu (jen minuty a sekundy)
    string_extended = string, -- železniční čas v úplné textové formě (tzn. včetně cyklu)
}

## Třída "Cas"

Objekty této třídy vrací funkce ch_time.aktualni_cas() a ch_time.na_strukturu(). Reprezentují konkrétní časový okamžik
v kombinaci s příslušným místním a UTC časem.

  Cas:den_v_tydnu_cislo() -> int

Vrací den v týdnu jako číslo od 1 (pondělí) do 7 (neděle)

  Cas:den_v_tydnu_nazev() -> string

Vrací název dne v týdnu malými písmeny ("pondělí" až "neděle")

  Cas:nazev_mesice(pad) -> string

pad musí být 1, nebo 2. Vrací název měsíce v uvedeném pádě.

  Cas:den_v_roce() -> int

Vrací den v roce (1 až 366)

  Cas:posun_cislo() -> int

Vrací posun místního času proti UTC v počtu hodin.

  Cas:posun_text() -> string

Vrací posun místního času proti UTC v textovém formátu "+HH:MM".

  Cas:znamka32() -> int

Vrací celý počet sekund od 1. 1. 2020 UTC (může být záporný), v rozsahu typu int32_t.

  Cas:YYYY_MM_DD() -> string

Vrací místní čas ve formátu "YYYY-MM-DD".

  Cas:YYYY_MM_DD_HH_MM_SS() -> string

Vrací místní čas ve formátu "YYYY-MM-DD HH:MM:SS".

  Cas:YYYY_MM_DD_HH_MM_SS_ZZZ() -> string

Vrací místní čas ve formátu "YYYY-MM-DD HH:MM:SS +HH:MM".

  Cas:YYYY_MM_DD_HH_MM_SSZZZ() -> string

Vrací místní čas ve formátu "YYYY-MM-DD HH:MM:SS+HH:MM".

  Cas:YYYY_MM_DDTHH_MM_SSZZZ() -> string

Vrací místní čas ve formátu "YYYY-MM-DDTHH:MM:SS+HH:MM" (tzn. zcela bez mezer).

  Cas:HH_MM_SS()

Vrací místní čas ve formátu "HH:MM:SS".

  Cas:UTC_YYYY_MM_DD()

Vrací UTC čas ve formátu "YYYY-MM-DD".

  Cas:UTC_YYYY_MM_DD_HH_MM_SS()

Vrací UTC čas ve formátu "YYYY-MM-DD HH:MM:SS".

  Cas:za_n_sekund(n)

Vrací nový objekt třídy Cas reprezentující časový okamžik o n sekund později než tento objekt;
n může být záporné, v takovém případě bude okamžik o -n sekund dříve.

## Funkce pro práci s reálným časem

  ch_time.aktualni_cas()

Vrací objekt třídy Cas reprezentující aktuální čas. V podstatě jde o synonymum k ch_time.na_strukturu(nil).

  ch_time.time() -> int

Vrací hodnotu os.time() posunutou o posun zadaný funkcí ch_time.set_time_shift(new_shift).

  ch_time.na_strukturu(time)

Vrací objekt třídy Cas reprezentující zadaný čas (ve stejném formátu jako výstup ch_time.time()).
Kromě metod nabízí ještě následující datové prvky:

{
  time = int, -- původní zadaná časová známka
  utc = table, -- struktura vrácená příkazem os.date() reprezentující UTC čas; prvky jsou např.: year, month, day, hour, min, sec, yday
  lt = lt, -- struktura vrácená příkazem os.date() reprezentující místní čas
  rok = int, -- rok (místní)
  mesic = int, -- měsíc 1 až 12 (místní)
  den = int, -- den 1 až 31 (místní)
  hodina = int, -- hodina 0 až 23 (místní)
  minuta = int, -- minuta 0 až 59 (místní)
  sekunda = int, -- sekunda 0 až 59 (místní)
  je_letni_cas = bool, -- indikátor, zda místní čas je letní
}

  ch_time.znamka32(time)

Vrátí časovou známku v rozsahu typu 'int32_t' jako počet sekund od 1. 1. 2020 UTC.
Rozsah je od 1951-12-13 20:45:53 UTC do 2088-01-19 03:14:07 UTC.
Není-li zadaná časová známka (nil), použije aktuální čas.

## Funkce pro práci s herním časem

  ch_time.herni_cas() -> table

Vrací herní čas ve struktuře s následujícími prvky:

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

  ch_time.herni_cas_nastavit(h, m, s) -> table

Nastaví herní čas na zadanou hodnotu uvedenou ve formátu hodin, minut a sekund.
Vrací výstup ch_time.herni_cas() po provedení nastavení.
Součástí nastavení může být změna rychlosti plynutí času.

# Příkazy v četu

## /posunčasu

Syntaxe:

``/posunčasu <celé_číslo>``

Nastaví posun času, volá funkci ch_time.set_time_shift(). Účinek je okamžitý.
Vyžaduje právo *server*.

## /čas

Syntaxe:

``/čas [utc|utc+|m[ístní]|m[ístní]+|h[erní]|h[erní]+|ž[elezniční]|ž[elezniční]+]``

Vypíše požadovaný druh času. Není-li druh zadán, vypíše herní čas.

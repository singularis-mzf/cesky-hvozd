# Veřejné funkce

## Data

  ch_data.online_charinfo[player_name]

Tabulka neperzistentních dat pro danou postavu, která je ve hře. Musí obsahovat minimálně následující položky:

* formspec_version : int : nejvyšší verze formspec podporovaná klientem; 0, pokud údaj není k dispozici
* join_timestamp : int : časová známka vytvoření online_charinfo (vstupu postavy do hry), z get_us_time()
* lang_code : string : jazykový kód (obvykle "cs")
* news_role : string : co udělat po připojení (významy jednotlivých řetězců se mění)
* player_name : string : přihlašovací jméno

  ch_data.offline_charinfo[player_name]

Tabulka perzistentních dat pro danou postavu. Vytváří se pro každou známou postavu. Musí obsahovat minimálně
položky z ch_data.initial_offline_charinfo.

  ch_data.initial_offline_charinfo

Tabulka klíč/hodnota. Klíče specifikují klíče vyžadované v záznamech offline_charinfo. Hodnoty specifikují
výchozí hodnoty těchto klíčů, které se buď doplní při načtení, pokud nejsou k dispozici, nebo se doplní
při vytvoření nového záznamu offline_charinfo. Položky v této tabulce mohou být přepisovány z jiných
módů, ale tyto změny se uplatní teprve při vytváření nových záznamů offline_charinfo.

## Funkce

  ch_data.get_flag(charinfo : table, flag_name : string, default_result : any) -> string or any

Z daného charinfo (offline_charinfo) přečte znak odpovídající požadovanému příznaku. Není-li příznak
dostupný, vrací default_result, popř. " ".

  ch_data.get_flags(charinfo : table) -> table

Z daného charinfo (offline_charinfo) přečte všechny příznaky a vrátí je ve formě tabulky.
Vhodné pro dumpování.

  ch_data.set_flag(charinfo, flag_name, value) -> bool

V daném charinfo (offline_charinfo) nastaví hodnotu požadovaného příznaku. Pokud příznak neexistuje, vrátí false.

  ch_data.get_joining_online_charinfo(player) -> table

Volá se z callbacků on_joinplayer; vrátí ch_data.online_charinfo[player_name]. Pokud není, inicializuje jej.
Může být použita víckrát po sobě.

  ch_data.get_leaving_online_charinfo(player) -> table

Volá se z callbacků on_leaveplayer; vrátí ch_data.online_charinfo[player_name] a vyřadí ho z tabulky.
Pokud už bylo vyřazeno, vrátí poslední vyřazenou tabulku. To umožňuje pracovat s online daty postavy
po celou dobu jejího odpojování.

  ch_data.delete_offline_charinfo(player_name) -> bool, string

Pokud postava není ve hře, smaže její ch_data.offline_charinfo[] se vším všudy a vrátí true.
Pokud postava je ve hře, nebo její offline_charinfo neexistuje, vrátí false a chybovou zprávu.

  ch_data.get_offline_charinfo(player_name) -> table

Vrátí ch_data.offline_charinfo[player_name]. Pokud neexistuje, skončí s chybou.

  ch_data.get_or_add_offline_charinfo(player_name) -> table

Vrátí ch_data.offline_charinfo[player_name]. Pokud neexistuje, inicializuje nové.

  ch_data.save_offline_charinfo(player_name) -> bool

Uloží ch_data.offline_charinfo[player_name]. Vrátí false, pokud dané offline_charinfo neexistuje nebo je jméno postavy nepřijatelné.

  ch_data.clear_help(player)

Pro danou postavu smaže ch_data.online_charinfo[player_name].navody (perzistentně).

  ch_data.should_show_help(player : PlayerRef, online_charinfo : table, item_name : string) -> table or nil

Otestuje, zda podle online_charinfo má dané postavě být zobrazený v četu návod k položce daného názvu.
Pokud ano, nastaví příznak, aby se to znovu již nestalo, a vrátí definici daného předmětu,
z níž lze z položek description a _ch_help sestavit text k zobrazení. Jinak vrátí nil.

  ch_data.nastavit_shybani(player_name : string, shybat : bool) -> bool

Pro danou postavu perzistentně nastaví shýbání. (Volá ch_data.save_offline_charinfo().)

# Příkazy v četu

## /delete_offline_charinfo

Syntaxe:

``/delete_offline_charinfo Jmeno_postavy``

Odstraní údaje o postavě uložené v systému ch_data. Postava nesmí být ve hře. Vyžaduje právo `server`.

## /návodyznovu

Syntaxe:

``/návodyznovu``

Smaže údaje o tom, ke kterým předmětům již byly postavě zobrazeny nápovědy, takže budou znovu zobrazovány nápovědy ke všem předmětům.

## /shýbat

Syntaxe:

``/shýbat <ano|ne>``

Trvale vypne či zapne shýbání postavy při držení Shiftu.

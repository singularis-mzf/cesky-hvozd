Datové struktury:

train = {
    line_status = {
        -- záznam o posledním zastavení/průjezdu vlaku neanonymní zastávkovou kolejí
        -- (používá se jako údaj o poloze vlaku)
        last_enter = {
            stn = string, -- kód dopravny
            encpos = string, -- zakódovaná pozice koleje, kde došlo ke kontaktu
            rwtime = int, -- železniční čas
        } or nil,

        -- záznam o posledním odjezdu/průjezdu vlaku neanonymní zastávkovou kolejí
        -- (používá se jako údaj o poloze vlaku)
        last_leave = {
            stn = string, -- kód dopravny
            encpos = string, -- zakódovaná pozice koleje, kde došlo ke kontaktu
            rwtime = int, -- železniční čas
        } or nil,

        -- pokud vlak právě stojí na zastávkové koleji, obsahuje její zakódovanou pozici;
        -- při odjezdu se vynuluje
        standing_at = string or nil,

        -- nastaví se na 1 v případě, že "bylo dáno znamení", aby vlak zastavil
        stop_request = 1 or nil,

        -- údaje o poslední skončené jízdě na lince, dokud se nezmění číslo linky a dokud neuplyne 24 žel. hodin (cyklů)
        -- nevyplní se, pokud vlak skončí jízdu jinak než zastavením na koncové zastávce
        linevar_past = {
            -- označení linky (LINE z linevar)
            line = string,
            -- linevar poslední jízdy na lince
            linevar = string,
            -- kód koncové zastávky, kde vlak skončil jízdu na lince
            station = string,
            -- žel. čas příjezdu na koncovou zastávku
            arrival = int,
        } or nil,

        -- Následující pole jsou vyplněna jen u linkových vlaků:
        -- ===========================
        -- varianta linky LINE/STCODE/RC
        linevar = string,

        -- prostřední díl z 'linevar' (kód stanice, kde jsou uložena data varianty linky)
        linevar_station = string,

        -- skutečný železniční čas odjezdu z *výchozí* zastávky spoje
        linevar_dep = int,

        -- index zastávky spoje (do pole 'stops'), kde vlak naposledy zastavil
        linevar_index = int,

        -- skutečný železniční čas odjezdu z poslední zastávky spoje, kde vlak zastavil
        linevar_last_dep = int,

        -- kód zastávky spoje, kde vlak naposledy zastavil
        linevar_last_stn = string,
    }
}

station = {
    linevars = {
        [linevar] = {
            -- linevar (LINE/STCODE/RC)
            name = string,

            -- LINE (první část názvu)
            line = string,

            -- přihlašovací jméno postavy, která linku spravuje
            owner = string,

            -- jméno vlaku pro zobrazení (volitelné)
            train_name = string or nil,

            -- je-li true, nové vlaky nemohou dostat tuto variantu přidělenu
            disabled = bool or nil,

            -- je-li neprázdný řetězec, udává označení linky, na kterou bude vlak pravděpodobně pokračovat
            -- ze zastávky v režimu MODE_FINAL_CONTINUE
            continue_line = string or nil,

            -- je-li continue_line neprázdný řetězec, udává směrový kód pro pokračování
            continue_rc = string or nil,

            -- index zobrazované výchozí zastávky v poli 'stops'; nil značí, že taková zastávka nebyla nalezena
            index_vychozi = int or nil,

            -- index zobrazované cílové zastávky v poli 'stops'; nil značí, že taková zastávka nebyla nalezena
            index_cil = int or nil,

            -- seznam zastávek na lince, seřazený podle 'dep':
            stops = {
                {
                    -- kód dopravny, kde má vlak zastavit
                    stn = string,

                    -- plánovaný čas odjezdu, relativně vůči odjezdu z výchozí zastávky (v sekundách)
                    dep = int,

                    -- předpokládaný čas stání před časem odjezdu (používá se k zjištění času příjezdu)
                    -- je-li nil, počítá se 10 sekund
                    -- výjimka: pro koncové zastávky udává předpokládanou dobu stání po čase 'dep'
                    wait = int or nil,

                    -- režim zastávky (podle konstant ve zdrojovém kódu)
                    -- nil odpovídá 0 (normální zastavení)
                    mode = int or nil,

                    -- je-li vyplněna, vlak zastaví jen na koleji na uvedené pozici
                    pos = "X,Y,Z" or nil,

                    -- orientační údaj pro cestující, na které koleji má vlak zastavit
                    track = string or nil,
                }...
            }
        }
    },
    anns = { -- staniční rozhlasy
        [encoded_pos] = {
            cedule = {
                -- formát prázdné řádky pro danou ceduli
                empty = string,
                -- pozice připojené cedule ve tvaru pro použití ve formspecu, nebo "", pokud daná cedule není připojená
                fs = string,
                -- pozice připojené cedule ve formě vektoru
                pos = vector,
                -- formát řádky s odjezdem pro danou ceduli
                row = string,
                -- formát pro sestavení textu cedule z řádků; může používat značky {1} až {9} a může mít víc řádek
                text = "{1}{2}",
                -- seznam řádků, které jsou odkazovány v poli 'text', nebo prázdný řetězec, pokud nejsou odkazovány žádné
                text_rtf = {int, ...} or "",
            },
            -- dosah zpráv v četu (>= 0, nil znamená 50):
            chat_dosah = int or nil,

            -- formát pro kladné zpoždění
            fmt_delay = string,

            -- formát pro záporné zpoždění
            fmt_negdelay = string,

            -- formát pro „bez zpoždění“
            fmt_nodelay = string,

            -- udává, zda na cedulích bude první znak každého řádku s odjezdem (textu dosazeného za značku {1} až {9})
            -- převeden na velké písmeno:
            fn_firstupper = bool,

            -- obsah pole "koleje" zformátovaný pro použití ve formspecu; prázdný řetězec "" znamená, že st. rozhlas platí pro všechny koleje
            -- a na .koleje pak nezáleží
            fs_koleje = string,

            -- pokud st. rozhlas není omezený na určité koleje, nil nebo ""
            -- je-li omezen na jednu konkrétní kolej, pak jde o název této koleje
            -- je-li omezen na více kolejí, pak jde o množinu indexovanou označeními kolejí
            koleje = {[string] = true, ...} or string or nil,

            -- režim rozhlasu (RMODE_*)
            rmode = int,

            -- číslo verze systému staničního rozhlasu (pro detekci zastaralých rozhlasů)
            version = int,

            -- řetězce pro formátování hlášení v četu; nemusí být uvedeny všechny, nil znamená použít výchozí text
            tx_* = string or nil,
        }
    }
}

stop = {
    -- žel. čas posledního odjezdu jakéhokoliv zastavivšího vlaku z této zastávkové koleje;
    -- používá se v kombinaci s intervalem
    last_dep = int or nil,
    -- původně naplánovaná doba stání vlaku vztahující se k last_dep
    last_wait = int or nil,
}

local current_passages = {--[[
    [train_id] = {[1] = rwtime, ..., [n] = rwtime (časy *odjezdu*, kromě koncových zastávek, kde jde o čas příjezdu)}
]]}

local last_passages = {--[[
    [linevar] = {
        [1..10] = {[1] = rwtime, ...} -- jízdy seřazeny od nejstarší (1) po nejnovější (až 10) podle odjezdu z výchozí zastávky
    }
]]}

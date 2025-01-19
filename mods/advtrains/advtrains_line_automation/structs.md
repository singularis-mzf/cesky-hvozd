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

            -- seznam zastávek na lince, seřazený podle 'dep':
            stops = {
                {
                    -- kód dopravny, kde má vlak zastavit
                    stn = string,

                    -- plánovaný čas odjezdu, relativně vůči odjezdu z výchozí zastávky (v sekundách)
                    dep = int,

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
            ...
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

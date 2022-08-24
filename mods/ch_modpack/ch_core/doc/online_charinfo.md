# Dokumentace prvků struktury online\_charinfo

## submodul \[data\]

* public **player\_name** (string) -- obsahuje přihlašovací jméno postavy; vyplní se okamžitě při vzniku struktury; umožňuje zjistit přihlašovací jméno postavy ze samotného odkazu na online\_charinfo
* public **join\_timestamp** (float) -- při vstupu postavy do hry se vyplní na ch\_core.cas; umožňuje počítat odehranou dobu
* public **docasne\_tituly** (table: titul -&gt; 1) -- tabulka dočasných titulů aktivních pro danou postavu

## submodul \[chat\]

* public **doslech** (int) -- aktuální doslech postavy, výchozí hodnota je 65535
* public **chat\_ignore\_list** (table: player\_name -&gt; true) -- množina hráčských jmen postav, které tato postava ignoruje; výchozí hodnotou je prázdná tabulka
* **posl_soukr_adresat** (string) -- přihlašovací jméno posledního adresáta/ky soukromé zprávy od této postavy; výchozí hodnota je nil
* public **horka\_zprava** (table: index \-&gt; řádek + \["timeout"\] = čas vypršení) -- je-li nastavena, má se nad postavou zobrazit obsažená zpráva; první řádek zprávy vždy nastavuje barvu písma

## submodul \[hud\]

* public **player\_list\_huds** (table: index -&gt; hud\_id) -- tabulka, která se vyplní jen v době, kdy je hráči/ce zobrazen seznam postav ve hře; obsahuje ID jednotlivých řádků seznamu, aby je bylo možno později zrušit; při skrytí seznamu se vždy nastaví na nil, podle její přítomnosti tedy lze testovat, zda je zobrazený seznam postav
* **hudbars** (table: index -&gt; hudbar\_id) -- tabulka evidující obsazené „hudbars“; je pouze pro vnitřní použití funkcemi ch_core.try_alloc_hudbar() a ch_core.free_hudbar()

## submodul \[vezeni\]

* **last\_hudbar\_trest\_max** (int) -- poslední maximum ukazatele trestu
* **prison\_hudbar** (string) -- je-li zobrazen ukazatel trestu, tato položka obsahuje jeho ID; je určena jen pro vnitřní potřebu submodulu

## submodul \[timers\]

* public **ch\_timers** (table: timer\_id -&gt; timer\_data) -- tabulka aktivních časovačů

## submodul \[pryc\]

* public **pryc** (funkce) -- je-li vyplněna, hráč/ka je pryč od počítače; zavoláním funkce se tento stav zruší
* **pryc\_hud\_id** (string) -- identifikátor HUD „pryč od počítače“ (pro vnitřní potřebu)

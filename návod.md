# Návod ke zprovoznění vlastního serveru

Následující návod poskytuji v dobré víře, že bude většině uživatelů/ek fungovat, ale bez záruky.

Ke zprovoznění vlastního serveru s použitím kódu z tohoto repozitáře
budete potřebovat server Minetest verze 5.8.0 (dodává se s klientem
odpovídající verze). Může to fungovat i s novější verzí,
ale nemohu to zaručit. Dále budete potřebovat několik set megabajtů místa na disku
(doporučuji vyhradit alespoň gigabajt). Musíte však použít dedikovanou
instanci, kterou nebudete používat k žádnému jinému účelu (proto doporučuji
volit „portable“ variantu klienta/serveru a nikoliv tu instalovanou).

1. Stáhněte si obsah tohoto repozitáře (přinejmenším adresáře „minetest\_game“ a „mods“ a soubor „část-minetest.conf“).
2. Pokud máte v adresáři „games“ Vašeho serveru podadresář „minetest\_game“, smažte ho. Rovněž smažte adresář „mods“ přímo v kořenovém adresáři Vašeho serveru.
3. Adresář „minetest\_game“ z tohoto repozitáře přesuňte do adresáře „games“ Vašeho serveru.
4. Adresář „mods“ z tohoto repozitáře přesuňte do kořenového adresáře Vašeho serveru (tím nahradíte původní adresář téhož jména).
5. Soubor „část-minetest.conf“ z tohoto repozitáře nakopíruje do kořenového adresáře Vašeho serveru pod názvem „minetest.conf“.
6. Spusťte hru, vytvořte svět hry „Minetest Game“ s libovolným generátorem mapy.
7. Před prvním spuštěním nově vytvořeného světa mu zapněte všechny dostupné módy kromě těch v balíčku „ch\_devel“ (ty by měly zůstat vypnuté, nemusejí být dodělané). Pokud nechcete zapínat všechny módy, mělo by stačit zapnout mód „ch\_min“ a jeho závislosti.
8. Spusťte server. („kreativní mód“ nechte vypnutý a zranění zapnuté, s jiným nastavením kód není testovaný) Vytvořte postavu jménem „Administrace“.
9. Po přihlášení na postavu „Administrace“ zadejte do četu: „/grantme all“.
10. Nyní můžete vytvořit další postavy herního světa, vzniknou jako turistické.

Při startu se objevují chyby týkající se nenastavených pozic v herním světě. Bez nich by však server měl také fungovat.

Nové postavy přijmete na server následujícími příkazy:

``/registrovat creative Jmeno_postavy`` — pro kouzelnický styl hry
``/registrovat survival Jmeno_postavy`` — pro dělnický styl hry

Další správcovské příkazy objevíte pomocí příkazu /help.

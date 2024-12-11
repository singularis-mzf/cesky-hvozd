Dokumentace metadat:

inventory main — hlavní inventář truhly, může mít libovolnou velikost; výchozí velikost je 8*4
inventory qmove — speciální inventář sloužící k rychlému přesunu dávek stejného typu, velikost 1
inventory trash — speciální inventář sloužící k ničení dávek, velikost 1
inventory upgrades — obsahuje kovové bloky pro zvýšení kapacity truhly (velikost 5)

int width — šířka inventáře pro zobrazení; >= 1
int height — výška inventáře pro zobrazení; >= 1
int splitstacks — pro mód pipeworks: dovolí dělení dávek při vstupu z rour
int autosort — je povoleno automatické řazení? 0 = ne, 1 = ano
int sort_mode — režim řazení (0 = výchozí režim)
int ch_given — 0 = truhla není darovaná; 1 = truhla je darovaná neanonymně; 2 = darovaná anonymně
int chest_id — sériové číslo truhly
string owner — postava s plnými právy k truhle; v případě darované truhly obdarovaná postava
string agroup — seznam postav ve skupině v normalizovaném tvaru (|postava1|postava2|)
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

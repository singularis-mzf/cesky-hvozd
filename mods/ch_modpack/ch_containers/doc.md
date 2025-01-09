# Data v 'storage':

string {container_id}_owner -- vlastník/ice kontejneru
string {container_id}_next_free
  -- je-li kontejner prázdný, udává ID následujícího prázdného kontejneru ve frontě
  -- poslední prázdný kontejner ve frontě má toto pole nastaveno na hodnotu ";"
string next_free -- udává ID prvního prázdného kontejneru ve frontě
int ap_x, ap_y, ap_z -- pozice posledního umístěného přístupového terminálu (pro návrat z kontejnerů)





base = vector.new(-3840, 3744, -3840),
offset = vector.new(96, -256, 96),
limit = vector.new(80, 2, 80),

- kontejnery se vytvářejí počínaje od souřadnic


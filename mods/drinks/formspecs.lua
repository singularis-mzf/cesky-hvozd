function drinks.liquid_storage_formspec(fruit_name, fullness, max)
	local formspec =
   'size[8,8]'..
      'label[0,0;Můžete plnit jedním libovolným typem šťávy či nápoje,]'..
      'label[0,.4;míchání různých nápojů není dovoleno.]'..
      'label[4.5,1.2;Nápoj k uložení ->]'..
      'label[.5,1.2;Ukládám '..((drinks.drink_table[fruit_name] or {})[4] or fruit_name)..'.]'..
      'label[.5,1.65;Naplnění: '..(fullness/2)..' z '..(max/2)..' dávek.]'..
      'label[4.5,2.25;Nádoba k naplnění ->]'..
      'label[2,3.2;(Vylije pryč veškerý obsah)]'..
      'button[0,3;2,1;purge;Vylít vše]'..
      'list[current_name;src;6.5,1;1,1;]'..
      'list[current_name;dst;6.5,2;1,1;]'..
      'list[current_player;main;0,4;8,5;]'
   return formspec
end

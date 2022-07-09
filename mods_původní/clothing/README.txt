Wool Clothing - Wool Clothing [WIP] [clothing]
==============================================

Depends: skinsdb

Recommends: sfinv, inventory_plus or unified_inventory (use only one)

Adds simple clothing that can be crafted from coloured wool using a loom.
Requires the wool mod for craft registration.

Crafting
--------

[clothing:spinning_machine]
+------+--------+------+
| wood |  wood  | wood |
+------+--------+------+
| wood | string | wood |
+------+--------+------+
| wood |  wood  | wood |
+------+--------+------+

[clothing:loom]
+-------+----------+----------+
| stick | pinewood |  stick   |
+-------+----------+----------+
| stick | pinewood |  stick   |
+-------+----------+----------+
| stick | pinewood | pinewood |
+-------+----------+----------+

[clothing:sewing_table]
+-------+--------+-------+
| wood  |  wood  | wood  |
+-------+--------+-------+
| stick | needle | stick |
+-------+--------+-------+
| stick | needle | stick |
+-------+--------+-------+

[clothing:dya_machineempty]
+------+-------+------+
| wood | stick | wood |
+------+-------+------+
| wood | stick | wood |
+------+-------+------+
| wood | wood  | wood |
+------+-------+------+

[clothing:needle]
+--------+
| needle |
+--------+
| needle |
+--------+

[clothing:yarn_spool_empty]
+-------+
| stick |
+-------+
| wood  |
+-------+

Spinning
  wool -> yarn_spool
  cotton -> yarn_spool
  hemp fibre -> yarn_spool

Weaving
  +------------+------------+
  | yarn_spool | yarn_spool |
  +------------+------------+ -> fabric
  | yarn_spool | yarn_spool |
  +------------+------------+
  
  +-----------------+-----------------+
  | yarn_spool_col1 | yarn_spool_col2 |
  +-----------------+-----------------+ -> dual color fabric
  | yarn_spool_col2 | yarn_spool_col1 |
  +-----------------+-----------------+

Dyeing
  - colorize white yarn, fabric or wool

Sewing
  - use same color of fabric and yarn  
  
  Hat
    +--------+------------+--------+
    | fabric |   fabric   | fabric |
    +--------+------------+--------+
    | fabric | yarn spool | fabric |
    +--------+------------+--------+
    +        +            +        +
    +--------+------------+--------+
  
  Shirt
    +--------+------------+--------+
    | fabric | undershirt | fabric |
    +--------+------------+--------+
    | fabric | yarn spool | fabric |
    +--------+------------+--------+
    +        +            +        +
    +--------+------------+--------+
  
  Pants
    +--------+------------+--------+
    | fabric |   fabric   | fabric |
    +--------+------------+--------+
    | fabric | yarn spool | fabric |
    +--------+------------+--------+
    | fabric |            | fabric |
    +--------+------------+--------+
  
  Cape
    +--------+--------+------------+
    | fabric | fabric | yarn spool |
    +-----------------+------------+
    | fabric | fabric |            |
    +--------+--------+------------+
    | fabric | fabric |            |
    +--------+--------+------------+
  
  Hood mask
    +--------+------------+--------+
    | fabric |   fabric   | fabric |
    +--------+------------+--------+
    |        |   fabric   |        |
    +--------+------------+--------+
    | fabric | yarn spool | fabric |
    +--------+------------+--------+
  
  Right glove
    +------------+--------+-+
    | yarn spool | fabric | |
    +------------+--------+-+
    +            +        + |
    +------------+--------+-+
    +            +        + |
    +------------+--------+-+
  
  Left glove
    +--------+------------+-+
    | fabric | yarn spool | |
    +--------+------------+-+
    +        +            + |
    +--------+------------+-+
    +        +            + |
    +--------+------------+-+
  
  Shirt with short sleeve (shortshirt)
    +--------+------------+--------+
    | fabric | undershirt | fabric |
    +--------+------------+--------+
    |        | yarn spool |        |
    +--------+------------+--------+
  
  Undershirt
    +--------+------------+--------+
    | fabric | yarn spool | fabric |
    +--------+------------+--------+
    | fabric |   fabric   | fabric |
    +--------+------------+--------+
    | fabric |   fabric   | fabric |
    +--------+------------+--------+
  
  Shorts
    +--------+------------+--------+
    |        | yarn spool |        |
    +--------+------------+--------+
    | fabric |   fabric   | fabric |
    +--------+------------+--------+
    | fabric |            | fabric |
    +--------+------------+--------+
  
  Pictures
    - pictures for shirt or cape
    - embroidery by colored yarns
    
    Minetest logo
      +-------+-------+------------+
      | green | cloth | dark green |
      +-------+-------+------------+
      | brown | green | yellow     |
      +-------+-------+------------+
      | black | blue  | grey       |
      +-------+-------+------------+

Configuration
-------------

Craft registration can disabled by adding `clothing_enable_craft = false` to
your minetest.conf file.


# we_maze

a command to create 2d mazes using worldedit.

you can specify material(s), path width, wall width, algorithm, and a seed.

e.g.
```
//maze default:stone,default:cobble air 3 2 wilsons 7717
```

makes a maze where the nodes in the walls are randomly cobble or stone, the passages are air, the width of a path is
3, the width of the walls is 2, and 7717 is a seed (to generate the same maze consistently). note that if a seed is
provided, the maze will only be identical if the x/z size is identical.

note that mazes lack floors or ceilings, or entrances or exits. those can be added via other worldedit commands, e.g.
```
//fp set1
```

supported algorithms:

* wilsons (default)

  this produces the most balanced mazes - all possible mazes are equally likely

  ```
  █████████████████████
  █           █       █
  █ █████ ███ ███ ███ █
  █   █ █   █     █   █
  █████ █████ ███ █ █ █
  █       █     █ █ █ █
  █ ███████ █████████ █
  █   █         █     █
  █ ███ █ ███████ ███ █
  █     █       █   █ █
  █████████████████████
  ```

* backtrack

  this tends to produce mazes with long paths and few dead ends

  ```
  █████████████████████
  █   █   █         █ █
  █ █ █ █ ███ █ ███ █ █
  █ █   █   █ █   █   █
  █ ███████ █ ███ █████
  █   █   █ █   █     █
  █ █ █ ███ █████ ███ █
  █ █ █     █   █ █   █
  █ █ ███ ███ █ ███ █ █
  █ █   █     █     █ █
  █████████████████████
  ```

* prims

  this tends to produce mazes with short paths and lots of dead ends

  ```
  █████████████████████
  █             █     █
  ███████ █████ ███ ███
  █   █   █           █
  ███ ███████████ █ ███
  █   █ █         █   █
  ███ █ ███ █████ █ ███
  █       █ █     █   █
  ███ ███ █ ███ ███ ███
  █   █     █   █     █
  █████████████████████
  ```

* random

  this will randomly choose one of the above algorithms.

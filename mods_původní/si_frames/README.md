# Superimposed Window Frames - si_frames

This mod is a fork of [Smacker's `si_frames` mod](https://github.com/h-v-smacker/si_frames) and is backward-compactible.

This mod provides a small assortment of window frames that can be added to any xpane-like
glass surface. The object itself is shifted relatively to the placing position, so the result
is both objects sharing the same space, as if the glass is inside the frame. While this isn't
particularly useful with obsidian glass, regular and stained glass types produce the desired
effect.

Currently, woods from [Minetest Game](https://content.minetest.net/packages/Minetest/minetest_game/),
[Ethereal](https://content.minetest.net/packages/TenPlus1/ethereal/), [Maple](https://content.minetest.net/packages/Duvalon/maple/)
and [MineClone2](https://content.minetest.net/packages/Wuzzy/mineclone2/) are supported.

## How to use

Stand in front of the glass pane and place the frame on it. To remove, use the hitbox
that will appear in front of the glass. It is slightly smaller than a regular node box to
make it easier to tell apart.

Regular square frame (▢):

```
stick,   stick,            stick
stick,   %wood_planks%,    stick
stick,   stick,            stick
```

Quartered square frame (▢ + ✛):

```
"",      stick,            ""
stick,   %wood_planks%,    stick
"",      stick,            ""
```

Diagonally quartered frame (▢ + ✕):

```
stick,   "",               stick
"",      %wood_planks%,    ""
stick,   "",               stick
```

Rhombus frame (▢ + ◇):

```
"",      stick,            stick
"",      %wood_planks%,    ""
stick,   stick,            ""
```

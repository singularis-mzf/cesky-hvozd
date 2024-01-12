Books Redux Mod v1.0
By Leslie Krause

Books Redux is full rewrite of default books from Minetest Game, offering players a rich 
selection of books and papers for in-game communication.

 * Choose from 4 different cover and page styles for books
 * Choose from 12 different page styles for papers
 * Choose from a wide variety of background color schemes
 * Page sizes can range from small, large, wide, and tall
 * Bookmarks can be added, removed, or recalled on-the-fly
 * Edits to books and papers can be previewed before saving
 * Simple page navigation for editing and viewing books
 * All content is encrypted using a 128-bit block cipher
 * Legacy books can still be viewed in compatibility mode

Even better still, books and papers are both easily craftable using the same traditional 
recipes as before: 3 papyrus for one paper, and 3 paper for one book.

With so many possible combinations of sizes, colors, and styles, the design possibilities 
are virtually endless! Moreover, custom layout and formatting of text is also possible 
using the Bedrock Markup Language. In fact, the editor for books and papers should be 
very familiar to those accustomed to the Signs Redux mod.

https://forum.minetest.net/viewtopic.php?f=9&t=23955

Of course, plain-text messages are acceptable as well, as they will render exactly as 
they are input, without any fancy colors or styles. Then again, that would be boring ;)

Now for an important word about security....

Last year one of my more vigilant players made me aware that it is possible for anyone 
to inspect locked chests on servers with only basic CSM knowledge. This means that 
confidential information in written books is vulnerable to intrusion.

Fortunately, Books Redux addresses this very concern by encrypting the content of all
written books and written papers via the Simple Cipher mod. This means that if anyone
gains access to a copy of the map, without the server operator's private key, they
won't be able to examine the personal correspondence of other players.

Currently there is no way to automatically convert legacy books to the new format. It
must be done manually by copying and pasting text into a new book.


Repository
----------------------

Browse source code:
  https://bitbucket.org/sorcerykid/books_rx

Download archive:
  https://bitbucket.org/sorcerykid/books_rx/get/master.zip
  https://bitbucket.org/sorcerykid/books_rx/get/master.tar.gz

Compatability
----------------------

Minetest 0.4.15+ required

Dependencies
----------------------

Default Mod (required)
  https://github.com/minetest-game-mods/default

ActiveFormspecs Mod (required)
  https://bitbucket.org/sorcerykid/formspecs

Bedrock Markup Language Mod (required)
  https://bitbucket.org/sorcerykid/markup

Safety Deposit Mod (required)
  https://bitbucket.org/sorcerykid/safety_deposit

Installation
----------------------

  1) Unzip the archive into the mods directory of your game
  2) Rename the books_rx-master directory to "books_rx"


Source Code License
----------------------------------------------------------

GNU Lesser General Public License v3 (LGPL-3.0)

Copyright (c) 2019-2020, Leslie E. Krause

This program is free software; you can redistribute it and/or modify it under the terms of
the GNU Lesser General Public License as published by the Free Software Foundation; either
version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU Lesser General Public License for more details.

http://www.gnu.org/licenses/lgpl-2.1.html


Multimedia License (textures, sounds, and models)
----------------------------------------------------------

Attribution-ShareAlike 3.0 Unported (CC BY-SA 3.0)

   /textures/default_paper_written.png
   obtained from https://github.com/Mossmanikin/memorandum
   by Mossmanikin
   modified by sorcerykid

   /textures/book_classic_cover.png
   obtained from https://www.onlygfx.com/7-old-book-open-textures-jpg/
   by zolee
   modified by sorcerykid

   /textures/book_classic_front.png
   obtained from https://colorlava.com/freebies/book-cover-texture-designs/
   modified by sorcerykid

   /textures/book_plain_cover.png
   obtained from https://www.onlygfx.com/7-old-book-open-textures-jpg/
   by zolee
   modified by sorcerykid

   /textures/book_plain_front.png
   obtained from https://colorlava.com/freebies/book-cover-texture-designs/
   modified by sorcerykid

   /textures/book_vintage_cover.png
   obtained from https://www.onlygfx.com/7-old-book-open-textures-jpg/
   by zolee
   modified by sorcerykid

   /textures/book_vintage_front.png
   obtained from https://colorlava.com/freebies/book-cover-texture-designs/
   modified by sorcerykid

   /textures/paper_classic1.png
   obtained from http://designbeep.com/2012/09/24/40-free-high-resolution-old-book-textures-for-designers/
   modified by sorcerykid

   /textures/paper_classic2.png
   obtained from http://designbeep.com/2012/09/24/40-free-high-resolution-old-book-textures-for-designers/
   modified by sorcerykid

   /textures/paper_plain1.png
   obtained from http://designbeep.com/2012/09/24/40-free-high-resolution-old-book-textures-for-designers/
   modified by sorcerykid

   /textures/paper_plain2.png
   obtained from http://designbeep.com/2012/09/24/40-free-high-resolution-old-book-textures-for-designers/
   modified by sorcerykid

   /textures/paper_vintage1.png
   obtained from http://designbeep.com/2012/09/24/40-free-high-resolution-old-book-textures-for-designers/
   modified by sorcerykid

   /textures/paper_vintage2.png
   obtained from http://designbeep.com/2012/09/24/40-free-high-resolution-old-book-textures-for-designers/
   modified by sorcerykid

   /textures/paper_vintage3.png
   obtained from http://designbeep.com/2012/09/24/40-free-high-resolution-old-book-textures-for-designers/
   modified by sorcerykid

   /textures/paper_vintage4.png
   obtained from http://designbeep.com/2012/09/24/40-free-high-resolution-old-book-textures-for-designers/
   modified by sorcerykid


You are free to:
Share — copy and redistribute the material in any medium or format.
Adapt — remix, transform, and build upon the material for any purpose, even commercially.
The licensor cannot revoke these freedoms as long as you follow the license terms.

Under the following terms:

Attribution — You must give appropriate credit, provide a link to the license, and
indicate if changes were made. You may do so in any reasonable manner, but not in any way
that suggests the licensor endorses you or your use.

No additional restrictions — You may not apply legal terms or technological measures that
legally restrict others from doing anything the license permits.

Notices:

You do not have to comply with the license for elements of the material in the public
domain or where your use is permitted by an applicable exception or limitation.
No warranties are given. The license may not give you all of the permissions necessary
for your intended use. For example, other rights such as publicity, privacy, or moral
rights may limit how you use the material.

For more details:
http://creativecommons.org/licenses/by-sa/3.0/

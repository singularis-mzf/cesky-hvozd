-- SPDX-FileCopyrightText: 2022 David Hurka <doxydoxy@mailbox.org>
--
-- SPDX-License-Identifier: MIT OR LGPL-2.1-or-later

return {
    {
        -- Short description
        "Single digit";
        -- Display string input
        "1";
        -- Expected texture string (with autotest mocks)
        "vlnd_transparent.png^[resize:128x26^[combine:128x26:0,0={vlnd_pixel.png^[multiply:#1e00ff^[resize:25x26^[combine:25x17:11,9={[combine:5x8:0,0=1.png^[colorize:#ffffff}}";
        -- Display configuration: max_width, height, level
        { 128, 26, "number" };
    };
    {
        "Subway wagon colors";
        "2";
        "vlnd_transparent.png^[resize:128x26^[combine:128x26:0,0={vlnd_pixel.png^[multiply:#ff001e^[resize:25x26^[combine:25x17:11,9={[combine:5x8:0,0=2.png^[colorize:#ffffff}}";
        { 128, 26, "number" };
    };
    {
        "Leading non-digits";
        "U3";
        "vlnd_transparent.png^[resize:128x26^[combine:128x26:0,0={vlnd_pixel.png^[multiply:#7f007f^[resize:26x26^[combine:26x17:9,9={[combine:10x8:0,0=U3.png^[colorize:#ffffff}}";
        { 128, 26, "number" };
    };
    {
        "Trailing non-digits";
        "4a";
        "vlnd_transparent.png^[resize:128x26^[combine:128x26:0,0={vlnd_pixel.png^[multiply:#007f00^[resize:26x26^[combine:26x17:9,9={[combine:10x8:0,0=4a.png^[colorize:#ffffff}}";
        { 128, 26, "number" };
    };
    {
        "Square background";
        "{square|5}";
        "vlnd_transparent.png^[resize:128x26^[combine:128x26:0,0={vlnd_pixel.png^[multiply:#d19f47^[resize:25x26^[combine:25x19:8,7={vlnd_pixel.png^[resize:9x12^[multiply:#ffa400}:11,9={[combine:5x8:0,0=5.png}}";
        { 128, 26, "number" };
    };
    {
        "Round, diamond background";
        "{round|Line} {diamond|6}";
        "vlnd_transparent.png^[resize:128x26^[combine:128x26:0,0={vlnd_pixel.png^[multiply:#d1d147^[resize:39x26^[combine:39x25:0,1={vlnd_circle.png^[resize:24x24^[multiply:#ffff00}:3,9={[combine:20x8:0,0=Line.png}:26,6={vlnd_diamond.png^[resize:13x13^[multiply:#ffff00}:31,8={[combine:5x8:0,0=6.png}}";
        { 128, 26, "number" };
    };
    {
        "Outlined background";
        "{square_outlined|Outlined} {round_outlined|7th} {diamond_outlined|Line}";
        "vlnd_transparent.png^[resize:128x26^[combine:128x26:0,0={vlnd_pixel.png^[multiply:#797979^[resize:115x26^[combine:115x26:0,5={[combine:48x16:0,0={vlnd_pixel.png^[resize:48x16}:2,2={vlnd_pixel.png^[resize:44x12^[multiply:#797979}}:5,9={[combine:40x8:0,0=Outlined.png^[colorize:#ffffff}:50,1={[combine:24x24:0,0={vlnd_circle.png^[resize:24x24}:2,2={vlnd_circle.png^[resize:20x20^[multiply:#797979}}:55,9={[combine:15x8:0,0=7th.png^[colorize:#ffffff}:76,0={[combine:39x26:0,0={vlnd_diamond.png^[resize:39x26}:3,2={vlnd_diamond.png^[resize:33x22^[multiply:#797979}}:86,9={[combine:20x8:0,0=Line.png^[colorize:#ffffff}}";
        { 128, 26, "number" };
    };
    {
        "Text section";
        "{<>|8}; some Destination";
        "vlnd_transparent.png^[resize:128x26^[combine:128x26:0,0={vlnd_pixel.png^[multiply:#a6298c^[resize:95x26^[combine:95x19:0,6={vlnd_diamond.png^[resize:13x13^[multiply:#ff1ed0}:5,8={[combine:5x8:0,0=8.png}:16,9={[combine:80x8:0,0=some Destination.png}}";
        { 128, 26, "text" };
    };
    {
        "Details section";
        "{[]|9}\nsome Destination\nvia {<>|some} stopover";
        "vlnd_transparent.png^[resize:256x52^[combine:256x52:0,0={vlnd_pixel.png^[multiply:#2baea3^[resize:182x52^[combine:182x52:0,14={vlnd_pixel.png^[resize:18x24^[multiply:#00c0b1}:6,18={[combine:5x8:0,0=9.png^[resize:10x16}:24,0={[combine:80x8:0,0=some Destination.png^[resize:160x16}:53,30={[combine:15x8:0,0=via.png}:72,16={vlnd_diamond.png^[resize:36x36^[multiply:#00c0b1}:81,30={[combine:20x8:0,0=some.png}:113,30={[combine:40x8:0,0=stopover.png}}";
        { 128, 26, "details" };
    };
    {
        "Color algorithm";
        "10";
        "vlnd_transparent.png^[resize:128x26^[combine:128x26:0,0={vlnd_pixel.png^[multiply:#063b5c^[resize:26x26^[combine:26x17:9,9={[combine:10x8:0,0=10.png^[colorize:#ffffff}}";
        { 128, 26, "number" };
    };
    {
        "Background features 1";
        "{stroke_13_background|11}";
        "vlnd_transparent.png^[resize:128x26^[combine:128x26:0,0={vlnd_pixel.png^[multiply:#499ca5^[resize:26x26^[combine:26x17:8,9={vlnd_stroke_13.png^[resize:10x8^[multiply:#ff2222}:9,9={[combine:10x8:0,0=11.png}}";
        { 128, 26, "number" };
    };
    {
        "Background features 2";
        "{[]|stroke_24_background|12}";
        "vlnd_transparent.png^[resize:128x26^[combine:128x26:0,0={vlnd_pixel.png^[multiply:#67d4c6^[resize:26x26^[combine:26x20:6,6={vlnd_pixel.png^[resize:14x14^[multiply:#8cfdee}:8,9={vlnd_stroke_24.png^[resize:10x8^[multiply:#ff2222}:9,9={[combine:10x8:0,0=12.png}}";
        { 128, 26, "number" };
    };
    {
        "Background features 3";
        "{stroke_background|[]|13}";
        "vlnd_transparent.png^[resize:128x26^[combine:128x26:0,0={vlnd_pixel.png^[multiply:#705349^[resize:26x26^[combine:26x20:6,6={vlnd_pixel.png^[resize:14x14^[multiply:#cf5f38}:8,9={vlnd_stroke.png^[resize:10x8^[multiply:#000000}:9,9={[combine:10x8:0,0=13.png^[colorize:#ffffff}}";
        { 128, 26, "number" };
    };
    {
        "Foreground features";
        "{/|[]|14}; towards A; via {-|B}";
        "vlnd_transparent.png^[resize:256x52^[combine:256x52:0,0={vlnd_pixel.png^[multiply:#44a783^[resize:122x52^[combine:122x40:0,12={vlnd_pixel.png^[resize:28x28^[multiply:#13c081}:6,18={[combine:10x8:0,0=14.png^[resize:20x16}:4,18={vlnd_stroke_13.png^[resize:20x16^[multiply:#ff2222}:34,14={[combine:45x8:0,0=towards A.png^[resize:90x16}:65,30={[combine:15x8:0,0=via.png}:85,30={[combine:5x8:0,0=B.png}:84,30={vlnd_stroke.png^[resize:5x8^[multiply:#ff2222}}";
        { 128, 26, "details" };
    };
    {
        "Background patterns 1";
        "{()|upper|15}";
        "vlnd_transparent.png^[resize:128x26^[combine:128x26:0,0={vlnd_pixel.png^[multiply:#735ca9^[resize:26x26^[combine:26x21:5,5={vlnd_circle.png^[resize:16x16^[multiply:#5622ca^(vlnd_upper.png^[resize:16x16^[mask:{vlnd_circle.png^[resize:16x16}^[multiply:#ffaaff)}:9,9={[combine:10x8:0,0=15.png^[colorize:#ffffff}}";
        { 128, 26, "number" };
    };
    {
        "Background patterns 2";
        "{()|4|16}";
        "vlnd_transparent.png^[resize:128x26^[combine:128x26:0,0={vlnd_pixel.png^[multiply:#877b3e^[resize:26x26^[combine:26x21:5,5={vlnd_circle.png^[resize:16x16^[multiply:#ffaaff^(vlnd_corner_2.png^[resize:16x16^[mask:{vlnd_circle.png^[resize:16x16}^[multiply:#998314)}:9,9={[combine:10x8:0,0=16.png^[colorize:#ffffff}}";
        { 128, 26, "number" };
    };
    {
        "Background patterns 3";
        "{lower_left|()|17}";
        "vlnd_transparent.png^[resize:128x26^[combine:128x26:0,0={vlnd_pixel.png^[multiply:#9ca053^[resize:26x26^[combine:26x21:5,5={vlnd_circle.png^[resize:16x16^(vlnd_corner_1.png^[resize:16x16^[mask:{vlnd_circle.png^[resize:16x16}^[multiply:#dce45d)}:9,9={[combine:10x8:0,0=17.png}}";
        { 128, 26, "number" };
    };
    {
        "Background patterns 4";
        "{left|round|18}";
        "vlnd_transparent.png^[resize:128x26^[combine:128x26:0,0={vlnd_pixel.png^[multiply:#50628e^[resize:26x26^[combine:26x21:5,5={vlnd_circle.png^[resize:16x16^[multiply:#2046a6^(vlnd_left.png^[resize:16x16^[mask:{vlnd_circle.png^[resize:16x16}^[multiply:#ffaaff)}:9,9={[combine:10x8:0,0=18.png^[colorize:#ffffff}}";
        { 128, 26, "number" };
    };
    {
        "Background patterns 5";
        "{round|24|19}";
        "vlnd_transparent.png^[resize:128x26^[combine:128x26:0,0={vlnd_pixel.png^[multiply:#4f81b6^[resize:26x26^[combine:26x21:5,5={vlnd_circle.png^[resize:16x16^[multiply:#63a7ef^(vlnd_plus.png^[resize:16x16^[mask:{vlnd_circle.png^[resize:16x16})}:9,9={[combine:10x8:0,0=19.png}}";
        { 128, 26, "number" };
    };
    {
        "Background patterns 6";
        "{()|left_right|20}";
        "vlnd_transparent.png^[resize:128x26^[combine:128x26:0,0={vlnd_pixel.png^[multiply:#963250^[resize:26x26^[combine:26x21:5,5={vlnd_circle.png^[resize:16x16^[multiply:#550000^(vlnd_x.png^[resize:16x16^[mask:{vlnd_circle.png^[resize:16x16}^[multiply:#a60939)}:9,9={[combine:10x8:0,0=20.png^[colorize:#ffffff}}";
        { 128, 26, "number" };
    };
    {
        "Background patterns 7";
        "{()|upper_left|21} {()|lower_right|21}";
        "vlnd_transparent.png^[resize:128x26^[combine:128x26:0,0={vlnd_pixel.png^[multiply:#ad5868^[resize:34x26^[combine:34x21:0,5={vlnd_circle.png^[resize:16x16^(vlnd_corner_2.png^[resize:16x16^[mask:{vlnd_circle.png^[resize:16x16}^[multiply:#e96a82)}:4,9={[combine:10x8:0,0=21.png}:18,5={vlnd_circle.png^[resize:16x16^[multiply:#e96a82^(vlnd_corner_2.png^[resize:16x16^[mask:{vlnd_circle.png^[resize:16x16})}:22,9={[combine:10x8:0,0=21.png}}";
        { 128, 26, "number" };
    };
    {
        "Background patterns 8";
        "{upper_left_lower_right|()|22};; {upper_right_lower_left|()|22}";
        "vlnd_transparent.png^[resize:256x52^[combine:256x52:0,0={vlnd_pixel.png^[multiply:#6ca4a4^[resize:52x52^[combine:52x42:0,10={vlnd_circle.png^[resize:32x32^[multiply:#2dcbcb^(vlnd_plus.png^[resize:32x32^[mask:{vlnd_circle.png^[resize:32x32})}:8,18={[combine:10x8:0,0=22.png^[resize:20x16}:36,18={vlnd_circle.png^[resize:16x16^(vlnd_plus.png^[resize:16x16^[mask:{vlnd_circle.png^[resize:16x16}^[multiply:#2dcbcb)}:40,22={[combine:10x8:0,0=22.png}}";
        { 128, 26, "details" };
    };
    {
        "Background patterns 9";
        "{_()_|upper_left_lower_right|23} {_[]_|upper_right_lower_left|23}";
        "vlnd_transparent.png^[resize:128x26^[combine:128x26:0,0={vlnd_pixel.png^[multiply:#702d15^[resize:40x26^[combine:40x23:0,3={[combine:20x20:0,0={vlnd_circle.png^[resize:20x20}:2,2={vlnd_circle.png^[resize:16x16^[multiply:#702d15^(vlnd_plus.png^[resize:16x16^[mask:{vlnd_circle.png^[resize:16x16}^[multiply:#ffaaff)}}:6,9={[combine:10x8:0,0=23.png^[colorize:#ffffff}:22,5={[combine:18x16:0,0={vlnd_pixel.png^[resize:18x16}:2,2={vlnd_pixel.png^[resize:14x12^[multiply:#ffaaff^(vlnd_plus.png^[resize:14x12^[multiply:#702d15)}}:27,9={[combine:10x8:0,0=23.png^[colorize:#ffffff}}";
        { 128, 26, "number" };
    };
    {
        "Background patterns 10";
        "{_()_|upper_lower|24} {_<>_|left_right|upper_lower|24}";
        "vlnd_transparent.png^[resize:256x52^[combine:256x52:0,0={vlnd_pixel.png^[multiply:#b38e5e^[resize:224x52^[combine:224x52:0,6={[combine:40x40:0,0={vlnd_circle.png^[resize:40x40^[multiply:#000000}:3,3={vlnd_circle.png^[resize:34x34^[multiply:#b38e5e^(vlnd_x.png^[resize:34x34^[mask:{vlnd_circle.png^[resize:34x34})}}:12,18={[combine:10x8:0,0=24.png^[resize:20x16}:44,0={[combine:180x52:0,0={vlnd_diamond.png^[resize:180x52^[multiply:#000000}:11,3={vlnd_diamond.png^[resize:158x46^(vlnd_x.png^[resize:158x46^[mask:{vlnd_diamond.png^[resize:158x46}^[multiply:#b38e5e)}}:82,20={[combine:70x8:0,0=upper_lower|24.png^[resize:105x12}}";
        { 128, 26, "number" };
    };
    {
        "Double space line breaks 1";
        "Line  25";
        "vlnd_transparent.png^[resize:128x26^[combine:128x26:0,0={vlnd_pixel.png^[multiply:#f6efa7^[resize:26x26^[combine:26x21:4,5={[combine:20x16:0,0=Line\n25.png}}";
        { 128, 26, "number" };
    };
    {
        "Double space line breaks 2";
        "{<>|Line  26}; to  A; {via  B}";
        "vlnd_transparent.png^[resize:256x52^[combine:256x52:0,0={vlnd_pixel.png^[multiply:#3b48a1^[resize:72x52^[combine:72x50:0,2={vlnd_diamond.png^[resize:48x48^[multiply:#3a51f0}:10,14={[combine:20x16:0,0=Line\n26.png^[colorize:#ffffff^[resize:30x24}:54,2={[combine:10x16:0,0=to\nA.png^[colorize:#ffffff^[resize:20x32}:55,34={[combine:15x16:0,0=via\nB.png^[colorize:#ffffff}}";
        { 128, 26, "details" };
    };
    {
        "Entities 1";
        "{<>|Line {sp}27}; to {space}A; {via{nl}B}";
        "vlnd_transparent.png^[resize:256x52^[combine:256x52:0,0={vlnd_pixel.png^[multiply:#849075^[resize:188x52^[combine:188x52:0,0={vlnd_diamond.png^[resize:134x52^[multiply:#7db23a}:29,18={[combine:40x8:0,0=Line  27.png^[resize:80x16}:140,10={[combine:25x8:0,0=to  A.png^[resize:50x16}:155,26={[combine:15x16:0,0=via\nB.png}}";
        { 128, 26, "details" };
    };
    {
        "Entities 2";
        "{<>|Line {}28}; to {space}A; via{NewLine}B";
        "vlnd_transparent.png^[resize:256x52^[combine:256x52:0,0={vlnd_pixel.png^[multiply:#a74584^[resize:204x52^[combine:204x52:0,0={vlnd_diamond.png^[resize:150x52^[multiply:#c01483}:32,18={[combine:45x8:0,0=Line {}28.png^[colorize:#ffffff^[resize:90x16}:156,10={[combine:25x8:0,0=to  A.png^[colorize:#ffffff^[resize:50x16}:171,26={[combine:15x16:0,0=via\nB.png^[colorize:#ffffff}}";
        { 128, 26, "details" };
    };
    {
        "Entities 3";
        "{_<>_|{bar}29\\|}";
        "vlnd_transparent.png^[resize:128x26^[combine:128x26:0,0={vlnd_pixel.png^[multiply:#0475cc^[resize:39x26^[combine:39x26:0,0={[combine:39x26:0,0={vlnd_diamond.png^[resize:39x26}:3,2={vlnd_diamond.png^[resize:33x22^[multiply:#0475cc}}:10,9={[combine:20x8:0,0=|29|.png^[colorize:#ffffff}}";
        { 128, 26, "number" };
    };
    {
        "HTML 4 entities";
        "30; K{ouml}ln";
        "vlnd_transparent.png^[resize:128x26^[combine:128x26:0,0={vlnd_pixel.png^[multiply:#47d616^[resize:37x26^[combine:37x17:1,9={[combine:10x8:0,0=30.png^[colorize:#ffffff}:13,9={[combine:25x8:0,0=Köln.png^[colorize:#ffffff}}";
        { 128, 26, "text" };
    };
    {
        "HTML 5 entities";
        "31; {OpenCurlyDoubleQuote}Island{CloseCurlyDoubleQuote}";
        "vlnd_transparent.png^[resize:128x26^[combine:128x26:0,0={vlnd_pixel.png^[multiply:#8a385f^[resize:72x26^[combine:72x17:1,9={[combine:10x8:0,0=31.png^[colorize:#ffffff}:13,9={[combine:60x8:0,0=“Island”.png^[colorize:#ffffff}}";
        { 128, 26, "text" };
    };
    {
        "Missing glyph entities";
        "32; {{num} {sharp}}";
        "vlnd_transparent.png^[resize:128x26^[combine:128x26:0,0={vlnd_pixel.png^[multiply:#cd99a8^[resize:57x26^[combine:57x17:1,9={[combine:10x8:0,0=32.png}:13,9={[combine:45x8:0,0=# {sharp}.png}}";
        { 128, 26, "text" };
    };
    {
        "Numeric entities 1";
        "33; No {#32}line{#x20} breaks";
        "vlnd_transparent.png^[resize:128x26^[combine:128x26:0,0={vlnd_pixel.png^[multiply:#11faf1^[resize:92x26^[combine:92x17:1,9={[combine:10x8:0,0=33.png}:13,9={[combine:80x8:0,0=No  line  breaks.png}}";
        { 128, 26, "text" };
    };
    {
        "Numeric entities 2";
        "34; {#08216}Island{#x002019}";
        "vlnd_transparent.png^[resize:128x26^[combine:128x26:0,0={vlnd_pixel.png^[multiply:#545c3b^[resize:72x26^[combine:72x17:1,9={[combine:10x8:0,0=34.png^[colorize:#ffffff}:13,9={[combine:60x8:0,0=‘Island’.png^[colorize:#ffffff}}";
        { 128, 26, "text" };
    };
    {
        "Color brace sequences 1";
        "{<>|{background:#ffffff}35}; {text:#ffaa00}Orange";
        "vlnd_transparent.png^[resize:128x26^[combine:128x26:0,0={vlnd_pixel.png^[multiply:#97bd84^[resize:49x26^[combine:49x21:0,4={vlnd_diamond.png^[resize:17x17}:4,8={[combine:10x8:0,0=35.png}:20,9={[combine:30x8:0,0=Orange.png^[colorize:#ffaa00}}";
        { 128, 26, "text" };
    };
    {
        "Color brace sequences 2";
        "{<>|b:#000|36}; {t:#ffaa00}Orange";
        "vlnd_transparent.png^[resize:128x26^[combine:128x26:0,0={vlnd_pixel.png^[multiply:#da1fcd^[resize:49x26^[combine:49x21:0,4={vlnd_diamond.png^[resize:17x17^[multiply:#000000}:4,8={[combine:10x8:0,0=36.png^[colorize:#ffffff}:20,9={[combine:30x8:0,0=Orange.png^[colorize:#ffaa00}}";
        { 128, 26, "text" };
    };
    {
        "Color brace sequences 3";
        "{<>|37}{b:#00f}; Text";
        "vlnd_transparent.png^[resize:128x26^[combine:128x26:0,0={vlnd_pixel.png^[multiply:#0000ff^[resize:39x26^[combine:39x21:0,4={vlnd_diamond.png^[resize:17x17^[multiply:#1e8017}:4,8={[combine:10x8:0,0=37.png^[colorize:#ffffff}:20,9={[combine:20x8:0,0=Text.png^[colorize:#ffffff}}";
        { 128, 26, "text" };
    };
    {
        "Color brace sequences 4";
        "{b:#00f}{<>|38}; Text";
        "vlnd_transparent.png^[resize:128x26^[combine:128x26:0,0={vlnd_pixel.png^[multiply:#4747d1^[resize:39x26^[combine:39x21:0,4={vlnd_diamond.png^[resize:17x17^[multiply:#0000ff}:4,8={[combine:10x8:0,0=38.png^[colorize:#ffffff}:20,9={[combine:20x8:0,0=Text.png^[colorize:#ffffff}}";
        { 128, 26, "text" };
    };
    {
        "Color brace sequences 5";
        "{<>|39}{t:#00f}; Text";
        "vlnd_transparent.png^[resize:128x26^[combine:128x26:0,0={vlnd_pixel.png^[multiply:#b04fb5^[resize:39x26^[combine:39x21:0,4={vlnd_diamond.png^[resize:17x17^[multiply:#a443a9}:4,8={[combine:10x8:0,0=39.png^[colorize:#ffffff}:20,9={[combine:20x8:0,0=Text.png^[colorize:#0000ff}}";
        { 128, 26, "text" };
    };
    {
        "Color brace sequences 6";
        "{t:#00f}{<>|40}; Text";
        "vlnd_transparent.png^[resize:128x26^[combine:128x26:0,0={vlnd_pixel.png^[multiply:#bb85c4^[resize:39x26^[combine:39x21:0,4={vlnd_diamond.png^[resize:17x17^[multiply:#e7a4f2}:4,8={[combine:10x8:0,0=40.png^[colorize:#0000ff}:20,9={[combine:20x8:0,0=Text.png^[colorize:#0000ff}}";
        { 128, 26, "text" };
    };
    {
        "“all” color brace sequence 1";
        "{all:1}{<>|41}; Text";
        "vlnd_transparent.png^[resize:128x26^[combine:128x26:0,0={vlnd_pixel.png^[multiply:#5747d1^[resize:39x26^[combine:39x21:0,4={vlnd_diamond.png^[resize:17x17^[multiply:#1e00ff}:4,8={[combine:10x8:0,0=41.png^[colorize:#ffffff}:20,9={[combine:20x8:0,0=Text.png^[colorize:#ffffff}}";
        { 128, 26, "text" };
    };
    {
        "“all” color brace sequence 2";
        "{<>|42}; {_[]_|Some} {a:1} {_[]_|Text}";
        "vlnd_transparent.png^[resize:128x26^[combine:128x26:0,0={vlnd_pixel.png^[multiply:#7a7391^[resize:77x26^[combine:77x21:0,4={vlnd_diamond.png^[resize:17x17^[multiply:#6e6785}:4,8={[combine:10x8:0,0=42.png^[colorize:#ffffff}:19,5={[combine:28x16:0,0={vlnd_pixel.png^[resize:28x16}:2,2={vlnd_pixel.png^[resize:24x12^[multiply:#6e6785}}:24,9={[combine:20x8:0,0=Some.png^[colorize:#ffffff}:49,5={[combine:28x16:0,0={vlnd_pixel.png^[resize:28x16}:2,2={vlnd_pixel.png^[resize:24x12^[multiply:#1e00ff}}:54,9={[combine:20x8:0,0=Text.png^[colorize:#ffffff}}";
        { 128, 26, "text" };
    };
    {
        "Referencing color brace sequences";
        "{<>|{b:\"42\"}43}; {t:\"39\"|Text}";
        "vlnd_transparent.png^[resize:128x26^[combine:128x26:0,0={vlnd_pixel.png^[multiply:#b1c8ce^[resize:39x26^[combine:39x21:0,4={vlnd_diamond.png^[resize:17x17^[multiply:#6e6785}:4,8={[combine:10x8:0,0=43.png^[colorize:#ffffff}:20,9={[combine:20x8:0,0=Text.png^[colorize:#a443a9}}";
        { 128, 26, "text" };
    };
    {
        "Explicit colors";
        "{[]|44}; {t:#0ff} {()|some} {()|text}";
        "vlnd_transparent.png^[resize:128x26^[combine:128x26:0,0={vlnd_pixel.png^[multiply:#90362f^[resize:66x26^[combine:66x25:0,6={vlnd_pixel.png^[resize:14x14^[multiply:#f42a18}:3,9={[combine:10x8:0,0=44.png^[colorize:#ffffff}:16,1={vlnd_circle.png^[resize:24x24^[multiply:#f42a18}:19,9={[combine:20x8:0,0=some.png^[colorize:#00ffff}:42,1={vlnd_circle.png^[resize:24x24^[multiply:#f42a18}:45,9={[combine:20x8:0,0=text.png^[colorize:#00ffff}}";
        { 128, 26, "text" };
    };
    {
        "Deleting explicit colors 1";
        "{[]|45}; {t:#0ff} {()|some} {t:} {()|text}";
        "vlnd_transparent.png^[resize:128x26^[combine:128x26:0,0={vlnd_pixel.png^[multiply:#44976d^[resize:66x26^[combine:66x25:0,6={vlnd_pixel.png^[resize:14x14^[multiply:#388b61}:3,9={[combine:10x8:0,0=45.png^[colorize:#ffffff}:16,1={vlnd_circle.png^[resize:24x24^[multiply:#388b61}:19,9={[combine:20x8:0,0=some.png^[colorize:#00ffff}:42,1={vlnd_circle.png^[resize:24x24^[multiply:#388b61}:45,9={[combine:20x8:0,0=text.png^[colorize:#ffffff}}";
        { 128, 26, "text" };
    };
    {
        "Deleting explicit colors 2";
        "{upper_left_lower_right|[]|secondary_background:#000|46}; {upper_left_lower_right|[]|46}";
        "vlnd_transparent.png^[resize:128x26^[combine:128x26:0,0={vlnd_pixel.png^[multiply:#65b486^[resize:30x26^[combine:30x20:0,6={vlnd_pixel.png^[resize:14x14^[multiply:#7becaa^(vlnd_plus.png^[resize:14x14^[multiply:#000000)}:3,9={[combine:10x8:0,0=46.png^[colorize:#2222ff}:16,6={vlnd_pixel.png^[resize:14x14^[multiply:#7becaa^(vlnd_plus.png^[resize:14x14)}:19,9={[combine:10x8:0,0=46.png}}";
        { 128, 26, "text" };
    };
    {
        "Syntax errors 1";
        "{[]|47}; {{broken:#123} color} {brace:sequences}";
        "vlnd_transparent.png^[resize:256x52^[combine:256x52:0,0={vlnd_pixel.png^[multiply:#8e40b4^[resize:240x52^[combine:240x36:0,14={vlnd_pixel.png^[resize:22x22^[multiply:#be4ef3}:4,19={[combine:10x8:0,0=47.png^[resize:15x12}:27,22={[combine:95x8:0,0={broken:#123} color.png}:127,20={[combine:75x8:0,0=brace:sequences.png^[resize:113x12}}";
        { 128, 26, "text" };
    };
    {
        "Syntax errors 2";
        "{[]|48}; {t:#1234} broken color brace sequence";
        "vlnd_transparent.png^[resize:256x52^[combine:256x52:0,0={vlnd_pixel.png^[multiply:#2a9f52^[resize:212x52^[combine:212x36:0,14={vlnd_pixel.png^[resize:22x22^[multiply:#02af3d}:4,19={[combine:10x8:0,0=48.png^[colorize:#ffffff^[resize:15x12}:27,22={[combine:185x8:0,0={t:#1234} broken color brace sequence.png^[colorize:#ffffff}}";
        { 128, 26, "text" };
    };
    {
        "Syntax errors 3";
        "{[]|49}}; {_[]|wrong} {{}|blocks}";
        "vlnd_transparent.png^[resize:128x26^[combine:128x26:0,0={vlnd_pixel.png^[multiply:#543779^[resize:115x26^[combine:115x20:0,6={vlnd_pixel.png^[resize:14x14^[multiply:#451186}:3,9={[combine:10x8:0,0=49.png^[colorize:#ffffff}:17,9={[combine:5x8:0,0=}.png^[colorize:#ffffff}:24,9={[combine:45x8:0,0=_[]|wrong.png^[colorize:#ffffff}:71,9={[combine:45x8:0,0={}|blocks.png^[colorize:#ffffff}}";
        { 128, 26, "text" };
    };
    {
        "Syntax errors 4";
        "{[]|50}; {No {<>|nested blocks}}";
        "vlnd_transparent.png^[resize:128x26^[combine:128x26:0,0={vlnd_pixel.png^[multiply:#614ba8^[resize:121x26^[combine:121x20:0,6={vlnd_pixel.png^[resize:14x14^[multiply:#8872cf}:3,9={[combine:10x8:0,0=50.png}:17,9={[combine:105x8:0,0=No {<>|nested blocks}.png}}";
        { 128, 26, "text" };
    };
};

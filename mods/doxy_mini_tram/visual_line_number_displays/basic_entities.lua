-- SPDX-FileCopyrightText: 2022 David Hurka <doxydoxy@mailbox.org>
--
-- SPDX-License-Identifier: MIT OR LGPL-2.1-or-later

visual_line_number_displays.basic_entities = {
    -- These are brace sequences which are necessary to escape syntax symbols.
    -- Examples: {lcurl} -> {, {slash} -> /
    lcurl = "{";
    llcurl = "{{";
    rcurl = "}";
    rrcurl = "}}";
    lbrak = "[";
    llbrak = "[[";
    rbrak = "]";
    rrbrak = "]]";
    lpar = "(";
    llpar = "((";
    rpar = ")";
    rrpar = "))";
    lt = "<";
    ltlt = "<<";
    gt = ">";
    gtgt = ">>";

    bar = "|";
    vline = "|";
    dash = "-";
    minus = "-";
    slash = "/";
    bslash = "\\";
    backslash = "\\";

    sp = " ";
    space = " ";
    nl = "\n";
    newline = "\n";

    colon = ":";
    semicolon = ";";
    sc = ";";
    equals = "=";
    equal = "=";
    eq = "=";
    quote = '"';
    hash = "#";

    underscore = "_";
    us = "_";

    -- These are HTML 4 entities, but only those available in font_metro.
    -- These entities are first stored as integer codepoint,
    -- and then converted to string (see below).
    -- (https://www.w3.org/TR/html401/sgml/entities.html)
    nbsp = 160;
    iexcl = 161;
    cent = 162;
    pound = 163;
    curren = 164;
    yen = 165;
    brvbar = 166;
    sect = 167;
    uml = 168;
    copy = 169;
    ordf = 170;
    laquo = 171;
    ["not"] = 172;
    shy = 173;
    reg = 174;
    macr = 175;
    deg = 176;
    plusmn = 177;
    sup2 = 178;
    sup3 = 179;
    acute = 180;
    micro = 181;
    para = 182;
    middot = 183;
    cedil = 184;
    sup1 = 185;
    ordm = 186;
    raquo = 187;
    frac14 = 188;
    frac12 = 189;
    frac34 = 190;
    iquest = 191;
    Agrave = 192;
    Aacute = 193;
    Acirc = 194;
    Atilde = 195;
    Auml = 196;
    Aring = 197;
    AElig = 198;
    Ccedil = 199;
    Egrave = 200;
    Eacute = 201;
    Ecirc = 202;
    Euml = 203;
    Igrave = 204;
    Iacute = 205;
    Icirc = 206;
    Iuml = 207;
    ETH = 208;
    NTilde = 209;
    Ograve = 210;
    Oacute = 211;
    Ocirc = 212;
    Otilde = 213;
    Ouml = 214;
    times = 215;
    Oslash = 216;
    Ugrave = 217;
    Uacute = 218;
    Ucirc = 219;
    Uuml = 220;
    Yacute = 221;
    THORN = 222;
    szlig = 223;
    agrave = 224;
    aacute = 225;
    acirc = 226;
    atilde = 227;
    auml = 228;
    aring = 229;
    aelig = 230;
    ccedil = 231;
    egrave = 232;
    eacute = 233;
    ecirc = 234;
    euml = 235;
    igrave = 236;
    iacute = 237;
    icirc = 238;
    iuml = 239;
    eth = 240;
    ntilde = 241;
    ograve = 242;
    oacute = 243;
    ocirc = 244;
    otilde = 245;
    ouml = 246;
    divide = 247;
    oslash = 248;
    ugrave = 249;
    uacute = 250;
    ucirc = 251;
    uuml = 252;
    yacute = 253;
    thorn = 254;
    yuml = 255;

    -- HTML 4 math and greek entities

    -- No &fnof; (&#402;)

    Alpha = 913;
    Beta = 914;
    Gamma = 915;
    Delta = 916;
    Epsilon = 917;
    Zeta = 918;
    Eta = 919;
    Theta = 920;
    Iota = 921;
    Kappa = 922;
    Lambda = 92;
    Mu = 924;
    Nu = 925;
    Xi = 926;
    Omicron = 927;
    Pi = 928;
    Rho = 929;
    -- No U+03A2
    Sigma = 931;
    Tau = 932;
    Upsilon = 933;
    Phi = 934;
    Chi = 935;
    Psi = 936;
    Omega = 937;

    alpha = 945;
    beta = 946;
    gamma = 947;
    delta = 948;
    epsilon = 949;
    zeta = 950;
    eta = 951;
    theta = 952;
    iota = 953;
    kappa = 954;
    lambda = 955;
    mu = 956;
    nu = 957;
    xi = 958;
    omicron = 959;
    pi = 960;
    rho = 961;
    sigmaf = 962;
    sigma = 963;
    tau = 964;
    upsilon = 965;
    phi = 966;
    chi = 967;
    psi = 968;
    omega = 969;

    -- No further math and greek glyphs in font_metro.

    -- HTML 4 markup significant entities
    quot = 34;
    amp = 38;
    -- lt and gt already defined above.

    OElig = 338;
    oelig = 339;
    Scaron = 352;
    scaron = 353;
    Yuml = 376;

    -- No &circ; (&#710;) and &tilde; (&#732;)

    -- Only a few of the General Punctuation entities.
    lsquo = 8216;
    rsquo = 8217;
    ldquo = 8220;
    rdquo = 8221;
    euro = 8364;

    -- And these are HTML 5 entities.
    -- (https://dev.w3.org/html5/html-author/charref)
    Tab = 9;
    NewLine = 10;
    excl = 33;
    QUOT = 34;
    num = 35;
    dollar = 36;
    percnt = 37;
    AMP = 38;
    apos = 39;
    ast = 42;
    midast = 42;
    plus = 43;
    comma = 44;
    period = 46;
    sol = 47;
    semi = 49;
    LT = 60;
    GT = 62;
    quest = 63;
    commat = 64;
    lsqb = 91;
    lbrack = 91;
    bsol = 92;
    rsqb = 93;
    rbrack = 93;
    Hat = 94;
    lowbar = 95;
    grave = 96;
    DiacriticalGrave = 97;

    lcub = 123;
    lbrace = 123;
    verbar = 124;
    vert = 124;
    VerticalLine = 124;
    rcub = 125;
    rbrace = 126;
    NonBreakingSpace = 160;
    Dot = 168;
    die = 168;
    DoubleDot = 168;
    COPY = 169;
    circledR = 174;
    REG = 174;
    OverBar = 175;
    strns = 175;
    pm = 177;
    PlusMinus = 177;
    DiacriticalAcute = 180;
    centerdot = 183;
    CenterDot = 183;
    Cedilla = 184;
    half = 189;

    div = 247;

    Amacr = 256;
    amacr = 257;
    Abreve = 258;
    abreve = 259;
    Aogon = 260;
    aogon = 261;
    Cacute = 262;
    cacute = 263;
    Ccirc = 264;
    ccirc = 265;
    Cdot = 266;
    cdot = 267;
    Ccaron = 268;
    ccaron = 269;
    Dcaron = 270;
    dcaron = 271;
    Dstrok = 272;
    dstrok = 273;
    Emacr = 274;
    emacr = 275;
    Edot = 278;
    edot = 279;
    Eogon = 280;
    eogon = 281;
    Ecaron = 282;
    ecaron = 283;
    Gcirc = 284;
    gcirc = 285;
    Gbreve = 286;
    gbreve = 287;
    Gdot = 288;
    gdot = 289;
    Gcedil = 290;
    HCirc = 292;
    hcirc = 293;
    Hstrok = 294;
    hstrok = 295;
    Itilde = 296;
    itilde = 297;
    Imacr = 298;
    imacr = 299;
    Iogon = 302;
    iogon = 303;
    Idot = 304;
    imath = 305;
    inodot = 305;
    IJlig = 306;
    ijlig = 307;
    Jcirc = 308;
    jcirc = 309;
    Kcedil = 310;
    kcedil = 311;
    kgreen = 312;
    Lacute = 313;
    lacute = 314;
    Lcedil = 315;
    lcedil = 316;
    Lcaron = 317;
    lcaron = 318;
    Lmidot = 319;
    lmidot = 320;
    Lstrok = 321;
    lstrok = 322;
    Nacute = 323;
    nacute = 324;
    Ncedil = 325;
    ncedil = 326;
    Ncaron = 327;
    ncaron = 328;
    napos = 329;
    ENG = 330;
    eng = 331;
    Omacr = 332;
    omacr = 333;
    Odblac = 336;
    odblac = 337;
    Racute = 340;
    racute = 341;
    Rcedil = 342;
    rcedil = 343;
    Rcaron = 344;
    rcaron = 345;
    Sacute = 346;
    sacute = 347;
    Scirc = 348;
    scirc = 349;
    Scedil = 350;
    scedil = 351;
    Tcedil = 354;
    tcedil = 355;
    Tcaron = 356;
    tcaron = 357;
    Tstrok = 358;
    tstrok = 359;
    Utilde = 360;
    utilde = 361;
    Umacr = 362;
    umacr = 363;
    Ubreve = 364;
    ubreve = 365;
    Uring = 366;
    uring = 367;
    Udblac = 368;
    udblac = 369;
    Uogon = 370;
    uogon = 371;
    Wcirc = 372;
    wcirc = 373;
    Ycirc = 374;
    ycirc = 375;
    Zacute = 377;
    zacute = 378;
    Zdot = 379;
    zdot = 380;
    Zcaron = 381;
    zcaron = 382;

    epsiv = 949;
    varepsilon = 949;
    sigmav = 962;
    varsigma = 962;
    upsi = 965;
    phiv = 966;
    varphi = 966;

    DJcy = 1026;
    Jukcy = 1028;

    LJcy = 1033;
    NJcy = 1034;
    TSHcy = 1035;

    DZcy = 1039;
    Acy = 1040;
    Bcy = 1041;
    Vcy = 1042;
    Gcy = 1043;
    Dcy = 1044;
    IEcy = 1045;
    ZHcy = 1046;
    Zcy = 1047;
    Icy = 1048;
    Jcy = 1049;
    Kcy = 1050;
    Lcy = 1051;
    Mcy = 1052;
    Ncy = 1053;
    Ocy = 1054;
    Pcy = 1055;
    Rcy = 1056;
    Scy = 1057;
    Tcy = 1058;
    Ucy = 1059;
    Fcy = 1060;
    KHcy = 1061;
    TScy = 1062;
    CHcy = 1063;
    SHcy = 1064;
    SHCHcy = 1065;
    HARDcy = 1066;
    Ycy = 1067;
    SOFTcy = 1068;
    Ecy = 1069;
    YUcy = 1070;
    YAcy = 1071;
    acy = 1072;
    bcy = 1073;
    vcy = 1074;
    gcy = 1075;
    dcy = 1076;
    iecy = 1077;
    zhcy = 1078;
    zcy = 1079;
    icy = 1080;
    jcy = 1081;
    kcy = 1082;
    lcy = 1083;
    mcy = 1084;
    ncy = 1085;
    ocy = 1086;
    pcy = 1087;
    rcy = 1088;
    scy = 1089;
    tcy = 1090;
    ucy = 1091;
    fcy = 1092;
    khcy = 1093;
    tscy = 1094;
    chcy = 1095;
    shcy = 1096;
    shchcy = 1097;
    hardcy = 1098;
    ycy = 1099;
    softcy = 1100;
    ecy = 1101;
    yucy = 1102;
    yacy = 1103;

    OpenCurlyQuote = 8216;
    rsquor = 8217;
    CloseCurlyQuote = 8217;

    OpenCurlyDoubleQuote = 8220;
    rdquor = 8221;
    CloseCurlyDoubleQuote = 8221;
};

local byte_2_pos = 1 / 0x40;
local byte_3_pos = 1 / 0x1000;
local byte_4_pos = 1 / 0x40000;

--! Returns a Lua string with the UTF-8 character @c codepoint.
function visual_line_number_displays.codepoint_to_string(codepoint)
    local bytes = {};
    if codepoint <= 0x7f then
        bytes[1] = codepoint;
    elseif codepoint <= 0x7ff then
        bytes[1] = 0xc0 + math.floor(codepoint * byte_2_pos);
        bytes[2] = 0x80 + codepoint % 0x40;
    elseif codepoint <= 0xffff then
        bytes[1] = 0xe0 + math.floor(codepoint * byte_3_pos);
        bytes[2] = 0x80 + math.floor(codepoint * byte_2_pos) % 0x40;
        bytes[3] = 0x80 + codepoint % 0x40;
    elseif codepoint <= 0x10ffff then
        bytes[1] = 0xf0 + math.floor(codepoint * byte_4_pos);
        bytes[2] = 0x80 + math.floor(codepoint * byte_3_pos) % 0x40;
        bytes[3] = 0x80 + math.floor(codepoint * byte_2_pos) % 0x40;
        bytes[4] = 0x80 + codepoint % 0x40;
    else
        return nil;
    end

    -- Create a Lua string.
    -- table.unpack() is too new for Minetest.
    local result = "";
    for _, b in ipairs(bytes) do
        result = result .. string.char(b);
    end

    return result;
end

for k, v in pairs(visual_line_number_displays.basic_entities) do
    if type(v) == "number" then
        visual_line_number_displays.basic_entities[k] = visual_line_number_displays.codepoint_to_string(v);
    end
end

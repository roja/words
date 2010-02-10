module Words

    # Provides a pure ruby connector to the Wordnet dataset.
    class PureWordnetConnection

	# Convert single letter POS to it's multi-letter equivilent
	SHORT_TO_POS_FILE_TYPE = { 'a' => 'adj', 'r' => 'adv', 'n' => 'noun', 'v' => 'verb' }

	# Set of indexes for seeking directly into wordnet files to identify terms with significantly improved performance
	INDEXES = {
	    :noun => {"mv"=>2908615, "fa"=>1455677, "g-"=>1695451, "hy"=>2196287, "ac"=>21116, "wr"=>4743086, "rt"=>3724403, "k_"=>2405676, "mw"=>2908680, "fb"=>1539515, "g."=>1695573, "hz"=>2219696, "ad"=>48269, "ws"=>4747643, "ru"=>3724431, "mx"=>2908742, "fc"=>1539583, "80"=>6057, "ae"=>63445, "wt"=>4747670, "rv"=>3740230, "ka"=>2405742, "l-"=>2459655, "my"=>2908771, "fd"=>1539637, "af"=>68288, "wu"=>4747756, "rw"=>3740258, "kb"=>2417524, "l."=>2459745, "fe"=>1539722, "ag"=>74279, "wv"=>4748078, "kc"=>2417632, "ah"=>83260, "ry"=>3740424, "pa"=>3143343, "36"=>5141, "ai"=>83677, "ww"=>4748110, "pb"=>3211047, "ke"=>2417664, "aj"=>91267, "v-"=>4545234, "pc"=>3211172, "fh"=>1559167, "ak"=>91562, "wy"=>4748137, "v."=>4545387, "ua"=>4496561, "pd"=>3211308, "kg"=>2427122, "fi"=>1559226, "al"=>92464, "ub"=>4496594, "pe"=>3211419, "2n"=>4947, "fj"=>1596225, "am"=>130827, "kh"=>2427183, "uc"=>4496797, "pf"=>3263095, "88"=>6083, "an"=>154839, "ki"=>2428739, "za"=>4773142, "ud"=>4496830, "fl"=>1596256, "ao"=>203539, "zb"=>4775763, "ph"=>3263286, "fm"=>1622351, "ap"=>204006, "uf"=>4496962, "pi"=>3293279, "fn"=>1622416, "aq"=>218174, "kk"=>2442519, "zd"=>4775847, "ug"=>4497019, "pj"=>3328895, "fo"=>1622444, "ar"=>219963, "kl"=>2442551, "ze"=>4775874, "uh"=>4497483, "pk"=>3328925, "fp"=>1650875, "as"=>262743, "km"=>2443913, "ui"=>4497543, "pl"=>3329011, "at"=>282628, "kn"=>2443973, "pm"=>3357376, "fr"=>1650935, "au"=>299805, "ko"=>2448754, "zh"=>4778739, "uk"=>4497767, "pn"=>3357459, "fs"=>1681993, "av"=>316371, "kp"=>2453337, "zi"=>4778934, "ul"=>4498102, "po"=>3358476, "ft"=>1682056, "aw"=>319552, "um"=>4501463, "fu"=>1682252, "ax"=>320182, "1-"=>1892, "kr"=>2453390, "un"=>4503199, "pp"=>3416671, "ay"=>321448, "ks"=>2455025, "zl"=>4782157, "fw"=>1695021, "az"=>322115, "kt"=>2455090, "d_"=>1083112, "up"=>4528358, "pr"=>3416755, "o'"=>3029255, "10"=>1959, "ku"=>2455116, "zn"=>4782189, "ps"=>3483993, "e-"=>1289529, "fy"=>1695051, "kv"=>2458073, "da"=>1083181, "zo"=>4782217, "ur"=>4532258, "pt"=>3492829, "i_"=>2220034, "11"=>2218, "kw"=>2458174, "db"=>1108193, "e."=>1289664, "us"=>4538820, "t'"=>4259996, "pu"=>3496345, "60"=>5843, "12"=>2315, "dc"=>1108287, "ut"=>4542211, "pv"=>3517927, "ia"=>2220399, "13"=>2445, "ky"=>2458844, "zr"=>4784927, "pw"=>3517990, "ib"=>2220863, "j."=>2341407, "14"=>2471, "dd"=>1108386, "zs"=>4784956, "uu"=>4544207, "px"=>3518017, "ic"=>2221692, "15"=>2558, "de"=>1108520, "uv"=>4544342, "py"=>3518043, "o."=>3029509, "na"=>2919040, "id"=>2226538, "16"=>2733, "df"=>1168182, "zu"=>4784989, "s_"=>3741387, "nb"=>2942448, "ie"=>2230327, "17"=>2788, "dg"=>1168212, "ux"=>4544722, "t-"=>4260104, "nc"=>2942542, "if"=>2230421, "18"=>3024, "dh"=>1168244, "zw"=>4785347, "uy"=>4544863, "t."=>4260425, "sa"=>3741419, "nd"=>2942608, "ig"=>2230448, "19"=>3319, "di"=>1168953, "x_"=>4749915, "uz"=>4544913, "sb"=>3800209, "ne"=>2942718, "dj"=>1223633, "zy"=>4785471, "y-"=>4755272, "sc"=>3800328, "dk"=>1223962, "xa"=>4749991, "sd"=>3836240, "ng"=>2975369, "ii"=>2232411, "dl"=>1224061, "se"=>3836272, "nh"=>2975761, "ij"=>2232906, "dm"=>1224120, "xc"=>4750937, "sf"=>3898201, "ni"=>2975793, "ik"=>2233046, "dn"=>1224525, "sg"=>3898276, "nj"=>2989622, "il"=>2233145, "do"=>1224823, "y2"=>4755339, "xe"=>4750963, "sh"=>3898399, "im"=>2236982, "dp"=>1251815, "si"=>3934020, "nl"=>2989719, "in"=>2250132, "sj"=>3974373, "nm"=>2989774, "io"=>2317192, "dr"=>1251968, "xh"=>4752829, "sk"=>3974412, "ip"=>2319242, "ds"=>1271920, "xi"=>4752879, "sl"=>3982232, "nn"=>2989842, "iq"=>2320204, "dt"=>1272024, "sm"=>3995291, "no"=>2989930, "ir"=>2320265, "du"=>1272082, "sn"=>4003308, "np"=>3016438, "is"=>2328830, "dv"=>1284206, "xl"=>4753577, "so"=>4011968, "it"=>2336645, "b_"=>324352, "dw"=>1284263, "xm"=>4753603, "sp"=>4051506, "nr"=>3016535, "iu"=>2338757, "0"=>1840, "4-"=>5374, "sq"=>4097051, "ns"=>3016775, "iv"=>2338786, "1"=>1865, "ba"=>324554, "c-"=>600455, "dy"=>1286409, "xo"=>4753634, "sr"=>4102220, "nt"=>3016984, "8_"=>6119, "iw"=>2340321, "2"=>4177, "c."=>600659, "dz"=>1289430, "g_"=>1695801, "nu"=>3017043, "ix"=>2340452, "9-"=>6205, "3"=>4985, "bb"=>390069, "40"=>5406, "ss"=>4102507, "nv"=>3026658, "iy"=>2341048, "4"=>5349, "3d"=>5205, "ga"=>1695861, "h-"=>2030546, "st"=>4102714, "nw"=>3026690, "iz"=>2341117, "9/"=>6238, "5"=>5594, "bd"=>390218, "gb"=>1726120, "h."=>2030576, "su"=>4180331, "90"=>6271, "6"=>5818, "be"=>390276, "c2"=>601143, "gc"=>1726268, "xt"=>4753701, "sv"=>4232564, "ny"=>3026772, "7"=>5946, "la"=>2459898, "m-"=>2643999, "gd"=>1726351, "sw"=>4232896, "q_"=>3524972, "8"=>6032, "lb"=>2507825, "m."=>2644096, "44"=>5495, "ge"=>1726452, "xv"=>4753754, "r-"=>3544131, "9"=>6180, "bh"=>428251, "lc"=>2507915, "h2"=>2030821, "sy"=>4247569, "r."=>3544158, "qa"=>3525003, "bi"=>428758, "ld"=>2507971, "v_"=>4545417, "sz"=>4259706, "bj"=>454188, "le"=>2508074, "m1"=>2644168, "xx"=>4753864, "qc"=>3525650, "bk"=>454250, "lf"=>2545647, "m2"=>2644194, "gh"=>1914825, "xy"=>4754258, "w."=>4622501, "va"=>4545477, "bl"=>454276, "lg"=>2545676, "m3"=>2644220, "gi"=>1915953, "qe"=>3525677, "bm"=>487643, "lh"=>2545732, "gj"=>1928001, "vc"=>4562340, "bn"=>487795, "li"=>2545866, "vd"=>4562367, "bo"=>487822, "lj"=>2588790, "gl"=>1928034, "ve"=>4562424, "bp"=>527090, "gm"=>1941192, "vf"=>4587559, "qi"=>3525733, "3r"=>5272, "gn"=>1941253, "br"=>527207, "ll"=>2588826, "go"=>1942339, "vh"=>4587589, "lm"=>2589254, "gp"=>1965489, "a'"=>6392, "bs"=>567010, "vi"=>4587630, "3t"=>5322, "bt"=>567093, "lo"=>2589280, "gr"=>1965634, "bu"=>567123, "lp"=>2623355, "gs"=>2010072, "bv"=>598604, "vl"=>4612572, "qo"=>3526131, "1_"=>3606, "bw"=>598664, "2-"=>4204, "lr"=>2623408, "gu"=>2010162, "8v"=>6153, "k'"=>2405456, "ls"=>2623434, "a-"=>6423, "by"=>598787, "vo"=>4613249, "lt"=>2623463, "e_"=>1290183, "6_"=>5911, "gw"=>2026208, "a."=>6630, "lu"=>2623552, "'h"=>1740, "20"=>4330, "ea"=>1290252, "gy"=>2026300, "21"=>4385, "vr"=>4621015, "lw"=>2635752, "eb"=>1300178, "f."=>1455392, "j_"=>2341888, "qu"=>3526162, "lx"=>2635783, "ec"=>1301281, "70"=>5971, "22"=>4411, "vt"=>4621044, "ly"=>2635907, "ed"=>1308417, "ja"=>2341922, "k-"=>2405491, "23"=>4474, "vu"=>4621076, "qw"=>3544030, "o_"=>3029601, "k."=>2405619, "24"=>4500, "p-"=>3142944, "ee"=>1316159, "25"=>4636, "p."=>3143064, "oa"=>3029664, "ef"=>1316593, "jd"=>2362188, "26"=>4662, "t_"=>4260563, "p/"=>3143308, "ob"=>3030924, "eg"=>1318289, "je"=>2362216, "27"=>4688, "vx"=>4622352, "u-"=>4495612, "oc"=>3037012, "eh"=>1321628, "jf"=>2371138, "k2"=>2405647, "28"=>4714, "vy"=>4622382, "u."=>4495708, "ta"=>4260664, "od"=>3042646, "ei"=>1321758, "29"=>4740, "y_"=>4755366, "tb"=>4295216, "oe"=>3044953, "ej"=>1323919, "'s"=>1771, "jh"=>2371165, "z-"=>4773112, "tc"=>4295357, "of"=>3046532, "ek"=>1324264, "78"=>5997, "ji"=>2371193, "ya"=>4755402, "td"=>4295640, "og"=>3049310, "el"=>1324361, "yb"=>4759174, "te"=>4295669, "oh"=>3049737, "em"=>1348056, "u3"=>4496533, "oi"=>3050182, "en"=>1357595, "oj"=>3052575, "eo"=>1377701, "ye"=>4759264, "th"=>4330947, "ok"=>3052696, "1s"=>3787, "ep"=>1378260, "ti"=>4366648, "ol"=>3053511, "jn"=>2373545, "eq"=>1387580, "yg"=>4767903, "tj"=>4385574, "om"=>3062383, "jo"=>2373601, "er"=>1391721, "yh"=>4767972, "tk"=>4385664, "on"=>3064512, "d'"=>1082835, "es"=>1401937, "yi"=>4768028, "tl"=>4385691, "et"=>1408856, "tm"=>4385787, "oo"=>3070387, "jr"=>2392018, "eu"=>1413487, "tn"=>4385843, "op"=>3071039, "a"=>6297, "ev"=>1427580, "yl"=>4768444, "to"=>4385934, "b"=>323845, "c_"=>601171, "ew"=>1432034, "ym"=>4768512, "tp"=>4413193, "or"=>3081061, "c"=>600316, "ju"=>2392073, "ex"=>1432298, "n'"=>2918885, "5-"=>5619, "os"=>3115959, "d"=>1082786, "jv"=>2405234, "ca"=>601439, "d-"=>1082871, "ey"=>1452457, "yo"=>4768542, "tr"=>4413220, "ot"=>3122137, "e"=>1289463, "cb"=>712079, "d."=>1082934, "ez"=>1454953, "yp"=>4771198, "ts"=>4466928, "ou"=>3124879, "f"=>1455328, "50"=>5765, "yq"=>4771250, "ov"=>3129739, "ha"=>2030856, "i-"=>2219776, "g"=>1695338, "jy"=>2405260, "cc"=>712135, "yr"=>4771279, "tt"=>4467892, "ow"=>3136728, "hb"=>2076148, "i."=>2219806, "h"=>2030472, "cd"=>712198, "tu"=>4467944, "ox"=>3137307, "hc"=>2076182, "i"=>2219725, "ce"=>712729, "n-"=>2918921, "yt"=>4771310, "tv"=>4484640, "oy"=>3141259, "hd"=>2076237, "j"=>2341367, "cf"=>737620, "ma"=>2644246, "yu"=>4771416, "tw"=>4485217, "r_"=>3544308, "oz"=>3142126, "n."=>2918965, "he"=>2076337, "k"=>2405363, "cg"=>737739, "mb"=>2737124, "yv"=>4773040, "tx"=>4490575, "s-"=>3741191, "hf"=>2121232, "l"=>2459527, "ch"=>737800, "mc"=>2737372, "ty"=>4490610, "s."=>3741222, "ra"=>3544339, "hg"=>2121297, "m"=>2643918, "ci"=>811192, "md"=>2738186, "tz"=>4495399, "s/"=>3741360, "rb"=>3580128, "n"=>2918808, "cj"=>827445, "me"=>2738337, "x-"=>4749199, "rc"=>3580216, "o"=>3029204, "hh"=>2121341, "mf"=>2788090, "wa"=>4622931, "p"=>3142904, "hi"=>2121371, "cl"=>827472, "mg"=>2788180, "wb"=>4654707, "re"=>3580247, "q"=>3524944, "cm"=>860967, "mh"=>2788224, "rf"=>3658425, "r"=>3544069, "cn"=>861094, "mi"=>2788281, "s"=>3741105, "rg"=>3658504, "co"=>861878, "hl"=>2139669, "we"=>4654819, "t"=>4259917, "rh"=>3658530, "cp"=>1012981, "mk"=>2830687, "hm"=>2139701, "u"=>4495561, "ri"=>3667785, "ml"=>2830716, "hn"=>2139877, "v"=>4545170, "cr"=>1013175, "ho"=>2139935, "wh"=>4672549, "w"=>4622437, "cs"=>1048516, "mm"=>2830804, "hp"=>2182075, "x"=>4749153, "wi"=>4692782, "ct"=>1048663, "mn"=>2830893, "4t"=>5531, "hq"=>2182104, "y"=>4755232, "cu"=>1049194, "mo"=>2831144, "hr"=>2182134, "z"=>4773075, "rn"=>3687863, "cv"=>1068811, "mp"=>2881103, "hs"=>2182299, "wl"=>4724359, "ro"=>3688004, "2_"=>4766, "cw"=>1068869, "4w"=>5558, "ht"=>2182563, "a_"=>7001, "wm"=>4724387, "rp"=>3724343, "l'"=>2459588, "3-"=>5010, "mr"=>2881244, "hu"=>2182649, "wn"=>4724445, "b-"=>323934, "cy"=>1068938, "ms"=>2881650, "wo"=>4724472, "b."=>324186, "cz"=>1082090, "mt"=>2881981, "f_"=>1455546, "hw"=>2196252, "aa"=>7256, "wp"=>4743059, "30"=>5078, "mu"=>2882421, ".2"=>1811, "ab"=>8002},
	    :adj => {"2d"=>4592, "31"=>4851, "fa"=>261714, ".3"=>1880, "hy"=>340391, "ac"=>12021, "32"=>4905, "wr"=>818088, ".4"=>2020, "ad"=>18614, "80"=>7432, "ae"=>23100, "ru"=>595594, "ka"=>388840, "l-"=>392296, "33"=>4959, "my"=>455103, "81"=>7486, "af"=>24303, "34"=>5013, "fe"=>267964, "82"=>7512, "ag"=>26180, "rw"=>598392, "35"=>5067, "83"=>7538, "ah"=>28531, "36"=>5121, "pa"=>505816, "84"=>7564, "ai"=>28659, "ke"=>389430, "37"=>5175, "85"=>7590, "aj"=>29502, "38"=>5229, "v-"=>789182, "86"=>7644, "ak"=>29530, "39"=>5283, "fi"=>270598, "wy"=>819172, "87"=>7670, "al"=>29597, "2n"=>4618, "ub"=>722231, "pe"=>515525, "am"=>36386, "kh"=>389925, "88"=>7696, "an"=>40420, "ki"=>389956, "za"=>822848, "fl"=>275697, "89"=>7722, "ao"=>51761, "ph"=>523560, "ap"=>51861, "pi"=>526560, "aq"=>56753, "ug"=>722267, "fo"=>280302, "ar"=>57023, "ze"=>823049, "as"=>62836, "pl"=>530025, "at"=>67162, "kn"=>390913, "fr"=>286656, "au"=>69848, "ko"=>391903, "uk"=>722361, "pn"=>534250, "7t"=>7346, "av"=>73727, "zi"=>823276, "ul"=>722396, "po"=>534415, "aw"=>74649, "um"=>723080, "fu"=>290894, "ax"=>75702, "un"=>723684, "az"=>76033, "up"=>785441, "6-"=>6566, "pr"=>541620, "10"=>2210, "ku"=>392129, "ps"=>556687, "da"=>189020, "zo"=>823490, "pt"=>558010, "11"=>2525, "ur"=>787459, "60"=>6600, "pu"=>558096, "12"=>2691, "us"=>788002, "61"=>6654, "ia"=>343317, "13"=>2857, "ky"=>392202, "ut"=>788423, "62"=>6680, "ib"=>343385, "14"=>3023, "63"=>6706, "ic"=>343452, "15"=>3189, "de"=>191816, "na"=>456102, "o."=>482752, "64"=>6732, "py"=>562611, "id"=>344057, "16"=>3355, "uv"=>788962, "65"=>6786, "17"=>3521, "if"=>345034, "18"=>3687, "t-"=>685912, "ux"=>789057, "66"=>6840, "ig"=>345064, "19"=>3797, "sa"=>598455, "di"=>206077, "67"=>6866, "dj"=>220263, "uz"=>789122, "ne"=>459116, "zy"=>823837, "y-"=>820785, "68"=>6892, "sc"=>604552, "69"=>6918, "xa"=>819260, "ii"=>345421, "se"=>608988, "xc"=>819292, "ni"=>464278, "il"=>345474, "do"=>220299, "y2"=>820817, "xe"=>819571, "im"=>347578, "sh"=>623055, "in"=>353335, "si"=>629245, "io"=>380365, "dr"=>225168, "ip"=>380637, "sk"=>635321, "5t"=>6514, "xi"=>819747, "sl"=>636220, "ir"=>380672, "sm"=>639638, "du"=>227825, "no"=>466328, "is"=>382721, "sn"=>641766, "xl"=>819882, "it"=>383968, "so"=>643211, "dw"=>229873, "0"=>2160, "sp"=>649763, "4-"=>5389, "iv"=>384300, "1"=>2185, "ba"=>76418, "sq"=>656684, "dy"=>229940, "2"=>3934, "sr"=>658125, "nt"=>481308, "ix"=>384390, "9-"=>7800, "3"=>4645, "40"=>5460, "nu"=>481335, "4"=>5364, "41"=>5570, "ga"=>294211, "h-"=>313795, "5"=>6083, "st"=>658188, "42"=>5624, "90"=>7834, "6"=>6541, "be"=>83696, "su"=>671222, "43"=>5678, "91"=>7888, "7"=>6971, "sv"=>681720, "la"=>392328, "ny"=>482674, "92"=>7914, "8"=>7373, "sw"=>681768, "44"=>5732, "ge"=>296692, "xv"=>820134, "93"=>7940, "9"=>7775, "bh"=>89324, "45"=>5786, "r."=>566629, "94"=>7966, "bi"=>89359, "sy"=>683436, "46"=>5840, "qa"=>563600, "95"=>7992, "le"=>398566, "47"=>5894, "xx"=>820244, "96"=>8046, "48"=>5948, "w-"=>800937, "gh"=>299675, "97"=>8072, "bl"=>96334, "49"=>6002, "va"=>789214, "gi"=>299913, "98"=>8098, "li"=>402864, "99"=>8124, "bo"=>102434, "gl"=>300821, "ve"=>791850, "3r"=>5337, "gn"=>303067, "br"=>107474, "go"=>303237, "vi"=>795294, "lo"=>409658, "gr"=>305879, "bu"=>114508, "8t"=>7748, "2-"=>3959, "gu"=>312309, "a-"=>8177, "by"=>118813, "vo"=>799000, "a."=>8266, "lu"=>416153, "7-"=>6996, "20"=>3996, "lv"=>417909, "ea"=>230712, "gy"=>313409, "21"=>4106, "eb"=>232434, "lx"=>418019, "ec"=>232594, "70"=>7030, "qu"=>563668, "22"=>4160, "ly"=>418802, "ed"=>233599, "71"=>7084, "ja"=>384470, "23"=>4214, "vu"=>800557, "72"=>7110, "24"=>4268, "ee"=>234244, "73"=>7136, "25"=>4322, "ef"=>234377, "oa"=>482782, "p."=>505788, "74"=>7162, "26"=>4376, "eg"=>235115, "ob"=>482870, "75"=>7188, "je"=>385496, "27"=>4430, "u-"=>722199, "oc"=>484785, "76"=>7242, "28"=>4484, "ei"=>235526, "od"=>485595, "29"=>4538, "ta"=>685944, "oe"=>486011, "77"=>7268, "of"=>486090, "78"=>7294, "ji"=>386292, "ya"=>820854, "el"=>236340, "79"=>7320, "em"=>238831, "oh"=>487955, "te"=>690141, "en"=>240855, "oi"=>487986, "eo"=>245834, "ye"=>820972, "ok"=>488175, "1s"=>3907, "th"=>695473, "ep"=>245983, "ol"=>488233, "ti"=>702295, "eq"=>247606, "om"=>489492, "jo"=>386595, "er"=>248382, "on"=>489888, "6t"=>6944, "es"=>249587, "yi"=>822204, "et"=>250446, "oo"=>493273, "jr"=>387299, "eu"=>251131, "op"=>493333, "ev"=>252105, "to"=>705018, "or"=>495731, "c"=>118928, "ju"=>387326, "ex"=>253536, "5-"=>6108, "os"=>498199, "d"=>188965, "ca"=>118953, "ey"=>261468, "yo"=>822254, "ot"=>498747, "tr"=>709204, "d."=>188990, "ou"=>499048, "ts"=>717450, "50"=>6142, "ov"=>501567, "ha"=>313827, "cc"=>131547, "51"=>6252, "ow"=>505326, "cd"=>131600, "52"=>6278, "i"=>343292, "ce"=>131626, "tu"=>717516, "n-"=>456074, "53"=>6304, "ox"=>505512, "ma"=>419357, "54"=>6330, "yu"=>822690, "he"=>320515, "k"=>388815, "tw"=>719084, "l"=>392271, "s-"=>598423, "ch"=>134647, "55"=>6356, "ra"=>566657, "m"=>419332, "ci"=>142370, "ty"=>721720, "56"=>6410, "tz"=>722141, "me"=>429139, "57"=>6436, "58"=>6462, "x-"=>819228, "hi"=>327145, "cl"=>144311, "59"=>6488, "wa"=>800969, "re"=>571244, "mi"=>436715, "co"=>150272, "rh"=>587466, "we"=>804320, "hm"=>331476, "ri"=>588287, "u"=>722172, "v"=>789157, "cr"=>176976, "ho"=>331505, "wh"=>809316, "x"=>819203, "ct"=>183185, "mn"=>442650, "4t"=>6056, "wi"=>811263, "cu"=>183216, "mo"=>442756, "9t"=>8150, "cv"=>186983, "ro"=>591099, "a_"=>8294, "cx"=>187009, "3-"=>4670, "hu"=>337473, "cy"=>187229, "cz"=>188827, "wo"=>814766, "30"=>4741, "mu"=>450942, ".2"=>1740, "8-"=>7398, "ab"=>8553},
	    :verb => {"ox"=>317944, "ep"=>169705, "ki"=>261865, "ne"=>302629, "x-"=>522318, "oy"=>318231, "ru"=>392475, "ur"=>502622, "bu"=>56124, "eq"=>169837, "oz"=>318263, "us"=>502895, "aa"=>1740, "er"=>170250, "ut"=>503162, "ab"=>1767, "es"=>170652, "ho"=>232836, "ac"=>3529, "et"=>171392, "ni"=>303882, "ta"=>465047, "ad"=>6490, "da"=>118966, "by"=>61875, "eu"=>171927, "ae"=>8718, "ev"=>172155, "kn"=>263317, "af"=>8929, "ko"=>264585, "ag"=>9437, "ex"=>173105, "te"=>472676, "wa"=>508666, "ga"=>204003, "ey"=>178534, "hu"=>237591, "ai"=>10286, "de"=>120649, "no"=>304585, "th"=>475571, "ti"=>478689, "we"=>512699, "za"=>523414, "ge"=>206371, "ja"=>255802, "hy"=>239280, "al"=>10951, "di"=>136972, "kv"=>264661, "am"=>12800, "wh"=>514913, "an"=>13706, "dj"=>148986, "ze"=>523472, "wi"=>517343, "je"=>256873, "ma"=>280541, "nu"=>305772, "ap"=>16409, "gh"=>210633, "to"=>481065, "aq"=>18267, "gi"=>210790, "ar"=>18347, "zi"=>523585, "as"=>19764, "do"=>149014, "pa"=>318325, "qu"=>356569, "tr"=>483983, "at"=>21915, "gl"=>213421, "ji"=>257383, "me"=>287710, "ts"=>490986, "wo"=>519567, "au"=>23027, "av"=>23935, "dr"=>152421, "gn"=>215270, "g."=>203975, "aw"=>24513, "go"=>215409, "tu"=>491013, "wr"=>520951, "ax"=>24704, "mi"=>290558, "pe"=>324550, "sa"=>395891, "zo"=>523781, "ca"=>61939, "du"=>158291, "tw"=>493797, "az"=>24779, "gr"=>218976, "sc"=>398961, "dw"=>159135, "jo"=>257765, "ph"=>328230, "pi"=>328891, "se"=>403889, "va"=>503309, "ty"=>494840, "fa"=>178632, "dy"=>159383, "gu"=>222269, "ce"=>72643, "mo"=>295025, "pl"=>332016, "sh"=>410924, "si"=>417650, "ve"=>504664, "ya"=>522393, "ch"=>73529, "fe"=>183011, "gy"=>223294, "ju"=>258735, "ci"=>81247, "po"=>336199, "sk"=>421199, "ic"=>240465, "sl"=>422915, "id"=>240617, "sm"=>427144, "vi"=>506088, "ye"=>522895, "cl"=>82562, "la"=>264691, "mu"=>299509, "sn"=>428534, "fi"=>185556, "pr"=>341164, "so"=>430811, "ig"=>240935, "ps"=>350290, "sp"=>433886, "co"=>87668, "pt"=>350435, "sq"=>440723, "yi"=>523082, "fl"=>189489, "le"=>268258, "my"=>301203, "pu"=>350501, "ob"=>306433, "vo"=>507446, "cr"=>110051, "oc"=>307497, "fo"=>194383, "od"=>307842, "st"=>442042, "il"=>241065, "li"=>271717, "ra"=>358635, "py"=>356507, "su"=>454237, "vr"=>508439, "cu"=>115910, "im"=>241391, "of"=>307921, "yo"=>523290, "ba"=>24810, "fr"=>199363, "in"=>244059, "og"=>308488, "sw"=>460901, "io"=>254520, "vu"=>508468, "ft"=>202432, "oi"=>308518, "re"=>363091, "sy"=>463729, "ea"=>159598, "cy"=>118743, "fu"=>202461, "ir"=>254766, "ok"=>308584, "be"=>30231, "eb"=>160312, "lo"=>275662, "rh"=>386786, "ec"=>160555, "is"=>255120, "om"=>308616, "ri"=>386952, "ed"=>160739, "it"=>255504, "on"=>308689, "ha"=>223396, "ug"=>495123, "bi"=>37946, "o."=>306373, "ef"=>161223, "oo"=>308723, "xe"=>522360, "eg"=>161607, "op"=>308863, "bl"=>39622, "he"=>228710, "ka"=>259787, "lu"=>279432, "or"=>309814, "ro"=>389309, "ej"=>161771, "os"=>310691, "ul"=>495155, "bo"=>44472, "ek"=>161875, "um"=>495274, "el"=>161933, "ke"=>259848, "na"=>301427, "ly"=>280367, "ou"=>310976, "un"=>495308, "em"=>162861, "hi"=>231023, "ov"=>313178, "e-"=>159560, "br"=>48932, "en"=>164868, "ow"=>317836, "up"=>501838},
	    :adv => {"ul"=>146918, "sa"=>121999, "me"=>87949, "is"=>79726, "al"=>6456, "fu"=>54854, "ty"=>146844, "ro"=>121173, "op"=>100918, "it"=>79763, "am"=>8151, "ba"=>15505, "gi"=>56230, "va"=>156823, "un"=>147057, "sc"=>122613, "pe"=>105172, "an"=>8719, "cy"=>31883, "or"=>101364, "ea"=>40812, "i."=>64191, "up"=>155754, "se"=>123441, "os"=>101738, "mi"=>89536, "lu"=>85885, "eb"=>41346, "ap"=>10042, "bc"=>16615, "gl"=>56390, "ph"=>107333, "ot"=>101845, "ha"=>58556, "do"=>38706, "ec"=>41381, "ve"=>157238, "ur"=>156560, "pi"=>107876, "ou"=>101917, "o."=>96668, "ar"=>10688, "be"=>16664, "ed"=>41593, "us"=>156624, "sh"=>125358, "ov"=>102923, "go"=>56887, "as"=>11428, "ye"=>162287, "ut"=>156758, "si"=>126337, "ru"=>121807, "ow"=>103605, "ly"=>86271, "dr"=>39948, "ee"=>41743, "at"=>12932, "pl"=>108832, "na"=>92504, "he"=>60006, "ef"=>41771, "au"=>14641, "jo"=>80066, "vi"=>157846, "sk"=>127582, "bi"=>18176, "gr"=>57195, "eg"=>41998, "a."=>1802, "av"=>14980, "sl"=>127918, "pn"=>109745, "mo"=>90407, "ke"=>80998, "du"=>40494, "aw"=>15087, "yi"=>162508, "sm"=>128914, "po"=>109782, "ei"=>42035, "ax"=>15383, "ux"=>156789, "ta"=>138198, "sn"=>129359, "ne"=>92966, "gu"=>58424, "bl"=>18795, "so"=>129638, "ca"=>22029, "hi"=>61819, "wa"=>159164, "sp"=>132158, "dy"=>40699, "el"=>42063, "ju"=>80410, "ki"=>81028, "vo"=>158698, "sq"=>133295, "pr"=>111025, "em"=>42369, "fa"=>47339, "bo"=>19295, "te"=>138977, "ps"=>114778, "ni"=>94052, "mu"=>91756, "en"=>42630, "yo"=>162542, "e'"=>40734, "we"=>159590, "pu"=>114861, "p."=>103637, "ib"=>64217, "ep"=>43786, "br"=>19838, "ce"=>23083, "th"=>140092, "st"=>133477, "ic"=>64297, "eq"=>43822, "fe"=>48826, "cf"=>23412, "la"=>81356, "ho"=>62489, "ze"=>162691, "ti"=>142646, "su"=>135818, "my"=>92434, "id"=>64326, "er"=>43965, "kn"=>81226, "wh"=>160191, "vu"=>159098, "es"=>44216, "bu"=>20620, "ch"=>23461, "ie"=>64701, "wi"=>160770, "sw"=>137556, "py"=>115529, "ob"=>96696, "et"=>44370, "a_"=>1884, "b."=>15451, "ci"=>24468, "if"=>64725, "ra"=>116360, "oc"=>97499, "no"=>94335, "le"=>82562, "ig"=>64753, "eu"=>44719, "zi"=>162788, "sy"=>137715, "od"=>97535, "fi"=>49357, "e."=>40786, "ev"=>44758, "by"=>20853, "cl"=>24639, "hu"=>63384, "to"=>143107, "of"=>97605, "da"=>31998, "ex"=>45689, "ab"=>2343, "re"=>117290, "li"=>83328, "ac"=>3468, "fl"=>50352, "wo"=>161523, "ga"=>55429, "co"=>25439, "ad"=>4138, "tr"=>145364, "nu"=>96480, "hy"=>63857, "il"=>64855, "ae"=>5138, "rh"=>120391, "im"=>65172, "af"=>5207, "ja"=>79789, "fo"=>50969, "wr"=>162050, "ri"=>120500, "qu"=>115566, "ok"=>98535, "cr"=>30383, "de"=>32710, "in"=>67015, "ag"=>5747, "ma"=>86304, "'t"=>1740, "ah"=>6150, "ge"=>55713, "tu"=>146503, "om"=>98587, "ip"=>78991, "ai"=>6367, "fr"=>53467, "pa"=>103691, "on"=>98620, "lo"=>84939, "je"=>79886, "cu"=>31304, "tw"=>146716, "o'"=>96613, "di"=>35621, "ir"=>79023, "ak"=>6428, "c."=>21975}
	}

	# Hash object used for caching retreved terms to further improve retreval performance
	WORDS_CACHE = Hash.new

	## Returns the current connection status of the wordnet object.
	#
	# @return [true, false] The current connection status of the wordnet object.
	attr_reader :connected

	## Returns the current connection status of the wordnet object.
	#
	# @return [true, false] The current connection status of the wordnet object.
	alias :connected? connected
	
	# Returns the type of the current wordnet connection.
	#
	# @return [Symbol] The current wordnet connection type. Currently supported :pure & :tokyo.
	attr_reader :connection_type
	
	# Returns the datapath currently in use (this may be irrelevent when using the pure connector and thus could be nil.)
	#
	# @return [Pathname, nil] The path to the data directory currently in use. Returns nil if unknown.
	attr_reader :data_path
	
	# Returns the path to the wordnet collection currently in use (this may be irrelevent when using the tokyo connector and thus could be nil.)
	#
	# @return [Pathname, nil] The path to the wordnet collection currently in use. Returns nil if unknown.
	attr_reader :wordnet_path

	# Constructs a new pure ruby connector for use with the words wordnet class.
	#
	# @param [Pathname] data_path Specifies the directory within which constructed datasets can be found (evocations etc...)
	# @param [Pathname] wordnet_path Specifies the directory within which the wordnet dictionary can be found.
	# @return [PureWordnetConnection] A new wordnet connection.
	# @raise [BadWordnetConnector] If an invalid connector type is provided.
	def initialize(data_path, wordnet_path)

	    @data_path, @wordnet_path, @connection_type, @connected = data_path, wordnet_path, :pure, false
	
	    open!

	end

	# Causes the connection specified within the wordnet object to be reopened if currently closed.
	# 
	# @raise [BadWordnetConnector] If an invalid connector type is provided.
	def open!

	    raise BadWordnetDataset, "Failed to locate the wordnet database. Please ensure it is installed and that if it resides at a custom path that path is given as an argument when constructing the Words object." if @wordnet_path.nil?

	    @connected = true

	    # try and open evocations too
	    evocation_path = @data_path + 'evocations.dmp'
	    File.open(evocation_path, 'r') do |file|
		@evocations = Marshal.load file.read
	    end if evocation_path.exist?
	    return nil
	    
	end

	# Causes the current connection to wordnet to be closed.
	#
	def close!

	    @connected = false
	    return nil

	end

	# Locates from a term any relevent homographs and constructs a homographs hash.
	#
	# @param [String] term The specific term that is desired from within wordnet.
	# @param [true, false] use_cache Specify whether to use caching when finding and retreving terms.
	# @result [Hash, nil] A hash in the format { 'lemma' => ..., 'tagsense_counts' => ..., 'synset_ids' => ...  }, or nil if no homographs are available.
	# @raise [NoWordnetConnection] If there is currently no wordnet connection.
	def homographs(term, use_cache = true)

	    raise NoWordnetConnection, "There is presently no connection to wordnet. To attempt to reistablish a connection you should use the 'open!' command on the Wordnet object." unless connected?

	    # clean up the term
	    term = term.gsub(" ", "_").downcase

	    # identify the term initials
	    term_initials = term[0,2]

	    # for each index we have
	    INDEXES.keys.each do |index_pos|
		next unless INDEXES[index_pos].include? term_initials # if the index does not contain the desired word skip the index
		file = File.new(@wordnet_path + "index.#{index_pos}") # open wordnet index file
		file.seek INDEXES[index_pos][term_initials] # seek to the index starting point

		while (line = file.gets) && (term_initials == line[0,2]) # break if line if EOF or we are past the term and thus the line doesnt start with the term initials
		    lemma, pos, *index_parts = line.split(' ') # split the line and split off the lemma
		    if (lemma == term || use_cache) # if it's the term we are after or we are using cache then we save the word
			WORDS_CACHE[lemma] ||= [ lemma ] # ensure that there is datastructure to hold our word information
			if !WORDS_CACHE[lemma].include?(index_pos) # unless there already exists an entry for said word associated with the current index
			    tagsense_count, *synset_offsets = index_parts.slice(index_parts[1].to_i+3..-1) # seperate out what is useful from the index as a whole
			    WORDS_CACHE[lemma] += [ pos, tagsense_count.to_i, synset_offsets ] # add the tagsense_count and the synsets for the pos
			    break if lemma == term # if we have the word in this index then we can jump out and check the next
			end
		    end
		end

		file.close # close wordnet index file
	    end unless WORDS_CACHE.include?(term) && use_cache # if we have the term already and are ok with using cache then simply use that!

	    # we should either have the word in cache now or nowt... we should now change that into homograph input format (we do this here to improve performance during the cacheing performed above)
	    lemma, *raw_homographs = WORDS_CACHE[term] # split the homograph
	    unless raw_homographs.empty? # if we have something... format it
		tagsense_counts = Array.new
		synset_ids = Array.new
		while !raw_homographs.empty?
		    pos = raw_homographs.shift
		    tagsense_counts << "#{pos}#{raw_homographs.shift}"
		    synset_ids += raw_homographs.shift.map { |sense_offset|  "#{pos}#{sense_offset}" }
		end
		return { 'lemma' => lemma, 'tagsense_counts' => tagsense_counts.join('|'), 'synset_ids' => synset_ids.join('|')  }
	    else
		return nil # we return nil if we haven't found the term
	    end

	end

	# Locates from a synset_id a specific synset and constructs a synset hash.
	#
	# @param [String] synset_id The synset id to locate.
	# @result [Hash, nil] A hash in the format { "synset_id" => ..., "lexical_filenum" => ..., "synset_type" => ..., "words" => ..., "relations" => ..., "gloss" => ... }, or nil if no synset is available.
	# @raise [NoWordnetConnection] If there is currently no wordnet connection.
	def synset(synset_id)

	    raise NoWordnetConnection, "There is presently no connection to wordnet. To attempt to reistablish a connection you should use the 'open!' command on the Wordnet object." unless connected?

	    pos = synset_id[0,1]
	    File.open(@wordnet_path + "data.#{SHORT_TO_POS_FILE_TYPE[pos]}","r") do |file|
		file.seek(synset_id[1..-1].to_i)
		data_line, gloss = file.readline.strip.split(" | ")
		lexical_filenum, synset_type, word_count, *data_parts = data_line.split(" ")[1..-1]
		words = Array.new(word_count.to_i(16)).map { "#{data_parts.shift}.#{data_parts.shift}" }
		relations = Array.new(data_parts.shift.to_i).map { "#{data_parts.shift}.#{data_parts.shift}.#{data_parts.shift}.#{data_parts.shift}" }
		return { "synset_id" => synset_id, "lexical_filenum" => lexical_filenum, "synset_type" => synset_type, "words" => words.join('|'), "relations" => relations.join('|'), "gloss" => gloss.strip }
	    end

	end

	# Returns wheter evocations are currently avalable to use with the current wordnet object. (More information on setting these up can be found within the README)
	#
	# @return [true, false] Whether evocations are currently available or not.
	def evocations?

	    !evocations('n08112402').nil?

	end

	# Locates from a synset id any relevent evocations and constructs an evocations hash.
	#
	# @see Synset
	# @param [String] senset_id The id number of a specific synset.
	# @result [Hash, nil] A hash in the format { 'relations' => ..., 'means' => ..., 'medians' => ... }, or nil if no evocations are available.
	# @raise [NoWordnetConnection] If there is currently no wordnet connection.
	def evocations(synset_id)

	    raise NoWordnetConnection, "There is presently no connection to wordnet. To attempt to reistablish a connection you should use the 'open!' command on the Wordnet object." unless connected?

	    if defined? @evocations
		raw_evocations = @evocations[synset_id + "s"]
		{ 'relations' => raw_evocations[0], 'means' => raw_evocations[1], 'medians' => raw_evocations[2]} unless raw_evocations.nil?
	    else
		nil
	    end

	end

	# Provides a textural description of the current connection state of the Wordnet object.
	#
	# @return [String] A textural description of the current connection state of the Wordnet object. e.g. "Words not Connected" or "Words running in pure mode using wordnet files found at /opt/wordnet"
	def to_s

	    "Words running in pure mode using wordnet files found at #{wordnet_path}"

	end

    end

end
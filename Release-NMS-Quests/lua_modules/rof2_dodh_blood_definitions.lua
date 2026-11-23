local function actor(npc, spawn) return { npc = npc, spawn = spawn } end

return {
    shyra = {
        name = "Blood Raid: Matriarch Shyra", label = "Matriarch Shyra",
        zone = 359, version = 3, short = "westkorlacha", presence = actor(359031, 263147),
        boss = actor(359037, 263163), guards = {actor(359038, 263164), actor(359039, 263165)},
        request = {zone = 358, short = "westkorlach", actor = actor(358059, 101913)},
        entry = {-1549, 577, 4, 0}, curse = 7810,
        gear = {83494, 83495, 83496, 83497, 83498, 83499, 83500, 83501}, draws = 2,
        runes = {77936, 77937},
    },
    bloodeye = {
        name = "Blood Raid: Bloodeye", label = "Bloodeye",
        zone = 363, version = 2, short = "eastkorlacha", presence = actor(363049, 260896),
        boss = actor(363050, 260897), anchor = {1456, 502, -82.875, 254},
        request = {zone = 358, short = "westkorlach", actor = actor(358058, 101899)},
        entry = {16, 3, -12, 0}, curse = 7815,
        gear = {83462, 83463, 83464, 83465}, draws = 1, runes = {77936, 77937},
    },
    draygun = {
        name = "Blood Raid: Emperor Draygun", label = "Emperor Draygun",
        zone = 350, version = 2, short = "illsalinc", presence = actor(350041, 263234),
        boss = actor(350051, 263273), book = actor(350050, 263272),
        request = {zone = 362, short = "eastkorlach", actor = actor(362108, 102606), prophecy = true},
        entry = {0, 0, -15, 0}, curse = 7800,
        gear = {83550, 83551, 83552, 83553, 83554, 83555, 83556, 83557, 83558},
        draws = 3, mixed_runes = {77937, 77938},
    },
    sendaii = {
        name = "Blood Raid: Sendaii", label = "Sendaii",
        zone = 357, version = 1, short = "drachnidhivec", presence = actor(357014, 260634),
        boss = actor(357016, 260636), egg = actor(357015, 260635),
        request = {zone = 362, short = "eastkorlach", actor = actor(362037, 102418), faction = 1055},
        entry = {-55.72, -70.27, -755, 0}, curse = 7820, draws = 3, runes = {77937, 77937},
        gear = {83540, 83541, 83542, 83543, 83544, 83545, 83546, 83547, 83548, 83549, 89512},
    },
}

#pragma once
// Discipline timer-band table (spellID -> banded CARecastTimerID).
// Auto-generated from the client's spells_us.txt field 168.
// The native client wraps CARecastTimerID mod 20 on load, collapsing the per-class
// bands back onto stock timers (23->3, 143->3), which re-collides classes. We write the
// full banded value back into _SPELL.CARecastTimerID after load so the >=20 map shim keeps
// each class's discs on their own timer. Only entries with banded>=20 are included.
struct NMSDiscBand { int spellID; int banded; };
static const NMSDiscBand g_discBandTable[] = {
    { 4499, 21 }, // Defensive Discipline
    { 4503, 21 }, // Evasive Discipline
    { 4688, 21 }, // Stonewall Discipline
    { 4670, 22 }, // Fortitude Discipline
    { 4674, 22 }, // Furious Discipline
    { 4498, 23 }, // Aggressive Discipline
    { 4501, 23 }, // Precision Discipline
    { 4514, 23 }, // Mighty Strike Discipline
    { 4672, 23 }, // Charge Discipline
    { 4675, 23 }, // Fellstrike Discipline
    { 10959, 24 }, // Aura of Draconic Runes
    { 4689, 24 }, // Spirit of Rage Discipline
    { 6191, 24 }, // Aura of Runes Discipline
    { 6192, 25 }, // Savage Onslaught Discipline
    { 6190, 26 }, // Shocking Defense Discipline
    { 6173, 27 }, // Bazu Bellow
    { 4608, 28 }, // Provoke
    { 4681, 28 }, // Bellow
    { 4682, 28 }, // Berate
    { 4697, 28 }, // Incite
    { 5015, 28 }, // Bellow of the Mastruq
    { 5016, 28 }, // Ancient: Chaos Cry
    { 8467, 28 }, // Mock
    { 6725, 29 }, // Cyclone Blade
    { 6750, 29 }, // Whirlwind Blade
    { 8000, 30 }, // Commanding Voice
    { 8468, 30 }, // Champion's Aura
    { 8921, 30 }, // Myrmidon's Aura
    { 4500, 61 }, // Holyforge Discipline
    { 4518, 62 }, // Sanctification Discipline
    { 6663, 64 }, // Guard of Righteousness
    { 6731, 64 }, // Guard of Humility
    { 7004, 64 }, // Guard of Piety
    { 4506, 81 }, // Trueshot Discipline
    { 8019, 81 }, // Warder's Wrath
    { 4519, 82 }, // Weapon Shield Discipline
    { 4520, 101 }, // Unholy Aura Discipline
    { 4504, 102 }, // Leechcurse Discipline
    { 6673, 104 }, // Soul Shield
    { 6741, 104 }, // Soul Guard
    { 7005, 104 }, // Ichor Guard
    { 8002, 140 }, // Fists of Wu
    { 8474, 140 }, // Master's Aura
    { 8923, 140 }, // Disciple's Aura
    { 4502, 141 }, // Voiddance Discipline
    { 4509, 141 }, // Whirlwind Discipline
    { 4510, 141 }, // Stonestance Discipline
    { 4690, 141 }, // Earthwalk Discipline
    { 4512, 142 }, // Innerflame Discipline
    { 4513, 142 }, // Hundred Fists Discipline
    { 4507, 143 }, // Silentfist Discipline
    { 4508, 143 }, // Ashenhand Discipline
    { 4511, 143 }, // Thunderkick Discipline
    { 4692, 144 }, // Planeswalk Discipline
    { 6193, 144 }, // Dreamwalk Discipline
    { 6194, 145 }, // Rapid Kick Discipline
    { 8473, 145 }, // Heel of Kanji
    { 6195, 146 }, // Counterforce Discipline
    { 6727, 148 }, // Dragon Fang
    { 6752, 148 }, // Leopard Claw
    { 4614, 149 }, // Phantom Zephyr
    { 4683, 149 }, // Phantom Wind
    { 4684, 149 }, // Phantom Echo
    { 4698, 149 }, // Phantom Call
    { 5019, 149 }, // Phantom Shadow
    { 5020, 149 }, // Ancient: Phantom Chaos
    { 6175, 149 }, // Phantom Cry
    { 4691, 150 }, // Speed Focus Discipline
    { 4516, 161 }, // Deftdance Discipline
    { 4586, 162 }, // Puretone Discipline
    { 8030, 162 }, // Thousand Blades
    { 8001, 179 }, // Thief's Eyes
    { 4515, 181 }, // Nimble Discipline
    { 4673, 181 }, // Counterattack Discipline
    { 4517, 182 }, // Kinesthetics Discipline
    { 4676, 182 }, // Duelist Discipline
    { 4505, 183 }, // Deadeye Discipline
    { 4677, 183 }, // Blinding Speed Discipline
    { 4694, 183 }, // Deadly Precision Discipline
    { 4695, 183 }, // Twisted Chance Discipline
    { 4696, 184 }, // Weapon Affinity Discipline
    { 6198, 184 }, // Imperceptible Discipline
    { 6197, 185 }, // Frenzied Stabbing Discipline
    { 4659, 188 }, // Sneak Attack
    { 4685, 188 }, // Thief's Vengeance
    { 4686, 188 }, // Assassin's Strike
    { 5017, 188 }, // Kyv Strike
    { 5018, 188 }, // Ancient: Chaos Strike
    { 6174, 188 }, // Daggerfall
    { 6726, 188 }, // Assassin's Feint
    { 6751, 188 }, // Rogue's Ploy
    { 8470, 188 }, // Razorarc
    { 8471, 189 }, // Poison Spikes Trap
    { 8922, 189 }, // Poison Spurs Trap
    { 6196, 195 }, // Deadly Aim Discipline
    { 4671, 301 }, // Protective Spirit Discipline
    { 4678, 302 }, // Bestial Fury Discipline
    { 8233, 302 }, // Empathic Fury
    { 8782, 308 }, // Rake
    { 8003, 320 }, // Cry Havoc
    { 8477, 320 }, // Bloodlust Aura
    { 8924, 320 }, // Aura of Rage
    { 4934, 321 }, // Divertive Strike
    { 4935, 321 }, // Distracting Strike
    { 4936, 321 }, // Confusing Strike
    { 6171, 321 }, // Baffling Strike
    { 6729, 321 }, // Destroyer's Volley
    { 6754, 321 }, // Rage Volley
    { 5038, 322 }, // Battle Focus Discipline
    { 5040, 322 }, // Reckless Discipline
    { 5042, 322 }, // Indomitable Discipline
    { 5043, 322 }, // Cleaving Anger Discipline
    { 5034, 323 }, // Burning Rage Discipline
    { 5035, 323 }, // Focused Fury Discipline
    { 5037, 323 }, // Cleaving Rage Discipline
    { 5039, 323 }, // Inspired Anger Discipline
    { 5041, 323 }, // Blind Rage Discipline
    { 5044, 324 }, // Sprint Discipline
    { 6201, 324 }, // Unflinching Will Discipline
    { 6199, 325 }, // Vengeful Flurry Discipline
    { 6200, 326 }, // Unpredictable Rage Discipline
    { 4937, 327 }, // Corroded Axe
    { 4938, 327 }, // Blunt Axe
    { 4939, 327 }, // Steel Axe
    { 4940, 327 }, // Bearded Axe
    { 4941, 327 }, // Mithril Axe
    { 4942, 327 }, // Balanced War Axe
    { 4943, 327 }, // Bonesplicer Axe
    { 4944, 327 }, // Fleshtear Axe
    { 4945, 327 }, // Cold Steel Cleaving Axe
    { 4946, 327 }, // Mithril Bloodaxe
    { 4947, 327 }, // Rage Axe
    { 4948, 327 }, // Bloodseeker's Axe
    { 4949, 327 }, // Battlerage Axe
    { 4950, 327 }, // Deathfury Axe
    { 5107, 327 }, // Tainted Axe of Hatred
    { 6172, 327 }, // Axe of the Destroyer
    { 5027, 328 }, // Battle Cry
    { 5028, 328 }, // War Cry
    { 5029, 328 }, // Battle Cry of Dravel
    { 5030, 328 }, // War Cry of Dravel
    { 5031, 328 }, // Battle Cry of the Mastruq
    { 5032, 328 }, // Ancient: Cry of Chaos
    { 8476, 328 }, // Bloodthirst
    { 4928, 329 }, // Leg Strike
    { 4929, 329 }, // Leg Cut
    { 4930, 329 }, // Leg Slice
    { 4931, 329 }, // Head Strike
    { 4932, 329 }, // Head Pummel
    { 4933, 329 }, // Head Crush
    { 6169, 329 }, // Crippling Strike
    { 6170, 329 }, // Mind Strike
};
static const int g_discBandCount = 152;

#!/usr/bin/env python3
"""
fabled_roster.py - generate utils/sql/fabled_roster_seed.sql for the `fabled_npcs` table.

The live Fabled roster (Classic through Planes of Power, including Plane of Time) is embedded
below as data, one row per Fabled: "<live display name> | <live level> | <zone long name>".
Source: the community "Fabled Mobs for Newbies" list (paullynch.org/eqguide/guides/fabled-mobs).
The drop column of that list is not needed here and is omitted.

For every row the script resolves (zone long name -> zone short name(s), "The Fabled <name>" ->
npc_types.name) against the PEQ dump shipped in Release-NMS-Server/database/release-peq.zip, using
spawn2 / spawnentry to prefer the npc id that actually spawns in the roster's zone. Name matching is
tolerant: underscores vs spaces, case, leading articles (a / an / the), backtick vs apostrophe,
a leading '#', commas and parentheticals. Anything it cannot resolve is printed, never guessed.

Usage:
    PYTHONDONTWRITEBYTECODE=1 python3 utils/scripts/fabled_roster.py [--dump PATH] [--report-only] [--out PATH]

    --dump PATH     release-peq.zip or an already extracted release-peq.sql (default: the repo zip).
                    The 560 MB SQL is streamed line by line; it is never printed.
    --report-only   Print the match report, do not write the seed file.
    --out PATH      Where to write the seed (default: utils/sql/fabled_roster_seed.sql).

The seed is `INSERT ... ON DUPLICATE KEY UPDATE era, level` so re-applying it never clobbers the
per-row overrides (multipliers, spell set, special abilities, chance, enabled) an operator tuned.
"""

import argparse
import io
import os
import re
import sys
import zipfile
from collections import defaultdict

# ----------------------------------------------------------------------------------------------
# Zone table: page long name -> (short names to search, era). Several long names map to one zone.
# Era is the NMS stage name the season scoping compares against (Classic|RoK|SoV|SoL|PoP).
# ----------------------------------------------------------------------------------------------
ZONES = {
    # Classic
    "North Qeynos":                           (["qeynos2"], "Classic"),
    "Qeynos Hills":                           (["qeytoqeys", "qeytoqrg"], "Classic"),  # PEQ places Pyzjn in qeytoqrg
    "Misty Thicket":                          (["misty"], "Classic"),
    "Butcherblock Mountains":                 (["butcher"], "Classic"),
    "Northern Desert of Ro":                  (["nro"], "Classic"),
    "Southern Desert of Ro":                  (["sro", "oasis"], "Classic"),  # live merged Oasis into SRo
    "Befallen":                               (["befallen"], "Classic"),
    "Lake Rathetear":                         (["lakerathe"], "Classic"),
    "The Mountains of Rathe":                 (["rathemtn"], "Classic"),
    "Crushbone":                              (["crushbone"], "Classic"),
    "Commonlands":                            (["commons", "ecommons", "commonlands"], "Classic"),
    "Najena":                                 (["najena"], "Classic"),
    "Highpass Hold":                          (["highpass", "highpasshold"], "Classic"),
    "Dagnor's Cauldron":                      (["cauldron"], "Classic"),
    "West Karana":                            (["qey2hh1"], "Classic"),
    "North Karana":                           (["northkarana"], "Classic"),
    "East Karana":                            (["eastkarana"], "Classic"),
    "South Karana":                           (["southkarana"], "Classic"),
    "Beholders Maze (Gorge of King Xorbb)":   (["beholder"], "Classic"),
    "Unrest":                                 (["unrest"], "Classic"),
    "Permafrost Keep":                        (["permafrost"], "Classic"),
    "Everfrost Peaks":                        (["everfrost"], "Classic"),
    "Upper Guk":                              (["guktop"], "Classic"),
    "Lower Guk":                              (["gukbottom"], "Classic"),
    "Solusek's Eye (Solusek A)":              (["soldunga"], "Classic"),
    "Nagafen's Lair (Solusek B)":             (["soldungb"], "Classic"),
    "Nagafen's Lair":                         (["soldungb"], "Classic"),
    "Castle Mistmoore":                       (["mistmoore"], "Classic"),
    "Kedge Keep":                             (["kedge"], "Classic"),
    "Ocean of Tears":                         (["oot"], "Classic"),
    # Ruins of Kunark
    "Kurn's Tower":                           (["kurn"], "RoK"),
    "Timorous Deep":                          (["timorous"], "RoK"),
    "Frontier Mountains":                     (["frontiermtns"], "RoK"),
    "Warsliks Woods":                         (["warslikswood"], "RoK"),
    "Lake of Ill Omen":                       (["lakeofillomen"], "RoK"),
    "Dreadlands":                             (["dreadlands"], "RoK"),
    "Burning Woods":                          (["burningwood"], "RoK"),
    "Trakanon's Teeth":                       (["trakanon"], "RoK"),
    "Skyfire Mountains":                      (["skyfire"], "RoK"),
    "Emerald Jungle":                         (["emeraldjungle"], "RoK"),
    "Kaesora":                                (["kaesora"], "RoK"),
    "Mines of Nurga":                         (["nurga"], "RoK"),
    "Old Sebilis":                            (["sebilis"], "RoK"),
    "Karnor's Castle":                        (["karnor"], "RoK"),
    "Swamp of No Hope":                       (["swampofnohope"], "RoK"),
    "City of Mist":                           (["citymist"], "RoK"),
    "Howling Stones (Charasis)":              (["charasis"], "RoK"),
    "Chardok":                                (["chardok"], "RoK"),
    # Scars of Velious
    "Eastern Wastes":                         (["eastwastes"], "SoV"),
    "Western Wastes":                         (["westwastes"], "SoV"),
    "Crystal Caverns":                        (["crystal"], "SoV"),
    "Tower of Frozen Shadow":                 (["frozenshadow"], "SoV"),
    "Great Divide":                           (["greatdivide"], "SoV"),
    "Wakening Land":                          (["wakening"], "SoV"),
    "Wakening Lands":                         (["wakening"], "SoV"),
    "The Wakening Land":                      (["wakening"], "SoV"),
    "Velketor's Labyrinth":                   (["velketor"], "SoV"),
    "Iceclad Ocean":                          (["iceclad"], "SoV"),
    "Cobalt Scar":                            (["cobaltscar"], "SoV"),
    "Siren's Grotto":                         (["sirens"], "SoV"),
    "Icewell Keep":                           (["thurgadinb"], "SoV"),
    "Temple of Veeshan":                      (["templeveeshan"], "SoV"),
    "Kael Drakkel":                           (["kael"], "SoV"),
    "Dragon Necropolis":                      (["necropolis"], "SoV"),
    "Skyshrine":                              (["skyshrine"], "SoV"),
    "Kerafyrm's Lair (Sleeper's Tomb)":       (["sleeper"], "SoV"),
    "Plane of Growth":                        (["growthplane"], "SoV"),
    # Shadows of Luclin
    "Paludal Caverns":                        (["paludal"], "SoL"),
    "Netherbian Lair":                        (["netherbian"], "SoL"),
    "Hollowshade Moor":                       (["hollowshade"], "SoL"),
    "Hollowshade Moors":                      (["hollowshade"], "SoL"),
    "Echo Caverns":                           (["echo"], "SoL"),
    "Marus Seru":                             (["mseru"], "SoL"),
    "Twilight Sea":                           (["twilight"], "SoL"),
    "Dawnshroud Peaks":                       (["dawnshroud"], "SoL"),
    "Mons Letalis":                           (["letalis"], "SoL"),
    "Grimling Forest":                        (["grimling"], "SoL"),
    "Shadeweaver's Thicket":                  (["shadeweaver"], "SoL"),
    "Scarlet Desert":                         (["scarlet"], "SoL"),
    "Tenebrous Mountains":                    (["tenebrous"], "SoL"),
    "The Tenebrous Mountains":                (["tenebrous"], "SoL"),
    "The Grey":                               (["thegrey"], "SoL"),
    "Fungus Grove":                           (["fungusgrove"], "SoL"),
    "The Maiden's Eye":                       (["maiden"], "SoL"),
    "Ssraeshza Temple":                       (["ssratemple"], "SoL"),
    "Grieg's End":                            (["griegsend"], "SoL"),
    "Katta Castellum":                        (["katta"], "SoL"),
    "The Deep":                               (["thedeep"], "SoL"),
    "Akheva Ruins":                           (["akheva"], "SoL"),
    "Vex Thal":                               (["vexthal"], "SoL"),
    "Sanctus Seru":                           (["sseru"], "SoL"),
    "Acrylia Caverns":                        (["acrylia"], "SoL"),
    "The Umbral Plains":                      (["umbral"], "SoL"),
    # Planes of Power
    "Torden, the Bastion of Thunder":         (["bothunder"], "PoP"),
    "Plane of Storms":                        (["postorms"], "PoP"),
    "Drunder, Fortress of Zek (Plane of Tactics)": (["potactics"], "PoP"),
    "Vegarlson, the Earthen Badlands":        (["poeartha"], "PoP"),
    "Ragrax, Stronghold of the Twelve":       (["poearthb"], "PoP"),
    "Reef of Coirnav":                        (["powater"], "PoP"),
    "Doomfire, the Burning Lands":            (["pofire"], "PoP"),
    "Eryslai, the Kingdom of Wind":           (["poair"], "PoP"),
    "Plane of Torment":                       (["potorment"], "PoP"),
    "Solusek Ro's Tower":                     (["solrotower"], "PoP"),
    "Plane of Innovation":                    (["poinnovation"], "PoP"),
    "Plane of Disease":                       (["podisease"], "PoP"),
    "Plane of Valor":                         (["povalor"], "PoP"),
    "Ruins of Lxanvom (Crypt of Decay)":      (["codecay"], "PoP"),
    "Lair of Terris Thule":                   (["nightmareb"], "PoP"),
    "Temple of Marr":                         (["hohonorb"], "PoP"),
    "Plane of Time B":                        (["potimeb"], "PoP"),
}

# Manual aliases for rows whose live name does not resolve by the tolerant matcher. Keys are the
# live name exactly as in ROSTER; values are the npc_types.name to look for instead (matched with
# the same tolerance, still restricted to the roster's zone). Add here rather than editing ROSTER.
ALIASES = {
    "The Fabled Heirophant Grazan":            "Hierophant Grazan",       # live typo
    "The Fabled Narmak Berekka":               "Narmak Berreka",          # PEQ spelling
    "The Fabled Harbringer Freglor":           "Harbinger Freglor",       # live typo
    "The Fabled Zeixshi'Kar the Ancient":      "Zeixshi-Kar the Ancient", # hyphen in PEQ
    "Fabled Falto, Lord of Thunder":           "Lord of Thunder",         # PEQ drops the first name
    "Fabled Hraquis Arch Mage":                "Hraquis Arch Magus",
    "A Fabled Monstrous Mudwalker":            "A Monsterous Mudwalker",  # PEQ spelling
    "The Fabled Warlord, Rallos Zek":          "Rallos Zek the Warlord",  # Tactics boss, not the Time version
}

# ----------------------------------------------------------------------------------------------
# Live roster. "<live name> | <live level> | <zone long name>". A level range keeps its low end.
# ----------------------------------------------------------------------------------------------
ROSTER = """
The Fabled Fippy Darkpaw | 4 | North Qeynos
The Fabled Snow Bunny | 10 | Eastern Wastes
The Fabled Mooto | 11 | Misty Thicket
The Fabled Corflunk | 15 | Butcherblock Mountains
The Fabled Rahotep | 16 | Northern Desert of Ro
The Fabled Thaumaturgist | 20 | Befallen
The Fabled Zarchoomi | 20 | Butcherblock Mountains
The Fabled Webclaw Murkwave | 25 | Lake Rathetear
The Fabled Emperor Crush | 25 | Crushbone
The Fabled Bargynn | 25 | Kurn's Tower
The Fabled Kizdean Gix | 25 | Commonlands
The Fabled Najena | 28 | Najena
The Fabled Pyzjn | 30 | Qeynos Hills
The Fabled Grenix Mucktail | 30 | Highpass Hold
The Fabled Lockjaw | 30 | Southern Desert of Ro
The Fabled Ambassador Dvinn | 30 | Crushbone
The Fabled Ugrak da Raider | 30 | Timorous Deep
The Fabled Stonegrinder | 30 | Frontier Mountains
The Fabled Yelloweyes | 30 | Paludal Caverns
The Fabled Barnacle Bones | 30 | Dagnor's Cauldron
The Fabled Bonedigger | 30 | Frontier Mountains
The Fabled Ch'ktok | 30 | Paludal Caverns
The Fabled Chief Goonda | 34 | West Karana
The Fabled King Xorbb | 35 | Beholders Maze (Gorge of King Xorbb)
The Fabled Undead Barkeep | 35 | Unrest
The Fabled Undead Knight of Unrest | 35 | Unrest
The Fabled Iksar Bandit Lord | 35 | Warsliks Woods
The Fabled Trog King | 35 | Netherbian Lair
The Fabled Reishicyben | 35 | Paludal Caverns
The Fabled Ghowlik | 35 | Hollowshade Moor
The Fabled Warpaw Dankpelt | 35 | Hollowshade Moor
The Fabled Evil Eye (Beholders Maze) | 38 | Beholders Maze (Gorge of King Xorbb)
The Fabled Grizzleknot | 40 | South Karana
The Fabled King Thex'Ka IV | 40 | Permafrost Keep
The Fabled Goblin Preacher | 40 | Permafrost Keep
The Fabled Oowomp | 40 | Timorous Deep
The Fabled Soothsayer Dregzak | 40 | Frontier Mountains
The Fabled Ry'Gorr Herbalist | 40 | Crystal Caverns
The Fabled Swarm Leader | 40 | Netherbian Lair
The Fabled Grum No Eyes | 40 | Hollowshade Moors
The Fabled Needlite Queen | 40 | Echo Caverns
The Fabled Grachnist The Destroyer | 42 | Warsliks Woods
The Fabled Karg IceBear | 45 | Everfrost Peaks
The Fabled Froglok Shin Lord | 45 | Upper Guk
The Fabled CWG Model EXG | 45 | Solusek's Eye (Solusek A)
The Fabled Garanel Rucksif | 45 | Unrest
The Fabled Reclusive Ghoul Magus | 45 | Unrest
The Fabled Bloodgill Marauder | 45 | Lake of Ill Omen
The Fabled Foreman Smason | 45 | Crystal Caverns
The Fabled Captain Ulmog | 45 | Eastern Wastes
The Fabled Priest Majes Medory | 45 | Tower of Frozen Shadow
The Fabled Narmak Berekka | 45 | Tower of Frozen Shadow
The Fabled Head Usher | 45 | Tower of Frozen Shadow
The Fabled Zorglim the Dead | 45 | Tower of Frozen Shadow
The Fabled Gleeknot Gnitrat | 45 | Hollowshade Moor
The Fabled Gorehorn | 45 | Hollowshade Moor
The Fabled Queen Kvaknak | 45 | Marus Seru
The Fabled Hydro | 45 | Twilight Sea
The Fabled Ancient Cyclops | 50 | Southern Desert of Ro
The Fabled Terrorantula | 50 | Southern Desert of Ro
The Fabled Quillmane | 50 | South Karana
The Fabled Gabbie Mardoddle | 50 | Solusek's Eye (Solusek A)
The Fabled Bilge Farfathom | 50 | Dagnor's Cauldron
The Fabled Cloaked Dhampyre | 50 | Castle Mistmoore
The Fabled Chancellor of Di'Zok | 50 | Lake of Ill Omen
The Fabled Lord Gorelik | 50 | Lake of Ill Omen
The Fabled Rotting Skeleton | 50 | Dreadlands
The Fabled Entalon | 50 | Burning Woods
The Fabled Chief RokGus | 50 | Frontier Mountains
The Fabled Froglok Hunter | 50 | Trakanon's Teeth
The Fabled Froglok Forager | 50 | Trakanon's Teeth
The Fabled Black Scar | 50 | Skyfire Mountains
The Fabled Life Leech | 50 | Crystal Caverns
The Fabled Foreman Rixact | 50 | Crystal Caverns
The Fabled Firbrand | 50 | Eastern Wastes
The Fabled Shardtooth | 50 | Great Divide
The Fabled Maggot Infested Flesh | 50 | Tower of Frozen Shadow
The Fabled Sambata Tribal Keeper | 50 | Dawnshroud Peaks
The Fabled Gnarlick | 50 | Hollowshade Moor
The Fabled Ancient Zelniak | 50 | Marus Seru
The Fabled Ranvik Darkwaters | 50 | Twilight Sea
The Fabled Warlord Skarlon | 53 | Nagafen's Lair (Solusek B)
The Fabled Rapticor | 53 | Wakening Land
The Fabled GrimFeather | 55 | North Karana
The Fabled Proon | 55 | East Karana
The Fabled Coloth Meadowgreen | 55 | South Karana
The Fabled Drelzna | 55 | Najena
The Fabled Maid Issis | 55 | Castle Mistmoore
The Fabled Gorgul Paclock | 55 | Burning Woods
The Fabled Eldak Howlingbear | 55 | Frontier Mountains
The Fabled Xalgoz | 55 | Kaesora
The Fabled Overseer Malam | 55 | Mines of Nurga
The Fabled Taskmaster Huflam | 55 | Mines of Nurga
The Fabled Blackguard Thabis | 55 | Mines of Nurga
The Fabled Overseer Pruckib | 55 | Mines of Nurga
The Fabled Froglok Ostiary | 55 | Old Sebilis
The Fabled Queen Dracnia | 55 | Crystal Caverns
The Fabled Chief Ry'Gorr | 55 - 59 | Eastern Wastes
The Fabled Gorul Longshanks | 55 | Great Divide
The Fabled Icetooth | 55 | Great Divide
The Fabled Shardwurm Matriarch | 55 | Great Divide
The Fabled Blizzent | 55 | Great Divide
The Fabled Cara Omica | 55 | Tower of Frozen Shadow
The Fabled Incoherent Spirit | 55 | Tower of Frozen Shadow
The Fabled Age Old Rockhopper | 55 | Dawnshroud Peaks
The Fabled Highpriest Giplish | 55 | Grimling Forest
The Fabled Spymaster Gephes | 55 | Grimling Forest
The Fabled Warlord Gok Thok | 55 | Shadeweaver's Thicket
The Fabled Warlord Shik Thras | 55 | Shadeweaver's Thicket
The Fabled Corrupter Ahgra | 55 | Grimling Forest
The Fabled Fiery Thought Leech | 55 | Mons Letalis
The Fabled Kraen Flameweaver | 55 | Scarlet Desert
The Fabled Ancient Darkwing Bat | 60 | Tenebrous Mountains
The Fabled Crystal Eyes | 60 | Velketor's Labyrinth
The Fabled Crystal Fang | 60 | Velketor's Labyrinth
The Fabled Death Beetle | 60 | Nagafen's Lair
The Fabled Evil Eye | 60 | Lower Guk
The Fabled Froglok Noble | 60 | Lower Guk
The Fabled Ghoul Assassin | 60 | Lower Guk
The Fabled Grand Vizier Poolakacha'tei | 60 | Wakening Lands
The Fabled Gullerback | 60 | Burning Woods
The Fabled Hangnail | 60 | Karnor's Castle
The Fabled Kaggy Krup | 60 | Swamp of No Hope
The Fabled Lord Ghiosk | 60 | City of Mist
The Fabled Mortificator Syythrak | 60 | The Mountains of Rathe
The Fabled Neh'Ashiir | 60 | City of Mist
The Fabled Oracle of Ry'Gorr | 60 | Eastern Wastes
The Fabled Pained Soul | 60 | Trakanon's Teeth
The Fabled Shardwurm Broodmother | 60 | Great Divide
The Fabled Skeletal Berserker | 60 | Karnor's Castle
The Fabled Skyshadow | 60 | Tenebrous Mountains
The Fabled Stormfeather | 60 | Iceclad Ocean
The Fabled Tserrina Syl'Tor | 60 | Tower of Frozen Shadow
The Fabled Ulump Pujluk | 60 | Swamp of No Hope
The Fabled Yvolcarn | 60 | Cobalt Scar
The Fabled Heirophant Grazan | 60 | The Grey
The Fabled Ancient Rockhopper | 65 | Mons Letalis
The Fabled Arch Duke Latol | 65 | Old Sebilis
The Fabled Azureake | 65 | Cobalt Scar
The Fabled Baron Yosig | 65 | Old Sebilis
The Fabled Crypt Caretaker | 65 | Old Sebilis
The Fabled Crypt Devourer | 65 | Howling Stones (Charasis)
The Fabled Crypt Excavator | 65 | Howling Stones (Charasis)
The Fabled Crypt Feaster | 65 | Howling Stones (Charasis)
The Fabled Crypt Keeper | 65 | Howling Stones (Charasis)
The Fabled Crypt Spectre | 65 | Howling Stones (Charasis)
The Fabled Crypt Wurm | 65 | Howling Stones (Charasis)
The Fabled Emissary Oomgado | 65 | The Tenebrous Mountains
The Fabled Fellspine | 65 | Siren's Grotto
The Fabled Frenzied Ghoul | 65 | Lower Guk
The Fabled Froglok King | 65 | Lower Guk
The Fabled Froglok Pickler | 65 | Old Sebilis
The Fabled Frostgiant Overseer | 65 | The Wakening Land
The Fabled Ghoul Cavalier | 65 | Lower Guk
The Fabled Ghoul Executioner | 65 | Lower Guk
The Fabled Ghoul Lord | 65 | Lower Guk
The Fabled Glucose | 65 | Icewell Keep
The Fabled Harbringer Freglor | 65 | Old Sebilis
The Fabled Jynhadar | 65 | Shadeweaver's Thicket
The Fabled Kobold Champion | 65 | Nagafen's Lair (Solusek B)
The Fabled Kobold Noble | 65 | Nagafen's Lair (Solusek B)
The Fabled Lady Gelistial | 65 | The Wakening Land
The Fabled Lord Rak'Ashiir | 65 | City of Mist
The Fabled Magus Rokyl | 65 | Nagafen's Lair (Solusek B)
The Fabled Mortiferous Protector | 65 | Howling Stones (Charasis)
The Fabled Priest Delar | 65 | The Wakening Land
The Fabled Skeletal Captain | 65 | Karnor's Castle
The Fabled Solusek Kobold King | 65 | Nagafen's Lair (Solusek B)
The Fabled Spire Lord | 65 | Mons Letalis
The Fabled Tuchako | 65 | Fungus Grove
The Fabled Undertow | 65 | Kedge Keep
The Fabled Skeletal Warlord | 68 | Karnor's Castle
The Fabled Lendiniara the Keeper | 70 | Temple of Veeshan
The Fabled Revenant Sthzzzizt | 70 | The Grey
The Fabled Derasinal | 70 | Western Wastes
The Fabled Chamberlain Krystorf | 70 | Icewell Keep
The Fabled Drolvarg Captain | 70 | Karnor's Castle
The Fabled Froglok Commander | 70 | Old Sebilis
The Fabled Klandicar | 70 | Western Wastes
The Fabled Heratius Grolden | 70 | The Tenebrous Mountains
The Fabled Ail the Elder | 70 | Plane of Growth
The Fabled Kobold Priest | 70 | Nagafen's Lair (Solusek B)
The Fabled Draazak | 70 | Western Wastes
The Fabled Fjokar Frozenshard | 70 | Kael Drakkel
The Fabled King Tranix | 70 | Nagafen's Lair (Solusek B)
The Fabled Faydedar | 70 | Timorous Deep
The Fabled Kallis Stormcaller | 70 | Kael Drakkel
The Fabled Warmaster Utvara | 70 | Dragon Necropolis
The Fabled Efreeti Lord Djarn | 70 | Nagafen's Lair (Solusek B)
The Fabled Froglok Bartender | 70 | Old Sebilis
Velketor's Fabled Experiment | 70 | Velketor's Labyrinth
The Fabled Goranga Battlemaster | 70 | The Maiden's Eye
The Fabled Derakor the Vindicator | 70 | Kael Drakkel
The Fabled Karkona | 70 | Western Wastes
The Fabled Ikatiar the Venom | 70 | Temple of Veeshan
The Fabled Priest Kak'thak | 70 | Fungus Grove
The Fabled Estrella of Gloomwater | 70 | Kedge Keep
The Fabled Esorpa of the Ring | 70 | Western Wastes
The Fabled Fayl Everstrong | 70 | Plane of Growth
The Fabled Drolvarg Warlord | 70 | Karnor's Castle
The Fabled Entariz | 70 | Western Wastes
The Fabled Revenant Zsshta | 70 | The Grey
The Fabled Wuoshi | 70 | The Wakening Land
The Fabled Ishva Mal | 70 | South Karana
The Fabled Gruplinort | 70 | Old Sebilis
The Fabled Myga | 70 | Western Wastes
The Fabled Idol of Rallos Zek | 70 | Kael Drakkel
The Fabled High Priestess Sercema | 70 | Siren's Grotto
The Fabled Gorenaire | 70 | Dreadlands
The Fabled Harla Dar | 70 | Western Wastes
Velketor the Fabled Sorcerer | 70 | Velketor's Labyrinth
The Fabled Warlord Skarlon | 70 | Nagafen's Lair (Solusek B)
The Fabled Bridge Keeper | 70 | Chardok
The Fabled Rumbleroot | 70 | Plane of Growth
The Fabled Charayan the Crusader | 70 | Skyshrine
The Fabled Jortreva the Crusader | 70 | Skyshrine
The Fabled Lord Doljonijiarnimorinar | 70 | Velketor's Labyrinth
The Fabled Eashen of the Sky | 70 | Temple of Veeshan
The Fabled Boulder | 70 | The Grey
The Fabled Dustbinder Grakina | 70 | Dragon Necropolis
The Fabled Treah Greenroot | 70 | Plane of Growth
The Fabled Ayillish | 70 | Western Wastes
The Fabled Crusader Kezzal | 70 | The Grey
The Fabled Dominator Yisaki | 70 | Dragon Necropolis
The Fabled Seeker Bulava | 70 | Dragon Necropolis
The Fabled Kelorek'Dar | 70 | Cobalt Scar
The Fabled Watch Captain Hir'Roul | 70 | Chardok
The Fabled Stronghorn | 70 | Western Wastes
The Fabled Shadow Overlord | 70 | The Maiden's Eye
The Fabled Zlandicar | 70 | Dragon Necropolis
The Fabled Mistress Latazura | 70 | Siren's Grotto
The Fabled Hierophant Prime Grekal | 70 | Old Sebilis
The Fabled King Tormax | 70 | Kael Drakkel
The Fabled Grizznot | 70 | Icewell Keep
The Fabled Talendor | 70 | Skyfire Mountains
The Fabled Severilous | 70 | Emerald Jungle
The Fabled Susarrak the Crusader | 70 | Skyshrine
The Fabled Allizewsaur | 70 | Ocean of Tears
The Fabled Vilefang | 70 | Dragon Necropolis
The Fabled Dozekar the Cursed | 70 | Temple of Veeshan
The Fabled General Jared Blaystich | 70 | Echo Caverns
The Fabled Prince Thirneg | 70 | Plane of Growth
The Fabled Brogg | 70 | Old Sebilis
The Fabled Statue of Rallos Zek | 72 | Kael Drakkel
The Fabled Taskmaster Vezhkah | 75 | Ssraeshza Temple
The Fabled Tjudawos the Ancient | 75 | Kerafyrm's Lair (Sleeper's Tomb)
The Fabled Prince Selrach Di'zok | 75 | Chardok
The Fabled Tunare | 75 | Plane of Growth
The Fabled Lady Mirenilla | 75 | Temple of Veeshan
The Fabled Khemot Agarthizar | 75 | Grieg's End
The Fabled Lodizal | 75 | Iceclad Ocean
The Fabled Queen Velazul Di'Zok | 75 | Chardok
The Fabled Lord Vyemm | 75 | Temple of Veeshan
The Fabled Warden Mekuzh | 75 | Ssraeshza Temple
The Fabled Vaniki | 75 | Dragon Necropolis
The Fabled Lord Yelinak | 75 | Skyshrine
The Fabled Queen Raltaas | 75 | Dragon Necropolis
The Fabled Rhozth Ssrakezh | 75 | Ssraeshza Temple
The Fabled Emperor Chottal | 75 | Old Sebilis
The Fabled Kildrukaun the Ancient | 75 | Kerafyrm's Lair (Sleeper's Tomb)
The Fabled Rhozth Ssravizh | 75 | Ssraeshza Temple
The Fabled Valdanov Zevfeer | 75 | The Tenebrous Mountains
The Fabled Zlexak | 75 | Temple of Veeshan
The Fabled Jorlleag | 75 | Temple of Veeshan
The Fabled Taskmaster Zerumaz | 75 | Ssraeshza Temple
The Fabled Del Sapara | 75 | Western Wastes
The Fabled Drusella Sathir | 75 | Howling Stones (Charasis)
The Fabled Sontalak | 75 | Western Wastes
The Fabled Aaryonar | 75 | Temple of Veeshan
The Fabled Taskmaster Zhe'Vozh | 75 | Ssraeshza Temple
The Fabled Final Arbiter | 75 | Kerafyrm's Lair (Sleeper's Tomb)
The Fabled Sevalak | 75 | Temple of Veeshan
The Fabled Lady Nevederia | 75 | Temple of Veeshan
The Fabled Servitor of Luclin | 75 | Grieg's End
The Fabled Keldor Dek'Torek | 75 | Kael Drakkel
The Fabled Mraaka | 75 | Western Wastes
The Fabled Lord Kreizenn | 75 | Temple of Veeshan
The Fabled Warlord Tk'kik'tthik | 75 | Fungus Grove
The Fabled Master of the Guard | 75 | Kerafyrm's Lair (Sleeper's Tomb)
The Fabled Cekenar | 75 | Temple of Veeshan
The Fabled Lcea Katta | 75 | Katta Castellum
The Fabled Burrower Parasite | 75 | The Deep
The Fabled Froglok Chef | 75 | Old Sebilis
The Fabled Gozzrem | 75 | Temple of Veeshan
The Fabled Taskmaster Revan'Kezh | 75 | Ssraeshza Temple
The Fabled Ionat | 75 | Western Wastes
The Fabled Venril Sathir | 75 | Karnor's Castle
The Fabled Tantor | 75 | Western Wastes
The Fabled Taskmaster Keuzozh | 75 | Ssraeshza Temple
The Fabled Dain Frostreaver IV | 75 | Icewell Keep
The Fabled Tolapumj | 75 | Old Sebilis
The Fabled Telkorenar | 75 | Temple of Veeshan
The Fabled Itraer Vius | 75 | Akheva Ruins
The Fabled Vyskudra the Ancient | 75 | Kerafyrm's Lair (Sleeper's Tomb)
The Fabled Trakanon | 75 | Old Sebilis
The Fabled Lord Feshlak | 75 | Temple of Veeshan
The Fabled Taskmaster Kavamezh | 75 | Ssraeshza Temple
The Fabled Progenitor | 75 | Kerafyrm's Lair (Sleeper's Tomb)
The Fabled Zeixshi'Kar the Ancient | 75 | Kerafyrm's Lair (Sleeper's Tomb)
The Fabled Grendish the Crusader | 75 | Skyshrine
The Fabled Burrower Beast | 75 | The Deep
The Fabled Myconid Spore King | 75 | Old Sebilis
The Fabled Dagarn the Destroyer | 75 | Temple of Veeshan
The Fabled Taskmaster Mikazha | 75 | Ssraeshza Temple
The Fabled Overseer | 75 | Kerafyrm's Lair (Sleeper's Tomb)
The Fabled Overking Bathezid | 75 | Chardok
The Fabled Lord Koi'Doken | 75 | Temple of Veeshan
The Fabled Thought Horror Overfiend | 80 | The Deep
The Fabled Shei Vinitras | 80 | Akheva Ruins
The Fabled Auliffe Chaoswind | 80 | Torden, the Bastion of Thunder
The Fabled Hreidar Lynhillig | 80 | Torden, the Bastion of Thunder
The Fabled Thall Xundraux Diabo | 80 | Vex Thal
The Fabled Insanity Crawler | 80 | Akheva Ruins
The Fabled Vyzh'dra the Cursed | 80 | Ssraeshza Temple
The Fabled Diabo Xi Xin | 80 | Vex Thal
The Fabled Lord Inquisitor Seru | 80 | Sanctus Seru
The Fabled Kuanbyr Hailstorm | 80 | Torden, the Bastion of Thunder
The Fabled Thall Va Xakra | 80 | Vex Thal
The Fabled Gurebk, Lord of Krendic | 80 | Plane of Storms
The Fabled Vulak'Aerr | 80 | Temple of Veeshan
The Fabled Khati Sha the Twisted | 80 | Acrylia Caverns
The Fabled Laef Windfall | 80 | Torden, the Bastion of Thunder
The Fabled Brynju Thunderclap | 80 | Torden, the Bastion of Thunder
The Fabled Grieg Veneficus | 80 | Grieg's End
The Fabled Thall Va Kelun | 80 | Vex Thal
Fabled Falto, Lord of Thunder | 80 | Plane of Storms
The Fabled Kaas Thox Xi Aten Ha Ra | 80 | Vex Thal
The Fabled Diabo Xi Xin Thall | 80 | Vex Thal
The Fabled High Priest of Ssraeshza | 80 | Ssraeshza Temple
The Fabled Tagrin Maldric | 80 | Drunder, Fortress of Zek (Plane of Tactics)
The Fabled Diabo Xi Va | 80 | Vex Thal
The Fabled Jeplak, Lord of Srerendi | 80 | Plane of Storms
The Fabled Avatar of War | 80 | Kael Drakkel
The Fabled Warder of Life | 80 | Acrylia Caverns
The Fabled Eindride Icestorm | 80 | Torden, the Bastion of Thunder
The Fabled Xerkizh The Creator | 80 | Ssraeshza Temple
The Fabled Diabo Xi Va Temariel | 80 | Vex Thal
The Fabled Oreen Wavecrasher | 80 | Torden, the Bastion of Thunder
The Fabled Glykus Helmir | 80 | Drunder, Fortress of Zek (Plane of Tactics)
The Fabled Va Xi Aten Ha Ra | 80 | Vex Thal
The Fabled Doomshade | 80 | The Umbral Plains
The Fabled Rumblecrush | 80 | The Umbral Plains
The Fabled Stampeding Piglet | 80 | Drunder, Fortress of Zek (Plane of Tactics)
The Fabled Kaas Thox Xi Ans Dyek | 80 | Vex Thal
The Fabled Neffiken, Lord of Kelek'Vor | 80 | Plane of Storms
The Fabled Warder of Death | 80 | Acrylia Caverns
The Fabled Gaukr Sandstorm | 80 | Torden, the Bastion of Thunder
Fabled A Prismatic Basilisk | 83 | Vegarlson, the Earthen Badlands
Fabled Ferocious Barracuda | 83 | Reef of Coirnav
A Fabled Triloun | 83 | Reef of Coirnav
Fabled Ancient Vekerchiki Champion | 83 | Vegarlson, the Earthen Badlands
Fabled Regrua Protector | 83 | Reef of Coirnav
Fabled Doomfire Firecharmer | 83 | Doomfire, the Burning Lands
Fabled Earthcrafted Assassin | 83 | Vegarlson, the Earthen Badlands
Fabled The Living Earth | 83 | Vegarlson, the Earthen Badlands
Fabled Razorfin | 83 | Reef of Coirnav
Fabled Obsidian War Spider | 83 | Doomfire, the Burning Lands
Fabled Jopal Flame Protector | 83 | Doomfire, the Burning Lands
Fabled Savage Deepwater Kraken | 83 | Reef of Coirnav
Fabled A Perfect Rock Formation | 83 | Vegarlson, the Earthen Badlands
Fabled Hammertooth | 83 | Reef of Coirnav
Fabled Doomfire Vicar | 83 | Doomfire, the Burning Lands
Fabled Fiery Spirit Equine Overlord | 83 | Doomfire, the Burning Lands
A Fabled Jopal | 83 | Doomfire, the Burning Lands
Fabled Monstrous Sea Turtle | 83 | Reef of Coirnav
Fabled Magma Overlord | 83 | Doomfire, the Burning Lands
Fabled Jopal Seer | 83 | Doomfire, the Burning Lands
Fabled Glimmerstone | 83 | Vegarlson, the Earthen Badlands
Fabled Triloun Seer | 83 | Reef of Coirnav
Fabled A Korascian Warlord | 83 | Vegarlson, the Earthen Badlands
Fabled Flame Wilder | 83 | Doomfire, the Burning Lands
Fabled Doomfire Magus | 83 | Doomfire, the Burning Lands
Fabled Temple Guardian | 83 | Eryslai, the Kingdom of Wind
Fabled Jopal Tracker | 83 | Doomfire, the Burning Lands
Fabled Wild Fiery Spirit Steed | 83 | Doomfire, the Burning Lands
Fabled A Shimmering Gem Sentry | 83 | Vegarlson, the Earthen Badlands
Fabled Vicar of Fire | 83 | Doomfire, the Burning Lands
Fabled Dark Obsidian Lava Spider | 83 | Doomfire, the Burning Lands
Fabled Frenzied Anglerfish | 83 | Reef of Coirnav
Fabled Swordfang | 83 | Reef of Coirnav
Fabled Doomfire Warmaster | 83 | Doomfire, the Burning Lands
Fabled Galsinak Earthrumble | 83 | Vegarlson, the Earthen Badlands
Fabled Charmer of Fire | 83 | Doomfire, the Burning Lands
Fabled Tribal Leader Diseranon | 83 | Vegarlson, the Earthen Badlands
Fabled Flame Overlord | 83 | Doomfire, the Burning Lands
Fabled Regrua Overlord | 83 | Reef of Coirnav
Fabled Vekerchiki Warrior | 83 | Vegarlson, the Earthen Badlands
Fabled Jopal Crafter | 83 | Doomfire, the Burning Lands
Fabled Obsidian Tree Spider Queen | 83 | Doomfire, the Burning Lands
Fabled A Pristine Gem Golem | 83 | Vegarlson, the Earthen Badlands
Fabled Jopal Lavahurler | 83 | Doomfire, the Burning Lands
Fabled Captain of Fire | 83 | Doomfire, the Burning Lands
Fabled Hraquis Arch Mage | 83 | Reef of Coirnav
Fabled Gigadon | 83 | Reef of Coirnav
The Fabled Diaku Armorer | 83 | Drunder, Fortress of Zek (Plane of Tactics)
Fabled Doomfire Warlord | 83 | Doomfire, the Burning Lands
Fabled Furious Deepwater Kraken | 83 | Reef of Coirnav
The Fabled Magmaton | 85 | Doomfire, the Burning Lands
The Fabled Saryrn | 85 | Plane of Torment
A Fabled Perfected Warder of Earth | 85 | Vegarlson, the Earthen Badlands
The Fabled Queen Silandria | 85 | Eryslai, the Kingdom of Wind
The Fabled Protector of Dresolik | 85 | Solusek Ro's Tower
The Fabled Krziik the Mighty | 85 | Reef of Coirnav
The Fabled Galremos | 85 | Solusek Ro's Tower
The Fabled Rizlona | 85 | Solusek Ro's Tower
The Fabled Arlyxir | 85 | Solusek Ro's Tower
The Fabled Chancellor Kirtra | 85 | Doomfire, the Burning Lands
The Fabled Blazzax the Omnifiend | 85 | Doomfire, the Burning Lands
The Fabled Xuzl | 85 | Solusek Ro's Tower
The Fabled Warlord Prollaz | 85 | Doomfire, the Burning Lands
The Fabled Jaxoliz Dawneyes | 85 | Doomfire, the Burning Lands
The Fabled Hebabbilys the Ragelord | 85 | Doomfire, the Burning Lands
The Fabled Emperor Ssraeshza | 85 | Ssraeshza Temple
The Fabled Rinturion Windblade | 85 | Eryslai, the Kingdom of Wind
The Fabled Peregrin Rockskull | 85 | Vegarlson, the Earthen Badlands
The Fabled Hydrotha | 85 | Reef of Coirnav
A Fabled Monstrous Mudwalker | 85 | Vegarlson, the Earthen Badlands
The Fabled Xanamech Nezmirthafen | 85 | Plane of Innovation
The Fabled Jiva | 85 | Solusek Ro's Tower
The Fabled Keeper of Sorrows | 85 | Plane of Torment
The Fabled Arch Mage Yozanni | 85 | Doomfire, the Burning Lands
The Fabled Babnoxis the Spider Queen | 85 | Doomfire, the Burning Lands
The Fabled Javonn the Overlord | 85 | Doomfire, the Burning Lands
The Fabled General Reparm | 85 | Doomfire, the Burning Lands
The Fabled Grummus | 85 | Plane of Disease
The Fabled Azobian the Darklord | 85 | Doomfire, the Burning Lands
The Fabled Aten Ha Ra | 85 | Vex Thal
The Fabled Quavonis Firetail | 85 | Doomfire, the Burning Lands
The Fabled Warlord Gintolaken | 85 | Ragrax, Stronghold of the Twelve
The Fabled Manaetic Behemoth | 85 | Plane of Innovation
The Fabled Grioihin the Wise | 85 | Reef of Coirnav
The Fabled Aerin'Dar | 85 | Plane of Valor
The Fabled Elemental Masterpiece | 85 | Eryslai, the Kingdom of Wind
The Fabled Bertoxxulous | 85 | Ruins of Lxanvom (Crypt of Decay)
The Fabled Reaxnous the Chaoslord | 85 | Doomfire, the Burning Lands
The Fabled Pyronis | 85 | Doomfire, the Burning Lands
The Fabled Chancellor Traxom | 85 | Doomfire, the Burning Lands
The Fabled Criare Sunmane | 85 | Doomfire, the Burning Lands
The Fabled Terris Thule | 85 | Lair of Terris Thule
The Fabled Omni Magus Crato | 85 | Doomfire, the Burning Lands
The Fabled Quarm | 90 | Plane of Time B
The Fabled Coirnav the Avatar of Water | 90 | Reef of Coirnav
The Fabled Cazic Thule | 90 | Plane of Time B
The Fabled Saryrn | 90 | Plane of Time B
The Fabled Agnarr the Storm Lord | 90 | Torden, the Bastion of Thunder
The Fabled Avatar of Earth | 90 | Ragrax, Stronghold of the Twelve
The Fabled Lord Mithaniel Marr | 90 | Temple of Marr
The Fabled Fennin Ro, the Tyrant of Fire | 90 | Doomfire, the Burning Lands
The Fabled Bertoxxulous | 90 | Plane of Time B
The Fabled Rallos Zek | 90 | Plane of Time B
The Fabled Terris Thule | 90 | Plane of Time B
The Fabled Warlord, Rallos Zek | 90 | Drunder, Fortress of Zek (Plane of Tactics)
The Fabled Mystical Arbitor of Earth | 90 | Vegarlson, the Earthen Badlands
The Fabled Vallon Zek | 90 | Drunder, Fortress of Zek (Plane of Tactics)
The Fabled Innoruuk | 90 | Plane of Time B
The Fabled Tallon Zek | 90 | Plane of Time B
The Fabled Xegony the Queen of Air | 90 | Eryslai, the Kingdom of Wind
The Fabled Solusek Ro | 90 | Solusek Ro's Tower
"""

# ----------------------------------------------------------------------------------------------
# Name normalisation
# ----------------------------------------------------------------------------------------------
_ARTICLE = re.compile(r"^(?:a|an|the)\s+")
_PAREN = re.compile(r"\s*\([^)]*\)")
_NONWORD = re.compile(r"[^a-z0-9 ]")
_SPACES = re.compile(r"\s+")


def norm(name):
    """Fold an npc_types.name or a live display name to a comparable key."""
    s = name.strip().lstrip("#").replace("_", " ").lower()
    s = _PAREN.sub("", s)
    s = s.replace("`", "").replace("'", "").replace("’", "")
    s = _NONWORD.sub(" ", s)
    s = _SPACES.sub(" ", s).strip()
    s = _ARTICLE.sub("", s)
    return s


def live_to_base(live_name):
    """'The Fabled Ghoul Lord' -> 'ghoul lord'; 'Velketor the Fabled Sorcerer' -> 'velketor the sorcerer'."""
    s = _PAREN.sub("", live_name)
    s = re.sub(r"\bFabled\b", " ", s)
    s = re.sub(r"^\s*(?:The|A|An)\s+(?=\S)", "", s.strip())
    return norm(s)


def tokens(key):
    return set(key.split())


# ----------------------------------------------------------------------------------------------
# Dump reader - streams the .sql (or the .zip it is in), keeps only what the matcher needs.
# ----------------------------------------------------------------------------------------------
_RE_NPC = re.compile(r"^\((\d+),'((?:[^'\\]|\\.)*)',(?:NULL|'(?:[^'\\]|\\.)*'),(\d+),")
_RE_SPAWN2 = re.compile(r"^\((\d+),(\d+),'([^']*)',(\d+),")
_RE_SPAWNENTRY = re.compile(r"^\((\d+),(\d+),(\d+),")
_RE_ZONE = re.compile(r"^\((\d+),(\d+),(\d+),'([^']*)','((?:[^'\\]|\\.)*)'")
_RE_INSERT = re.compile(r"^INSERT INTO `(\w+)`")


class Dump:
    def __init__(self):
        self.npc_name = {}        # id -> name
        self.npc_level = {}       # id -> level
        self.group_zones = defaultdict(set)   # spawngroupID -> {zone short}
        self.group_npcs = defaultdict(set)    # spawngroupID -> {npc id}
        self.zone_id = {}         # short -> zoneidnumber
        self.by_key = defaultdict(list)       # norm(name) -> [npc id]

    def open(self, path):
        if path.lower().endswith(".zip"):
            zf = zipfile.ZipFile(path)
            member = next(n for n in zf.namelist() if n.lower().endswith(".sql"))
            return io.TextIOWrapper(zf.open(member), encoding="latin-1", newline="")
        return open(path, encoding="latin-1", newline="")

    def load(self, path):
        wanted = {"npc_types", "spawn2", "spawnentry", "zone"}
        mode = None
        with self.open(path) as f:
            for line in f:
                if line[0] == "(":
                    if mode == "npc_types":
                        m = _RE_NPC.match(line)
                        if m:
                            nid = int(m.group(1))
                            name = m.group(2).replace("\\'", "'").replace("\\\\", "\\")
                            self.npc_name[nid] = name
                            self.npc_level[nid] = int(m.group(3))
                    elif mode == "spawn2":
                        m = _RE_SPAWN2.match(line)
                        if m:
                            self.group_zones[int(m.group(2))].add(m.group(3))
                    elif mode == "spawnentry":
                        m = _RE_SPAWNENTRY.match(line)
                        if m:
                            self.group_npcs[int(m.group(1))].add(int(m.group(2)))
                    elif mode == "zone":
                        m = _RE_ZONE.match(line)
                        if m:
                            self.zone_id.setdefault(m.group(4), int(m.group(2)))
                elif line.startswith("INSERT INTO"):
                    m = _RE_INSERT.match(line)
                    mode = m.group(1) if m and m.group(1) in wanted else None
                else:
                    mode = None  # rows of the next table always follow a fresh INSERT INTO line
        # derived indexes
        self.npc_zones = defaultdict(set)     # npc id -> {zone short} (via spawn2/spawnentry)
        for g, npcs in self.group_npcs.items():
            zones = self.group_zones.get(g)
            if not zones:
                continue
            for n in npcs:
                self.npc_zones[n].update(zones)
        for nid, name in self.npc_name.items():
            if "fabled" in name.lower():
                continue  # existing Fabled variants are never the base named
            self.by_key[norm(name)].append(nid)


# ----------------------------------------------------------------------------------------------
# Matching
# ----------------------------------------------------------------------------------------------
def parse_roster():
    rows = []
    for raw in ROSTER.strip().splitlines():
        raw = raw.strip()
        if not raw or raw.startswith("#"):
            continue
        name, level, zone = [p.strip() for p in raw.split("|")]
        level = int(re.match(r"\d+", level).group(0))
        rows.append((name, level, zone))
    return rows


def in_zone(dump, nid, shorts, zone_ids):
    """0 = spawns in zone, 1 = id prefix belongs to zone, 2 = neither."""
    if dump.npc_zones.get(nid, set()) & shorts:
        return 0
    if nid // 1000 in zone_ids:
        return 1
    return 2


def rank(dump, nid, shorts, zone_ids):
    """Lower is better: spawns in zone, then a plain name over the '#'/'trailing _' script variants."""
    name = dump.npc_name[nid]
    return (in_zone(dump, nid, shorts, zone_ids), name.startswith("#"), name.rstrip("_") != name)


def best_group(dump, ids, shorts, zone_ids):
    """Keep only the ids sharing the best rank (several plain duplicates in one zone are all kept)."""
    ranked = sorted(ids, key=lambda n: (rank(dump, n, shorts, zone_ids), n))
    top = rank(dump, ranked[0], shorts, zone_ids)
    return [n for n in ranked if rank(dump, n, shorts, zone_ids) == top], top[0]


def resolve(dump, live_name, zone_long):
    """Return (ids, how) where how in {exact, alias, fuzzy, global, none}; ids may be several."""
    shorts, _era = ZONES[zone_long]
    shorts = set(shorts)
    zone_ids = {dump.zone_id[s] for s in shorts if s in dump.zone_id}
    keys = [live_to_base(live_name)]
    how_for_key = ["exact"]
    if live_name in ALIASES:
        keys.insert(0, norm(ALIASES[live_name]))
        how_for_key.insert(0, "alias")

    global_hit = None
    for key, how in zip(keys, how_for_key):
        cands = dump.by_key.get(key, [])
        if not cands:
            continue
        group, where = best_group(dump, cands, shorts, zone_ids)
        if where < 2:
            return group, how
        # name exists but nowhere near this zone: remember as a global fallback
        global_hit = (group, how)
        break

    # fuzzy: token containment, restricted to NPCs that spawn in (or belong to) the zone.
    # A one-word live name must resolve to exactly one distinct npc name (Oowomp -> The_Great_Oowomp);
    # a multi-word one may be contained in, or contain, the npc name (Falto, Lord of Thunder).
    want = tokens(keys[-1])
    hits = []
    for nid, name in dump.npc_name.items():
        if "fabled" in name.lower() or in_zone(dump, nid, shorts, zone_ids) == 2:
            continue
        have = tokens(norm(name))
        if want <= have or (have <= want and len(have) >= 2):
            hits.append(nid)
    if hits:
        group, _where = best_group(dump, hits, shorts, zone_ids)
        distinct = {norm(dump.npc_name[n]) for n in group}
        if len(want) >= 2 or len(distinct) == 1:
            return group, "fuzzy"

    if global_hit:
        return global_hit[0], "global"
    return [], "none"


def main():
    here = os.path.dirname(os.path.abspath(__file__))
    server_root = os.path.abspath(os.path.join(here, "..", ".."))
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--dump", default=os.path.join(server_root, "database", "release-peq.zip"),
                    help="release-peq.zip or extracted release-peq.sql")
    ap.add_argument("--out", default=os.path.join(server_root, "utils", "sql", "fabled_roster_seed.sql"))
    ap.add_argument("--report-only", action="store_true")
    ap.add_argument("--verbose", action="store_true", help="also list every matched row")
    args = ap.parse_args()

    for zone_long in {r[2] for r in parse_roster()}:
        if zone_long not in ZONES:
            sys.exit(f"ROSTER zone not in ZONES table: {zone_long!r}")

    dump = Dump()
    print(f"reading {args.dump} ...", file=sys.stderr)
    dump.load(args.dump)
    print(f"npc_types={len(dump.npc_name)} spawngroups={len(dump.group_npcs)} zones={len(dump.zone_id)}",
          file=sys.stderr)

    rows = parse_roster()
    seed = {}          # npc id -> (era, level, live_name, zone_long)
    unmatched, ambiguous, fuzzy, global_only, dup_live = [], [], [], [], []
    seen_live = {}

    for live_name, level, zone_long in rows:
        shorts, era = ZONES[zone_long]
        k = (live_to_base(live_name), zone_long)
        if k in seen_live:
            dup_live.append((live_name, level, zone_long, seen_live[k]))
        seen_live[k] = level

        ids, how = resolve(dump, live_name, zone_long)
        if not ids:
            unmatched.append((live_name, level, zone_long))
            continue
        if how == "fuzzy":
            fuzzy.append((live_name, zone_long, [(n, dump.npc_name[n]) for n in ids]))
        elif how == "global":
            global_only.append((live_name, zone_long, [(n, dump.npc_name[n], sorted(dump.npc_zones.get(n, []))) for n in ids]))
        if len(ids) > 1:
            ambiguous.append((live_name, zone_long, [(n, dump.npc_name[n]) for n in ids]))
        for n in ids:
            prev = seed.get(n)
            if prev and prev[1] >= level:
                continue
            seed[n] = (era, level, live_name, zone_long)

    # ---- report ----------------------------------------------------------------------------
    matched_rows = len(rows) - len(unmatched)
    print(f"roster rows: {len(rows)}")
    print(f"matched:     {matched_rows}  (exact/alias {matched_rows - len(fuzzy) - len(global_only)}, "
          f"fuzzy {len(fuzzy)}, global-fallback {len(global_only)})")
    print(f"unmatched:   {len(unmatched)}")
    print(f"ambiguous:   {len(ambiguous)}  (all candidate ids included)")
    print(f"seed rows:   {len(seed)}  distinct npc ids")
    if dup_live:
        print("\nduplicate live rows (higher level kept):")
        for live_name, level, zone_long, prev in dup_live:
            print(f"  {live_name} | {prev} vs {level} | {zone_long}")
    if unmatched:
        print("\nUNMATCHED:")
        for live_name, level, zone_long in unmatched:
            print(f"  {live_name} | {level} | {zone_long}")
    if ambiguous:
        print("\nAMBIGUOUS (several npc ids spawn in the zone under that name; all included):")
        for live_name, zone_long, c in ambiguous:
            print(f"  {live_name} | {zone_long} -> " + ", ".join(f"{n}:{nm}" for n, nm in c))
    if fuzzy:
        print("\nFUZZY (token match, review):")
        for live_name, zone_long, c in fuzzy:
            print(f"  {live_name} | {zone_long} -> " + ", ".join(f"{n}:{nm}" for n, nm in c))
    if global_only:
        print("\nGLOBAL FALLBACK (name exists but has no spawn point / id prefix in the zone; review):")
        for live_name, zone_long, c in global_only:
            print(f"  {live_name} | {zone_long} -> " + ", ".join(f"{n}:{nm} zones={z}" for n, nm, z in c))
    if args.verbose:
        print("\nMATCHED:")
        for n, (era, level, live_name, zone_long) in sorted(seed.items(), key=lambda kv: (kv[1][0], kv[0])):
            print(f"  {n:>8} {dump.npc_name[n]:<40} L{dump.npc_level[n]:<3} -> {level:<3} {era:<7} {live_name} ({zone_long})")

    if args.report_only:
        return

    # ---- seed file --------------------------------------------------------------------------
    era_order = {"Classic": 0, "RoK": 1, "SoV": 2, "SoL": 3, "PoP": 4}
    per_era = defaultdict(int)
    for era, *_ in seed.values():
        per_era[era] += 1
    lines = [
        "-- ============================================================================",
        "-- Fabled roster seed for `fabled_npcs` (content DB).",
        "-- GENERATED by utils/scripts/fabled_roster.py - edit the script, not this file.",
        "--",
        f"-- live roster rows: {len(rows)}   matched: {matched_rows}   unmatched: {len(unmatched)}   "
        f"ambiguous: {len(ambiguous)}",
        f"-- seed rows (distinct npc ids): {len(seed)}   "
        + "   ".join(f"{e}: {per_era[e]}" for e in sorted(per_era, key=era_order.get)),
        "--",
        "-- Columns not listed keep their defaults: hp_mult/min_hit_mult/max_hit_mult = -1 (derive),",
        "-- npc_spells_id = 0 (keep), special_abilities_append = '', chance = 0 (season chance),",
        "-- enabled = 1. Re-applying only refreshes era and level, so per-row tuning survives.",
        "--",
        "-- Apply to the CONTENT database (see CODEBASE.md 4.4):",
        "--   mysql -u <user> -p <content_db> < utils/sql/fabled_roster_seed.sql",
        "-- ============================================================================",
        "",
        "INSERT INTO `fabled_npcs` (`npc_id`, `era`, `level`, `chance`) VALUES",
    ]
    items = sorted(seed.items(), key=lambda kv: (era_order[kv[1][0]], kv[0]))
    for i, (n, (era, level, live_name, zone_long)) in enumerate(items):
        sep = "," if i < len(items) - 1 else ""
        comment = f"{dump.npc_name[n]} ({zone_long.split(' (')[0]}) - {live_name}".replace("\n", " ")
        lines.append(f"({n}, '{era}', {level}, 0){sep}  -- {comment}")
    lines.append("ON DUPLICATE KEY UPDATE `era` = VALUES(`era`), `level` = VALUES(`level`);")
    if unmatched:
        lines.append("")
        lines.append("-- Unmatched live rows (no npc_types row found; add an ALIASES entry in the generator):")
        for live_name, level, zone_long in unmatched:
            lines.append(f"--   {live_name} | {level} | {zone_long}")
    lines.append("")
    with open(args.out, "w", encoding="utf-8", newline="\n") as f:
        f.write("\n".join(lines))
    print(f"\nwrote {args.out} ({len(seed)} rows)")


if __name__ == "__main__":
    main()

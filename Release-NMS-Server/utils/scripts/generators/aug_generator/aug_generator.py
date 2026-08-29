#!/usr/bin/env python3
"""
Augmentation Generator for NMS Server

Generates custom soul augmentations (Lost, Restless, Found) with randomized
stats, names, focus/worn effects, and associated lootdrop entries.

Usage:
    python aug_generator.py                  # Generate everything (items + loot)
    python aug_generator.py --items          # Items only
    python aug_generator.py --loot           # Loot only (requires prior CSV)
    python aug_generator.py --seed 42        # Reproducible run
    python aug_generator.py --lost-count 400 --start-id 170000

Output:
    output/generated_augs.sql           — INSERT statements for items table
    output/generated_augs_loot.sql      — INSERT statements for lootdrop_entries
    output/generated_augs_loottable.sql — INSERT for loottable + global_loot
    output/generated_augs_summary.csv   — Debug/review spreadsheet

Drop Chance:
    --drop-chance 0 (default) uses EQEmu's loottable probability gate for a
    flat ~1% chance per kill, level-scaled via per-band loot tables.
    Override with --drop-chance N for a fixed per-item percentage.
"""

import argparse
import csv
import math
import random
import os
import sys
from collections import defaultdict
from copy import deepcopy

# ============================================================
# PATHS — resolved relative to this script's directory
# ============================================================

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))

# ============================================================
# DEFAULTS
# ============================================================

DEFAULT_BASE_AUG    = os.path.join(SCRIPT_DIR, "base_aug.txt")
DEFAULT_OUTPUT_DIR  = os.path.join(SCRIPT_DIR, "output")
DEFAULT_NAMES_FILE  = os.path.join(SCRIPT_DIR, "used_names.txt")

DEFAULT_START_ITEM_ID     = 160000
DEFAULT_LOST_SOUL_COUNT   = 600
DEFAULT_RESTLESS_COUNT    = 100
DEFAULT_FOUND_COUNT       = 50
DEFAULT_LOOTDROP_ID       = 178700
DEFAULT_DROP_CHANCE       = 0  # 0 = flat 1% via loottable probability gate
DEFAULT_MAX_LEVEL_CAP     = 65
DEFAULT_MAX_AUG_LEVEL     = 65

LEVEL_TIERS = [10, 20, 30, 40, 50, 60, 65, 70, 75]

# Level-tier weights by aug type (must align with LEVEL_TIERS)
LEVEL_TIER_WEIGHTS = {
    "lost":     [2, 2, 2, 3, 4, 4, 3, 2, 1],
    "restless": [1, 1, 2, 3, 5, 5, 4, 2, 1],
    "found":    [3, 3, 2, 2, 6, 7, 6, 3, 1],
}

def get_active_tiers(max_aug_level):
    """Return LEVEL_TIERS filtered to levels <= max_aug_level."""
    return [level for level in LEVEL_TIERS if level <= max_aug_level]

# ============================================================
# AUG TYPE DEFINITIONS
# ============================================================

AUG_TYPES = {
    "lost":     {"lore": "Lost Soul",     "epithet_chance": 0.05},
    "restless": {"lore": "Restless Soul", "epithet_chance": 0.15},
    "found":    {"lore": "Found Soul",    "epithet_chance": 0.30},
}

# ============================================================
# STAT CAPS — ceiling(level * multiplier) per aug type
# ============================================================

STAT_CAPS_BY_TYPE = {
    #                  hp/mana   ac      primary  resist  heroic
    "lost":     {"hp": 2.000, "mana": 2.000, "ac": 0.350,
                 "primary": 0.325, "resist": 0.325, "heroic": 0.325},
    "restless": {"hp": 1.750, "mana": 1.750, "ac": 0.325,
                 "primary": 0.300, "resist": 0.300, "heroic": 0.300},
    "found":    {"hp": 1.500, "mana": 1.500, "ac": 0.300,
                 "primary": 0.275, "resist": 0.275, "heroic": 0.275},
}

def get_cap(aug_type, stat_group, level):
    mult = STAT_CAPS_BY_TYPE[aug_type][stat_group]
    return math.ceil(level * mult)

# ============================================================
# STAT COUNT RANGES BY TIER AND LEVEL
# ============================================================

STAT_COUNT_BASE = {
    "lost":     (5, 9),
    "restless": (7, 11),
    "found":    (9, 15),
}

def get_stat_count_range(aug_type, level):
    lo, hi = STAT_COUNT_BASE[aug_type]
    bonus = 0
    if level >= 20: bonus += 1
    if level >= 40: bonus += 1
    if level >= 60: bonus += 1
    return lo + bonus, hi + bonus

# ============================================================
# HEROIC CHANCE BY LEVEL (level 50+ only)
# ============================================================

HEROIC_CHANCE_BY_LEVEL = {
    50: 0.20,
    60: 0.25,
    65: 0.30,
    70: 0.35,
    75: 0.40,
}

def get_heroic_chance(level):
    if level < 50:
        return 0.0
    for threshold in sorted(HEROIC_CHANCE_BY_LEVEL.keys(), reverse=True):
        if level >= threshold:
            return HEROIC_CHANCE_BY_LEVEL[threshold]
    return 0.0

# ============================================================
# STAT GROUPS
# ============================================================

RESISTS = ["mr", "fr", "cr", "dr", "pr"]

HEROIC_MAP = {
    "astr": "heroic_str", "asta": "heroic_sta",
    "adex": "heroic_dex", "aagi": "heroic_agi",
    "awis": "heroic_wis", "aint": "heroic_int",
    "acha": "heroic_cha",
}

# ============================================================
# FOCUS EFFECTS (caster/healer — focuseffect field)
# ============================================================

FOCUS_CHANCE = 0.12

CASTER_FOCUS_EFFECTS = {
    1: [2366, 2336, 2333, 2345, 2348, 2339, 2342],
    2: [2367, 2337, 2334, 2346, 2349, 2340, 2343],
    3: [2368, 2338, 2335, 2347, 2350, 2341, 2344],
    4: [3507, 3513, 3504, 3501, 3510, 3525, 3537],
    5: [6412, 6414, 6411, 6410, 6413, 6415, 6419],
    6: [9507, 9509, 9506, 9505, 42606, 42607, 9511],
}

def get_caster_focus_tier(level):
    if level <= 20:  return 1
    elif level <= 40: return 2
    elif level <= 60: return 3
    elif level <= 65: return 4
    elif level <= 70: return 5
    else:             return 6

# ============================================================
# WORN EFFECTS (melee — worneffect field)
# ============================================================

WORN_CHANCE = 0.12

MELEE_WORN_EFFECTS = {
    50: [3883, 3886, 3889, 3896, 3892],
    60: [3884, 3887, 3890, 3897, 3893],
    70: [3885, 3888, 3891, 3898, 3894],
}

def get_melee_worn_tier(level):
    if level >= 70: return 70
    elif level >= 60: return 60
    elif level >= 50: return 50
    return None

def fill_missing_focus_effects(sql_items, debug_items):
    """
    Across the full combined item pool, ensure every caster focus effect
    appears at least once within its tier's level range.
    Only assigns to caster/healer augs with no current focus or worn effect.
    """
    tier_indices = defaultdict(list)
    for i, row in enumerate(debug_items):
        tier = get_caster_focus_tier(row["level"])
        if tier is not None:
            tier_indices[tier].append(i)

    for tier, indices in tier_indices.items():
        required = set(CASTER_FOCUS_EFFECTS.get(tier, []))
        if not required:
            continue
        present = {debug_items[i]["focuseffect"] for i in indices} & required
        missing = required - present
        if not missing:
            continue
        candidates = [
            i for i in indices
            if debug_items[i]["focuseffect"] == 0
            and debug_items[i]["worneffect"]  == 0
            and debug_items[i]["archetype"] in ["caster", "healer"]
        ]
        random.shuffle(candidates)
        for j, effect in enumerate(list(missing)):
            if j < len(candidates):
                idx = candidates[j]
                sql_items[idx]["focuseffect"]   = effect
                sql_items[idx]["focustype"]      = 6
                debug_items[idx]["focuseffect"]  = effect
            else:
                print(f"  Warning: caster focus tier {tier} missing effect "
                      f"{effect} — no eligible candidates.")


def fill_missing_worn_effects(sql_items, debug_items):
    """
    Across the full combined item pool, ensure every melee worn effect
    appears at least once within its tier's level range.
    Only assigns to melee_offense/melee_defense augs with no current focus or worn effect.
    """
    tier_indices = defaultdict(list)
    for i, row in enumerate(debug_items):
        tier = get_melee_worn_tier(row["level"])
        if tier is not None:
            tier_indices[tier].append(i)

    for tier, indices in tier_indices.items():
        required = set(MELEE_WORN_EFFECTS.get(tier, []))
        if not required:
            continue
        present = {debug_items[i]["worneffect"] for i in indices} & required
        missing = required - present
        if not missing:
            continue
        candidates = [
            i for i in indices
            if debug_items[i]["worneffect"]  == 0
            and debug_items[i]["focuseffect"] == 0
            and debug_items[i]["archetype"] in ["melee_offense", "melee_defense"]
        ]
        random.shuffle(candidates)
        for j, effect in enumerate(list(missing)):
            if j < len(candidates):
                idx = candidates[j]
                sql_items[idx]["worneffect"]    = effect
                sql_items[idx]["worntype"]       = 2
                debug_items[idx]["worneffect"]   = effect
            else:
                print(f"  Warning: melee worn tier {tier} missing effect "
                      f"{effect} — no eligible candidates.")

# ============================================================
# ARCHETYPE WEIGHTS
# ============================================================

ARCHETYPE_WEIGHTS = {
    "melee_offense": 25,
    "melee_defense": 25,
    "caster":        20,
    "healer":        20,
    "mixed":         10,
}

def choose_archetype(has_focus, has_worn):
    if has_focus:
        return random.choice(["caster", "healer"])
    if has_worn:
        return random.choice(["melee_offense", "melee_defense"])
    return random.choices(
        list(ARCHETYPE_WEIGHTS.keys()),
        weights=list(ARCHETYPE_WEIGHTS.values()),
        k=1
    )[0]

# ============================================================
# HP / MANA / AC SELECTION BY ARCHETYPE
# ============================================================

HMA_CHANCES = {
    #                      hp     mana    ac
    "melee_offense": {"hp": 0.95, "mana": 0.10, "ac": 0.60},
    "melee_defense": {"hp": 0.95, "mana": 0.10, "ac": 0.75},
    "caster":        {"hp": 0.65, "mana": 0.95, "ac": 0.40},
    "healer":        {"hp": 0.65, "mana": 0.95, "ac": 0.40},
    "mixed":         {"hp": 0.70, "mana": 0.60, "ac": 0.60},
}

def select_hma_stats(archetype, slots_available, has_focus):
    chances = HMA_CHANCES[archetype]
    selected = []

    if has_focus and archetype in ["caster", "healer"]:
        selected.append("mana")

    for stat in ["hp", "mana", "ac"]:
        if stat in selected:
            continue
        if len(selected) >= min(3, slots_available):
            break
        if random.random() < chances[stat]:
            selected.append(stat)

    if not selected:
        if archetype in ["caster", "healer"]:
            selected.append("mana")
        elif archetype in ["melee_offense", "melee_defense"]:
            selected.append("hp")
        else:
            selected.append(random.choice(["hp", "mana", "ac"]))

    return selected

# ============================================================
# PRIMARY STAT POOL BY ARCHETYPE
# ============================================================

def get_primary_pool(archetype):
    if archetype == "melee_offense":
        return ["astr", "adex", "aagi", "asta"], ["aint", "awis"]
    elif archetype == "melee_defense":
        return ["asta", "aagi", "adex", "astr"], ["aint", "awis"]
    elif archetype == "caster":
        return ["aint", "acha", "asta"], ["astr", "aagi", "awis"]
    elif archetype == "healer":
        return ["awis", "acha", "asta"], ["astr", "aagi", "aint"]
    else:  # mixed
        return ["astr", "asta", "adex", "aagi", "aint", "awis", "acha"], []

def pick_primary_stats(archetype, count):
    main_pool, off_pool = get_primary_pool(archetype)
    pool = main_pool * 3 + off_pool
    selected = []
    seen = set()
    while len(selected) < count and pool:
        pick = random.choice(pool)
        pool = [x for x in pool if x != pick]
        if pick not in seen:
            seen.add(pick)
            selected.append(pick)
    return selected

# ============================================================
# TOTAL POINTS — weighted comparison value for CSV
# ============================================================

POINT_VALUES = {
    "hp": 1, "mana": 1, "ac": 3,
    "astr": 4, "asta": 4, "adex": 4, "aagi": 4,
    "awis": 4, "aint": 4, "acha": 4,
    "mr": 3, "fr": 3, "cr": 3, "dr": 3, "pr": 3,
    "heroic_str": 8, "heroic_sta": 8, "heroic_dex": 8,
    "heroic_agi": 8, "heroic_wis": 8, "heroic_int": 8, "heroic_cha": 8,
}

def calc_total_points(stats):
    total = 0
    for stat, val in stats.items():
        total += int(val or 0) * POINT_VALUES.get(stat, 1)
    return total

# ============================================================
# CORE STAT GENERATION
# ============================================================

def roll_stat(aug_type, stat_group, level):
    cap = get_cap(aug_type, stat_group, level)
    if cap <= 0:
        return 1
    level_fraction = min(level / 75.0, 1.0)
    if stat_group == "heroic":
        if level >= 75:   floor_frac, ceil_frac, mode_frac = 0.35, 1.00, 0.65
        elif level >= 70: floor_frac, ceil_frac, mode_frac = 0.28, 0.90, 0.58
        elif level >= 65: floor_frac, ceil_frac, mode_frac = 0.22, 0.80, 0.52
        elif level >= 60: floor_frac, ceil_frac, mode_frac = 0.18, 0.72, 0.55
        else:             floor_frac, ceil_frac, mode_frac = 0.12, 0.62, 0.55
        floor   = max(1, int(cap * floor_frac))
        ceiling = max(floor + 1, int(cap * ceil_frac))
        mode    = floor + (ceiling - floor) * mode_frac
        return min(ceiling, max(floor, int(random.triangular(floor, ceiling, mode))))
    else:
        if stat_group in ("hp", "mana"):
            floor_frac = 0.15 + 0.25 * level_fraction
        else:
            floor_frac = 0.10 + 0.30 * level_fraction
        floor = max(1, int(cap * floor_frac))
        mode  = floor + (cap - floor) * (0.40 + 0.35 * level_fraction)
        return min(cap, max(floor, int(random.triangular(floor, cap, mode))))

def generate_aug_stats(aug_type, archetype, level, has_focus, has_worn):
    stats = {}

    lo, hi = get_stat_count_range(aug_type, level)
    total_slots = random.randint(lo, hi)

    slots_remaining = total_slots
    if has_focus or has_worn:
        slots_remaining -= 1
    slots_remaining = max(1, slots_remaining)

    hma = select_hma_stats(archetype, slots_remaining, has_focus)
    slots_remaining -= len(hma)

    for stat in hma:
        if stat == "hp":
            stats["hp"] = roll_stat(aug_type, "hp", level)
        elif stat == "mana":
            stats["mana"] = roll_stat(aug_type, "mana", level)
        elif stat == "ac":
            stats["ac"] = roll_stat(aug_type, "ac", level)

    if slots_remaining <= 0:
        return stats

    primary_count = max(1, round(slots_remaining * 0.60))
    resist_count  = slots_remaining - primary_count

    all_primaries = ["astr", "asta", "adex", "aagi", "aint", "awis", "acha"]
    primary_count = min(primary_count, len(all_primaries))

    chosen_primaries = pick_primary_stats(archetype, primary_count)
    for stat in chosen_primaries:
        stats[stat] = roll_stat(aug_type, "primary", level)

    resist_count = min(resist_count, len(RESISTS))
    if resist_count > 0:
        chosen_resists = random.sample(RESISTS, resist_count)
        for stat in chosen_resists:
            stats[stat] = roll_stat(aug_type, "resist", level)

    heroic_chance = get_heroic_chance(level)
    if heroic_chance > 0:
        for primary_stat in chosen_primaries:
            if primary_stat in HEROIC_MAP:
                if random.random() < heroic_chance:
                    heroic_stat = HEROIC_MAP[primary_stat]
                    stats[heroic_stat] = roll_stat(aug_type, "heroic", level)

    return stats

# ============================================================
# LEVEL DISTRIBUTION
# ============================================================

def build_level_distribution(aug_type, count, active_tiers):
    """Distribute `count` items across active_tiers using per-type weights."""
    full_weights = LEVEL_TIER_WEIGHTS[aug_type]
    weights = []
    for i, level in enumerate(LEVEL_TIERS):
        if level in active_tiers:
            weights.append(full_weights[i])

    if not weights:
        return [10] * count

    total_weight = sum(weights)
    distribution = []
    for i, level in enumerate(active_tiers):
        tier_count = round(count * weights[i] / total_weight)
        distribution.extend([level] * tier_count)
    while len(distribution) < count:
        distribution.append(random.choice(active_tiers))
    while len(distribution) > count:
        distribution.pop()
    random.shuffle(distribution)
    return distribution

# ============================================================
# APPEARANCE
# ============================================================

VALID_ICONS = [
    507, 646, 734, 767, 773, 804, 819, 859, 885, 886,
    905, 917, 943, 944, 945, 946, 947, 948, 949, 950,
    951, 952, 953, 954, 955, 956, 957, 958, 959, 960,
    961, 962, 963, 964, 965, 966, 967, 968, 969, 1088,
    1130, 1131, 1135, 1202, 1245, 1253, 1327, 1429, 1430, 1431,
    1432, 1433, 1434, 1435, 1436, 1437, 1438, 1439, 1440, 1441,
    1442, 1443, 1452, 1476, 1486, 1501, 1898, 1916, 1945, 1993,
    1994, 1995, 1996, 1997, 1998, 2001, 2081, 2138, 2190, 2244,
    2258, 2772
]
IDFILE = "IT63"

# ============================================================
# NAME GENERATION SYSTEM
# ============================================================

HARD_OPEN = [
    "Ald", "Bren", "Cad", "Drav", "Forv", "Gren", "Harv", "Jard", "Kald",
    "Lend", "Mord", "Narv", "Pald", "Renv", "Sold", "Thar", "Ulv", "Vald",
    "Warv", "Xeld", "Zarv", "Brak", "Drak", "Gald", "Hord", "Korv", "Mald",
    "Thren", "Greym", "Strax", "Vrek", "Zorn", "Drax", "Gorv", "Helk",
    "Krond", "Treld", "Vrax", "Wulv", "Skeld", "Brond", "Falk", "Hrath"
]
HARD_MID = [
    "ar", "in", "ak", "ur", "eld", "orn", "and", "rath", "isk",
    "ord", "arn", "eth", "urg", "avn", "enk", "olt", "ast", "ilk"
]
HARD_END = [
    "an", "or", "us", "en", "ath", "ok", "el", "om", "im",
    "esh", "ull", "on", "ane", "ash", "eld", "und", "ent",
    "old", "ost", "yn", "em", "oth", "one", "orm"
]
SOFT_OPEN = [
    "Ael", "Brel", "Cael", "Dael", "Elan", "Fael", "Gael", "Hael",
    "Isan", "Kael", "Lael", "Mael", "Nael", "Orin", "Rael", "Sael",
    "Tael", "Vael", "Wael", "Zael", "Celi", "Trel", "Wina", "Kija",
    "Nali", "Sumi", "Tand", "Lain", "Seren", "Miren", "Velen", "Elyn",
    "Caer", "Aeli", "Isil", "Lyri", "Nori", "Theli", "Aryn", "Breli"
]
SOFT_MID = [
    "an", "el", "in", "ara", "ira", "ora", "una", "ere",
    "ova", "essa", "ella", "aven", "alia", "eni", "ori"
]
SOFT_END = [
    "a", "el", "yn", "ith", "ene", "una", "ire", "ion",
    "ia", "ari", "ani", "wyn", "wen", "lis", "ren", "len",
    "mir", "rin", "ora", "ara", "iel", "ath", "orn", "eth"
]
SHORT_HARD = [
    "Thren", "Greym", "Kador", "Sikor", "Thane", "Vorn", "Brak", "Gorn",
    "Mord", "Drax", "Roth", "Durk", "Kael", "Zorn", "Torv", "Rend",
    "Helm", "Falk", "Keld", "Wulf", "Skeld", "Vrek", "Hrath", "Drav",
    "Gorv", "Strax", "Brond", "Treld", "Vrax", "Krond"
]
SHORT_SOFT = [
    "Pani", "Seren", "Maren", "Lyra", "Wren", "Aela", "Caer", "Nali",
    "Orin", "Lain", "Wina", "Eira", "Zael", "Elan", "Kija", "Tael",
    "Yael", "Rael", "Suma", "Tand", "Isil", "Lyri", "Nori", "Aryn",
    "Velen", "Elyn", "Miren", "Breli", "Theli", "Aeli"
]
LIT_MALE = [
    "Theron", "Cassin", "Veran", "Aldric", "Borin", "Pelian", "Corin",
    "Edric", "Gareth", "Leoric", "Tavish", "Soren", "Declan", "Finnian",
    "Rowan", "Cormac", "Davan", "Faolan", "Gavin", "Berek", "Aldren",
    "Hadrik", "Caelan", "Ivar", "Brennan", "Dorian", "Kiran", "Urien",
    "Valdis", "Jareth", "Oswin", "Hadwin", "Nolan", "Faranek", "Maren"
]
LIT_FEMALE = [
    "Aldara", "Valeria", "Elowen", "Brynn", "Caera", "Elyse", "Isara",
    "Orla", "Rhian", "Tanith", "Branwen", "Deryn", "Elara", "Morwen",
    "Nimue", "Serafin", "Idris", "Isolde", "Valdra", "Seren", "Maren",
    "Elyra", "Caelin", "Aldris", "Faera", "Gwenna", "Neryn", "Selara",
    "Vaelis", "Thalindra", "Brenna", "Corwyn", "Daelyn", "Fenara", "Lirath"
]
COMPOUND_HARD = [
    "Ironveil", "Darkmantle", "Grimward", "Ashborne", "Coldvein",
    "Dreadmark", "Stormward", "Fellborn", "Swordborn", "Frostborn",
    "Warborn", "Scarbearer", "Boneward", "Helmward", "Axeborn"
]
COMPOUND_SOFT = [
    "Dawnweave", "Silvermark", "Moonborn", "Stillwater", "Mistweave",
    "Lightborn", "Embermark", "Veilborn", "Loreborn", "Runeweave",
    "Sageborn", "Songborn", "Starborn", "Calmborn", "Windborn"
]
LAST_HARD_1 = [
    "Iron", "Stone", "Dark", "Grim", "Ash", "Cold", "War", "Bone",
    "Black", "Storm", "Dusk", "Scar", "Crag", "Fell", "Dread",
    "Gale", "Frost", "Helm", "Sword", "Axe", "Blood", "Slate",
    "Flint", "Dirk", "Grave"
]
LAST_HARD_2 = [
    "hand", "fist", "born", "wall", "blade", "mark", "peak", "ridge",
    "vale", "hide", "forge", "cloak", "vein", "brow", "keep",
    "fall", "ward", "hold", "breaker", "sworn", "mantle", "shroud",
    "crest", "edge", "spite"
]
LAST_SOFT_1 = [
    "Dawn", "Silver", "Moon", "Star", "Still", "Ever", "Mist", "Light",
    "Ember", "Pale", "Swift", "Veil", "Lore", "Rune", "Sage",
    "Wind", "Dusk", "Clear", "Bright", "Calm", "Ash", "Morn",
    "Tide", "Vale", "Glen"
]
LAST_SOFT_2 = [
    "weave", "mere", "born", "song", "mark", "water", "vale", "whisper",
    "mantle", "flame", "brook", "glass", "rise", "hollow", "seeker",
    "singer", "keeper", "walker", "ward", "touch", "shade", "drift",
    "bloom", "haven", "borne"
]
EPITHETS = {
    "melee_offense": [
        "the Unyielding", "the Relentless", "the Fierce", "the Wrathful",
        "the Scarred", "the Fearless", "the Ironwilled", "the Furious",
        "the Undaunted", "the Bold", "the Bloodied", "the Savage",
    ],
    "melee_defense": [
        "the Steadfast", "the Immovable", "the Stalwart", "the Enduring",
        "the Unbroken", "the Vigilant", "the Resolute", "the Guardian",
        "the Warden", "the Bulwark", "the Ironborn", "the Fortified",
    ],
    "caster": [
        "the Arcane", "the Learned", "the Sage", "the Mystic",
        "the Weaver", "the Enlightened", "the Seeker", "the Insightful",
        "the Gifted", "the Knowing", "the Far-Sighted", "the Brilliant",
    ],
    "healer": [
        "the Merciful", "the Faithful", "the Blessed", "the Devoted",
        "the Gentle", "the Compassionate", "the Serene", "the Pure",
        "the Tender", "the Graceful", "the Kind", "the Pious",
    ],
    "mixed": [
        "the Wanderer", "the Lost", "the Forgotten", "the Remembered",
        "the Last", "the Silent", "the Patient", "the Resilient",
        "the Quiet", "the Persistent", "the Unseen", "the Enduring",
    ],
}

MAX_FIRST_LEN = 10

def _build_hard_first():
    for _ in range(20):
        name = random.choice(HARD_OPEN)
        if random.random() < 0.40:
            name += random.choice(HARD_MID)
        name += random.choice(HARD_END)
        if len(name) <= MAX_FIRST_LEN:
            return name
    return random.choice(SHORT_HARD)

def _build_soft_first():
    for _ in range(20):
        name = random.choice(SOFT_OPEN)
        if random.random() < 0.35:
            name += random.choice(SOFT_MID)
        name += random.choice(SOFT_END)
        if len(name) <= MAX_FIRST_LEN:
            return name
    return random.choice(SHORT_SOFT)

def _make_first(pool, gender):
    strategy = random.choices(["syllable", "short", "literary"], weights=[50, 25, 25], k=1)[0]
    if pool == "hard":
        if strategy == "syllable": return _build_hard_first()
        elif strategy == "short":  return random.choice(SHORT_HARD)
        else:                      return random.choice(LIT_MALE)
    else:
        if strategy == "syllable": return _build_soft_first()
        elif strategy == "short":  return random.choice(SHORT_SOFT)
        else:
            return random.choice(LIT_FEMALE if gender == "female" else LIT_MALE)

def _make_last(pool):
    if pool == "hard":
        return random.choice(LAST_HARD_1) + random.choice(LAST_HARD_2)
    return random.choice(LAST_SOFT_1) + random.choice(LAST_SOFT_2)

def _make_standalone(pool):
    if pool == "hard": return random.choice(COMPOUND_HARD)
    return random.choice(COMPOUND_SOFT)

def generate_soul_name(archetype, aug_type):
    epithet_chance = AUG_TYPES[aug_type]["epithet_chance"]
    if archetype in ["melee_offense", "melee_defense"]:
        pool = "hard"
    elif archetype in ["caster", "healer"]:
        pool = "soft"
    else:
        pool = random.choice(["hard", "soft"])
    gender = random.choice(["male", "female"])
    structure = random.choices(["first_last", "first_only", "compound"],
                               weights=[85, 10, 5], k=1)[0]
    if structure == "compound":
        name = _make_standalone(pool)
    elif structure == "first_only":
        if pool == "hard":
            name = random.choice(SHORT_HARD + LIT_MALE)
        else:
            name = random.choice(SHORT_SOFT + (LIT_FEMALE if gender == "female" else LIT_MALE))
    else:
        name = f"{_make_first(pool, gender)} {_make_last(pool)}"
    if random.random() < epithet_chance:
        epithet = random.choice(EPITHETS.get(archetype, EPITHETS["mixed"]))
        name = f"{name} {epithet}"
    return name, pool

# ============================================================
# GLOBAL NAME TRACKING
# ============================================================

USED_NAMES = set()

def load_used_names(path):
    global USED_NAMES
    if not os.path.exists(path):
        USED_NAMES = set()
        return USED_NAMES
    with open(path, "r", encoding="utf-8") as f:
        USED_NAMES = set(line.strip() for line in f if line.strip())
    return USED_NAMES

def save_used_names(path):
    global USED_NAMES
    with open(path, "w", encoding="utf-8") as f:
        for name in sorted(USED_NAMES):
            f.write(name + "\n")

# ============================================================
# BASE AUG LOADER
# ============================================================

def load_base_aug(path):
    with open(path, "r", encoding="utf-8") as f:
        content = f.read()
    start_cols  = content.find("(")
    end_cols    = content.find(")")
    columns_raw = content[start_cols + 1:end_cols]
    columns     = [c.strip().strip("`") for c in columns_raw.split(",")]
    values_start = content.lower().find("values")
    values_part  = content[values_start:].split("(", 1)[1].rsplit(")", 1)[0]
    values       = parse_sql_values(values_part)
    return columns, dict(zip(columns, values))

def parse_sql_values(value_string):
    values, current, in_string, escape = [], "", False, False
    for char in value_string:
        if escape:
            current += char; escape = False; continue
        if char == "\\": escape = True; continue
        if char == "'": in_string = not in_string; current += char; continue
        if char == "," and not in_string:
            values.append(current.strip()); current = ""; continue
        current += char
    if current: values.append(current.strip())
    cleaned = []
    for val in values:
        if val.upper() == "NULL": cleaned.append(None)
        elif val.startswith("'") and val.endswith("'"): cleaned.append(val[1:-1].replace("''", "'"))
        else: cleaned.append(val)
    return cleaned

# ============================================================
# DATA SANITIZATION
# ============================================================

ALL_STAT_COLUMNS = [
    "ac", "hp", "mana",
    "astr", "asta", "adex", "aagi", "awis", "aint", "acha",
    "mr", "fr", "cr", "dr", "pr",
    "heroic_str", "heroic_sta", "heroic_dex",
    "heroic_agi", "heroic_wis", "heroic_int", "heroic_cha",
]

def enforce_not_null_constraints(item, base_template):
    for col in ["charmfile", "filename", "lore", "clickname",
                "procname", "wornname", "focusname", "scrollname"]:
        if item.get(col) is None:
            item[col] = ""
        if base_template.get(col) not in (None, "") and item.get(col) == "":
            item[col] = base_template.get(col)
    return item

def strip_internal_fields(item):
    for key in ["_archetype", "_aug_type", "_name_pool"]:
        item.pop(key, None)
    return item

# ============================================================
# ITEM GENERATION
# ============================================================

def generate_batch(columns, base_template, aug_type, level_distribution, id_start):
    sql_items   = []
    debug_items = []
    lore_text   = AUG_TYPES[aug_type]["lore"]

    for i, level in enumerate(level_distribution):
        new_id = id_start + i
        item   = deepcopy(base_template)
        item["id"] = new_id

        item["reclevel"] = level
        item["reqlevel"] = max(1, level - 9)
        item["icon"]     = random.choice(VALID_ICONS)
        item["idfile"]   = IDFILE

        focuseffect_id = 0
        worneffect_id  = 0
        has_focus = False
        has_worn  = False

        effect_roll = random.random()
        if effect_roll < FOCUS_CHANCE:
            tier = get_caster_focus_tier(level)
            effects = CASTER_FOCUS_EFFECTS.get(tier, [])
            if effects:
                focuseffect_id = random.choice(effects)
                has_focus = True
        elif effect_roll < FOCUS_CHANCE + WORN_CHANCE:
            worn_tier = get_melee_worn_tier(level)
            if worn_tier:
                effects = MELEE_WORN_EFFECTS.get(worn_tier, [])
                if effects:
                    worneffect_id = random.choice(effects)
                    has_worn = True

        archetype = choose_archetype(has_focus, has_worn)

        stats = generate_aug_stats(aug_type, archetype, level, has_focus, has_worn)

        attempts = 0
        name_pool = "hard"
        while True:
            candidate_name, name_pool = generate_soul_name(archetype, aug_type)
            if candidate_name not in USED_NAMES:
                USED_NAMES.add(candidate_name)
                item["Name"] = candidate_name
                break
            attempts += 1
            if attempts > 500:
                candidate_name = f"{candidate_name} {new_id}"
                item["Name"] = candidate_name
                USED_NAMES.add(candidate_name)
                break

        item["lore"] = lore_text

        if aug_type in ["restless", "found"]:
            item["nodrop"]    = 0
            item["loregroup"] = -1
        else:
            item["nodrop"]    = 1
            item["loregroup"] = 0

        for stat in ALL_STAT_COLUMNS:
            item[stat] = stats.get(stat, 0)

        item["focuseffect"] = focuseffect_id
        item["focustype"]   = 6 if has_focus else base_template.get("focustype")
        item["focuslevel"]  = 0
        item["focuslevel2"] = 0

        item["worneffect"] = worneffect_id
        item["worntype"]   = 2 if has_worn else base_template.get("worntype")
        item["wornlevel"]  = 0
        item["wornlevel2"] = 0

        total_points = calc_total_points(stats)
        item["total_points"] = total_points

        item = enforce_not_null_constraints(item, base_template)

        debug_row = {
            "id":           new_id,
            "name":         item["Name"],
            "aug_type":     aug_type,
            "name_pool":    name_pool,
            "archetype":    archetype,
            "level":        level,
            "lore":         lore_text,
            "focuseffect":  focuseffect_id,
            "worneffect":   worneffect_id,
            "total_points": total_points,
            "stat_count":   sum(1 for s in ALL_STAT_COLUMNS if stats.get(s, 0) > 0),
        }
        for stat in ALL_STAT_COLUMNS:
            debug_row[stat] = stats.get(stat, 0)

        debug_items.append(debug_row)
        sql_items.append(strip_internal_fields(item))

    return sql_items, debug_items

# ============================================================
# SQL EXPORT — ITEMS
# ============================================================

def sql_format(value, base_value):
    if value is None:
        value = base_value
    if isinstance(base_value, str):
        if value is None: value = base_value
        if value == "": return "''"
        return "'" + str(value).replace("'", "''") + "'"
    if isinstance(base_value, (int, float)) or (
        isinstance(base_value, str)
        and str(base_value).lstrip("-").replace(".", "", 1).isdigit()
    ):
        try:
            return str(int(value)) if isinstance(base_value, int) else str(value)
        except:
            return "NULL"
    if value is None: return "NULL"
    return str(value)

def export_items_sql(columns, base_template, items, output_path):
    with open(output_path, "w", encoding="utf-8") as f:
        for item in items:
            values = [sql_format(item.get(col), base_template.get(col)) for col in columns]
            f.write("INSERT INTO items VALUES (" + ",".join(values) + ");\n")
    print(f"  Items SQL:  {output_path} ({len(items)} items)")

# ============================================================
# SQL EXPORT — LOOT DROP ENTRIES
# ============================================================

TIER_BANDS = {
    10: (1,  10),
    20: (11, 20),
    30: (21, 30),
    40: (31, 40),
    50: (41, 50),
    60: (51, 60),
    65: (61, 65),
    70: (66, 70),
    75: (71, 75),
}

LOOTDROP_HEADER = (
    "INSERT INTO `lootdrop_entries`\n"
    "(`lootdrop_id`, `item_id`, `item_charges`, `equip_item`, `chance`, `disabled_chance`,\n"
    "`trivial_min_level`, `trivial_max_level`, `multiplier`,\n"
    "`npc_min_level`, `npc_max_level`,\n"
    "`min_expansion`, `max_expansion`,\n"
    "`content_flags`, `content_flags_disabled`)\n"
    "VALUES\n"
)

def get_band_range(aug_level):
    """Return the (npc_min, npc_max) level band an aug belongs to by its tier."""
    band = TIER_BANDS.get(int(aug_level))
    if band is None:
        return max(1, int(aug_level) - 9), int(aug_level)
    return band[0], band[1]

def compute_bands(debug_items):
    """Return the ordered list of (npc_min, npc_max) bands present in the item pool."""
    bands = []
    for row in debug_items:
        band = get_band_range(int(row["level"]))
        if band not in bands:
            bands.append(band)
    return sorted(bands)

def get_npc_levels(aug_level, aug_type, max_level_cap):
    """Legacy per-item npc_min/npc_max for fixed --drop-chance mode."""
    band = TIER_BANDS.get(int(aug_level))
    if band is None:
        npc_min = max(1, int(aug_level) - 9)
        npc_max = int(aug_level)
        return npc_min, npc_max

    npc_min = band[0]

    if aug_type == "lost":
        npc_max = band[1]
    else:
        npc_max = max_level_cap

    return npc_min, npc_max

def export_loot_sql(debug_items, output_path, lootdrop_id, drop_chance, max_level_cap, bands=None):
    if not debug_items:
        print("  Loot SQL:  skipped (no items)")
        return

    # --- Legacy mode: single lootdrop with fixed per-item chance ---
    if drop_chance > 0:
        lines = []
        for row in debug_items:
            item_id   = int(row["id"])
            aug_level = int(row["level"])
            aug_type  = row["aug_type"].strip().lower()
            npc_min, npc_max = get_npc_levels(aug_level, aug_type, max_level_cap)
            values = [
                lootdrop_id, item_id, 1, 0, drop_chance, 0, 0, 0, 1,
                npc_min, npc_max, -1, -1, "NULL", "NULL",
            ]
            lines.append("(" + ",".join(str(v) for v in values) + ")")

        with open(output_path, "w", encoding="utf-8") as f:
            f.write(LOOTDROP_HEADER + ",\n".join(lines) + ";\n")

        print(f"  Loot SQL:  {output_path}")
        print(f"    Lootdrop ID: {lootdrop_id}  Drop chance: {drop_chance}% per item")
        return

    # --- Flat 1% mode: one lootdrop per level band, all items chance=100 ---
    bands = bands or compute_bands(debug_items)
    blocks = []
    for i, (npc_min, npc_max) in enumerate(bands):
        band_id = lootdrop_id + i
        band_rows = [r for r in debug_items if get_band_range(int(r["level"])) == (npc_min, npc_max)]
        lines = []
        for row in band_rows:
            item_id = int(row["id"])
            values = [
                band_id, item_id, 1, 0, 100.0, 0, 0, 0, 1,
                npc_min, npc_max, -1, -1, "NULL", "NULL",
            ]
            lines.append("(" + ",".join(str(v) for v in values) + ")")
        blocks.append(
            f"-- Band {npc_min}-{npc_max} (lootdrop {band_id})\n"
            + LOOTDROP_HEADER
            + ",\n".join(lines)
            + ";"
        )

    with open(output_path, "w", encoding="utf-8") as f:
        f.write("\n\n".join(blocks) + "\n")

    print(f"  Loot SQL:  {output_path}")
    for i, (npc_min, npc_max) in enumerate(bands):
        n = sum(1 for r in debug_items if get_band_range(int(r["level"])) == (npc_min, npc_max))
        print(f"    Band {npc_min}-{npc_max}: {n} augs  (lootdrop {lootdrop_id + i})")

# ============================================================
# SQL EXPORT — LOOTTABLE + GLOBAL LOOT
# ============================================================

def export_global_loot_sql(output_path, loottable_id, lootdrop_id, global_loot_id, drop_chance, bands=None):
    # --- Legacy mode: single loottable + single global_loot ---
    if drop_chance > 0:
        lines = [
            "INSERT INTO `loottable`",
            "(`id`, `name`, `mincash`, `maxcash`, `avgcoin`, `done`, `min_expansion`, `max_expansion`, `content_flags`, `content_flags_disabled`)",
            "VALUES",
            f"({loottable_id}, 'Soul_Augs', 0, 0, 0, 0, -1, -1, NULL, NULL);",
            "",
            "INSERT INTO `loottable_entries`",
            "(`loottable_id`, `lootdrop_id`, `multiplier`, `droplimit`, `mindrop`, `probability`)",
            "VALUES",
            f"({loottable_id}, {lootdrop_id}, 1, 0, 0, 100);",
            "",
            "INSERT INTO `global_loot`",
            "(`id`, `description`, `loottable_id`, `enabled`, `min_level`, `max_level`,",
            " `rare`, `raid`, `race`, `class`, `bodytype`, `zone`,",
            " `hot_zone`, `min_expansion`, `max_expansion`, `content_flags`, `content_flags_disabled`)",
            "VALUES",
            f"({global_loot_id}, 'GLB-Soul-Augs', {loottable_id}, 1, 0, 0, 0, 0, '', '', '', '', 0, -1, -1, '', '');",
        ]
        with open(output_path, "w", encoding="utf-8") as f:
            f.write("\n".join(lines) + "\n")
        print(f"  Loot Table SQL:  {output_path}")
        print(f"    Loottable ID: {loottable_id}  Lootdrop ID: {lootdrop_id}  Global Loot ID: {global_loot_id}")
        return

    # --- Flat 1% mode: per-band loottable + loottable_entries + global_loot ---
    blocks = []
    for i, (npc_min, npc_max) in enumerate(bands):
        lt = loottable_id + i
        ld = lootdrop_id + i
        gl = global_loot_id + i
        name = f"Soul_Augs_{npc_min}-{npc_max}"
        blocks.append(
            f"-- Band {npc_min}-{npc_max}\n"
            f"INSERT INTO `loottable`\n"
            f"(`id`, `name`, `mincash`, `maxcash`, `avgcoin`, `done`, `min_expansion`, `max_expansion`, `content_flags`, `content_flags_disabled`)\n"
            f"VALUES\n"
            f"({lt}, '{name}', 0, 0, 0, 0, -1, -1, NULL, NULL);\n\n"
            f"INSERT INTO `loottable_entries`\n"
            f"(`loottable_id`, `lootdrop_id`, `multiplier`, `droplimit`, `mindrop`, `probability`)\n"
            f"VALUES\n"
            f"({lt}, {ld}, 1, 1, 0, 1);\n\n"
            f"INSERT INTO `global_loot`\n"
            f"(`id`, `description`, `loottable_id`, `enabled`, `min_level`, `max_level`,\n"
            f" `rare`, `raid`, `race`, `class`, `bodytype`, `zone`,\n"
            f" `hot_zone`, `min_expansion`, `max_expansion`, `content_flags`, `content_flags_disabled`)\n"
            f"VALUES\n"
            f"({gl}, 'GLB-Soul-Augs', {lt}, 1, {npc_min}, {npc_max}, 0, 0, '', '', '', '', 0, -1, -1, '', '');"
        )

    with open(output_path, "w", encoding="utf-8") as f:
        f.write("\n\n".join(blocks) + "\n")

    print(f"  Loot Table SQL:  {output_path}")
    for i, (npc_min, npc_max) in enumerate(bands):
        print(f"    Band {npc_min}-{npc_max}: loottable {loottable_id + i}  "
              f"lootdrop {lootdrop_id + i}  global_loot {global_loot_id + i}")

# ============================================================
# CSV EXPORT
# ============================================================

def export_csv(debug_items, output_path):
    if not debug_items:
        return

    fieldnames = (
        ["id", "name", "aug_type", "name_pool", "archetype", "level", "lore",
         "focuseffect", "worneffect", "total_points", "stat_count"]
        + ALL_STAT_COLUMNS
    )

    type_order = {"lost": 0, "restless": 1, "found": 2}
    sorted_items = sorted(
        debug_items,
        key=lambda x: (x.get("level", 0), type_order.get(x.get("aug_type", "lost"), 0))
    )

    with open(output_path, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames, quoting=csv.QUOTE_ALL)
        writer.writeheader()
        for row in sorted_items:
            writer.writerow({col: row.get(col, 0) for col in fieldnames})

    print(f"  CSV:       {output_path}")

# ============================================================
# CLI
# ============================================================

def parse_args():
    p = argparse.ArgumentParser(
        description="Generate soul augmentations for NMS Server",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__,
    )

    mode = p.add_mutually_exclusive_group()
    mode.add_argument("--items", action="store_true",
                      help="Generate only item SQL (skip loot)")
    mode.add_argument("--loot", action="store_true",
                      help="Generate only loot SQL from existing CSV")

    p.add_argument("--start-id", type=int, default=DEFAULT_START_ITEM_ID,
                   help=f"Starting item ID (default: {DEFAULT_START_ITEM_ID})")
    p.add_argument("--lost-count", type=int, default=DEFAULT_LOST_SOUL_COUNT,
                   help=f"Lost Soul count (default: {DEFAULT_LOST_SOUL_COUNT})")
    p.add_argument("--restless-count", type=int, default=DEFAULT_RESTLESS_COUNT,
                   help=f"Restless Soul count (default: {DEFAULT_RESTLESS_COUNT})")
    p.add_argument("--found-count", type=int, default=DEFAULT_FOUND_COUNT,
                   help=f"Found Soul count (default: {DEFAULT_FOUND_COUNT})")
    p.add_argument("--lootdrop-id", type=int, default=DEFAULT_LOOTDROP_ID,
                   help=f"Lootdrop table ID (default: {DEFAULT_LOOTDROP_ID})")
    p.add_argument("--loottable-id", type=int, default=None,
                   help="Loottable ID (default: same as --lootdrop-id)")
    p.add_argument("--global-loot-id", type=int, default=None,
                   help="Global loot rule ID (default: same as --lootdrop-id)")
    p.add_argument("--drop-chance", type=int, default=DEFAULT_DROP_CHANCE,
                   help="Drop chance: 0=flat 1%% via loottable probability gate (default), "
                        "or fixed per-item %%")
    p.add_argument("--max-level", type=int, default=DEFAULT_MAX_LEVEL_CAP,
                   help=f"Max drop level for Restless/Found (default: {DEFAULT_MAX_LEVEL_CAP})")
    p.add_argument("--max-aug-level", type=int, default=DEFAULT_MAX_AUG_LEVEL,
                   help=f"Highest aug tier to generate (default: {DEFAULT_MAX_AUG_LEVEL})")
    p.add_argument("--seed", type=int, default=None,
                   help="Random seed for reproducible runs")
    p.add_argument("--base-aug", type=str, default=DEFAULT_BASE_AUG,
                   help=f"Path to base_aug.txt (default: {DEFAULT_BASE_AUG})")
    p.add_argument("--output-dir", type=str, default=DEFAULT_OUTPUT_DIR,
                   help=f"Output directory (default: {DEFAULT_OUTPUT_DIR})")
    p.add_argument("--names-file", type=str, default=DEFAULT_NAMES_FILE,
                   help=f"Used names tracking file (default: {DEFAULT_NAMES_FILE})")

    return p.parse_args()

# ============================================================
# MAIN
# ============================================================

def main():
    args = parse_args()

    if args.seed is not None:
        random.seed(args.seed)
        print(f"Random seed: {args.seed}")

    os.makedirs(args.output_dir, exist_ok=True)

    do_items = not args.loot
    do_loot  = not args.items

    if args.loottable_id is None:
        args.loottable_id = args.lootdrop_id
    if args.global_loot_id is None:
        args.global_loot_id = args.lootdrop_id

    # --- Loot-only mode: read from existing CSV ---
    if args.loot:
        csv_path = os.path.join(args.output_dir, "generated_augs_summary.csv")
        if not os.path.exists(csv_path):
            print(f"ERROR: CSV not found: {csv_path}")
            print("Run with --items first to generate the item data.")
            sys.exit(1)
        debug_items = []
        with open(csv_path, "r", encoding="utf-8") as f:
            for row in csv.DictReader(f):
                debug_items.append(row)
        loot_path = os.path.join(args.output_dir, "generated_augs_loot.sql")
        loottable_path = os.path.join(args.output_dir, "generated_augs_loottable.sql")
        print("Generating loot SQL...")
        bands = compute_bands(debug_items) if args.drop_chance == 0 else None
        export_loot_sql(debug_items, loot_path, args.lootdrop_id,
                        args.drop_chance, args.max_level, bands)
        export_global_loot_sql(loottable_path, args.loottable_id,
                               args.lootdrop_id, args.global_loot_id,
                               args.drop_chance, bands)
        print("Done.")
        return

    # --- Load base template ---
    if not os.path.exists(args.base_aug):
        print(f"ERROR: Base aug file not found: {args.base_aug}")
        sys.exit(1)
    columns, base_template = load_base_aug(args.base_aug)
    load_used_names(args.names_file)

    active_tiers = get_active_tiers(args.max_aug_level)
    print(f"Active aug tiers: {active_tiers}")

    all_sql_items   = []
    all_debug_items = []
    current_id      = args.start_id

    # --- Generate each tier ---
    for aug_type, count in [
        ("lost",     args.lost_count),
        ("restless", args.restless_count),
        ("found",    args.found_count),
    ]:
        levels = build_level_distribution(aug_type, count, active_tiers)
        sql_items, debug_items = generate_batch(
            columns, base_template, aug_type, levels, current_id
        )
        all_sql_items   += sql_items
        all_debug_items += debug_items
        current_id      += len(sql_items)
        print(f"  {aug_type.capitalize():10s} Souls: {len(sql_items)}")

    # --- Gap-fills ---
    print("  Running focus/worn effect gap-fills...")
    fill_missing_focus_effects(all_sql_items, all_debug_items)
    fill_missing_worn_effects(all_sql_items, all_debug_items)

    # --- Export ---
    items_path = os.path.join(args.output_dir, "generated_augs.sql")
    csv_path   = os.path.join(args.output_dir, "generated_augs_summary.csv")
    loot_path  = os.path.join(args.output_dir, "generated_augs_loot.sql")
    loottable_path = os.path.join(args.output_dir, "generated_augs_loottable.sql")

    bands = compute_bands(all_debug_items) if args.drop_chance == 0 else None

    print("Exporting...")
    export_items_sql(columns, base_template, all_sql_items, items_path)
    export_csv(all_debug_items, csv_path)

    if do_loot:
        export_loot_sql(all_debug_items, loot_path, args.lootdrop_id,
                        args.drop_chance, args.max_level, bands)
        export_global_loot_sql(loottable_path, args.loottable_id,
                               args.lootdrop_id, args.global_loot_id,
                               args.drop_chance, bands)

    save_used_names(args.names_file)

    print(f"\nTotal: {len(all_sql_items)} items  |  "
          f"ID range: {args.start_id} - {args.start_id + len(all_sql_items) - 1}")
    print("Done.")


if __name__ == "__main__":
    main()

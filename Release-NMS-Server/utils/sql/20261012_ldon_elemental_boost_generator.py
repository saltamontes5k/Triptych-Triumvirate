#!/usr/bin/env python3
"""
Generator for custom DB migration v142: LDoN gear -> elemental group / raid tier
relative boost ("20261012_ldon_elemental_boost").

What it does
  1. Reads the LDoN gear population from the live peq DB:
       - loot of the 48 LDoN instance zones (229-276) + takishruins/takishruinsa
       - ldonsold=1 items (wayfarer-camp point purchase)
       - theme-name-matched quested items
     and the adventure end-boss items (adventure_template type=1 assassinate
     targets via the loot chain).
  2. Filters to real gear (no bags, no augs, no no-stat junk), routes each item
     to raid tier (boss loot, or already ac>=30 / hp>=150 / dmg ratio>=3.0) or
     group tier, and computes new stat values with the factors below.
  3. Writes the twin SQL utils/sql/20261012_ldon_elemental_boost.sql,
     splices the ManifestEntry into common/database/database_update_manifest_custom.cpp
     (chunked raw-string literals, idempotent via marker comments), and bumps
     CUSTOM_BINARY_DATABASE_VERSION in common/version.h to 142.
  4. Prints a before/after sample table and bucket counts.

Re-run safe: the manifest splice replaces the marked block, version bump is a
no-op once at 142, and the emitted UPDATEs are absolute SETs (idempotent SQL).
The manifest .check sentinel still gates the migration run-once like v100.

Run:  python utils/sql/20261012_ldon_elemental_boost_generator.py   (from repo root)
"""

import math
import re
import subprocess
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parents[3]          # C:\EQS
SERVER = REPO / "Release-NMS-Server"
SQL_TWIN = SERVER / "utils" / "sql" / "20261012_ldon_elemental_boost.sql"
MANIFEST = SERVER / "common" / "database" / "database_update_manifest_custom.cpp"
VERSION_H = SERVER / "common" / "version.h"

VERSION = 142
DESCRIPTION = "20261012_ldon_elemental_boost"
ENTRY_TAG = "LDONBOOST142"
MARKER = "V142:20261012_ldon_elemental_boost"

MYSQL = ["mysql", "-ueqemu", "-peqemu", "peq", "--batch", "-N", "-e"]

# ---------------------------------------------------------------- LDoN zones
LDON_ZONE_SHORTS = [
    # Deepest Guk (229-264)
    "guka", "gukb", "gukc", "gukd", "guke", "gukf", "gukg", "gukh",
    # Rujarkian Hills (230-273)
    "ruja", "rujb", "rujc", "rujd", "ruje", "rujf", "rujg", "rujh", "ruji", "rujj",
    # Takish-Hiz (231-274)
    "taka", "takb", "takc", "takd", "take", "takf", "takg", "takh", "taki", "takj",
    # Miragul's Menagerie (232-275)
    "mira", "mirb", "mirc", "mird", "mire", "mirf", "mirg", "mirh", "miri", "mirj",
    # Mistmoore's Catacombs (233-276)
    "mmca", "mmcb", "mmcc", "mmcd", "mmce", "mmcf", "mmcg", "mmch", "mmci", "mmcj",
    # LDoN static zones
    "takishruins", "takishruinsa",
]

QUESTED_NAME_PATTERNS = [
    "%Takish%", "%Rujark%", "%Miragul%", "%Mistmoore%", "%Deepest Guk%",
]

# ------------------------------------------------------------- boost factors
# Group tier: LDoN base drops/purchases -> elemental-plane group level.
# Raid tier: adventure end-boss loot (and anything already that strong) -> ~1.5x
# the group tier, per the approved design.
# Every column is scaled with a never-nerf cap: new = min(round(old*f), max(old,
# cap)). The caps keep the group/raid boundary monotonic (a hp-149 group item
# must not overtake a hp-185 raid item).
GROUP = {
    "ac": 3.5, "ac_cap": 65,
    "pool": 8.0, "pool_cap": 190,  # pool = hp/mana/endur
    "stat": 4.0, "stat_cap": 60,
    "resist": 5.0, "resist_cap": 100,
    "attack": 4.0, "attack_cap": 60,
    "dmg": 1.8, "dmg_delay_mult": 1.65,   # new damage <= delay*1.65 (ratio <= 3.3)
    "weapon_ac_floor": 15, "weapon_hp_floor": 100,
}
RAID = {
    "ac": 1.5, "ac_cap": 75,
    "pool": 1.3, "pool_cap": 500,
    "stat": 1.5, "stat_cap": 90,
    "resist": 1.5, "resist_cap": 150,
    "attack": 1.5, "attack_cap": 90,
    "dmg": 1.4, "dmg_delay_mult": 1.75,   # ratio <= 3.5
    "weapon_ac_floor": 20, "weapon_hp_floor": 150,
}

# Routing thresholds: an item that already sits at this level goes to raid tier
# so the big group multipliers can never overshoot it.
RAID_AC = 30
RAID_HP = 150
RAID_RATIO = 3.0

# Skip tier: items already far beyond any elemental/raid target are left
# untouched (fork-custom endgame gear that happens to sit in LDoN loot or to
# carry a theme name, e.g. Crested Mistmoore Ring ac129/hp3017/req90).
SKIP_AC = 80
SKIP_HP = 500
SKIP_MANA = 500
SKIP_RATIO = 5.0

STAT_COLS = ["astr", "asta", "aint", "awis", "adex", "aagi", "acha"]
RESIST_COLS = ["cr", "dr", "fr", "mr", "pr", "svcorruption"]
POOL_COLS = ["hp", "mana", "endur"]
# Every column the boost SETs (haste, regens, reqlevel deliberately untouched).
SET_COLS = POOL_COLS + ["ac", "attack"] + RESIST_COLS + STAT_COLS + ["damage"]


def sql_round(x):
    """MySQL ROUND(x) for non-negative values: half away from zero."""
    return int(math.floor(x + 0.5))


def query(sql):
    r = subprocess.run(MYSQL + [sql], capture_output=True, text=True, encoding="utf-8",
                       errors="replace")
    if r.returncode != 0:
        sys.exit("mysql failed: %s\n%s" % (sql[:200], r.stderr))
    rows = []
    for line in r.stdout.splitlines():
        rows.append(line.split("\t"))
    return rows


def sql_str_list(parts):
    return ",".join("'%s'" % p.replace("'", "''") for p in parts)


def chunked(seq, n):
    for i in range(0, len(seq), n):
        yield seq[i:i + n]


# ------------------------------------------------------------------ queries
LOOT_IDS_SQL = """
SELECT DISTINCT lde.item_id
FROM spawn2 s2
JOIN spawngroup sg ON sg.id = s2.spawngroupID
JOIN spawnentry se ON se.spawngroupID = sg.id
JOIN npc_types nt ON nt.id = se.npcID
JOIN loottable_entries lte ON lte.loottable_id = nt.loottable_id
JOIN lootdrop_entries lde ON lde.lootdrop_id = lte.lootdrop_id
WHERE s2.zone IN (%s)
""" % sql_str_list(LDON_ZONE_SHORTS)

BOSS_LOOT_IDS_SQL = """
SELECT DISTINCT lde.item_id
FROM (SELECT DISTINCT type_data AS npc_id FROM adventure_template WHERE type = 1) b
JOIN npc_types nt ON nt.id = b.npc_id
JOIN loottable_entries lte ON lte.loottable_id = nt.loottable_id
JOIN lootdrop_entries lde ON lde.lootdrop_id = lte.lootdrop_id
"""

QUESTED_IDS_SQL = ("SELECT id FROM items WHERE name LIKE %s"
                   % " OR name LIKE ".join("'%s'" % p for p in QUESTED_NAME_PATTERNS))

ITEM_COLS = ("id, name, itemclass, augtype, slots, itemtype, damage, delay, "
             + ", ".join(SET_COLS))


def fetch_items(ids):
    out = {}
    for batch in chunked(sorted(ids), 400):
        sql = "SELECT %s FROM items WHERE id IN (%s)" % (ITEM_COLS, ",".join(map(str, batch)))
        for row in query(sql):
            (iid, name, itemclass, augtype, slots, itemtype, damage, delay,
             hp, mana, endur, ac, attack,
             cr, dr, fr, mr, pr, svcorruption,
             astr, asta, aint, awis, adex, aagi, acha, dmg_col) = row
            def num(v):
                return 0 if v in (None, "NULL", "") else int(v)
            out[int(iid)] = {
                "name": name, "itemclass": num(itemclass), "augtype": num(augtype),
                "slots": num(slots), "itemtype": num(itemtype),
                "damage": num(damage), "delay": num(delay),
                "hp": num(hp), "mana": num(mana), "endur": num(endur),
                "ac": num(ac), "attack": num(attack),
                "cr": num(cr), "dr": num(dr), "fr": num(fr),
                "mr": num(mr), "pr": num(pr), "svcorruption": num(svcorruption),
                "astr": num(astr), "asta": num(asta), "aint": num(aint),
                "awis": num(awis), "adex": num(adex), "aagi": num(aagi),
                "acha": num(acha), "damage": num(dmg_col),
            }
    return out


def is_gear(it):
    """Wearable or weapon with at least one combat stat. No bags, no augs."""
    if it["itemclass"] == 2 or it["augtype"] != 0:
        return False
    if it["slots"] == 0 and it["damage"] == 0:
        return False
    combat = (it["ac"] or it["hp"] or it["mana"] or it["endur"] or it["attack"]
              or it["cr"] or it["dr"] or it["fr"] or it["mr"] or it["pr"]
              or it["svcorruption"] or any(it[c] for c in STAT_COLS)
              or it["damage"])
    return bool(combat)


def is_raid_tier(it, boss_ids):
    if it["id"] in boss_ids:
        return True
    if it["ac"] >= RAID_AC or it["hp"] >= RAID_HP:
        return True
    if it["damage"] > 0 and it["delay"] > 0 and (it["damage"] * 2.0 / it["delay"]) >= RAID_RATIO:
        return True
    return False


def _scale(old, mult, cap):
    """Multiply with a never-nerf cap: caps only bind above the old value."""
    return min(sql_round(old * mult), max(old, cap))


def boost(it, tier):
    """Return {col: new_value} for one base item."""
    f = RAID if tier == "raid" else GROUP
    new = {}
    for c in POOL_COLS:
        new[c] = _scale(it[c], f["pool"], f["pool_cap"])
    new["ac"] = _scale(it["ac"], f["ac"], f["ac_cap"])
    new["attack"] = _scale(it["attack"], f["attack"], f["attack_cap"])
    for c in RESIST_COLS:
        new[c] = _scale(it[c], f["resist"], f["resist_cap"])
    for c in STAT_COLS:
        new[c] = _scale(it[c], f["stat"], f["stat_cap"])
    new["damage"] = 0
    if it["damage"] > 0:
        # ratio cap shapes the uplift but never nerfs an already-strong weapon
        new["damage"] = max(it["damage"],
                            min(sql_round(it["damage"] * f["dmg"]),
                                sql_round(it["delay"] * f["dmg_delay_mult"])))
        new["ac"] = max(new["ac"], f["weapon_ac_floor"])
        new["hp"] = max(new["hp"], f["weapon_hp_floor"])
    return new


def set_clause(vals):
    return "SET " + ", ".join("%s=%d" % (c, vals[c]) for c in SET_COLS)


# ---------------------------------------------------------------------- main
def main():
    loot_ids = {int(r[0]) for r in query(LOOT_IDS_SQL)}
    boss_ids = {int(r[0]) for r in query(BOSS_LOOT_IDS_SQL)}
    bought_ids = {int(r[0]) for r in query("SELECT id FROM items WHERE ldonsold = 1")}
    quested_ids = {int(r[0]) for r in query(QUESTED_IDS_SQL)}

    union_ids = loot_ids | bought_ids | quested_ids
    items = fetch_items(union_ids)

    gear, dropped_junk, clone_tier_in_pop, reserved_in_pop = {}, 0, 0, 0
    for iid, it in items.items():
        it["id"] = iid
        if not is_gear(it):
            dropped_junk += 1
            continue
        # +1M/+2M tier rows are written ONLY by the 2x clone logic of their
        # base; never boost them standalone (base+clone double-write conflict)
        if iid >= 3000000:
            reserved_in_pop += 1
            continue
        if iid >= 1000000:
            clone_tier_in_pop += 1
            continue
        gear[iid] = it

    src_counts = {
        "loot": len(loot_ids & set(gear)), "bought": len(bought_ids & set(gear)),
        "quested": len(quested_ids & set(gear)),
    }

    raid, group, skipped = {}, {}, {}
    for iid, it in gear.items():
        ratio = (it["damage"] * 2.0 / it["delay"]) if it["damage"] > 0 and it["delay"] > 0 else 0
        if (it["hp"] >= SKIP_HP or it["ac"] >= SKIP_AC or it["mana"] >= SKIP_MANA
                or ratio >= SKIP_RATIO):
            skipped[iid] = it
        elif is_raid_tier(it, boss_ids):
            raid[iid] = it
        else:
            group[iid] = it

    # clone existence (+1M Enchanted / +2M Legendary)
    all_ids = set(gear)
    clone_ids = {iid + 1000000 for iid in gear} | {iid + 2000000 for iid in gear}
    clones = fetch_items(clone_ids)

    # ------------------------------------------------------------ build SQL
    lines = []
    samples_by_tier = {"raid": [], "group": []}

    def emit(iid, vals, comment):
        lines.append("UPDATE items %s WHERE id = %d; -- %s"
                     % (set_clause(vals), iid, comment))

    for bucket_name, bucket in (("raid", raid), ("group", group)):
        for iid in sorted(bucket):
            it = bucket[iid]
            new = boost(it, bucket_name)
            emit(iid, new, it["name"])
            # clones are exactly 2x the new base row
            clone_here = [cid for cid in (iid + 1000000, iid + 2000000) if cid in clones]
            if clone_here:
                clone_vals = {c: 2 * new[c] for c in SET_COLS}
                for cid in clone_here:
                    emit(cid, clone_vals, it["name"] + " (tier clone 2x)")
            if len(samples_by_tier[bucket_name]) < 7:
                samples_by_tier[bucket_name].append((it, new))

    sql_body = "\n".join(lines) + "\n"

    header = (
        "-- ----------------------------------------------------------------------------\n"
        "-- v142: LDoN gear -> elemental group / raid tier relative boost\n"
        "-- (20261012_ldon_elemental_boost) - generated by\n"
        "-- utils/sql/20261012_ldon_elemental_boost_generator.py - do not hand-edit\n"
        "--\n"
        "-- Population: loot of the 48 LDoN instance zones + takishruins(a), ldonsold=1\n"
        "-- point purchases, theme-named quested items. Gear filter: wearable/weapon with\n"
        "-- at least one combat stat; augs excluded (already boosted by v100), bags and\n"
        "-- no-stat junk excluded. +1M/+2M tier rows are only written as 2x clones of\n"
        "-- their boosted base; id >= 3M (reserved custom band) is never touched.\n"
        "-- Routing: raid tier = adventure_template type=1 (assassinate) end-boss loot,\n"
        "-- or gear already at ac>=30 / hp>=150 / dmg ratio>=3.0. Group tier: all else.\n"
        "-- Skip: items already far beyond target (ac>=80 / hp>=500 / mana>=500 /\n"
        "-- weapon ratio >=5.0) are fork-custom endgame gear and left untouched.\n"
"-- Factors - group: ac x3.5 (cap 65), hp/mana/endur x8 (cap 190), stats x4 (cap\n"
"--   60), resists x5 (cap 100), attack x4 (cap 60), dmg x1.8 capped at ratio 3.3,\n"
"--   weapon floors ac 15 / hp 100.\n"
"--         raid:  ac x1.5 (cap 75), hp/mana/endur x1.3 (cap 500), stats/resists/\n"
"--   attack x1.5, dmg x1.4 capped at ratio 3.5, weapon floors ac 20 / hp 150.\n"
"-- All caps are never-nerf: they only bind above the item's current value.\n"
        "-- Enchanted/Legendary clones (+1000000/+2000000) rebased to exactly 2x the new\n"
        "-- base row (flat 2x/2x system unchanged).\n"
        "-- SETs are absolute (idempotent); the manifest .check sentinel still gates it.\n"
        "-- ----------------------------------------------------------------------------\n")
    sql_full = header + sql_body

    # sentinel: post-boost hp of the strongest raid-bucket base item
    sentinel_base = max((iid for iid in raid if gear[iid]["hp"] > 0),
                        key=lambda iid: gear[iid]["hp"], default=None)
    if sentinel_base is None:
        sys.exit("no raid-bucket item with hp>0 for sentinel")
    s_new = boost(gear[sentinel_base], "raid")
    check_sql = ("SELECT `id` FROM `items` WHERE `id` = %d AND `hp` = %d LIMIT 1"
                 % (sentinel_base, s_new["hp"]))
    s_name = gear[sentinel_base]["name"]

    SQL_TWIN.write_text(sql_full, encoding="utf-8", newline="\n")

    # ------------------------------------------------------------- cpp entry
    sql_chunks, cur = [], ""
    for ln in sql_full.splitlines(keepends=True):
        if len(cur) + len(ln) > 9000 and cur:
            sql_chunks.append(cur)
            cur = ""
        cur += ln
    if cur.strip():
        sql_chunks.append(cur)

    parts = []
    for ch in sql_chunks:
        parts.append('R"%s(\n%s)%s"' % (ENTRY_TAG, ch, ENTRY_TAG))
    sql_cpp = "\r\n        ".join(parts)

    block = (
        "\t// <%s>\r\n"
        "\t// LDoN dropped/purchased/quested gear raised to elemental group tier;\r\n"
        "\t// adventure end-boss loot (adventure_template type=1) to raid tier.\r\n"
        "\t// Factors + routing + clone policy: see twin header.\r\n"
        "\t// RUN-ONCE: sentinel gates it (absolute SETs are also idempotent).\r\n"
        "\t// Generator: utils/sql/20261012_ldon_elemental_boost_generator.py\r\n"
        "\t// Twin: utils/sql/20261012_ldon_elemental_boost.sql\r\n"
        "\tManifestEntry{\r\n"
        "\t\t.version = %d,\r\n"
        '\t\t.description = "%s",\r\n'
        '\t\t.check = "%s",\r\n'
        '\t\t.condition = "empty",\r\n'
        "\t\t.match = \"\",\r\n"
        "\t\t.sql =\r\n"
        "\t\t\t%s,\r\n"
        "\t\t.content_schema_update = false,\r\n"
        "\t},\r\n"
        "\t// <%s> END"
        % (MARKER, VERSION, DESCRIPTION, check_sql.replace('"', '\\"'), sql_cpp, MARKER)
    )

    with open(MANIFEST, "r", encoding="utf-8", newline="") as fh:
        manifest_text = fh.read()
    begin = "\t// <%s>" % MARKER
    end_marker = "\t// <%s> END" % MARKER
    if ("\t.version = %d," % VERSION) in manifest_text and begin not in manifest_text:
        sys.exit("manifest already contains a .version = %d entry from another session; aborting"
                 % VERSION)
    if begin in manifest_text:
        # cut the previous block wherever it sits, then re-insert at the anchor
        s = manifest_text.index(begin)
        e = manifest_text.index(end_marker) + len(end_marker)
        manifest_text = manifest_text[:s] + manifest_text[e:]
    # vector close: the LAST "};" at start of line. A plain rfind("};") would
    # hit the trailing "// };" struct-doc comment at the end of the file.
    close = manifest_text.rfind("\n};") + 1
    manifest_text = manifest_text[:close] + block + "\r\n" + manifest_text[close:]
    with open(MANIFEST, "w", encoding="utf-8", newline="") as fh:
        fh.write(manifest_text)

    # ------------------------------------------------------------- version.h
    with open(VERSION_H, "r", encoding="utf-8", newline="") as fh:
        vh = fh.read()
    m = re.search(r"#define CUSTOM_BINARY_DATABASE_VERSION (\d+)", vh)
    cur_ver = int(m.group(1))
    if cur_ver < VERSION:
        vh = vh[:m.start()] + ("#define CUSTOM_BINARY_DATABASE_VERSION %d" % VERSION) + vh[m.end():]
        with open(VERSION_H, "w", encoding="utf-8", newline="") as fh:
            fh.write(vh)
    elif cur_ver > VERSION:
        sys.exit("version.h already at %d (> %d); concurrent session? aborting" % (cur_ver, VERSION))

    # --------------------------------------------------------------- report
    print("== LDoN elemental boost generator ==")
    print("population ids: %d (loot %d, ldonsold %d, quested-name %d)"
          % (len(union_ids), len(loot_ids), len(bought_ids), len(quested_ids)))
    print("gear after filter: %d (junk excluded: %d, +1M/+2M rows left to clone logic: %d,"
          " reserved-band >=3M untouched: %d)" % (len(gear), dropped_junk,
                                                  clone_tier_in_pop, reserved_in_pop))
    print("gear by source: %s" % src_counts)
    print("raid tier: %d items   group tier: %d items   SKIPPED (already beyond target): %d"
          % (len(raid), len(group), len(skipped)))
    for iid in sorted(skipped)[:5]:
        it = skipped[iid]
        print("   skipped: %d %s (ac %d hp %d mana %d)" % (iid, it["name"], it["ac"],
                                                           it["hp"], it["mana"]))
    print("clone rows updated: %d of %d possible"
          % (sum(1 for iid in gear if iid + 1000000 in clones)
             + sum(1 for iid in gear if iid + 2000000 in clones), 2 * len(gear)))
    print("SQL lines: %d   twin: %s (%d KB)   cpp chunks: %d"
          % (len(lines), SQL_TWIN, len(sql_full) // 1024, len(sql_chunks)))
    print("sentinel: id %d (%s) post-boost hp %d" % (sentinel_base, s_name, s_new["hp"]))
    print()
    print("sample before/after (id name | tier | ac hp mana | resists sum | dmg/delay):")
    for want in ("raid", "group"):
        print("  -- %s tier --" % want)
        for it, new in samples_by_tier[want]:
            is_w = it["damage"] > 0
            print("  %8d %-34s ac %3d->%3d  hp %4d->%4d  mana %4d->%4d  res %3d->%3d%s"
                  % (it["id"], it["name"][:34],
                     it["ac"], new["ac"], it["hp"], new["hp"],
                     it["mana"], new["mana"],
                     it["cr"] + it["dr"] + it["fr"] + it["mr"] + it["pr"],
                     new["cr"] + new["dr"] + new["fr"] + new["mr"] + new["pr"],
                     ("  dmg %d/%d -> %d/%d" % (it["damage"], it["delay"],
                                                new["damage"], it["delay"])) if is_w else ""))


if __name__ == "__main__":
    main()

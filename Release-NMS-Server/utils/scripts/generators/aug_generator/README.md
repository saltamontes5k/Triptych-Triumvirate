# Augmentation Generator

Generates soul augmentations (Lost, Restless, Found) with randomized stats,
names, focus/worn effects, and lootdrop entries for the NMS Server.

## Quick Start

```bash
cd Release-NMS-Server/utils/scripts/generators/aug_generator

# Generate everything (items + loot + CSV)
python aug_generator.py
```

Output lands in `output/`:

| File | Description |
|------|-------------|
| `generated_augs.sql` | `INSERT INTO items` statements |
| `generated_augs_loot.sql` | `INSERT INTO lootdrop_entries` statements |
| `generated_augs_loottable.sql` | `INSERT INTO loottable` + `loottable_entries` + `global_loot` |
| `generated_augs_summary.csv` | Debug spreadsheet with all stats |

## CLI Options

```
python aug_generator.py [options]

Mode:
  --items          Generate items only (skip loot SQL)
  --loot           Generate loot only from existing CSV

Counts:
  --lost-count N   Lost Soul count (default: 600)
  --restless-count N  Restless Soul count (default: 100)
  --found-count N  Found Soul count (default: 50)

IDs:
  --start-id N     Starting item ID (default: 160000)
  --lootdrop-id N  Base lootdrop ID (default: 178700)
  --loottable-id N Base loottable ID (default: same as --lootdrop-id)
  --global-loot-id N  Base global loot rule ID (default: same as --lootdrop-id)
  --drop-chance N  Drop chance: 0=flat 1% via loottable probability gate (default), or fixed per-item %
  --max-level N    Max drop level for Restless/Found (default: 65)
  --max-aug-level N   Highest aug tier to generate (default: 65)

Other:
  --seed N         Random seed for reproducible runs
  --base-aug FILE  Path to base_aug.txt
  --output-dir DIR Output directory
  --names-file FILE  Used names tracking file
```

> **Note:** Band IDs are sequential from the base. With `--lootdrop-id 178700`, the 7 bands use lootdrops `178700-178706` (loottables and global_loot rules likewise). Only bands with items are emitted.

## Examples

```bash
# Default generation
python aug_generator.py

# Small test run with fixed seed
python aug_generator.py --lost-count 20 --restless-count 10 --found-count 5 --seed 42

# Items first, review CSV, then generate loot
python aug_generator.py --items
# ... review output/generated_augs_summary.csv ...
python aug_generator.py --loot

# Custom ID range for a different server
python aug_generator.py --start-id 170000 --lootdrop-id 179000

# Raise the aug tier cap (e.g. if server level cap is raised later)
python aug_generator.py --max-aug-level 75

# Legacy fixed per-item drop chance
python aug_generator.py --drop-chance 2
```

## Importing into the Database

1. Import items:
   ```sql
   SOURCE /path/to/generated_augs.sql;
   ```

2. Import loot entries:
   ```sql
   SOURCE /path/to/generated_augs_loot.sql;
   ```

3. Import loottable + global loot:
   ```sql
   SOURCE /path/to/generated_augs_loottable.sql;
   ```

After step 3, every NPC in the world has a chance to drop augs based on its level. No per-NPC edits needed.

### Drop Chance

By default (`--drop-chance 0`), drops use **EQEmu's loottable probability gate** for a flat ~1% chance per kill, level-scaled:

1. **9 level bands** (trimmed to 7 when the server is capped at 65): `1-10, 11-20, ..., 71-75`.
2. Each band has its own `loottable`, `loottable_entries`, and `global_loot` rule with `min_level`/`max_level` matching the band.
3. `loottable_entries.probability = 1` → only ~1% of kills even reach the drop roll.
4. `lootdrop_entries.chance = 100` + `droplimit = 1` → when the gate passes, **exactly one** aug drops, weighted evenly among that band's augs.

Result: **~1% flat** on any mob, and the aug that drops **scales with the mob's level**.

Override with `--drop-chance N` (>0) to use the legacy single-lootdrop behavior with a fixed per-item percentage instead.

## How It Works

### Soul Types

| Type | Count | Tradeable |
|------|-------|-----------|
| Lost Soul | 600 | No (no-drop) |
| Restless Soul | 100 | Yes |
| Found Soul | 50 | Yes |

All types drop via the level-band global loot system. Lost Souls are no-drop;
Restless and Found Souls are tradeable.

### Level Tiers

Augs spawn at one of: 10, 20, 30, 40, 50, 60, 65, 70, 75 (tiers above the
server's cap are skipped via `--max-aug-level`, default 65 → `10-65`).

### Level Bands (drop scaling)

Augs are grouped into non-overlapping level bands that gate drops by NPC level:

| Band | NPC level range | Default lootdrop ID |
|------|-----------------|---------------------|
| 1-10 | 1-10 | 178700 |
| 11-20 | 11-20 | 178701 |
| 21-30 | 21-30 | 178702 |
| 31-40 | 31-40 | 178703 |
| 41-50 | 41-50 | 178704 |
| 51-60 | 51-60 | 178705 |
| 61-65 | 61-65 | 178706 |

### Stat Scaling

Stats scale with level via `ceil(level * multiplier)`. Higher aug types
(Lost > Restless > Found) have lower multipliers but more stat slots.

### Archetypes

Each aug rolls an archetype that determines its stat distribution:
- **melee_offense** (25%) — STR/DEX/AGI, HP-heavy
- **melee_defense** (25%) — STA/AGI, HP+AC
- **caster** (20%) — INT/CHA, mana-heavy, focus effects
- **healer** (20%) — WIS/CHA, mana-heavy, focus effects
- **mixed** (10%) — spread across all stats

### Effects

- **Focus effects** (12% chance) — Caster/healer spell focus bonuses (6 tiers)
- **Worn effects** (12% chance) — Melee combat bonuses (3 tiers, level 50+)
- Gap-fill pass ensures every effect appears at least once in the pool

### Names

Names are procedurally generated from syllable pools with archetype-based
tone (hard/soft). Higher aug types have higher epithet chance (5%/15%/30%).

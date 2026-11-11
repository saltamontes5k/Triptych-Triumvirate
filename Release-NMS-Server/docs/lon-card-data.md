# Legends of Norrath — card data (`lon_data`)

The card game's catalogue is **not** in the database. `world` reads it from a folder on disk
(`Custom:LoNDataPath`, default `lon_data`, relative to the server root). That folder is a copy of
the client's own `LegendsOfNorrath\data`, i.e. Daybreak-copyright material, so **it is not shipped
in this repository**.

Nothing else depends on it. Without the folder the server boots normally, `world` logs

```
[LoN] card data missing under [lon_data] -- copy the client's LegendsOfNorrath/data there
[LoN] card service NOT started
```

and the card game simply cannot log in. Every other system — zones, quests, achievements, housing —
is unaffected.

## 1. What the release snapshot expects

`release_peq` ships the full `lon_*` schema. The per-account / per-character tables (`lon_card`,
`lon_deck`, `lon_account`, `lon_session`, `lon_posted_trade*`, `lon_tournament*`, `lon_reward_claim`,
`lon_delivery`, `lon_achievement`, `lon_pvp_*`, …) are **truncated**; the two catalogue tables
`lon_loot_item` and `lon_news` ship populated because they are content.

Rules in `rule_values` (from the shipped snapshot):

| Rule | Value | Meaning |
|---|---|---|
| `Custom:LoNEnabled` | `true` | start the card service in `world` |
| `Custom:LoNDataPath` | `lon_data` | folder, relative to the server root |
| `Custom:LoNPort` | `15792` | TCP port the client's `LegendsOfNorrath.dll` dials |

## 2. Build the folder from a client

Source: any RoF2-or-later client install that still carries the card game —
`<EverQuest>\LegendsOfNorrath\data`
Target: `<server root>\lon_data` — next to `world.exe`, i.e. `Release-NMS-Server\Build\bin\Release\lon_data`

The server needs these **62 core files** (copying the client folder wholesale is fine too — the
extra client files `ban.dat`, `restrict.dat` and `locale\*` are simply ignored):

```
lon_data\
  campaign.dat                   ~360 KB
  archetypes\                    8 files, ~13.0 MB
    index.dat          ~67 KB
    storage.dat        ~1.5 MB
    actionIndex.dat    ~250 KB
    actionStorage.dat  ~2.3 MB
    msgIndexen.dat     ~55 KB
    msgStorageen.dat   ~438 KB
    ruleIndex.dat      ~1.0 MB
    ruleStorage.dat    ~7.4 MB
  decks\                         53 files (52 .eqd + tournament\README.txt)
    1900002..1900005.eqd, 2900002..2900005.eqd, ... 9900002..9900005.eqd
    10900002..10900005.eqd, 11900002..11900005.eqd, 12900002..12900005.eqd
    6900004..6900007.eqd
    FighterStarter.eqd  MageStarter.eqd  PriestStarter.eqd  ScoutStarter.eqd
    tournament\README.txt
```

One-command path — from the repo root:

```
recreate-lon-data.bat <EverQuest-folder>
```

Manual equivalent:

```powershell
$client = "C:\EverQuest"                                        # a RoF2 client with the card game
$src    = Join-Path $client "LegendsOfNorrath\data"
$dest   = Join-Path (Get-Location) "Release-NMS-Server\Build\bin\Release\lon_data"   # run from the repo root
robocopy $src $dest /E /NFL /NDL /NJH /NP /R:1 /W:1              # rc 0-7 = success
(Get-ChildItem $dest -Recurse -File).Count                       # expect 62
```

`decks\tournament\README.txt` is part of the client folder; keep it, it keeps the file count honest.

## 3. Verify

Restart `world` and look for the one line that proves the data loaded:

```
[LoN] card data: [6027] archetypes ([0] unreadable), [16] booster sets, [46] starter decks,
[179] scenarios ([172] with rewards), [1] campaign rewards, [5] Loremaster cards
```

Acceptance criteria:

- the line is present at all — if you only see `card data missing`, `Custom:LoNDataPath` is wrong;
- `[0] unreadable` — anything above 0 means the files are corrupt or from a different client build;
- `archetypes` ≥ 6027, `booster sets` = 16, `starter decks` = 46, `scenarios` = 179 (172 rewarding),
  `campaign rewards` = 1, `Loremaster cards` = 5.

The loader is `world/lon_service.cpp` — `LoNService::Start()` bails out before listening if
`LoadData()` returns false, and `LoadData()` requires `archetypes/index.dat` **and**
`archetypes/storage.dat` and at least one booster pool. A folder with the decks but no `archetypes\`
still fails.

## 4. If you would rather not run the card game

```sql
UPDATE rule_values SET rule_value = 'false'
 WHERE ruleset_id = 1 AND rule_name = 'Custom:LoNEnabled';
```

Leaving the folder absent is enough as well; the only difference is one error line per boot.

## 5. Never commit the folder

`lon_data` was removed from the release on purpose. If you add it back locally, add this to
`.gitignore` first:

```gitignore
# Client-derived card data (Daybreak-copyright) — recreate locally, never commit
Release-NMS-Server/Build/bin/Release/lon_data/
```

## 6. For an LLM following these instructions

Do exactly this, in order, and stop if a check fails:

1. Locate a RoF2+ client install containing `LegendsOfNorrath\data` with `archetypes\index.dat` and
   `archetypes\storage.dat` present. If none exists, stop and report — do not invent or download the data.
2. Run `recreate-lon-data.bat <client>` from the repo root, or copy `LegendsOfNorrath\data\*` to
   `Release-NMS-Server\Build\bin\Release\lon_data\` (robocopy `/E`).
3. Assert `archetypes\index.dat`, `archetypes\storage.dat`, `campaign.dat` and at least 52 `.eqd`
   files exist (a wholesale client copy also carries `ban.dat`/`restrict.dat`/`locale\*` — fine).
4. Confirm `rule_values` has `Custom:LoNEnabled = true` and `Custom:LoNDataPath = lon_data`.
5. Start or restart `world` **only with the player-facing go-ahead**, then read the boot log for
   `[LoN] card data: [...] archetypes ([0] unreadable) ...` and check the numbers in §3.
6. Confirm `git status --porcelain` does not list anything under `lon_data/` — the `.gitignore` rule in §5
   must be in place before any commit.

Data loaded and verified is the only acceptable "done" here; a copied folder with a wrong count is not.

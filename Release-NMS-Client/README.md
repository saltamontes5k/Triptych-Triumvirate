# NMS Client DLL

Client-side add-on for the **RoF2** EverQuest client, built as `dinput8.dll`.

## What it is

RoF2 is a fixed, closed-source binary — the server cannot change how it behaves. Anything the
client itself gets wrong (or simply never supported) has to be fixed inside the client process.

This project builds a `dinput8.dll` that sits next to `eqgame.exe`. Windows loads it in place of
the system DirectInput library when the game starts, it forwards every real DirectInput call
through to the genuine system DLL, and while it is loaded it patches and hooks the client to add
the features below. It is not a launcher, it does not modify `eqgame.exe` on disk, and removing
the file returns the client to stock behaviour.

## What it does

Custom windows and systems added for this server:

- **Pet window** — a proper window for the multi-pet system, showing every pet you control with
  health, targets and per-pet commands, fed by a server-pushed pet list.
- **Waypoint window** — browse and travel to unlocked waypoints.
- **Multiclass `/who`** — shows all of a character's classes instead of just the visible one.
- **Discipline / skill timers** — the stock client only has 20 discipline timer slots, so
  multiclass characters collide on shared cooldowns. This replaces the fixed array with an
  unbounded map so each class keeps its own timers.
- **8-digit say-links** — stock RoF2 only parses 5-digit item link IDs, so high item IDs render
  as `[00000...]` garbage. This extends the parser so Bazaar, trader and quest links work.
- **Floating combat text**, an **FPS limiter**, and assorted UI fixes.

Behaviour is controlled by simple flags in [`eqgame_dll/_options.h`](eqgame_dll/_options.h) —
each one is commented with what it does. Useful ones include gamma restore on crash, `/fov` and
`/camera` commands, AA purchasing at level 1, old-model horse support, custom NPC races, custom
zones, and a food/drink spam toggle. Change a flag, rebuild, and ship the new DLL.

## Installing

### 1. You need a base client first

**This repository does not include an EverQuest client, and cannot.** The client files are
copyrighted by Daybreak, so you will have to source one yourself — the same RoF2-era client the
server this project is built on used. If you are rebuilding that server, you almost certainly know
where to find it. Nothing here will work without it.

Everything in `ClientFiles/` is an **overlay**: files that were changed for this server, meant to be
copied *over* an existing client. It is not a client on its own.

### 2. Copy the overlay in

Copy the contents of `ClientFiles/` into your EverQuest folder, keeping the folder structure:

| From | Goes to | What it is |
| --- | --- | --- |
| `dinput8.dll` | client root, next to `eqgame.exe` | the client add-on (see above) |
| `uifiles\default\*.xml` | `uifiles\default\` | modified + new windows |
| `uifiles\gearcore`, `shinsparxx`, `Blue` | same folders | the same changes for those skins |

Two of those windows are **new** and have no stock equivalent — `NMS_WaypointsWnd.xml` and
`NMS_MapFilterWnd.xml` — and `EQUI_PetInfoWindow.xml` is the multi-pet window. The rest are stock
windows with changes (inventory, merchant with the multiclass level column, bazaar search, big bank,
selector, character select/create, and the login screens).

To uninstall, delete `dinput8.dll` and restore the original XML. There is nothing else to undo.

> Some anti-virus products flag any unsigned DLL that hooks a game process. The full source is in
> this repository if you would rather build it yourself.

### 3. Regenerate the four client data files

Four client files are generated from the **server database**, not shipped here. Your server's own
data has to be in them or spells, discs, skill caps and item text will not match:

- `spells_us.txt`
- `dbstr_us.txt`
- `SkillCaps.txt`
- `BaseData.txt`

The server ships a tool for exactly this. With your database imported and `eqemu_config.json`
pointed at it, run from the server folder:

```
export_client_files
```

It writes all four into `export/`. Copy them into your client folder — and note the client keeps a
**second copy of each in `Resources\`**, so update both locations or the client may load stale data.

You can also export them from **Spire** if you prefer a UI. Re-export any time you change spells,
skills or item text in the database.

> The multiclass spell export happens automatically when the `Custom:MulticlassingEnabled` rule is
> true (the default).

### 4. Optional: stop the "XML files are not compatible" popup

Custom UI files make the client show this on every login:

> *Your XML files are not compatible with current EverQuest files, certain windows may not perform
> correctly. Use "/loadskin Default 1" to load the EverQuest default skin.*

It is harmless, but players tend to follow the advice and reset their skin, which undoes the custom
windows. To silence it, open `eqstr_us.txt` in your client folder, find the line beginning with
string id **3146** (around line 1907) and delete everything after the id, leaving:

```
3146 
```

Save. That is the only change needed.

### 5. Known gaps: invisible items and missing icons

This server's database references art added **after** the base client's art set. That art is
Daybreak's, so it is not included here. Everything else works — these items simply will not draw:

**Item models — 397 archives** referenced by `Resources\OnDemandResources.txt` that the base client
does not have (`cotfequip.eqg`, `coralweapons.eqg`, `arxmentisweapons.eqg`, and similar). Items using
them appear invisible when equipped. To fix it yourself, copy those `.eqg` archives from a newer
EverQuest client into your client folder.

**Inventory icons — sheets `dragitem179.dds` through `dragitem222.dds` (44 sheets).** The base client
only goes up to `dragitem178`, so items with icon ids above that show blank. To fix it: copy those 44
`.dds` files from a newer client into `uifiles\default\`, then add a matching `<TextureInfo>` block
for each one to `uifiles\default\EQUI_Animations.xml`, following the format the existing entries use.

**Zones.** If you add content beyond what the base client shipped with, you will need that zone's
files too. For an era-limited server this usually never comes up.

None of these stop the server from running — they are cosmetic gaps you can close on your own.

## Building

You need **Visual Studio 2022** with the *Desktop development with C++* workload.

1. Open `eqgame_dll.sln`.
2. Set the configuration to **Release** and the platform to **Win32** (x86 — the RoF2 client is
   32-bit; x64 will not load).
3. Build. The result lands in `Release\dinput8.dll`.

Building from the command line:

```
msbuild eqgame_dll.sln /t:Rebuild /p:Configuration=Release /p:Platform=Win32
```

> Always use **Rebuild** rather than an incremental build. Incremental builds here can link stale
> objects and fail in confusing ways.

The `dependencies\`, `Detours\`, `dxsdk81\` and `Blech\` folders are the bundled libraries this
needs — do not delete them.

## Origin and license

This began as **[classless-dll](https://github.com/SecretsOTheP/classless-dll)** (EQ Classless
3.0's DLL) and has been modified and extended for this server. It is released under the **MIT license**
— see [`LICENSE`](LICENSE), which retains the original copyright notice.

`eqgame_dll\License.txt` covers the bundled DirectInput proxy code, which carries its own terms.

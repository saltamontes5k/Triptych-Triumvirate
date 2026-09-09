# GM Commands

Every command registered by this server, transcribed from zone/command.cpp and the handlers in zone/gm_commands/. Status levels follow common/emu_constants.h (AccountStatus). Verify a command's live help with #help before assuming behaviour.

Stock detail (syntax, subcommands) is documented locally in reference/GM Commands.md; this file is the authoritative list plus Triptych-side notes.

## Account status levels

| Level | Name |
|---|---|
| 0 | Player |
| 10 | Steward |
| 20 | ApprenticeGuide |
| 50 | Guide |
| 80 | QuestTroupe |
| 81 | SeniorGuide |
| 85 | GMTester |
| 90 | EQSupport |
| 95 | GMStaff |
| 100 | GMAdmin |
| 150 | GMLeadAdmin |
| 160 | QuestMaster |
| 170 | GMAreas |
| 180 | GMCoder |
| 200 | GMMgmt |
| 250 | GMImpossible |

## Commands by name

| Command | Min status | Description |
|---|---|---|
| #acceptrules | 0 | [acceptrules] - Accept the EQEmu Agreement |
| #advnpcspawn | 150 | [maketype/makegroup/addgroupentry/addgroupspawn][removegroupspawn/movespawn/editgroupbox/cleargroupbox] |
| #aggrozone | 100 | [aggro] - Aggro every mob in the zone with X aggro. Default is 0. Not recommend if you're not invulnerable. |
| #ai | 100 | [factionid/spellslist/con/guard/roambox/stop/start] - Modify AI on NPC target |
| #alttoggle | 0 | [alttoggle] - Toggle the effectiveness of a passive AA by AA ID. |
| #appearance | 150 | [type] [value] - Send an appearance packet for you or your target |
| #appearanceeffects | 100 | [Help/Remove/Set/View] - Modify appearance effects on yourself or your target. |
| #apply_shared_memory | 250 | [shared_memory_name] - Tells every zone and world to apply a specific shared memory segment by name. |
| #attack | 150 | [Entity Name] - Make your NPC target attack an entity by name |
| #attackmode | 0 | Toggle Ranged and Melee Autoattack modes |
| #augmentitem | 250 | Force augments an item. Must have the augment item window open. |
| #autoskill | 0 | Configure automatic combat skill usage. |
| #award | 100 | EoM |
| #ban | 150 | [Character Name] [Reason] - Ban by character name |
| #bot | 0 | Type \"#bot help\" or \"^help\" to the see the list of available commands for bots. |
| #bugs | 80 | [Close/Delete/Review/Search/View] - Handles player bug reports |
| #camerashake | 80 | [Duration (Milliseconds)] [Intensity (1-10)] - Shakes the camera on everyone's screen globally. |
| #castspell | 50 | [Spell ID] [Instant (0 = False, 1 = True, Default is 1 if Unused)] - Cast a spell |
| #castspellnms | 5 | [Spell ID or Spell Name] - Cast a spell from your spellbook out of combat |
| #chat | 200 | [Channel ID] [Message] - Send a channel message to all zones |
| #clearxtargets | 0 | Clears XTargets |
| #copycharacter | 250 | [source_char_name] [dest_char_name] [dest_account_name] - Copies character to destination account |
| #corpse | 50 | Manipulate corpses, use with no arguments for help |
| #corpsefix | 0 | Attempts to bring corpses from underneath the ground within close proximity of the player |
| #countitem | 150 | [Item ID] - Counts the specified Item ID in your or your target's inventory |
| #damage | 100 | [Amount] - Damage yourself or your target |
| #databuckets | 80 | View/Delete [key] [limit]- View data buckets, limit 50 default or Delete databucket by key |
| #dbspawn2 | 100 | [Spawngroup ID] [Respawn] [Variance] [Condition ID] [Condition Minimum] - Spawn an NPC from a predefined row in the spawn2 table, Respawn and Variance are in Seconds (condition is optional) |
| #delacct | 150 | [Account ID/Account Name] - Delete an account by ID or Name |
| #delpetition | 20 | [petition number] - Delete a petition |
| #depop | 50 | [Start Spawn Timer] - Depop your NPC target and optionally start their spawn timer (false by default) |
| #depopzone | 100 | [Start Spawn Timers] - Depop the zone and optionally start spawn timers (false by default) |
| #devtools | 200 | [menu/window] [enable/disable] - Manages Developer Tools (send no parameter for menu) |
| #disablerecipe | 80 | [Recipe ID] - Disables a Recipe |
| #disarmtrap | 80 | Analog for ldon disarm trap for the newer clients since we still don't have it working. |
| #doanim | 50 | [Animation ID/Animation Name] [Speed] - Send an animation by ID or name at the specified speed to you or your target (Speed is optional) |
| #door | 80 | Door editing command |
| #dye | 20 | [slot/'help'] [red] [green] [blue] [use_tint] - Dyes the specified armor slot to Red, Green, and Blue provided, allows you to bypass darkness limits. |
| #dz | 80 | Manage expeditions and dynamic zone instances |
| #dzkickplayers | 0 | Removes all players from current expedition. (/kickplayers alternative for pre-RoF clients) |
| #editmassrespawn | 100 | [name-search] [second-value] - Mass (Zone wide) NPC respawn timer editing command |
| #emote | 80 | [Name/World/Zone] [type] [message] - Send an emote message by name, to the world, or to your zone (^ separator allows multiple messages to be sent at once) |
| #emptyinventory | 250 | Clears your or your target's entire inventory (Equipment, General, Bank, and Shared Bank) |
| #enablerecipe | 80 | [Recipe ID] - Enables a Recipe |
| #entityvariable | 100 | [clear/delete/set/view] - Modify entity variables for yourself or your target |
| #evolve | 10 | Evolving Item manipulation commands. Use argument help for more info. |
| #exptoggle | 80 | [Toggle] - Toggle your or your target's experience gain. |
| #faction | 80 | [Find (criteria / all ) / Review (criteria / all) / Reset (id)] - Resets Player's Faction |
| #factionassociation | 150 | [factionid] [amount] - triggers a faction hits via association |
| #feature | 80 | Change your or your target's feature's temporarily |
| #find | 50 | Search command used to find various things |
| #fish | 80 | Fish for an item |
| #fixmob | 80 | [race/gender/texture/helm/face/hair/haircolor/beard/beardcolor/heritage/tattoo/detail] [next/prev] - Manipulate appearance of your target |
| #flagedit | 100 | Edit zone flags on your target. Use #flagedit help for more info. |
| #fleeinfo | 80 | - Gives info about whether a NPC will flee or not, using the command issuer as top hate. |
| #forage | 80 | Forage an item |
| #gearup | 200 | Developer tool to quickly equip yourself or your target |
| #giveitem | 200 | [itemid] [charges] - Summon an item onto your target's cursor. Charges are optional. |
| #givemoney | 200 | [Platinum] [Gold] [Silver] [Copper] - Gives specified amount of money to you or your player target |
| #gmzone | 100 | [Zone ID/Zone Short Name] [Version] [Instance Identifier] - Zones to a private GM instance (Version defaults to 0 and Instance Identifier defaults to 'gmzone' if not used) |
| #goto | 10 | [playername] or [x y z] [h] - Teleport to the provided coordinates or to your target |
| #grantaa | 200 | [level] - Grants a player all available AA points up the specified level, all AAs are granted if no level is specified. |
| #grid | 170 | [add/delete] [grid_num] [wandertype] [pausetype] - Create/delete a wandering grid |
| #guild | 10 | Guild manipulation commands. Use argument help for more info. |
| #help | 0 | [Search Criteria] - List available commands and their description, specify partial command as argument to search |
| #hotfix | 250 | [hotfix_name] - Reloads shared memory into a hotfix, equiv to load_shared_memory followed by apply_shared_memory |
| #hp | 0 | Refresh your HP bar from the server. |
| #illusion | 0 | [store/list/use <id>] - Manage stored illusions (store/use/remove) |
| #illusionblock | 50 | Controls whether or not illusion effects will land on you when cast by other players or bots |
| #instance | 200 | Modify Instances |
| #interrogateinv | 0 | use [help] argument for available options |
| #interrupt | 50 | [Message ID] [Color] - Interrupt your casting. Arguments are optional. |
| #invsnapshot | 80 | Manipulates inventory snapshots for your current target |
| #ipban | 200 | [IP] - Ban IP |
| #kick | 150 | [Character Name] - Disconnect a player by name |
| #kill | 100 | Kill your target |
| #killallnpcs | 200 | [npc_name] - Kills all npcs by search name, leave blank for all attackable NPC's |
| #list | 20 | [npcs/players/corpses/doors/objects] [search] - Search entities |
| #load_shared_memory | 250 | [shared_memory_name] - Reloads shared memory and uses the input as output |
| #loc | 0 | Print out your or your target's current location and heading |
| #logs | 250 | Manage anything to do with logs |
| #lootsim | 250 | [npc_type_id] [loottable_id] [iterations] - Runs benchmark simulations using real loot logic to report numbers and data |
| #makepet | 50 | [Pet Name] - Make a pet |
| #memspell | 50 | [Spell ID] [Spell Gem] - Memorize a Spell by ID to the specified Spell Gem for you or your target |
| #merchantshop | 100 | Closes or opens your target merchant's shop |
| #modifynpcstat | 150 | [Stat] [Value] - Modifies an NPC's stats temporarily. |
| #movechar | 50 | [Character ID/Character Name] [Zone ID/Zone Short Name] - Move an offline character to the specified zone |
| #movement | 200 | Various movement commands |
| #myskills | 0 | Show details about your current skill levels |
| #mysql | 250 | [Help/Query] [SQL Query] - Mysql CLI, see 'Help' for options. |
| #mystats | 50 | Show details about you or your pet |
| #npccast | 80 | [targetname/entityid] [spellid] - Causes NPC target to cast spellid on targetname/entityid |
| #npcedit | 100 | [column] [value] - Mega NPC editing command |
| #npceditmass | 100 | [name-search] [column] [value] - Mass (Zone wide) NPC data editing command |
| #npcemote | 150 | [Message] - Make your NPC target emote a message. |
| #npcloot | 80 | Manipulate the loot an NPC is carrying. Use #npcloot help for more information. |
| #npcsay | 150 | [Message] - Make your NPC target say a message. |
| #npcshout | 150 | [Message] - Make your NPC target shout a message. |
| #npcspawn | 170 | [create/add/update/remove/delete] - Manipulate spawn DB |
| #npctypespawn | 10 | [NPC ID] [Faction ID] - Spawn an NPC by ID from the database with an option of setting its Faction ID |
| #nudge | 80 | Nudge your target's current position by specific values |
| #nukebuffs | 50 | [Beneficial/Detrimental/Help] - Strip all buffs by type on you or your target (no argument to remove all buffs) |
| #nukeitem | 150 | [Item ID] - Removes the specified Item ID from you or your player target's inventory |
| #object | 100 | List/Add/Edit/Move/Rotate/Copy/Save/Undo/Delete - Manipulate static and tradeskill objects within the zone |
| #opcode | 200 | Reloads all opcodes from server patch files |
| #parcels | 200 | View and edit the parcel system. Requires parcels to be enabled in rules. |
| #path | 200 | view and edit pathing |
| #peqzone | 0 | [Zone ID/Zone Short Name] - Teleports you to the specified zone if you meet the requirements. |
| #petcmd | 0 | Issue commands to specific pets |
| #petitems | 20 | View your pet's items if you have one |
| #petname | 100 | [newname] - Temporarily renames your pet. Leave name blank to restore the original name. |
| #picklock | 0 | Analog for ldon pick lock for the newer clients since we still don't have it working. |
| #profanity | 150 | Manage censored language. |
| #push | 150 | [Back Push] [Up Push] - Lets you do spell push on an NPC |
| #raidloot | 0 | [All/GroupLeader/RaidLeader/Selected] - Sets your Raid Loot Type if you have permission to do so. |
| #randomfeatures | 80 | Temporarily randomizes the Facial Features of your target |
| #refreshgroup | 0 | Refreshes Group for you or your player target. |
| #reload | 200 | Reloads different types of server data globally, use no argument for help menu. |
| #removeitem | 100 | [Item ID] [Amount] - Removes the specified Item ID by Amount from you or your player target's inventory (Amount defaults to 1 if not used) |
| #repop | 100 | [Force] - Repop the zone with optional force repop |
| #resetaa | 200 | [aa/leadership] - Resets a player's AAs or Leadership AAs and refunds spent AAs (not Leadership AAs) to unspent, may disconnect player. |
| #resetaa_timer | 200 | [All/Timer ID] - Command to reset AA cooldown timers for you or your player target. |
| #resetdisc_timer | 200 | [All/Timer ID] - Command to reset discipline timers. |
| #revoke | 200 | [Character Name] [0/1] - Revokes or unrevokes a player's ability to talk in OOC by name (0 = Unrevoke, 1 = Revoke) |
| #rl | 200 | Reloads logs (alias of #reload logs). |
| #roambox | 200 | [Remove/Set] [Box Size] [Delay (Milliseconds)] - Remove or set an NPC's roambox size and delay |
| #rq | 200 | Reloads quests (alias of #reload quests). |
| #rules | 250 | (subcommand) - Manage server rules |
| #save | 50 | Force your player or player corpse target to be saved to the database |
| #scale | 150 | Handles NPC scaling |
| #scribespell | 180 | [Spell ID] - Scribe a spell by ID to your or your target's spell book. |
| #scribespells | 150 | [Max level] [Min level] - Scribe all spells for you or your player target that are usable by them, up to level specified. (may freeze client for a few seconds) |
| #sendzonespawns | 150 | Refresh spawn list for all clients in zone |
| #sensetrap | 0 | Analog for ldon sense trap for the newer clients since we still don't have it working. |
| #serverrules | 0 | Show server rules |
| #set | 50 | Set command used to set various things |
| #show | 50 | Show command used to show various things |
| #shutdown | 150 | Shut this zone process down |
| #size | 80 | Change your targets size (alias of #feature size) |
| #soulmark | 100 | Manipulate account flags |
| #spawn | 10 | [name] [race] [level] [material] [hp] [gender] [class] [priweapon] [secweapon] [merchantid] - Spawn an NPC |
| #spawneditmass | 150 | [Search Criteria] [Edit Option] [Edit Value] [Apply] Mass editing spawn command (Apply is optional, 0 = False, 1 = True, default is False) |
| #spawnfix | 170 | Find targeted NPC in database based on its X/Y/heading and update the database to make it spawn at your current location/heading. |
| #stun | 100 | [duration] - Stuns you or your target for duration |
| #summon | 80 | [Character Name] - Summons your corpse, NPC, or player target, or by character name if specified |
| #summonburiedplayercorpse | 100 | Summons the target's oldest buried corpse, if any exist. |
| #summonitem | 200 | [itemid] [charges] - Summon an item onto your cursor. Charges are optional. |
| #suspend | 150 | [name] [days] [reason] - Suspend by character name and for specificed number of days |
| #suspendmulti | 150 | [Character Name One/Character Name Two/etc] [Days] [Reason] - Suspend multiple characters by name for specified number of days |
| #takeplatinum | 200 | [Platinum] - Takes specified amount of platinum from you or your player target |
| #task | 150 | (subcommand) - Task system commands |
| #tim | 0 | Toggle Improved Models |
| #traindisc | 150 | [level] - Trains all the disciplines usable by the target, up to level specified. (may freeze client for a few seconds) |
| #tune | 100 | Calculate statistical values related to combat. |
| #undye | 100 | Remove dye from all of your or your target's armor slots |
| #unmemspell | 50 | [Spell ID] - Unmemorize a Spell by ID for you or your target |
| #unmemspells | 50 | Unmemorize all spells for you or your target |
| #unscribespell | 180 | [Spell ID] - Unscribe a spell from your or your target's spell book by Spell ID |
| #unscribespells | 180 | Clear out your or your player target's spell book. |
| #untraindisc | 180 | [Spell ID] - Untrain your or your target's discipline by Spell ID |
| #untraindiscs | 180 | Untrains all disciplines from your target. |
| #wc | 200 | [Slot ID] [Material] [Hero Forge Model] [Elite Material] - Sets the specified slot for you or your target to a material, Hero Forge Model and Elite Material are optional |
| #worldshutdown | 200 | Shut down world and all zones |
| #worldwide | 250 | Performs world-wide GM functions such as cast (can be extended for other commands). Use caution |
| #wp | 170 | [add/delete] [grid_id] [pause] [waypoint_id] [-h] - Add or delete a waypoint by grid ID. (-h to use current heading) |
| #wpadd | 170 | [pause] [-h] - Add your current location as a waypoint to your NPC target's AI path. (-h to use current heading) |
| #zone | 50 | [Zone ID/Zone Short Name] [X] [Y] [Z] - Teleport to specified Zone by ID or Short Name (coordinates are optional) |
| #zonebootup | 150 | [ZoneServerID] [shortname] - Make a zone server boot a specific zone |
| #zoneinstance | 50 | [Instance ID] [X] [Y] [Z] - Teleport to specified Instance by ID (coordinates are optional) |
| #zoneshard | 0 | [zone] [instance_id] - Teleport explicitly to a zone shard |
| #zoneshutdown | 150 | [instance/zone] [Instance ID/Zone ID/Zone Short Name] - Shut down a zone server by Instance ID, Zone ID, or Zone Short Name |
| #zonevariable | 100 | [clear/delete/set/view] - Modify zone variables for your current zone |
| #zsave | 80 | Saves zheader to the database |


## Triptych custom commands

These are additions over stock EQEmu. Where a command touches a data bucket, currency, Discord webhook, or cross-zone signal, the note says so — see also CODEBASE.md for the governing Custom: rules.

### #alttoggle — Player
Toggle the effectiveness of a passive AA by AA ID.

### #award — GMAdmin
Award **Echo of Memory** (account alt-currency id 6). Writes the target character's EoM-Award data bucket, fires a Discord webhook on the admin channel, and sends cross-zone signal 666 to the character name. The actual credit happens in plugin::UpdateEoMAward (NMS_multiclass_utils.pl) on that signal and on zone-in.

### #castspellnms — status 5
Cast a non-detrimental spell from your spellbook while out of combat. Refuses in combat, refuses bard songs, checks level.

### #corpsefix — Player
Brings nearby corpses back up from underneath the ground.

### #disable_seasonal / #seasoninfo — seasonal handlers
Seasonal-character helpers (implemented in zone/gm_commands/seasonal.cpp). #disable_seasonal confirm permanently removes the character from the current season; #seasoninfo shows the active seasonal event.

### #feature / #size — QuestTroupe
Temporarily change your/target's appearance features (Drakkin heritage/beard/beardcolor/face/eyes/hair etc.) or size.

### #gearup — GMMgmt
Developer tool to quickly equip yourself or your target with an armor set by expansion choice.

### #illusion — Player
Store/list/use illusions from clickable items (#illusion store with an illusion item on cursor, #illusion list, #illusion use <id>). Backed by the character_illusions table.

### #illusionblock — Guide
Block or allow illusions landing on you from other players/bots.

### #lootsim — GMImpossible
Benchmark simulator over the real loot logic for an NPC type / loottable id / iterations; reports global-loot and drop data without spawning.

### #soulmark — GMAdmin
Add/remove the account CheaterFlag with a reason (#soulmark Add/Remove [Character] [Reason]).

### #tim — Player
Toggle Improved Models (legacy alias kept for the RoF2 client).

### #zoneinstance / #zoneshard — Guide / Player
#zoneinstance <instance_id> [x y z] teleports to a specific instance by id; #zoneshard [zone] [instance_id] teleports explicitly to a zone shard (respects the Custom:HubZones list, refuses while in combat).

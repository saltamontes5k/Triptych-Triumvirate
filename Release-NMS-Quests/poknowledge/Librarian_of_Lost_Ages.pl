# Librarian_of_Lost_Ages.pl - The Plane of Knowledge
# Progression spoiler NPC: tells players exactly how every expansion's access
# is earned (PoP onward), with live per-account flag status. READ-ONLY: this
# NPC never grants, sets, or checks off any flag itself.
#
# Every claim below was verified against the tree 2026-10-31:
#   stage prereqs / objectives  NMS_progression_utils.pl %STAGE_PREREQUISITES :354-372
#   zone->stage entry gates     NMS_progression_utils.pl %atlas :16-341 (enforced by
#                               global\global_player.pl EVENT_ENTERZONE :43 / CLICKDOOR :312)
#   stage flag grants           each gate boss spawns memory NPC 26000 (global\26000.pl);
#                               hail on the corpse writes the subflag
#   PoP flag web setters        potranquility\*.lua (Adler, Elder Fuirstel, Shadyglade,
#                               Elder Poxbourne, Adroha Jezith), pojustice trials
#                               (201078, 201434-201438 + #Mavuin), poinnovation
#                               (Giwin, Nitram, #Loreseeker_Maelin), potorment
#                               (Saryrn, Keeper of Sorrows), potactics, solrotower,
#                               poair/pofire/powater/poearthb; door checks
#                               potranquility\player.lua :1-126; PoK say teleports
#                               poknowledge\A_Planar_Projection.lua :2-163
#   Time gate                   pop.flags.maelin (poinnovation\#Loreseeker_Maelin.lua:20)
#                               + SoD stage (poknowledge\Herald_of_Druzzil_Ro.lua)
#   GoD chain                   barindu\#High_Priest_Diru_Riwirn.lua (god.flags.sewers),
#                               barindu\#Apprentice_Udranda.lua, vxed\#Stonespiritist_Ekikoa.lua
#                               / tipt\#Master_Stonespiritist_Okkanu.lua (god.flags.kt),
#                               kodtaz\Kevren_Nalavat.pl + kodtaz\Tublik_Narwethar.pl
#                               (god_qvic_access :255), kodtaz\player.lua + yxtta\player.lua
#                               (Qvic enter: items 60176+60252 or god.flags.qvic),
#                               yxtta\#Jerimo_Jiao.lua (Uqua request), qvic\player.lua
#                               (Txevu door 2: item 60254 / god.flags.txevu),
#                               txevu\player.lua (Tacvi expedition)
#   OoW / Anguish               anguish\player.lua (doors 57-61; guardians 317002-317005
#                               Warden Hanvar / Ture / Jelvan / Keldovan the Harrier)
#   LDoN raids                  ecommons\Rujarkian_Scout_Orlo.lua (Drudge Hollows),
#                               ecommons\Uzmanya_Zsiksta.lua (War March of Imal Ojun)
#   TSS gate                    theatera\381015.lua + theatera\#Ayonae_Ro.pl (TSS/deathknell)
#   TBS chain                   direwind\Zhubis_the_Griffon_Tamer.pl (tasks 600022/600013/
#                               600320-322/600360), vergalid\Nurtha_Frazzlesprocket.pl,
#                               direwind\600200.pl (Drizzlorn), ashenate\406150.lua
#   SoF gate                    solteris\Solusek_Ro.pl + solteris\Mayong_Mistmoore.pl
#   SoD gate                    sleeper\#Kerafyrm.pl + crystallos\#Kerafyrm.pl
#   FNagafen gate               potimeb\Quarm.lua; ejection soldungb\player.pl :12-28
#   UF gate                     convorteum\491290.lua (seven-stage controller)
#
# Helper plugins used: NMS_progression_utils.pl, NMS_general.pl.

# ---------------------------------------------------------------------------
# Stage objective tables. Flag keys are the lowercased objective strings used
# by plugin::GetSubflag / %STAGE_PREREQUISITES (NMS_progression_utils.pl:354).
# Labels are for display only. [key, label]
# ---------------------------------------------------------------------------
my %STAGE_OBJECTIVES = (
    'RoK' => [
        ['lord nagafen', 'Lord Nagafen (Nagafen\'s Lair)'],
        ['lady vox',     'Lady Vox (Permafrost)'],
    ],
    'SoV' => [
        ['trakanon',    'Trakanon (Old Sebilis)'],
        ['gorenaire',   'Gorenaire (Dreadlands)'],
        ['severilous',  'Severilous (Emerald Jungle)'],
        ['talendor',    'Talendor (Burning Wood)'],
    ],
    'SoL' => [
        ['klandicar',        'Klandicar (Dragon Necropolis)'],
        ['zlandicar',        'Zlandicar (Dragon Necropolis)'],
        ['wuoshi',           'Wuoshi (Wakening Lands)'],
        ['dozekar the cursed', 'Dozekar the Cursed (Temple of Veeshan)'],
        ['kelorek`dar',      'Kelorek`Dar (Cobaltscar)'],
    ],
    'PoP' => [
        ['thought horror overfiend', 'Thought Horror Overfiend (The Deep)'],
        ['the insanity crawler',     'The Insanity Crawler (Akheva)'],
        ['grieg veneficus',          'Grieg Veneficus (Grieg\'s End)'],
        ['xerkizh the creator',      'Xerkizh the Creator (SSRA Temple)'],
        ['emperor ssraeshza',        'Emperor Ssraeshza (SSRA Temple)'],
    ],
    'GoD' => [
        ['saryrn', 'Saryrn (Plane of Torment)'],
    ],
    'OoW' => [
        ['tunat`muram cuu vauax', 'Tunat`Muram Cuu Vauax (Tacvi)'],
    ],
    'DoN' => [
        ['xegony',                        'Xegony (Plane of Air)'],
        ['fennin ro the tyrant of fire',  'Fennin Ro (Plane of Fire)'],
        ['coirnav the avatar of water',   'Coirnav (Plane of Water)'],
        ['rathe council',                 'Rathe Council (Plane of Earth B)'],
        ['agnarr the storm lord',         'Agnarr (Bastion of Thunder)'],
    ],
    'LDoN' => [
        ['xegony',                        'Xegony (Plane of Air)'],
        ['fennin ro the tyrant of fire',  'Fennin Ro (Plane of Fire)'],
        ['coirnav the avatar of water',   'Coirnav (Plane of Water)'],
        ['rathe council',                 'Rathe Council (Plane of Earth B)'],
        ['agnarr the storm lord',         'Agnarr (Bastion of Thunder)'],
    ],
    'DoD' => [
        ['tunat`muram cuu vauax', 'Tunat`Muram Cuu Vauax (Tacvi)'],
        ['warlord imal ojun',     'Warlord Imal Ojun (Rujarkian raid)'],
    ],
    'PoR' => [
        ['master of hate',           'Master of Hate (MPG trial)'],
        ['master of weaponry',       'Master of Weaponry (MPG trial)'],
        ['master of foresight',      'Master of Foresight (MPG trial)'],
        ['master of specialization', 'Master of Specialization (MPG trial)'],
        ['master of adaptation',     'Master of Adaptation (MPG trial)'],
        ['master of destruction',    'Master of Destruction (MPG trial)'],
        ['anguish',                  'Overlord Mata Muram (Anguish)'],
        ['vishimtar the fallen',     'Vishimtar the Fallen (The Nest)'],
        ['mayong mistmoore dreadspire', 'Mayong Mistmoore (Dreadspire)'],
    ],
    'TSS' => [
        ['deathknell', 'Ayonae Ro (Deathknell, Tower of Dissonance)'],
    ],
    'TBS' => [
        ['dyn`leth', 'Dyn`Leth (Ashengate)'],
    ],
    'SoF' => [
        ['solusek ro',       'Solusek Ro (Solteris)'],
        ['mayong mistmoore', 'Mayong Mistmoore (Solteris)'],
    ],
    'SoD' => [
        ['kerafyrm',           'Kerafyrm (Sleeper\'s Tomb)'],
        ['kerafyrm-crystallos', 'Kerafyrm (Crystallos)'],
    ],
    'FNagafen' => [
        ['quarm', 'Quarm (Plane of Time)'],
    ],
    'UF' => [
        ['the first creation', 'The First Creation (Convorteum)'],
    ],
);

# ---------------------------------------------------------------------------
# Classic PoP pop.flags.* subsets for the PoP sub-topics.
# [bucket key, display label, required value (default 1)]
# ---------------------------------------------------------------------------
my @POP_TRIALS_FLAGS = (
    ['hedge',      'Hedge maze cleared (Thelin Poxbourne)', 1],
    ['construct',  'Thelin Poxbourne (Nightmare)',          1],
    ['terris',     'Terris Thule slain',                    1],
    ['poxbourne',  'Elder Poxbourne (PoT sick bay)',        1],
    ['adler',      'Adler Fuirstel (\'what ward\')',        1],
    ['grummus',    'Grummus slain + projection',            1],
    ['elder',      'Elder Fuirstel (PoT sick bay)',         1],
    ['codecay',    'Carprin event + Bertoxxulous',          2],
    ['bertox',     'Bertoxxulous slain + projection',       1],
    ['mavuin',     'Mavuin (\'information\')',              1],
    ['tribunal',   'Tribunal (\'mavuin sent me\')',         1],
    ['valor',      'Trial run + Mavuin hailed',             1],
    ['xanamech',   'Xanamech (factory key, optional)',      1],
    ['behemoth',   'Manaetic Behemoth + Giwin',             2],
    ['shadyglade', 'Fahlia Shadyglade (\'i will go\')',     1],
    ['newleaf',    'Keeper of Sorrows + Tylis Newleaf',     1],
    ['saryrn',     'Saryrn slain + hailed out fully',       2],
);

my @POP_STORMS_FLAGS = (
    ['askr',    'Askr the Lost giant-collect (1 to 4)', 4],
    ['agnarr',  'Agnarr event + Karana path',           1],
    ['karana',  'Karana hailed (BoT exit)',             1],
    ['aerin',   'Aerin\'Dar slain + projection',        1],
    ['faye',    'HoH Trial: Dragon (Trydan Faye)',      1],
    ['trell',   'HoH Trial: Villagers (Rhaliq Trell)',  1],
    ['garn',    'HoH Trial: Loner (Alekson Garn)',      1],
    ['marr',    'Lord Mithaniel Marr slain + projection', 1],
);

my @POP_TOWER_FLAGS = (
    ['tallon',    'Tallon Zek slain + projection',      1],
    ['vallon',    'Vallon Zek slain + projection',      1],
    ['rallos',    'Rallos Zek the Warlord slain',       1],
    ['librarian', 'Grand Librarian Maelin (PoK lore)',  1],
    ['arlyxir',   'Arlyxir (Tower mini)',               1],
    ['dresolik',  'Protector of Dresolik (Tower mini)', 1],
    ['jiva',      'Jiva (Tower mini)',                  1],
    ['rizlona',   'Rizlona (Tower mini)',               1],
    ['xuzl',      'Xuzl (Tower mini)',                  1],
    ['solusek',   'Solusek Ro slain + projection',      1],
    ['fennin',    'Fennin Ro slain + projection',       1],
    ['xegony',    'Xegony slain + projection',          1],
    ['coirnav',   'Coirnav slain + projection',         1],
    ['arbitor',   'Mystical Arbitor of Earth slain',    1],
    ['rathe',     'Rathe Council slain',                1],
);

my @POP_TIME_FLAGS = (
    ['maelin', 'Loreseeker Maelin (PoI Clocks, \'researched\')', 1],
);

my $MEMORY_NOTE =
    'After each gate kill, hail the planar memory that spawns on the corpse - ' .
    'that hail is what writes the flag to your account.';

# ---------------------------------------------------------------------------
# Menu
# ---------------------------------------------------------------------------
sub show_menu {
    plugin::NPCTell(
        'The roads through the ages, written plain. Name an era and I will lay the whole path bare: ' .
        '[RoK], [SoV], [SoL], [PoP] - or the deep PoP detail: [pop entry], [pop trials], [pop storms], [pop tower], [pop time]. ' .
        'Beyond: [GoD], [OoW], [DoN], [LDoN], [DoD], [PoR], [TSS], [TBS], [SoF], [SoD], [Fabled Nagafen], [Underfoot]. ' .
        'Ask for [My progression] to see where you stand.'
    );
}

# ---------------------------------------------------------------------------
# Status helpers
# ---------------------------------------------------------------------------
sub print_stage_status {
    my ($client, $stage) = @_;
    my $objs = $STAGE_OBJECTIVES{$stage};
    return unless $objs;
    plugin::BlueText("-- $stage gate status (your account) --");
    foreach my $o (@$objs) {
        my ($key, $label) = @$o;
        if (plugin::GetSubflag($client, $stage, $key)) {
            plugin::BlueText("  Completed: $label");
        } else {
            plugin::YellowText("  Still needed: $label");
        }
    }
}

sub print_bucket_flags {
    my ($client, $title, $flags) = @_;
    plugin::BlueText("-- $title (your account) --");
    foreach my $f (@$flags) {
        my ($key, $label, $req) = @$f;
        my $val = $client->GetAccountBucket("pop.flags.$key");
        $val = defined $val ? int($val) : 0;
        if ($val >= $req) {
            plugin::BlueText("  Completed: $label");
        } else {
            plugin::YellowText("  Still needed: $label" . ($req > 1 ? " (flag $val/$req)" : ""));
        }
    }
}

sub popup {
    my ($title, $body) = @_;
    quest::popup($title, $body, 0, 0, 0);
}

# ---------------------------------------------------------------------------
# EVENT_SAY
# ---------------------------------------------------------------------------
sub EVENT_SAY {
    plugin::ConvertFlags($client);

    if ($text =~ /^my progression$|^progression$|^status$/i) {
        plugin::list_unlock_progress($client);
        plugin::YellowText($MEMORY_NOTE);
        return;
    }

    if ($text =~ /^hail$/i) {
        show_menu();
        return;
    }

    if ($text =~ /^rok$/i) {
        popup('Ruins of Kunark',
            '<c "#FFD700">Ruins of Kunark</c><br>' .
            'RoK lands are open from the start; the stage flag is earned from two dragons.<br><br>' .
            '1. Kill <c "#FFA500">Lord Nagafen</c> in Nagafen\'s Lair (Solusek B). Bring fire resist gear; the giants send aid.<br>' .
            '2. Kill <c "#FFA500">Lady Vox</c> in Permafrost Keep. Ice resists.<br><br>' .
            'Hail the planar memory on each corpse.');
        print_stage_status($client, 'RoK');
        plugin::YellowText($MEMORY_NOTE);
        return;
    }

    if ($text =~ /^sov$/i) {
        popup('Scars of Velious',
            '<c "#FFD700">Scars of Velious</c><br>' .
            'Four dragons, each spawns a planar memory:<br>' .
            '1. <c "#FFA500">Trakanon</c> - Old Sebilis.<br>' .
            '2. <c "#FFA500">Gorenaire</c> - Dreadlands.<br>' .
            '3. <c "#FFA500">Severilous</c> - Emerald Jungle.<br>' .
            '4. <c "#FFA500">Talendor</c> - Burning Wood.<br><br>' .
            'Velious zones (Iceclad, Cobaltscar, Temple of Veeshan, Sleeper\'s Tomb...) open with this stage.');
        print_stage_status($client, 'SoV');
        plugin::YellowText($MEMORY_NOTE);
        return;
    }

    if ($text =~ /^sol$/i) {
        popup('Shadows of Luclin',
            '<c "#FFD700">Shadows of Luclin</c><br>' .
            'Five kills; each spawns a planar memory:<br>' .
            '1. <c "#FFA500">Klandicar</c> and <c "#FFA500">Zlandicar</c> - Dragon Necropolis.<br>' .
            '2. <c "#FFA500">Wuoshi</c> - Wakening Lands.<br>' .
            '3. <c "#FFA500">Dozekar the Cursed</c> - Temple of Veeshan.<br>' .
            '4. <c "#FFA500">Kelorek`Dar</c> - Cobaltscar.<br><br>' .
            'This stage opens the Planes of Power.');
        print_stage_status($client, 'SoL');
        plugin::YellowText($MEMORY_NOTE);
        return;
    }

    if ($text =~ /^pop$/i && $text !~ /entry|trials|storms|tower|time/i) {
        popup('Planes of Power - entry',
            '<c "#FFD700">Planes of Power</c><br>' .
            'Entry = finishing Luclin\'s endgame, five capstone kills:<br>' .
            '1. <c "#FFA500">Thought Horror Overfiend</c> - The Deep.<br>' .
            '2. <c "#FFA500">The Insanity Crawler</c> - Akheva Ruins.<br>' .
            '3. <c "#FFA500">Grieg Veneficus</c> - Grieg\'s End.<br>' .
            '4. <c "#FFA500">Xerkizh the Creator</c> - SSRA Temple.<br>' .
            '5. <c "#FFA500">Emperor Ssraeshza</c> - SSRA Temple.<br><br>' .
            'Alternate \'explorer\' path: bring the Bazaar\'s <c "#87CEEB">A Planar Projection</c> four rare collectibles (or an explorer token) and it flags all five.<br><br>' .
            'Deep detail: [pop entry], [pop trials], [pop storms], [pop tower], [pop time].');
        print_stage_status($client, 'PoP');
        plugin::YellowText($MEMORY_NOTE);
        return;
    }

    if ($text =~ /^pop entry$/i) {
        popup('PoP: getting around',
            '<c "#FFD700">PoP: travel and the inner gates</c><br>' .
            'Once the stage is unlocked: PoK portal to <c "#87CEEB">Plane of Tranquility</c> (the hub).<br><br>' .
            'The four outer planes (Justice, Disease, Innovation, Nightmare) are open; their doors in PoTranquility and the PoK <c "#87CEEB">Planar Projection</c> teleports check your flags.<br><br>' .
            'Say-phrases at the PoK Planar Projection port you once flags allow, e.g. \'I will defeat Saryrn\' to Torment, \'I am worthy of the elemental planes\' to the elementals.<br><br>' .
            'The full flag web: [pop trials], [pop storms], [pop tower], [pop time].');
        return;
    }

    if ($text =~ /^pop trials$/i) {
        popup('PoP: the flag web (early)',
            '<c "#FFD700">PoP: early planes</c><br>' .
            '<c "#FFA500">Justice:</c> hail Mavuin, say \'information\'. Run ONE of the six trials (Execution, Flame, Hanging, Lashing, Stoning, Torture), loot the Mark, say \'mavuin sent me\' to The Tribunal, then hail Mavuin again.<br>' .
            '<c "#FFA500">Disease:</c> say \'what ward\' to Adler Fuirstel in PoT. Kill Grummus, hail the projection.<br>' .
            '<c "#FFA500">Nightmare:</c> hail Adroha Jezith (\'tortured by nightmares\'), run the Hedge Maze, hail Thelin Poxbourne, kill Terris Thule, hail the projection, hail Elder Poxbourne in PoT.<br>' .
            '<c "#FFA500">Innovation:</c> say \'I will test the machine\' to Giwin Mirakon behind the factory door, kill Manaetic Behemoth, hail Giwin. (Xanamech is the optional key kill.)<br>' .
            '<c "#FFA500">Crypt of Decay:</c> hail Elder Fuirstel in PoT sick bay (needs Grummus). Clear the Carprin event, hail Tarkil Adan. Kill Bertoxxulous, hail the projection, hail Elder Fuirstel again.<br>' .
            '<c "#FFA500">Torment:</c> say \'i will go\' to Fahlia Shadyglade. Keeper of Sorrows event, hail Tylis Newleaf. Kill Saryrn, hail the projection, then hail Shadyglade and Tylis again.<br><br>' .
            '<c "#FF0000">This same Saryrn flag is the gate to the Gates of Discord.</c>');
        print_bucket_flags($client, 'PoP early flags', \@POP_TRIALS_FLAGS);
        return;
    }

    if ($text =~ /^pop storms$/i) {
        popup('PoP: Storms, Valor, BoT, Honor',
            '<c "#FFD700">PoP: middle planes</c><br>' .
            '<c "#FFA500">Storms:</c> do Askr the Lost\'s giant-collect quest in PoStorms (askr 1 to 4) for the Talisman, then click the center stone into Bastion of Thunder.<br>' .
            '<c "#FFA500">Valor:</c> kill Aerin\'Dar, hail the projection. The tunnel from PoValor leads to Halls of Honor (first entry must be from PoValor).<br>' .
            '<c "#FFA500">Bastion of Thunder:</c> run the Agnarr event, then say \'I will follow the path of the Fallen.\' to Karana.<br>' .
            '<c "#FFA500">Halls of Honor:</c> three trials - Dragon (hail Trydan Faye), Villagers (Rhaliq Trell), the lone villager (Alekson Garn).<br>' .
            '<c "#FFA500">Temple of Marr:</c> kill Lord Mithaniel Marr, hail the projection.<br><br>' .
            'Elemental plane access: [pop tower].');
        print_bucket_flags($client, 'PoP middle flags', \@POP_STORMS_FLAGS);
        return;
    }

    if ($text =~ /^pop tower$/i) {
        popup('PoP: Tower of Solusek Ro & elementals',
            '<c "#FFD700">PoP: Tower and elementals</c><br>' .
            '<c "#FFA500">Tactics:</c> kill Vallon Zek, Tallon Zek, then Rallos Zek the Warlord (projections on each).<br>' .
            '<c "#FFA500">Tower of Solusek Ro:</c> five minis - Xuzl, Arlyxir, Jiva, Rizlona, The Protector of Dresolik - click each mini\'s stone. Requires all flags through Rallos. Then Solusek Ro himself + projection; drop into the lava pit to Plane of Fire.<br>' .
            '<c "#FFA500">Elementals:</c> the door needs the full flag list. Kills: Fennin Ro (Fire), Xegony (Air - Wind Etched Key to the island), Coirnav (Water), and Earth: clear the four ring events in PoEarth A, kill the Mystical Arbitor of Earth, then the Rathe Council in PoEarth B.<br><br>' .
            '<c "#00FF00">Every elemental god kill also grants the Dragons of Norrath AND LDoN stage.</c>');
        print_bucket_flags($client, 'PoP tower/elemental flags', \@POP_TOWER_FLAGS);
        return;
    }

    if ($text =~ /^pop time$/i) {
        popup('PoP: Plane of Time',
            '<c "#FFD700">PoP: Time - two gates, both required</c><br>' .
            '<c "#FFA500">1. The maelin flag:</c> gather the four elemental essences from the god projections and combine them in an Odylic Vial into the Quintessence of Elements. Carry it to Loreseeker Maelin in Plane of Innovation, say \'researched\', then click the clock machine - that writes your Plane of Time zone flag.<br>' .
            '<c "#FFA500">2. The Herald of Druzzil Ro (PoK):</c> she ports you into Time, but only once the <c "#FF0000">Seeds of Destruction stage is complete (both Kerafyrm kills)</c> - and you must already hold the Time zone flag from step 1.<br><br>' .
            'SoD requirements: [SoD].');
        print_bucket_flags($client, 'PoP Time flag', \@POP_TIME_FLAGS);
        return;
    }

    if ($text =~ /^god$/i) {
        popup('Gates of Discord',
            '<c "#FFD700">Gates of Discord</c><br>' .
            '<c "#FFA500">Entry:</c> kill <c "#FF0000">Saryrn</c> in Plane of Torment (see [pop trials]) and hail the memory. Travel: Magic Map stones (Natimbi, Barindu, Kod\'Taz, Qvic, Txevu).<br>' .
            '<c "#FFA500">Kod\'Taz access:</c> Barindu - High Priest Diru Riwirn gives four sewer instances in order (Purifying Plant, Crematory, Lair of the Trapped Ones, Pools of Sludge). Shortcut: beat the Weapon Master in Ferubi and Scribe Gurru skips them. Then Apprentice Udranda gives the Vxed instance; hail Stonespiritist Ekikoa inside, take the obelisk out to Kod\'Taz. (Tipt and Master Okkanu is the second route.)<br>' .
            '<c "#FFA500">Qvic access:</c> Kod\'Taz - Kevren Nalavat: three Ikkinz group trials, then the three tasks (Martyr\'s Passage, Pit of the Lost, Crumbled Sanctuary), then the three Ikkinz raids. Turn-ins to Tublik Narwethar. Icon of the Altar to the Sentinel of the Altar, run Chambers of Destruction, loot the Sliver, return it to Tublik. Uqua raid (request from Jerimo Jiao in Yxtta), hail the Specter of Barxt for the Fragment. With Sliver + Fragment, zone into Qvic from Kod\'Taz or Yxtta.<br>' .
            '<c "#FFA500">Onward:</c> Inktu\'Ta expedition, hail An Ancient Sentinel for the Splinter. Brevik Kalaner (Abysmal Sea) combines Sliver + Fragment + Splinter into the Cipher of Txevu, which opens Txevu from Qvic. Request Tacvi in Txevu.<br>' .
            '<c "#FF0000">Kill Tunat`Muram Cuu Vauax -> memory = Omens of War (and half of Darkhollow).</c>');
        print_stage_status($client, 'GoD');
        plugin::YellowText($MEMORY_NOTE);
        return;
    }

    if ($text =~ /^oow$/i) {
        popup('Omens of War',
            '<c "#FFD700">Omens of War</c><br>' .
            '<c "#FFA500">Entry:</c> Tunat`Muram Cuu Vauax dies in Tacvi (see [GoD]) and the memory unlocks Omens. Travel: the Priest of Discord in PoK ports to Dranik\'s Scar; Magic Map stones (Wall of Slaughter, Bloodfields, Proving Grounds...).<br>' .
            '<c "#FFA500">Muramite Proving Grounds:</c> six single-group trials, requested from the six Projections (Arcana, Body, Mind, Power, Realms, Tactics). Each grants a resist-AA; all six are REQUIRED for Prophecy of Ro later.<br>' .
            '<c "#FFA500">Anguish raid:</c> kill Warden Hanvar, Ture, Jelvan and Keldovan the Harrier - the seal to the upper platform opens only when all four are dead. <c "#FF0000">Overlord Mata Muram</c> waits at the top and is required for Prophecy of Ro.');
        print_stage_status($client, 'OoW');
        plugin::YellowText($MEMORY_NOTE);
        return;
    }

    if ($text =~ /^don$/i) {
        popup('Dragons of Norrath',
            '<c "#FFD700">Dragons of Norrath</c><br>' .
            '<c "#FFA500">Gate:</c> the five elemental gods of PoP - Xegony (Air), Fennin Ro (Fire), Coirnav (Water), the Rathe Council (Earth B) and Agnarr (Bastion of Thunder). See [pop tower] for how to reach each. Each memory grants DoN and LDoN at once.<br>' .
            '<c "#FFA500">Travel:</c> the DoN Porter in Lavastorm; the Nest opens with this stage (Vishimtar there is a Prophecy of Ro requirement).');
        print_stage_status($client, 'DoN');
        plugin::YellowText($MEMORY_NOTE);
        return;
    }

    if ($text =~ /^ldon$/i) {
        popup('Lost Dungeons of Norrath',
            '<c "#FFD700">Lost Dungeons of Norrath</c><br>' .
            '<c "#FFA500">Gate:</c> the same five elemental gods as DoN (see [pop tower]). The Wayfarer camps open at the DoN stage.<br>' .
            '<c "#FFA500">Camps:</c> South Ro - Rujarkian Scout Orlo (Drudge Hollows) and Uzmanya Zsiksta (War March of Imal Ojun). East Commons, Butcherblock and Everfrost hold the other camps.<br>' .
            '<c "#FF0000">The War March of Imal Ojun raid is the second half of the Depths of Darkhollow gate - do not skip it.</c>');
        print_stage_status($client, 'LDoN');
        return;
    }

    if ($text =~ /^dod$/i) {
        popup('Depths of Darkhollow',
            '<c "#FFD700">Depths of Darkhollow</c><br>' .
            '<c "#FFA500">Gate (two kills):</c> <c "#FF0000">Tunat`Muram Cuu Vauax</c> (Tacvi - see [GoD]) and <c "#FF0000">Warlord Imal Ojun</c> (the LDoN Rujarkian raid, requested from Uzmanya Zsiksta in South Ro).<br>' .
            '<c "#FFA500">Travel:</c> the DoD Porter in Nektulos. Darkhollow zones include Dreadspire, where <c "#FF0000">Mayong Mistmoore</c> waits - another Prophecy of Ro requirement.');
        print_stage_status($client, 'DoD');
        plugin::YellowText($MEMORY_NOTE);
        return;
    }

    if ($text =~ /^por$/i) {
        popup('Prophecy of Ro',
            '<c "#FFD700">Prophecy of Ro</c><br>' .
            'Four threads, all required:<br>' .
            '<c "#FFA500">1. MPG trials:</c> clear all six Muramite Proving Ground trials (see [OoW]) - Masters of Hate, Weaponry, Foresight, Specialization, Adaptation, Destruction.<br>' .
            '<c "#FFA500">2. Anguish:</c> kill the Overlord Mata Muram (see [OoW]).<br>' .
            '<c "#FFA500">3. The Nest:</c> run the \'In the Shadows\' event - Vishimtar the Fallen.<br>' .
            '<c "#FFA500">4. Dreadspire:</c> kill Mayong Mistmoore.<br><br>' .
            'This stage opens Deathknell, Tower of Dissonance.');
        print_stage_status($client, 'PoR');
        plugin::YellowText($MEMORY_NOTE);
        return;
    }

    if ($text =~ /^tss$/i) {
        popup('The Serpent\'s Spine',
            '<c "#FFD700">The Serpent\'s Spine</c><br>' .
            '<c "#FFA500">Gate - one kill:</c> <c "#FF0000">Ayonae Ro</c>, final encounter of Deathknell, Tower of Dissonance (the zone opens at the Prophecy of Ro stage).<br><br>' .
            'The stage opens the Spine\'s zones: Steppes of Ruin, Sunderock Springs, Blackfeather Roost, the Foundation, Icefall, Valdeholm, Frostcrypt, Vergalid Mines, Direwind Cliffs and Ashengate - all of which feed The Buried Sea.');
        print_stage_status($client, 'TSS');
        plugin::YellowText($MEMORY_NOTE);
        return;
    }

    if ($text =~ /^tbs$/i) {
        popup('The Buried Sea',
            '<c "#FFD700">The Buried Sea</c><br>' .
            'A custom access arc; run it in order from the Spine\'s zones:<br>' .
            '<c "#FFA500">1. The Pretender:</c> Zhubis the Griffon Tamer (Direwind Cliffs) sends you into the Vergalid Mines instance to kill Nurtha Frazzlesprocket - \'Dyn`leth is no god - he is a machine\'.<br>' .
            '<c "#FFA500">2.</c> Finish Captain Zheren\'s task in Sunderock Springs.<br>' .
            '<c "#FFA500">3. Infiltrators arc:</c> back to Zhubis for Sabotage, Project Disarm and The Weakest Link.<br>' .
            '<c "#FFA500">4. Locate Drizzlorn</c> (Direwind Cliffs) - he opens Ashengate once BOTH wings of the Reliquary have fallen.<br>' .
            '<c "#FF0000">5. Kill Dyn`Leth</c> in Ashengate -> memory = The Buried Sea. (Travel after: the TBS Porter in Toxxulia; Magic Map stones for Buried Sea and Katta Castrum.)');
        print_stage_status($client, 'TBS');
        plugin::YellowText($MEMORY_NOTE);
        return;
    }

    if ($text =~ /^sof$/i) {
        popup('Secrets of Faydwer',
            '<c "#FFD700">Secrets of Faydwer</c><br>' .
            '<c "#FFA500">Gate:</c> enter <c "#87CEEB">Solteris</c> (the raid zone unlocked at the Buried Sea stage) and kill both gods: <c "#FF0000">Solusek Ro</c> and <c "#FF0000">Mayong Mistmoore</c>.<br><br>' .
            '<c "#FF0000">Note:</c> the memory that spawns off Dyn`Leth mentions Faydwer but does NOT count for this stage - only the Solteris pair does.<br><br>' .
            'Faydwer zones (Dragonscale Hills, Crystallos...) open with the stage.');
        print_stage_status($client, 'SoF');
        plugin::YellowText($MEMORY_NOTE);
        return;
    }

    if ($text =~ /^sod$/i) {
        popup('Seeds of Destruction',
            '<c "#FFD700">Seeds of Destruction</c><br>' .
            '<c "#FFA500">Gate - two Sleepers:</c><br>' .
            '1. <c "#FF0000">Kerafyrm</c> in the original Sleeper\'s Tomb (a Velious-era zone - yes, you go back).<br>' .
            '2. <c "#FF0000">Kerafyrm</c> in Crystallos (Faydwer).<br><br>' .
            '<c "#00FF00">The SoD stage also re-opens the Plane of Time</c> - the PoK Herald of Druzzil Ro requires it (see [pop time]).<br>' .
            'Deeper SoD content (Korafax, the Citadel of the Worldslayer, mercenary tiers) runs on its own task chains - ask in-game.');
        print_stage_status($client, 'SoD');
        plugin::YellowText($MEMORY_NOTE);
        return;
    }

    if ($text =~ /^fabled nagafen$/i) {
        popup('Fabled Nagafen\'s Lair',
            '<c "#FFD700">Fabled Nagafen\'s Lair</c><br>' .
            '<c "#FFA500">Gate:</c> kill <c "#FF0000">Quarm</c> at the end of the Plane of Time.<br><br>' .
            'The fabled (v1) expeditions of Solusek B - where Lord Fabled Nagafen himself lives - eject anyone without the Quarm flag.');
        print_stage_status($client, 'FNagafen');
        plugin::YellowText($MEMORY_NOTE);
        return;
    }

    if ($text =~ /^underfoot$/i) {
        popup('Underfoot',
            '<c "#FFD700">Underfoot</c><br>' .
            '<c "#FFA500">Gate:</c> <c "#87CEEB">Convorteum</c> (opens at the SoD stage) - seven sequential raid stages, from the Gatekeeper through the Magus Sisters, ending at <c "#FF0000">The First Creation</c>.<br><br>' .
            'The memory off the First Creation is the last stage flag the Librarian knows of.');
        print_stage_status($client, 'UF');
        plugin::YellowText($MEMORY_NOTE);
        return;
    }

    show_menu();
}

sub EVENT_ITEM {
    plugin::return_items(\%itemcount);
}

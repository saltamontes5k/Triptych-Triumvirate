# Librarian_of_Lost_Ages.pl - The Plane of Knowledge
# Progression spoiler NPC: tells players exactly how every expansion's access
# is earned (PoP onward), with live per-account flag status. READ-ONLY: this
# NPC never grants, sets, or checks off any flag itself. Players who have not
# unlocked PoP get one deny line - the guides assume you are past Luclin.
#
# Every claim below was verified against this tree 2026-10-31 (v2 rewrite):
#   stage prereqs / objectives   NMS_progression_utils.pl %STAGE_PREREQUISITES :354-372
#   zone->stage entry gates      %atlas :16-341 (enforced by global_player.pl :43/:312)
#   stage flag grants            gate boss spawns memory NPC 26000 (global\26000.pl)
#   PoP flag web                 potranquility\*.lua setters; door table
#                                potranquility\player.lua :1-126; PoK Projection
#                                say-phrases poknowledge\A_Planar_Projection.lua :2-163
#   PoP Askr/BoT chain           postorms\Askr_the_Lost.lua (heads 11486/28749/28781/
#                                28782 -> askr 1; Bag of Verity 17192; combine 11487 ->
#                                askr 3; combine 11488 consumed -> askr 4);
#                                postorms\player.lua :3-18 (door 4 = BoT flag);
#                                bothunder\player.lua :37-100 (Symbol of Torden 9433 =
#                                Agnarr tower door 51; Ring of Torden 9425 = corner
#                                towers 61/63/65/67; gargoyles on fail);
#                                bothunder\Karana.lua ("follow the path of the fallen",
#                                "send me on my path")
#   Time gate                    poinnovation\#Loreseeker_Maelin.lua:20 (pop.flags.maelin)
#                                + poknowledge\Herald_of_Druzzil_Ro.lua (SoD stage)
#   GoD chain                    barindu\#High_Priest_Diru_Riwirn.lua (sewers task, four
#                                Sewers of Nihilia expeditions in order);
#                                barindu\Scribe_Gurru.lua ("issues" skip/fix);
#                                barindu\#Apprentice_Udranda.lua (Vxed/Tipt tasks);
#                                vxed\#Stonespiritist_Ekikoa.lua / tipt\#Master_
#                                Stonespiritist_Okkanu.lua (god.flags.kt, obelisk doors
#                                vxed 7 / tipt 5); kodtaz\Kevren_Nalavat.pl (three
#                                temples in order + three tasks + raid trials);
#                                kodtaz\Tublik_Narwethar.pl (Icon 60173, Sliver turn-in
#                                :249-255 -> god_qvic_access); kodtaz\player.lua +
#                                yxtta\player.lua (Qvic enter: Sliver 60176 + Fragment
#                                60252 or god.flags.qvic); yxtta\#Jerimo_Jiao.lua (Uqua);
#                                qvic\player.lua (Txevu door 2: Cipher 60254 or
#                                god.flags.txevu); txevu\player.lua (Tacvi expedition)
#   OoW / MPG                    provinggrounds\Projection_of_*.lua (trial enrollment
#                                say-links; small-scale=group, large-scale=raid);
#                                anguish\player.lua (guardians 317002-317005 Warden
#                                Hanvar/Ture/Jelvan/Keldovan; Arch Magus Vangl 317107;
#                                seal door 61)
#   LDoN raids                   ecommons\Rujarkian_Scout_Orlo.lua (Drudge Hollows),
#                                ecommons\Uzmanya_Zsiksta.lua (War March of Imal Ojun),
#                                butcher\Kroggl.lua (Mistmoore's Catacombs), everfrost\
#                                Miragul_Scout_Vosk.lua (Miragul's Menagerie) - flow:
#                                hail -> "problem" -> "interested" -> "ready"
#   DoD / Dreadspire             corathus\#Treddlehoop.lua + lua_modules\dodh_helper.lua
#                                (tasks 505745-505749, 505762; device 88005, monocle
#                                88001); gate Tunat + Imal Ojun
#   PoR / Deathknell             lua_modules\por_helper.lua (chime items 36144/84159-
#                                84168, por.harmonic_dissonance, por.deathknell);
#                                arcstone\369011.lua (Arch Mage Galsin restores chime);
#                                theater\380000.lua Eodue the Pure (inspirations
#                                52594-52599 from companions Cassindra/Denon/Ervaj/
#                                Jonthan/Rizlona/Tuyen; "what curse"/"what source";
#                                Deathknell expedition)
#   TBS arcs                     kattacastrum\Prime_Researcher_Elnot_Waymun.pl (Solteris
#                                arc 625050-625063, ring 79901, "guidance"/"pursue");
#                                direwind\Zhubis_the_Griffon_Tamer.pl (600022/600013/
#                                600320-322/600360); vergalid\Nurtha_Frazzlesprocket.pl;
#                                sunderock\#Captain_Zheren.pl; direwind\600200.pl;
#                                ashenate\406150.lua (Dyn`Leth)
#   SoF gate                     solteris\Solusek_Ro.pl + solteris\Mayong_Mistmoore.pl
#   SoD gate                     sleeper\1520000010.pl (Keeper of the Tomb / Sleeper_
#                                Tomb_Gatekeeper: hail -> "tomb" -> expedition v1);
#                                sleeper\#Kerafyrm.pl; crystallos\#Kerafyrm.pl + wing
#                                bosses (Zeixshi`Kar 446212 etc.)
#   FNagafen gate                potimeb\Quarm.lua; ejection soldungb\player.pl :12-28
#                                (v1 expeditions eject non-Quarm accounts)
#   UF gate                      convorteum\491290.lua (seven stages, 72h per-stage
#                                lockouts); requester script brellsrest\480260.lua
#                                (NOTE: no spawn row in live DB at time of writing -
#                                see chat report)
#
# Helper plugins: NMS_progression_utils.pl, NMS_general.pl.

# ---------------------------------------------------------------------------
# Stage objectives (PoP onward). Keys are the lowercased objective strings
# used by plugin::GetSubflag / %STAGE_PREREQUISITES. [key, label]
# ---------------------------------------------------------------------------
my %STAGE_OBJECTIVES = (
    'PoP' => [
        ['thought horror overfiend', 'Thought Horror Overfiend (The Deep)'],
        ['the insanity crawler',     'The Insanity Crawler (Akheva Ruins)'],
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
        ['xegony',                       'Xegony (Plane of Air)'],
        ['fennin ro the tyrant of fire', 'Fennin Ro (Plane of Fire)'],
        ['coirnav the avatar of water',  'Coirnav (Plane of Water)'],
        ['rathe council',                'Rathe Council (Plane of Earth B)'],
        ['agnarr the storm lord',        'Agnarr (Bastion of Thunder)'],
    ],
    'LDoN' => [
        ['xegony',                       'Xegony (Plane of Air)'],
        ['fennin ro the tyrant of fire', 'Fennin Ro (Plane of Fire)'],
        ['coirnav the avatar of water',  'Coirnav (Plane of Water)'],
        ['rathe council',                'Rathe Council (Plane of Earth B)'],
        ['agnarr the storm lord',        'Agnarr (Bastion of Thunder)'],
    ],
    'DoD' => [
        ['tunat`muram cuu vauax', 'Tunat`Muram Cuu Vauax (Tacvi)'],
        ['warlord imal ojun',     'Warlord Imal Ojun (Rujarkian raid)'],
    ],
    'PoR' => [
        ['master of hate',              'Master of Hate (MPG raid trial)'],
        ['master of weaponry',          'Master of Weaponry (MPG raid trial)'],
        ['master of foresight',         'Master of Foresight (MPG raid trial)'],
        ['master of specialization',    'Master of Specialization (MPG raid trial)'],
        ['master of adaptation',        'Master of Adaptation (MPG raid trial)'],
        ['master of destruction',       'Master of Destruction (MPG raid trial)'],
        ['anguish',                     'Overlord Mata Muram (Anguish)'],
        ['vishimtar the fallen',        'Vishimtar the Fallen (The Nest)'],
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
        ['kerafyrm',            'Kerafyrm (Sleeper\'s Tomb)'],
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
    ['askr',   'Askr the Lost chain (giant head to medallion)', 4],
    ['agnarr', 'Agnarr event + projection',                     1],
    ['karana', 'Karana (\'follow the path of the fallen\')',    1],
    ['aerin',  'Aerin\'Dar slain + projection',                 1],
    ['faye',   'HoH Trial: Dragon (Trydan Faye)',               1],
    ['trell',  'HoH Trial: Villagers (Rhaliq Trell)',           1],
    ['garn',   'HoH Trial: Loner (Alekson Garn)',               1],
    ['marr',   'Lord Mithaniel Marr slain + projection',        1],
);

my @POP_TOWER_FLAGS = (
    ['tallon',    'Tallon Zek slain + projection',        1],
    ['vallon',    'Vallon Zek slain + projection',        1],
    ['rallos',    'Rallos Zek the Warlord slain',         1],
    ['librarian', 'Grand Librarian Maelin (PoK lore)',    1],
    ['arlyxir',   'Arlyxir (Tower mini)',                 1],
    ['dresolik',  'Protector of Dresolik (Tower mini)',   1],
    ['jiva',      'Jiva (Tower mini)',                    1],
    ['rizlona',   'Rizlona (Tower mini)',                 1],
    ['xuzl',      'Xuzl (Tower mini)',                    1],
    ['solusek',   'Solusek Ro slain + projection',        1],
    ['fennin',    'Fennin Ro slain + projection',         1],
    ['xegony',    'Xegony slain + projection',            1],
    ['coirnav',   'Coirnav slain + projection',           1],
    ['arbitor',   'Mystical Arbitor of Earth slain',      1],
    ['rathe',     'Rathe Council slain',                  1],
);

my @POP_TIME_FLAGS = (
    ['maelin', 'Loreseeker Maelin (PoI Clocks, \'researched\')', 1],
);

my @GOD_BUCKETS = (
    ['god.flags.sewers', 'Barindu sewers done (Diru Riwirn / Gurru)',       1],
    ['god.flags.kt',     'Vxed or Tipt stonespiritist hailed (Kod\'Taz)',   1],
    ['god.flags.qvic',   'Qvic barrier broken (Sliver + Fragment)',         1],
    ['god.flags.txevu',  'Txevu ciphered (Splinter + Brevik)',              1],
);

my $MEMORY_NOTE =
    'After each gate kill, hail the planar memory that spawns on the corpse - ' .
    'that hail is what writes the flag to your account.';

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
sub show_menu {
    plugin::NPCTell(
        'The roads through the ages, written plain. Name an era and I will lay the whole path bare: ' .
        '[PoP] - or the deep PoP detail: [pop entry], [pop trials], [pop storms], [pop tower], [pop time]. ' .
        'Beyond: [GoD], [OoW], [DoN], [LDoN], [DoD], [PoR], [TSS], [TBS], [SoF], [SoD], [Fabled Nagafen], [Underfoot]. ' .
        'Ask for [My progression] to see where you stand.'
    );
}

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
    my ($client, $title, $flags, $prefix) = @_;
    $prefix = 'pop.flags.' unless defined $prefix;
    plugin::BlueText("-- $title (your account) --");
    foreach my $f (@$flags) {
        my ($key, $label, $req) = @$f;
        my $val = $client->GetAccountBucket("$prefix$key");
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

    unless (plugin::is_stage_complete($client, 'PoP')) {
        plugin::NPCTell('The roads through the ages are written plain upon my shelves - but they open past the Planes of Power. Walk further before my books mean anything to you.');
        return;
    }

    if ($text =~ /^my progression$|^progression$|^status$/i) {
        plugin::list_unlock_progress($client);
        plugin::YellowText($MEMORY_NOTE);
        return;
    }

    if ($text =~ /^hail$/i) {
        show_menu();
        return;
    }

    # ----------------------------------------------------------------- PoP
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
        popup('PoP: travel & fixing flags',
            '<c "#FFD700">Planes of Power: travel</c><br>' .
            'The hub is <c "#87CEEB">Plane of Tranquility</c> (PoK portal). Every door there and every teleport from the <c "#87CEEB">Planar Projection in PoK</c> checks your flags. Say the exact phrase to the PoK Projection and it ports you once the flags match - word for word:<br><br>' .
            '"Darkness Beckons" -> PoNightmare B (Terris\' lair) - construct, hedge<br>' .
            '"the war drums echo" -> Plane of Tactics - behemoth<br>' .
            '"I will destroy the plaguebringer" -> Crypt of Decay - adler, elder, grummus<br>' .
            '"I am familiar with the order" -> PoStorms + PoValor - mavuin, tribunal, valor<br>' .
            '"My Valor is Unmatched" -> Halls of Honor - + aerin<br>' .
            '"I will defeat the Storm Lord" -> Bastion of Thunder - askr 4 + trial line<br>' .
            '"I am ready to face Lord Mithaniel Marr" -> Temple of Marr - + faye, trell, garn<br>' .
            '"I will defeat Saryrn" -> Plane of Torment - the full disease/nightmare web, codecay at 2<br>' .
            '"No gladiator shall match me" -> Tower of Solusek Ro - behemoth 2, saryrn 2, marr, tallon, vallon<br>' .
            '"I am a child of fire" -> Plane of Fire - + the five Tower minis, rallos, solusek<br>' .
            '"I am worthy of the elemental planes" -> Air + Water + Earth - the full 22-flag list, see [pop tower]<br><br>' .
            'The PoTranquility doors check the same flags, so either entrance works.<br><br>' .
            '<c "#FFA500">If a flag will not take:</c> hail <c "#87CEEB">Grand Librarian Maelin</c> (top of the PoK library) and say "what lore", then "what information" - repeat. Then the Seer beside me: sit, say "guided meditation", then "unlock my memories" until she has none left. Ping-pong between them two or three rounds; out-of-order flags only resolve this way.');
        return;
    }

    if ($text =~ /^pop trials$/i) {
        popup('PoP: the flag web (early planes)',
            '<c "#FFD700">PoP: early planes</c><br>' .
            '<c "#FFA500">Justice:</c> hail Mavuin, say "information". Run ONE of the six trials (Execution, Flame, Hanging, Lashing, Stoning, Torture), loot the Mark off the trial boss, then say <c "#00FF00">"mavuin sent me"</c> to The Tribunal in the trial room. Return to Mavuin and hail him. This trial line gates almost everything later - do it first.<br>' .
            '<c "#FFA500">Disease:</c> outside the PoDisease entrance say <c "#00FF00">"what ward"</c> to Adler Fuirstel. Kill Grummus, hail the Planar Projection on his corpse.<br>' .
            '<c "#FFA500">Nightmare:</c> in PoTranquility\'s sick bay hail Adroha Jezith, say "tortured by nightmares". Run the Hedge Maze; hail Thelin Poxbourne at the end. Kill Terris Thule (PoNightmare B), hail the projection. Then hail Elder Poxbourne back in PoTranquility.<br>' .
            '<c "#FFA500">Innovation:</c> say <c "#00FF00">"I will test the machine"</c> to Giwin Mirakon (behind the factory door - Xanamech is the optional key kill), kill Manaetic Behemoth, hail Giwin.<br>' .
            '<c "#FFA500">Crypt of Decay:</c> hail Elder Fuirstel in PoT sick bay (needs Grummus). Clear the Carprin event, hail Tarkil Adan. Kill Bertoxxulous, hail the projection, hail Elder Fuirstel again.<br>' .
            '<c "#FFA500">Torment:</c> say <c "#00FF00">"i will go"</c> to Fahlia Shadyglade. Run Keeper of Sorrows, hail Tylis Newleaf. Kill Saryrn, hail the projection, then hail Shadyglade AND Tylis once more - that second Shadyglade hail raises your saryrn flag to 2, which the Tower needs.<br><br>' .
            '<c "#FF0000">This same Saryrn flag is the gate to the Gates of Discord.</c>');
        print_bucket_flags($client, 'PoP early flags', \@POP_TRIALS_FLAGS);
        return;
    }

    if ($text =~ /^pop storms$/i) {
        popup('PoP: Storms, Valor, BoT, Honor',
            '<c "#FFD700">PoP: middle planes</c><br>' .
            '<c "#FFA500">Valor first:</c> say "I am familiar with the order" to the PoK Projection (needs the trial line) to reach PoValor. Kill Aerin\'Dar, hail the projection. The tunnel from PoValor leads to Halls of Honor - first entry must be through PoValor.<br>' .
            '<c "#FFA500">Askr the Lost (PoStorms, the BoT key chain)</c> - he only talks once your valor flag is set:<br>' .
            '1. Kill any storm giant and turn its head in to Askr.<br>' .
            '2. Say <c "#00FF00">"problem"</c>, then <c "#00FF00">"yes"</c>, then <c "#00FF00">"It was me"</c>, then <c "#00FF00">"I am paying attention"</c>, then <c "#00FF00">"continue"</c> - he hands you Askr\'s Bag of Verity.<br>' .
            '3. Kill one giant of each faction and combine their tokens in the bag: a Srerendi beard (shores, south of Grenidor), a Krendic bone (west), a Kelek`Vor sash (north woods). Hand the filled bag back.<br>' .
            '4. He refills the bag. Kill the faction leaders - each holds one piece. Combine two leader pieces in the bag and hand it back. Askr consumes the medallion it forms and gives you the real key: askr 4.<br>' .
            '5. Click the Mount Grenidor stone (postorms) with askr 4 + the trial line -> your Bastion of Thunder flag. Or say "I will defeat the Storm Lord" to the PoK Projection.<br>' .
            '<c "#FFA500">Inside BoT:</c> the courtyard is open. <c "#FF0000">Agnarr\'s Tower (the big door) needs the Symbol of Torden</c> and <c "#FF0000">the four corner towers need the Ring of Torden</c> - both drop from the tower giants, no quest. Click a locked door without its key and gargoyles come for you.<br>' .
            '<c "#FFA500">Agnarr the Storm Lord:</c> run his event, then hail the planar projection. Find Karana upstairs and say <c "#00FF00">"follow the path of the fallen"</c> - that is the flag. Say "send me on my path" to get gated out.<br>' .
            '<c "#FFA500">Halls of Honor trials</c> (all three open Temple of Marr): Trial of Dragon - hail Trydan Faye. Trial of Villagers - hail Rhaliq Trell. The lone villager - hail Alekson Garn. Then kill Lord Mithaniel Marr, hail the projection.');
        print_bucket_flags($client, 'PoP middle flags', \@POP_STORMS_FLAGS);
        return;
    }

    if ($text =~ /^pop tower$/i) {
        popup('PoP: Tower of Solusek Ro & elementals',
            '<c "#FFD700">PoP: Tower and elementals</c><br>' .
            '<c "#FFA500">Tactics:</c> "the war drums echo" ports you there. Kill Vallon Zek, Tallon Zek, then Rallos Zek the Warlord - hail a projection after each.<br>' .
            '<c "#FFA500">Tower of Solusek Ro</c> ("No gladiator shall match me" once saryrn is at 2): five minis - Xuzl, Arlyxir, Jiva, Rizlona, The Protector of Dresolik - click each one\'s stone after the kill. Then Solusek Ro himself, hail the projection, and drop into the lava pit to Plane of Fire.<br>' .
            '<c "#FFA500">The elementals</c> ("I am worthy of the elemental planes" - the 22-flag list): kill Fennin Ro (Fire), Xegony (Air - Wind Etched Key to reach the island), Coirnav (Water), and Earth: clear the four ring events in PoEarth A, kill the Mystical Arbitor of Earth, then the Rathe Council in PoEarth B. Hail a projection after every kill.<br><br>' .
            '<c "#00FF00">Every elemental god also grants the Dragons of Norrath AND LDoN stages.</c>');
        print_bucket_flags($client, 'PoP tower/elemental flags', \@POP_TOWER_FLAGS);
        return;
    }

    if ($text =~ /^pop time$/i) {
        popup('PoP: Plane of Time',
            '<c "#FFD700">PoP: Time - two gates, both required</c><br>' .
            '<c "#FFA500">Gate 1 - the maelin flag:</c> the four god projections each hand you an elemental essence. Combine all four in an Odylic Vial (crafted, tradable - one person in the raid needs one) -> the Quintessence of Elements. Carry it to Loreseeker Maelin in Plane of Innovation, say <c "#00FF00">"researched"</c>, then click the clock machine. That writes your Plane of Time zone flag.<br>' .
            '<c "#FFA500">Gate 2 - the Herald of Druzzil Ro (PoK):</c> she ports you into Time, but ONLY when the <c "#FF0000">Seeds of Destruction stage is done</c> - both Kerafyrm kills (Sleeper\'s Tomb + Crystallos). See [SoD].<br><br>' .
            'Both gates. No exceptions.');
        print_bucket_flags($client, 'PoP Time flag', \@POP_TIME_FLAGS);
        return;
    }

    # ----------------------------------------------------------------- GoD
    if ($text =~ /^god$/i) {
        popup('Gates of Discord',
            '<c "#FFD700">Gates of Discord</c><br>' .
            '<c "#FFA500">Entry:</c> kill <c "#FF0000">Saryrn</c> in Plane of Torment (see [pop trials]) and hail the memory. Travel: Magic Map stones (Natimbi, Barindu, Kod\'Taz, Qvic, Txevu).<br><br>' .
            '<c "#FFA500">Kod\'Taz access:</c> Barindu - hail <c "#87CEEB">High Priest Diru Riwirn</c>; he assigns the sewers task and runs the four <c "#87CEEB">Sewers of Nihilia</c> expeditions IN ORDER (Purifying Plant -> Crematory -> Lair of the Trapped Ones -> Pool of Sludge). Say "ready" to enter your expedition, finish it, hail him again for the next.<br>' .
            'Shortcut: <c "#87CEEB">Scribe Gurru</c> - say <c "#00FF00">"issues"</c> and he advances every sewers step you have already completed and sets the sewers flag once the task is done.<br>' .
            'Then <c "#87CEEB">Apprentice Udranda</c> (Barindu) grants the Vxed expedition. Inside, hail <c "#87CEEB">Stonespiritist Ekikoa</c>, then click the obelisk behind her to zone out to Kod\'Taz. (The second route: the Tipt expedition, hail Master Stonespiritist Okkanu - either sets your Kod\'Taz flag.)<br><br>' .
            '<c "#FFA500">Qvic access:</c> Kod\'Taz - hail <c "#87CEEB">Kevren Nalavat</c>, say "ready to be tested": the three group temples IN ORDER (Temple of Singular Might - Gazak Klelkek; Temple of Twin Struggles - Maroley Nazuey; Temple of Tri-Fates - Kenra Kalekkio), then his three tasks (Martyr\'s Passage, Pit of the Lost, Crumbled Sanctuary), then the three Ikkinz raids. Turn-ins go to <c "#87CEEB">Tublik Narwethar</c>.<br>' .
            'Craft the <c "#FFD700">Icon of the Altar</c>: three Inferno Scepters (smith, from Joran Mullven), each smelted with a block of Inanimate Ore -> three vials; three vials + three raid artifacts in a forge -> the Icon. Give the Icon to the Sentinel of the Altar atop Kod\'Taz -> run Chambers of Destruction -> loot the Sliver of the High Temple -> hand it back to Tublik.<br>' .
            'Run <c "#FFD700">Uqua</c> (request from Jerimo Jiao in Yxtta), hail the Specter of Barxt for the Fragment of the High Temple. With the quest Sliver + Fragment, zone into Qvic from Kod\'Taz or Yxtta.<br><br>' .
            '<c "#FFA500">Onward:</c> Inktu\'Ta expedition (Qvic), hail An Ancient Sentinel for the Splinter. Brevik Kalaner (Abysmal Sea) combines Sliver + Fragment + Splinter into the Cipher of Txevu, which opens Txevu from Qvic. Request Tacvi inside Txevu.<br>' .
            '<c "#FF0000">Kill Tunat`Muram Cuu Vauax -> memory = Omens of War (and half of Darkhollow).</c>');
        print_stage_status($client, 'GoD');
        print_bucket_flags($client, 'GoD access flags', \@GOD_BUCKETS, '');
        plugin::YellowText($MEMORY_NOTE);
        return;
    }

    # ----------------------------------------------------------------- OoW
    if ($text =~ /^oow$/i) {
        popup('Omens of War',
            '<c "#FFD700">Omens of War</c><br>' .
            '<c "#FFA500">Entry:</c> Tunat`Muram Cuu Vauax dies in Tacvi (see [GoD]) and the memory unlocks Omens. Travel: the Priest of Discord in PoK ("through") ports to Dranik\'s Scar; Magic Map stones (Wall of Slaughter, Bloodfields, Proving Grounds, Riftseekers\' Terris...).<br><br>' .
            '<c "#FFA500">Muramite Proving Grounds - the six Projections</c>, each keeper of two trials. Hail one and say the trial name to enroll: Arcana (Efficiency / Specialization), Body (Weaponry / Endurance), Mind (Fear / Hatred), Power (Destruction / Corruption), Realms (Ingenuity / Adaptation), Tactics (Subversion / Foresight). The small-scale trial is the group version, the large-scale one is the raid.<br>' .
            'The six <c "#FF0000">RAID trials</c> (Specialization, Endurance, Hatred, Corruption, Adaptation, Foresight) each spawn a Master - and <c "#FF0000">all six Masters are required for Prophecy of Ro</c>. The group trials pay resist AAs (2 extra per completed set, cap +50).<br><br>' .
            '<c "#FFA500">Anguish raid:</c> kill Warden Hanvar, Ture, Jelvan and Keldovan the Harrier - the seal to the upper platform opens only when all four are dead (Arch Magus Vangl holds the shield spells below). <c "#FF0000">Overlord Mata Muram</c> waits at the top and is required for Prophecy of Ro.');
        print_stage_status($client, 'OoW');
        plugin::YellowText($MEMORY_NOTE);
        return;
    }

    # ----------------------------------------------------------------- DoN
    if ($text =~ /^don$/i) {
        popup('Dragons of Norrath',
            '<c "#FFD700">Dragons of Norrath</c><br>' .
            '<c "#FFA500">Gate:</c> the five elemental gods of PoP - Xegony (Air), Fennin Ro (Fire), Coirnav (Water), the Rathe Council (Earth B) and Agnarr (Bastion of Thunder). See [pop tower] for how to reach each. Each memory grants DoN and LDoN at once.<br><br>' .
            '<c "#FFA500">Travel:</c> the DoN Porter in Lavastorm - say "ready" and she sends you to the Broodlands.<br>' .
            'The Nest opens with this stage; its raid event "In the Shadows" ends at <c "#FF0000">Vishimtar the Fallen</c> - another Prophecy of Ro requirement.');
        print_stage_status($client, 'DoN');
        plugin::YellowText($MEMORY_NOTE);
        return;
    }

    # ----------------------------------------------------------------- LDoN
    if ($text =~ /^ldon$/i) {
        popup('Lost Dungeons of Norrath',
            '<c "#FFD700">Lost Dungeons of Norrath</c><br>' .
            '<c "#FFA500">Gate:</c> the same five elemental gods as DoN (see [pop tower]). The Wayfarer camps open at the DoN stage.<br><br>' .
            '<c "#FFA500">The camps and their raid expeditions</c> - flow at every requester: hail -> say "problem" -> say "interested" (expedition created) -> say "ready" to enter:<br>' .
            'East Commonlands - Rujarkian Scout Orlo: <c "#FFD700">Drudge Hollows</c>; Uzmanya Zsiksta: <c "#FFD700">War March of Imal Ojun</c>.<br>' .
            'Butcherblock - Kroggl: <c "#FFD700">Mistmoore\'s Catacombs: Struggles within the Progeny</c>.<br>' .
            'Everfrost - Miragul Scout Vosk: <c "#FFD700">Miragul\'s Menagerie: The Forgotten Wastes</c>.<br><br>' .
            '<c "#FF0000">War March of Imal Ojun is the second half of the Depths of Darkhollow gate - do not skip it.</c>');
        print_stage_status($client, 'LDoN');
        return;
    }

    # ----------------------------------------------------------------- DoD
    if ($text =~ /^dod$/i) {
        popup('Depths of Darkhollow',
            '<c "#FFD700">Depths of Darkhollow</c><br>' .
            '<c "#FFA500">Gate (two kills):</c> <c "#FF0000">Tunat`Muram Cuu Vauax</c> (Tacvi - see [GoD]) and <c "#FF0000">Warlord Imal Ojun</c> (the LDoN Rujarkian raid - see [LDoN]).<br>' .
            '<c "#FFA500">Travel:</c> the DoD Porter in Nektulos Forest.<br><br>' .
            '<c "#FFA500">Dreadspire access (the monocle chain)</c> - <c "#87CEEB">Treddlehoop</c> in Corathus runs it:<br>' .
            '1. He hands you Treddlehoop\'s Wonderful Monoculor Seeing Device - that sees you into Dreadspire Keep (re-entry also via the Formal Dinner Invitation from Dreadspire trash).<br>' .
            '2. His <c "#FFD700">Scavenger Hunting</c> task: loot a Shiliskin Tentacle Cluster (Illsalin shiliskin), a Drachnid Silk Gland (the Hive) and two Chopping Swords (Stoneroot Falls orcs) -> Treddlehoop\'s Signature Monocle.<br>' .
            '3. The library tasks from his board: <c "#FFD700">Frustrated Functionary</c> (Melion Pell, Dreadspire - the library key), <c "#FFD700">Check Out a Library Book</c> (Shard of Mystical Glass -> the Official Cataloguer), <c "#FFD700">Eyes Wide Open</c> (crypt crest + eye patch).<br>' .
            '4. <c "#FFD700">Memories Lost</c> (the Doorman) flags Vule\'s chambers; <c "#FFD700">Misty for You</c> (Coldwind Blackfoot, Nektulos) ends in the Lens of Bound Eyes.<br>' .
            '5. Kill <c "#FF0000">Vule the Silent Tear</c> for Vule\'s Eye; with the lens that becomes the Lens of Eye-Glass -> the Monocle of Blood, the hard key to the Demi-Plane of Blood.<br><br>' .
            '<c "#FF0000">Mayong Mistmoore (Demi-Plane) is a Prophecy of Ro requirement.</c>');
        print_stage_status($client, 'DoD');
        plugin::YellowText($MEMORY_NOTE);
        return;
    }

    # ----------------------------------------------------------------- PoR
    if ($text =~ /^por$/i) {
        popup('Prophecy of Ro',
            '<c "#FFD700">Prophecy of Ro</c><br>' .
            'Four threads, all required:<br>' .
            '<c "#FFA500">1. MPG raid trials:</c> the six large-scale trials (see [OoW]) - Masters of Hate, Weaponry, Foresight, Specialization, Adaptation, Destruction.<br>' .
            '<c "#FFA500">2. Anguish:</c> kill the Overlord Mata Muram (see [OoW]).<br>' .
            '<c "#FFA500">3. The Nest:</c> run "In the Shadows" - Vishimtar the Fallen (see [DoN]).<br>' .
            '<c "#FFA500">4. Dreadspire:</c> kill Mayong Mistmoore (see [DoD] for the Demi-Plane monocle).<br><br>' .
            '<c "#FFA500">Deathknell entry (the TSS gate lives here):</c><br>' .
            'a. The PoR Porter in South Ro sends you to Arcstone. There, run the <c "#FFD700">chime chain</c>: Spirit of Ao\'s three missions (The Library, The Oubliette, The Laboratory) -> Tarnished Chime -> Harmonic Chime -> give to Arch Mage Galsin; Oathmir the Outcast and Queen Tak`Yaliz twist it further; Galsin restores the final Twisted Harmonic Chime.<br>' .
            'b. In the Theater of Blood, hail <c "#87CEEB">Eodue the Pure</c> - say "what curse", "what source". Kill her six cursed companions (Cassindra, Denon, Ervaj, Jonthan, Rizlona, Tuyen), loot an Inspiration, hand it in - you are attuned to the tower.<br>' .
            'c. Say "deathknell" (or "enter") to Eodue and she opens the <c "#FFD700">Deathknell, Tower of Dissonance</c> expedition. Ayonae Ro waits at the top.<br><br>' .
            '<c "#FF0000">Killing Ayonae Ro = The Serpent\'s Spine stage.</c>');
        print_stage_status($client, 'PoR');
        plugin::YellowText($MEMORY_NOTE);
        return;
    }

    # ----------------------------------------------------------------- TSS
    if ($text =~ /^tss$/i) {
        popup('The Serpent\'s Spine',
            '<c "#FFD700">The Serpent\'s Spine</c><br>' .
            '<c "#FFA500">Gate - one kill:</c> <c "#FF0000">Ayonae Ro</c>, final encounter of Deathknell, Tower of Dissonance. Entry is the PoR chain - see [PoR] step 4.<br><br>' .
            'The stage opens the Spine: Steppes of Ruin, Sunderock Springs, Blackfeather Roost, the Foundation, Icefall, Valdeholm, Frostcrypt, Vergalid Mines, Direwind Cliffs and Ashengate - all of which feed The Buried Sea.');
        print_stage_status($client, 'TSS');
        plugin::YellowText($MEMORY_NOTE);
        return;
    }

    # ----------------------------------------------------------------- TBS
    if ($text =~ /^tbs$/i) {
        popup('The Buried Sea',
            '<c "#FFD700">The Buried Sea - two arcs</c><br>' .
            '<c "#FFA500">Arc 1 - Dyn`Leth (the stage gate):</c> run it from the Spine\'s zones:<br>' .
            '1. <c "#FFD700">Zhubis the Griffon Tamer</c> (Direwind Cliffs): his task "The Pretender" sends you into the Vergalid Mines instance to kill Nurtha Frazzlesprocket - "Dyn`leth is no god - he is a machine".<br>' .
            '2. Finish <c "#FFD700">Captain Zheren\'s</c> work in Sunderock Springs.<br>' .
            '3. Back to Zhubis for the Infiltrators arc: Sabotage, Project Disarm, The Weakest Link.<br>' .
            '4. Locate Drizzlorn (Direwind Cliffs) - he opens Ashengate once BOTH wings of the Reliquary have fallen.<br>' .
            '<c "#FF0000">5. Kill Dyn`Leth</c> in Ashengate -> memory = The Buried Sea. (Travel after: the TBS Porter in Toxxulia; Magic Map stones for Buried Sea and Katta Castrum.)<br><br>' .
            '<c "#FFA500">Arc 2 - Solteris access (needed for Faydwer\'s raids):</c> Katta Castrum - hail <c "#87CEEB">Prime Researcher Elnot Waymun</c>. Say "guidance" any time to see your next step; say "pursue" to begin - he hands you the Combine Signet Ring and the arc runs itself, fourteen steps: speak to Plik -> mission Knowledge for Power (Atiiki) -> report to Maladoks -> mission Locating the Statue (Barren Coast) -> deliver the rubbing to Head Mage Antius -> return -> Snakes Hiding Something (Zhisza) -> Counter-Attack (Zhisza) -> return -> Confront Emperor Vaakiszh (Zhisza) -> Vizier Zio -> Where There\'s a Will (Silyssar) -> Slay the Serpent (Silyssar) -> Stop the Ritual (Silyssar). Loot the Softly Glowing Runed Pendant off the Empress. Solteris stands open.<br>' .
            '<c "#FF0000">Note: the Dyn`Leth memory mentions Faydwer but does NOT count for that stage.</c>');
        print_stage_status($client, 'TBS');
        plugin::YellowText($MEMORY_NOTE);
        return;
    }

    # ----------------------------------------------------------------- SoF
    if ($text =~ /^sof$/i) {
        popup('Secrets of Faydwer',
            '<c "#FFD700">Secrets of Faydwer</c><br>' .
            '<c "#FFA500">Gate:</c> enter <c "#87CEEB">Solteris</c> (opened by Elnot Waymun\'s arc - see [TBS] arc 2) and kill both gods: <c "#FF0000">Solusek Ro</c> and <c "#FF0000">Mayong Mistmoore</c>.<br><br>' .
            'Faydwer zones (Dragonscale Hills, Crystallos...) open with the stage.');
        print_stage_status($client, 'SoF');
        plugin::YellowText($MEMORY_NOTE);
        return;
    }

    # ----------------------------------------------------------------- SoD
    if ($text =~ /^sod$/i) {
        popup('Seeds of Destruction',
            '<c "#FFD700">Seeds of Destruction</c><br>' .
            '<c "#FFA500">Gate - two Sleepers:</c><br>' .
            '1. <c "#FF0000">Kerafyrm</c> in the original Sleeper\'s Tomb (Velious - yes, you go back). Hail the <c "#87CEEB">Keeper of the Tomb</c> beside the tomb, say "tomb", then "ready" - the expedition holds up to 72, six hours, with a lockout between runs. Wake the warders, face the Sleeper.<br>' .
            '2. <c "#FF0000">Kerafyrm</c> in <c "#87CEEB">Crystallos</c> (Faydwer, opens at the Faydwer stage): clear the wing bosses (Zeixshi`Kar the Ancient and kin), and the Sleeper stirs at the heart of the prismatic halls.<br><br>' .
            '<c "#00FF00">The SoD stage also re-opens the Plane of Time</c> - the PoK Herald of Druzzil Ro requires it (see [pop time]).<br>' .
            'Deeper Spine content (Korafax, the Citadel, mercenary tiers) runs on its own task chains - ask around, or hail the Bazaar\'s Orcish Adventurer for the stage status.');
        print_stage_status($client, 'SoD');
        plugin::YellowText($MEMORY_NOTE);
        return;
    }

    # ----------------------------------------------------------------- FNagafen
    if ($text =~ /^fabled nagafen$/i) {
        popup('Fabled Nagafen\'s Lair',
            '<c "#FFD700">Fabled Nagafen\'s Lair</c><br>' .
            '<c "#FFA500">Gate:</c> kill <c "#FF0000">Quarm</c> at the end of the Plane of Time (both gates - see [pop time]).<br><br>' .
            'The fabled (v1) expeditions of Solusek B - where Fabled Lord Nagafen himself lives - eject anyone without the Quarm flag at the door.');
        print_stage_status($client, 'FNagafen');
        plugin::YellowText($MEMORY_NOTE);
        return;
    }

    # ----------------------------------------------------------------- UF
    if ($text =~ /^underfoot$/i) {
        popup('Underfoot',
            '<c "#FFD700">Underfoot</c><br>' .
            '<c "#FFA500">Gate:</c> <c "#87CEEB">Convorteum</c> (opens at the SoD stage; the herald in Brell\'s Rest requests it). Seven sequential raid stages - each opened only by clearing the last, each with its own 72-hour lockout and a treasure chest:<br>' .
            '1. The Gatekeeper<br>' .
            '2-5. the halls between<br>' .
            '6. The Magus Sisters (all three must fall)<br>' .
            '<c "#FF0000">7. The First Creation</c> - the final stage, and the last gate flag the Librarian knows of.<br><br>' .
            'Hail the memory off the First Creation to write the Underfoot stage.');
        print_stage_status($client, 'UF');
        plugin::YellowText($MEMORY_NOTE);
        return;
    }

    show_menu();
}

sub EVENT_ITEM {
    plugin::return_items(\%itemcount);
}

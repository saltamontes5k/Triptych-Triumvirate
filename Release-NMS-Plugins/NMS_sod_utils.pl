# NMS_sod_utils.pl - Seeds of Destruction intra-expansion progression.
#
# Implements the raspersrealm SoD miscProgression rules on top of the
# per-account stage-flag system in NMS_progression_utils.pl. All state lives
# as subflags under the existing 'SoD' account stage, so era gating
# (is_eligible_for_zone) is untouched and the two systems cannot disagree.
#
#   Group chain tasks per theme + raid request tasks:
#     oceangreen-group  303000-303005     oceangreen-raid  303060
#     kithicor-group    303010-303012     kithicor-raid    303061
#     kunark-group      303020-303024     kunark-raid      303062
#     rathe-group       303030-303036     rathe-raid       303063
#     korafax-kuua      303040-303051     korafax-raid-1/2/3  303064-303066
#                                         discord-tower    303067
#
#   Derived (miscProgression rules):
#     Void version = 1 + themes completed (group OR raid per theme; a theme's
#     group+raid still counts once), then +1 for korafax-kuua (Void F) and
#     +1 for discord-tower (Void G). Maps to zones thevoida..thevoidg.
#     Korafax access = all four group chains OR all four raid chains
#     (never mixed). Citadel = Korafax access + all three Korafax raid
#     chains + a Tower Key (88343) on the character.
#
# Mercenary tier unlocks (Oceangreen=T2 .. Rathe=T5) are represented by the
# theme flags themselves; mercenaries are disabled server-wide, so there is
# nothing further to unlock (documented simplification).
#
# Zone gates (called from zone player.pl EVENT_ENTERZONE):
#   plugin::SodGateVoid($client, 'thevoidc')
#   plugin::SodGateKorafax($client)
#   plugin::SodGateCitadel($client)
# Task completion hook (global_player.pl EVENT_TASK_COMPLETE):
#   plugin::SodOnTaskComplete($client, $task_id)
# Giver NPC scripts (EVENT_SAY):
#   plugin::SodTaskGiver($client, <npc_id>, $text)
# Portal NPC scripts (EVENT_SAY):
#   plugin::SodPortalUse($client, <npc_id>)

# ---------------------------------------------------------------------------
# Task -> chain flag. Completing every task in a chain sets the flag.
# ---------------------------------------------------------------------------
my %SOD_TASK_FLAG = (
    303000 => 'oceangreen-group', 303001 => 'oceangreen-group',
    303002 => 'oceangreen-group', 303003 => 'oceangreen-group',
    303004 => 'oceangreen-group', 303005 => 'oceangreen-group',
    303010 => 'kithicor-group',   303011 => 'kithicor-group',
    303012 => 'kithicor-group',
    303020 => 'kunark-group',     303021 => 'kunark-group',
    303022 => 'kunark-group',     303023 => 'kunark-group',
    303024 => 'kunark-group',
    303030 => 'rathe-group',      303031 => 'rathe-group',
    303032 => 'rathe-group',      303033 => 'rathe-group',
    303034 => 'rathe-group',      303035 => 'rathe-group',
    303036 => 'rathe-group',
    303040 => 'korafax-kuua',     303041 => 'korafax-kuua',
    303042 => 'korafax-kuua',     303043 => 'korafax-kuua',
    303044 => 'korafax-kuua',     303045 => 'korafax-kuua',
    303046 => 'korafax-kuua',     303047 => 'korafax-kuua',
    303048 => 'korafax-kuua',     303049 => 'korafax-kuua',
    303050 => 'korafax-kuua',     303051 => 'korafax-kuua',
    303060 => 'oceangreen-raid',  303061 => 'kithicor-raid',
    303062 => 'kunark-raid',      303063 => 'rathe-raid',
    303064 => 'korafax-raid-1',   303065 => 'korafax-raid-2',
    303066 => 'korafax-raid-3',   303067 => 'discord-tower',
);

my %SOD_CHAIN_TASKS = (
    'oceangreen-group' => [303000, 303001, 303002, 303003, 303004, 303005],
    'kithicor-group'   => [303010, 303011, 303012],
    'kunark-group'     => [303020, 303021, 303022, 303023, 303024],
    'rathe-group'      => [303030, 303031, 303032, 303033, 303034, 303035, 303036],
    'korafax-kuua'     => [303040, 303041, 303042, 303043, 303044, 303045,
                           303046, 303047, 303048, 303049, 303050, 303051],
    'oceangreen-raid'  => [303060],
    'kithicor-raid'    => [303061],
    'kunark-raid'      => [303062],
    'rathe-raid'       => [303063],
    'korafax-raid-1'   => [303064],
    'korafax-raid-2'   => [303065],
    'korafax-raid-3'   => [303066],
    'discord-tower'    => [303067],
);

my @SOD_THEMES       = ('oceangreen', 'kithicor', 'kunark', 'rathe');
my @SOD_VOID_ZONES   = ('thevoida', 'thevoidb', 'thevoidc', 'thevoidd',
                        'thevoide', 'thevoidf', 'thevoidg');
my $SOD_TOWER_KEY    = 88343;

# ---------------------------------------------------------------------------
# Giver offers: npc id => [ [task id, prereq...], ... ]
# Prereq entries: a task id number, a chain flag name (e.g. 'kunark-group'),
# or the special string 'korafax' (= SodKorafaxAccess).
# ---------------------------------------------------------------------------
my %SOD_OFFERS = (
    # Oceangreen
    466141 => [[303000, ()], [303001, 303000]],                     # Sergeant Bronal Cadran
    466035 => [[303002, ()], [303003, 303002], [303004, 303003]],   # Captain Hiran Tillin
    466160 => [[303005, 303003, 303004]],                           # Raxtor Darkpaw
    467066 => [[303060, ()]],                                       # Apothecary Cadmael (raid req)
    # Kithicor
    456178 => [[303010, ()]],                                       # Lanys T`Vyl (Obliteration)
    456174 => [[303011, 303010]],                                   # Commander Barvian (Light)
    456171 => [[303012, 303011], [303061, ()]],                     # Firiona Vie
    # Kunark / Field of Scale
    452147 => [[303020, ()], [303021, 303020], [303022, 303021],
               [303023, 303022], [303024, 303023],
               [303062, ()]],                                       # Jaled`Dar
    # Rathe
    476122 => [[303030, ()]],                                       # Sterik Gristmaker
    476115 => [[303031, 303030], [303032, 303031], [303033, 303032]],  # Nedsin Tabbels
    476110 => [[303034, 303033], [303035, 303034], [303036, 303035],
               [303063, ()]],                                       # Ylatra the Vassal
    # Discord / Kuua
    472055 => [[303040, ()]],                                       # General Vurig the Imposing
    474036 => [[303041, 303040]],                                   # Yemall the Arcane
    470000 => [[303042, 'korafax'], [303043, 303042],               # a disheveled human
               [303044, 303043], [303045, 303044]],
    470020 => [[303046, 303045], [303047, 303046], [303048, 303047],  # Telivar (spawner)
               [303049, 303048], [303050, 303049], [303051, 303050]],
    # Korafax raids + Citadel
    470001 => [[303064, 'korafax-kuua'], [303065, 303064],
               [303066, 303065],
               [303067, 303064, 303065, 303066]],                   # Herald of Druzzil Ro
);

# ---------------------------------------------------------------------------
# Raid expeditions (real bosses; see sod_content/gen_raids.py and the
# <zone>/<npc_id>.lua encounters). Say 'request' at the giver to create the
# expedition (and receive the raid task); say 'ready' to zone into an
# expedition you hold. Zone versions 51-54 are reserved for SoD raids.
# ---------------------------------------------------------------------------
my %SOD_RAIDS = (
    303060 => { name => 'Stop the Ascension',       zone => 'bertoxtemple',
                version => 51, zonein => [2, -2, 2],
                compass => ['oceangreenvillage', 362, -2554, 6] },
    303061 => { name => 'Fall of General Bahgresh', zone => 'oldkithicor',
                version => 51, zonein => [-255, 1189, 10],
                compass => ['oldkithicor', 2087, 25, 154.75] },
    303062 => { name => 'A Council Divided',        zone => 'oldkaesoraa',
                version => 51, zonein => [33.67, -20.86, 3.37],
                compass => ['oldfieldofbone', 852, -1841, -0.25] },
    303063 => { name => "Eriak's Downfall",         zone => 'rathechamber',
                version => 51, zonein => [-19, -10, -22],
                compass => ['korascian', -142, 1013, -44.25] },
    303064 => { name => 'Pallorax the Soul Slayer', zone => 'discord',
                version => 51, zonein => [28, -20, -16],
                compass => ['discord', -51, 33, 27] },
    303065 => { name => 'The Mindshear Avatar',     zone => 'discord',
                version => 52, zonein => [28, -20, -16],
                compass => ['discord', -51, 33, 27] },
    303066 => { name => 'Venom Lord Ksathrax',      zone => 'discord',
                version => 53, zonein => [28, -20, -16],
                compass => ['discord', -51, 33, 27] },
    303067 => { name => 'The Mindblight',           zone => 'discordtower',
                version => 51, zonein => [0, -48, -48],
                compass => ['discord', -51, 33, 27] },
);

# ---------------------------------------------------------------------------
# Portal clickies: npc id => [kind, dest zone, x, y, z]
#   kind 'void'    - theme zone -> The Void (version redirect happens there)
#   kind 'korafax' - The Void  -> Korafax (gated)
#   kind 'citadel' - Korafax   -> Citadel of the Worldslayer (gated)
# ---------------------------------------------------------------------------
my %SOD_PORTALS = (
    478600 => ['void',    'thevoida',    -79, -158, 33],   # Oceangreen Hills rift
    478601 => ['void',    'thevoida',    -79, -158, 33],   # Bloody Kithicor rift
    478602 => ['void',    'thevoida',    -79, -158, 33],   # Field of Scale rift
    478603 => ['void',    'thevoida',    -79, -158, 33],   # Old Bloodfields rift
    478604 => ['void',    'thevoida',    -79, -158, 33],   # Toskirakk rift
    478605 => ['korafax', 'discord',      28,  -20, -16],   # thevoida Timeshear rift
    478606 => ['citadel', 'discordtower',   0,  -48, -48],   # Korafax Citadel rift
);

# ---------------------------------------------------------------------------
# Internals
# ---------------------------------------------------------------------------
sub _sod_subflag {
    my ($client, $flag) = @_;
    return (plugin::GetSubflag($client, 'SoD', $flag) ? 1 : 0);
}

sub _sod_prereq_met {
    my ($client, $pre) = @_;
    return 1 if !defined $pre || $pre eq '';
    if ($pre eq 'korafax')    { return SodKorafaxAccess($client); }
    if ($pre =~ /^[A-Za-z]/)  { return _sod_subflag($client, $pre); }
    return $client->IsTaskCompleted($pre) ? 1 : 0;
}

sub _sod_theme_done {
    my ($client, $theme) = @_;
    return 1 if _sod_subflag($client, "$theme-group");
    return 1 if _sod_subflag($client, "$theme-raid");
    return 0;
}

# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

# Create a raid expedition for $task_id. Returns 1 if it consumed the say.
sub SodRaidRequest {
    my ($client, $task_id, $npc_id) = @_;
    my $raid = $SOD_RAIDS{$task_id};
    return 0 unless $raid;

    my $current = $client->GetExpedition();
    if ($current) {
        if ($current->GetName() eq $raid->{name}) {
            $client->Message(15, "Your expedition stands ready. Say 'ready' to enter.");
        } else {
            $client->Message(13, "You already hold a claim on another expedition.");
        }
        return 1;
    }

    my ($czone, $cx, $cy, $cz) = @{$raid->{compass}};
    my $dz = $client->CreateExpedition($raid->{zone}, $raid->{version},
        8 * 60 * 60, $raid->{name}, 1, 54);
    if ($dz) {
        $dz->SetCompass($czone, $cx, $cy, $cz);
        $dz->SetSafeReturn($czone, $cx, $cy, $cz, 0);
        $dz->AddReplayLockout(72 * 60 * 60);
        $client->AssignTask($task_id, $npc_id || 0);
        $client->Message(15, "$raid->{name} is prepared. Say 'ready' to enter.");
    } else {
        $client->Message(13, "You are not yet able to claim that expedition.");
    }
    return 1;
}

# Zone the player into their held SoD raid expedition, if any.
sub SodRaidEnter {
    my ($client) = @_;
    my $dz = $client->GetExpedition();
    return 0 unless $dz;
    foreach my $raid (values %SOD_RAIDS) {
        next unless $dz->GetName() eq $raid->{name};
        my ($x, $y, $z) = @{$raid->{zonein}};
        $client->MovePCInstance($dz->GetZoneID(), $dz->GetInstanceID(), $x, $y, $z, 0);
        return 1;
    }
    return 0;
}

# Call from global_player.pl EVENT_TASK_COMPLETE.
sub SodOnTaskComplete {
    my ($client, $task_id) = @_;
    return unless exists $SOD_TASK_FLAG{$task_id};
    my $flag = $SOD_TASK_FLAG{$task_id};
    foreach my $tid (@{$SOD_CHAIN_TASKS{$flag}}) {
        return unless $client->IsTaskCompleted($tid);
    }
    plugin::SetSubflag($client, 'SoD', $flag, 1);
}

# Number of themes completed (group OR raid; a theme counts once).
sub SodThemeCount {
    my ($client) = @_;
    my $n = 0;
    foreach my $theme (@SOD_THEMES) {
        $n++ if _sod_theme_done($client, $theme);
    }
    return $n;
}

# 1 + themes (A-E), then F for korafax-kuua and G for discord-tower.
sub SodVoidVersion {
    my ($client) = @_;
    my $v = 1 + SodThemeCount($client);
    $v = 6 if _sod_subflag($client, 'korafax-kuua');
    $v = 7 if _sod_subflag($client, 'discord-tower');
    return $v > 7 ? 7 : $v;
}

sub SodVoidZone {
    my ($version) = @_;
    $version = 1 unless defined $version;
    $version = 7 if $version > 7;
    return $SOD_VOID_ZONES[$version - 1];
}

# Korafax access: ALL four group chains or ALL four raid chains (no mixing).
sub SodKorafaxAccess {
    my ($client) = @_;
    my ($g, $r) = (0, 0);
    foreach my $theme (@SOD_THEMES) {
        $g += _sod_subflag($client, "$theme-group");
        $r += _sod_subflag($client, "$theme-raid");
    }
    return 1 if $g == 4;
    return 1 if $r == 4;
    return 0;
}

# Citadel: Korafax access + all three Korafax raids + Tower Key on character.
sub SodCitadelAccess {
    my ($client) = @_;
    return 0 unless SodKorafaxAccess($client);
    return 0 unless _sod_subflag($client, 'korafax-raid-1');
    return 0 unless _sod_subflag($client, 'korafax-raid-2');
    return 0 unless _sod_subflag($client, 'korafax-raid-3');
    return ($client->CountItem($SOD_TOWER_KEY) > 0) ? 1 : 0;
}

# Void version gate. Returns 1 when the player may stay in $zonesn.
sub SodGateVoid {
    my ($client, $zonesn) = @_;
    return 1 if $client->GetGM();
    my ($want) = grep { $SOD_VOID_ZONES[$_] eq $zonesn } 0 .. $#SOD_VOID_ZONES;
    return 1 unless defined $want;
    my $earned = SodVoidVersion($client);
    return 1 if $earned >= $want + 1;
    my $dest = SodVoidZone($earned);
    $client->Message(13, "The timeshear rejects you; your thread of the Void "
        . "is still " . uc($dest) . ". (Themes completed: "
        . SodThemeCount($client) . "/4)");
    $client->MovePC($dest, -79, -158, 33, 0);
    return 0;
}

# Korafax (zone 'discord') gate.
sub SodGateKorafax {
    my ($client) = @_;
    return 1 if $client->GetGM();
    return 1 if SodKorafaxAccess($client);
    my $dest = SodVoidZone(SodVoidVersion($client));
    $client->Message(13, "A wall of discordant energy repels you. Korafax "
        . "opens only to those who restore every timeline: all four themes "
        . "by group missions or all four by raids.");
    $client->MovePC($dest, -79, -158, 33, 0);
    return 0;
}

# Citadel of the Worldslayer (zone 'discordtower') gate.
sub SodGateCitadel {
    my ($client) = @_;
    return 1 if $client->GetGM();
    return 1 if SodCitadelAccess($client);
    $client->Message(13, "The citadel gate is sealed. It answers only to "
        . "Korafax access, the fall of its three raid lords, and a Tower "
        . "Key borne in hand.");
    $client->MovePC('discord', 28, -20, -16, 0);
    return 0;
}

# Giver NPC EVENT_SAY handler. Returns 1 if it consumed the text.
# 'ready'  -- assign a group task, or zone into a held raid expedition.
# 'request'-- create a raid expedition (and receive the raid task).
# 'progress' -- full SoD standings report.
sub SodTaskGiver {
    my ($client, $npc_id, $text) = @_;
    my $offers = $SOD_OFFERS{$npc_id};
    return 0 unless $offers;
    return 0 unless $text =~ /hail|ready|progress/i;

    if ($text =~ /progress/i) {
        SodReport($client);
        return 1;
    }

    if ($text =~ /ready/i) {
        # zone into a held SoD raid expedition first
        if (SodRaidEnter($client)) { return 1; }
        foreach my $offer (@{$offers}) {
            my ($tid, @pres) = @{$offer};
            next if $SOD_RAIDS{$tid};   # raids go through 'request'
            next if $client->IsTaskCompleted($tid);
            next if $client->IsTaskActive($tid);
            my $ok = 1;
            foreach my $pre (@pres) {
                if (!_sod_prereq_met($client, $pre)) { $ok = 0; last; }
            }
            next unless $ok;
            $client->AssignTask($tid, $npc_id);
            return 1;
        }
        $client->Message(13, "There is no work for you yet.");
        return 1;
    }

    if ($text =~ /request/i) {
        foreach my $offer (@{$offers}) {
            my ($tid, @pres) = @{$offer};
            next unless $SOD_RAIDS{$tid};
            next if $client->IsTaskCompleted($tid);
            next if $client->IsTaskActive($tid);
            my $ok = 1;
            foreach my $pre (@pres) {
                if (!_sod_prereq_met($client, $pre)) { $ok = 0; last; }
            }
            next unless $ok;
            return SodRaidRequest($client, $tid, $npc_id);
        }
        $client->Message(13, "There is no raid for you to claim here yet.");
        return 1;
    }

    # Hail: list what this giver can offer.
    my $said = 0;
    foreach my $offer (@{$offers}) {
        my ($tid, @pres) = @{$offer};
        my $title = $SOD_RAIDS{$tid}
            ? quest::saylink("request", 1, "[Request]") . " -- a raid awaits."
            : quest::saylink("ready", 1, "[Ready]") . " -- work is available.";
        if ($client->IsTaskCompleted($tid)) {
            $client->Message(15, "Task $tid: completed.");
            next;
        }
        $said = 1;
        if ($client->IsTaskActive($tid)) {
            $client->Message(15, "Task $tid: you carry this duty still. Finish it.");
            next;
        }
        my $ok = 1;
        foreach my $pre (@pres) {
            if (!_sod_prereq_met($client, $pre)) { $ok = 0; last; }
        }
        if ($ok) {
            $client->Message(15, "$title (task $tid)");
        } else {
            $client->Message(13, "Task $tid awaits your earlier duties.");
        }
    }
    $client->Message(15, "Say 'progress' to review your Seeds of Destruction standings.")
        if $said || 1;
    return 1;
}

# Portal clicky EVENT_SAY handler.
sub SodPortalUse {
    my ($client, $npc_id) = @_;
    my $portal = $SOD_PORTALS{$npc_id};
    return 0 unless $portal;
    my ($kind, $dest, $x, $y, $z) = @{$portal};

    if ($kind eq 'void') {
        $client->Message(15, "You step through the timeshear rift...");
        $client->MovePC($dest, $x, $y, $z, 0);
        return 1;
    }
    if ($kind eq 'korafax') {
        if (SodKorafaxAccess($client) || $client->GetGM()) {
            $client->Message(15, "The rift steadies and opens onto Korafax.");
            $client->MovePC($dest, $x, $y, $z, 0);
        } else {
            $client->Message(13, "The rift seizes on your unfinished timelines. "
                . "Restore all four themes by group missions, or all four by "
                . "raids, before Korafax will take you.");
        }
        return 1;
    }
    if ($kind eq 'citadel') {
        if (SodCitadelAccess($client) || $client->GetGM()) {
            $client->Message(15, "Your Tower Key hums; the citadel gate opens.");
            $client->MovePC($dest, $x, $y, $z, 0);
        } elsif (!SodKorafaxAccess($client)) {
            $client->Message(13, "The gate ignores you. Korafax access comes first.");
        } elsif (!_sod_subflag($client, 'korafax-raid-1')
              || !_sod_subflag($client, 'korafax-raid-2')
              || !_sod_subflag($client, 'korafax-raid-3')) {
            $client->Message(13, "The gate ignores you. All three Korafax raid "
                . "lords must fall first.");
        } else {
            $client->Message(13, "The gate demands a Tower Key, looted from a "
                . "Korafax raid.");
        }
        return 1;
    }
    return 0;
}

# ---------------------------------------------------------------------------
# The Void loremasters (478750-478756): miscProgression "raid targets unlock
# Rank 3 spells in The Void". Spell lists live in %SOD_RK3_TIERS
# (plugins/NMS_sod_rk3_data.pl, generated by sod_content/gen_rk3.py).
# Tier 5 (Korafax, level 84) requires all three Korafax raid chains; every
# tier requires its theme's raid chain (group chains unlock nothing here).
# ---------------------------------------------------------------------------
my %SOD_RK3_TIER_FLAG = (
    1 => ['oceangreen-raid'],
    2 => ['kithicor-raid'],
    3 => ['kunark-raid'],
    4 => ['rathe-raid'],
    5 => ['korafax-raid-1', 'korafax-raid-2', 'korafax-raid-3'],
    6 => ['discord-tower'],
);

sub _sod_rk3_tier_unlocked {
    my ($client, $tier) = @_;
    my $flags = $SOD_RK3_TIER_FLAG{$tier} or return 0;
    foreach my $f (@{$flags}) {
        return 0 unless _sod_subflag($client, $f);
    }
    return 1;
}

# Loremaster NPC EVENT_SAY handler. Returns 1 if it consumed the text.
sub SodLoremaster {
    my ($client, $npc_id, $text) = @_;
    return 0 unless $npc_id >= 478750 && $npc_id <= 478756;
    return 0 unless $text =~ /hail|reclaim|progress/i;

    if ($text =~ /reclaim/i) {
        unless (%SOD_RK3_TIERS) {
            $client->Message(13, "The loremaster's tome is empty.");
            return 1;
        }
        my $scribed = 0;
        foreach my $tier (sort { $a <=> $b } keys %SOD_RK3_TIERS) {
            next unless _sod_rk3_tier_unlocked($client, $tier);
            foreach my $sid (@{$SOD_RK3_TIERS{$tier}}) {
                next if $client->HasSpellScribed($sid);
                my $slot = $client->GetNextAvailableSpellBookSlot();
                if ($slot < 0) {
                    $client->Message(13, "Your spell book is full; some "
                        . "lore could not be scribed.");
                    return 1;
                }
                $client->ScribeSpell($sid, $slot);
                $scribed++;
            }
        }
        if ($scribed) {
            $client->Message(15, "The loremaster scribes $scribed Rank III "
                . "spells into your book.");
        } else {
            $client->Message(15, "Your book already holds every Rank III "
                . "spell your victories have earned. Say 'progress' to the "
                . "task givers for your standings.");
        }
        return 1;
    }

    # hail: per-tier report
    foreach my $tier (sort { $a <=> $b } keys %SOD_RK3_TIER_FLAG) {
        my $count = exists $SOD_RK3_TIERS{$tier}
            ? scalar @{$SOD_RK3_TIERS{$tier}} : 0;
        my $state = _sod_rk3_tier_unlocked($client, $tier)
            ? "unlocked" : "sealed";
        $client->Message(15, "Rank III tier $tier ($count spells): $state.");
    }
    $client->Message(15, "Say 'reclaim' to scribe every Rank III spell your "
        . "victories have earned.");
    return 1;
}

# Player-facing progression report (say 'progress' to any giver).
sub SodReport {
    my ($client) = @_;
    foreach my $theme (@SOD_THEMES) {
        my $g = _sod_subflag($client, "$theme-group") ? "group" : "";
        my $r = _sod_subflag($client, "$theme-raid") ? "raid" : "";
        my $state = ($g || $r) ? "done (" . join("+", grep { $_ } ($g, $r)) . ")" : "not done";
        plugin::YellowText(ucfirst($theme) . ": $state");
    }
    plugin::YellowText("Kuua/Discord: " . (_sod_subflag($client, 'korafax-kuua') ? "done" : "not done"));
    plugin::YellowText("Discord Tower: " . (_sod_subflag($client, 'discord-tower') ? "done" : "not done"));
    my @raids = map { _sod_subflag($client, "korafax-raid-$_") ? 1 : 0 } (1, 2, 3);
    plugin::YellowText("Korafax raids: " . join("/", @raids)
        . "  Tower Key: " . ($client->CountItem($SOD_TOWER_KEY) > 0 ? "yes" : "no"));
    plugin::YellowText("Korafax access: " . (SodKorafaxAccess($client) ? "yes" : "no"));
    plugin::YellowText("Your Void: " . uc(SodVoidZone(SodVoidVersion($client)))
        . " (version " . SodVoidVersion($client) . ")");
}

1;

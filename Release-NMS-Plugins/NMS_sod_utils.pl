# NMS_sod_utils.pl - Seeds of Destruction intra-expansion progression.
#
# Implements the raspersrealm SoD miscProgression rules on top of the
# per-account stage-flag system in NMS_progression_utils.pl. All state lives
# as subflags under the existing 'SoD' account stage, so era gating
# (is_eligible_for_zone) is untouched and the two systems cannot disagree.
#
#   Group chain tasks per theme + raid request tasks:
#     oceangreen-group  303000-303005,     oceangreen-raid  303060
#                       303080-303081
#     kithicor-group    303010-303012     kithicor-raid    303061
#     kunark-group      303020-303024     kunark-raid      303062
#     rathe-group       303030-303036     rathe-raid       303063
#     korafax-kuua      303040-303051     korafax-raid-1/2/3  303064-303066
#                                         discord-tower    303067
#   Theme solo/partisan tasks (v145, no chain membership):
#     oceangreen 303100-303119, kithicor 303120-303135,
#     old commonlands 303140-303146
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
# theme flags themselves; mercenaries are enabled server-wide, so the SoD
# mercenary tasks are authored as standard solo tasks (v145).
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
    303080 => 'oceangreen-group', 303081 => 'oceangreen-group',
    303060 => 'oceangreen-raid',  303061 => 'kithicor-raid',
    303062 => 'kunark-raid',      303063 => 'rathe-raid',
    303064 => 'korafax-raid-1',   303065 => 'korafax-raid-2',
    303066 => 'korafax-raid-3',   303067 => 'discord-tower',
);

my %SOD_CHAIN_TASKS = (
    'oceangreen-group' => [303000, 303001, 303002, 303003, 303004, 303005,
                           303080, 303081],
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
    # Freedom! joins the chain live-faithfully: Raxtor offers it after the
    # Tillin tasks, and Beat the Blackburrow Boss now requires it plus the
    # v145 theme tasks Summary Execution (Bracka) and What Evil Lurks
    # (Fripp) -- the live page's full request gate.
    466160 => [[303080, 303003, 303004],
               [303005, 303003, 303004, 303080, 303106, 303107]],  # Raxtor Darkpaw
    466155 => [[303081, ()], [303109, ()]],                         # Elder Mystic Foppye
    # Queen Malarian path (v111): Cadmael carries the path and requests the
    # raid once Jerom's Bubonians task is also done; Stop the Ascension
    # remains requestable here with no prereqs.
    467066 => [[303070, ()], [303071, 303070], [303072, 303071],
               [303078, 303070, 303071, 303072, 303073],
               [303060, ()]],                                       # Apothecary Cadmael
    467069 => [[303073, 303072]],                                   # Jerom Bertrand
    # Kithicor
    456178 => [[303010, ()]],                                       # Lanys T`Vyl (Obliteration)
    456174 => [[303011, 303010]],                                   # Commander Barvian (Light)
    # Bahgresh paths (v111): Tephys -> Firiona -> Laarthik gate the raid.
    456172 => [[303074, ()]],                                       # Lord Tephys (Light)
    456171 => [[303012, 303011], [303075, 303074],
               [303061, 303074, 303075, 303076]],                   # Firiona Vie
    456175 => [[303076, 303075]],                                   # Laarthik V`Shin (Obliteration)
    # Crystal Bloom path (v111): Ulgin's task gates the Crystal Core raid.
    # v150 adds his four themeRathe Darkhammer tasks, gated on the four
    # Delver Hagorn tasks per the page.
    476041 => [[303077, ()], [303079, 303077],
               [303168, 303164, 303165, 303166, 303167],
               [303169, 303164, 303165, 303166, 303167],
               [303170, 303164, 303165, 303166, 303167],
               [303171, 303164, 303165, 303166, 303167]],            # Ulgin Darkhammer
    # Theme solo/partisan tasks (v145): raspersrealm themeOceangreen /
    # themeKithicor achievement lists. The Kithicor and Old Commonlands
    # givers sit behind the %SOD_NECKLACE_GATES necklace check.
    466042 => [[303100, ()], [303101, 303100]],                     # Garvin Windrunner
    466120 => [[303102, ()], [303103, ()], [303104, 303103]],       # Kerrin the Unkempt
    466025 => [[303105, 303104]],                                   # Seradi Stormcaller
    466154 => [[303106, ()]],                                       # Bracka Darkpaw
    466157 => [[303107, ()], [303108, 303107]],                     # Fripp Darkpaw
    466041 => [[303110, ()], [303111, 303110], [303112, 303111]],   # Tabron Caulria
    466052 => [[303113, 303112, 303001], [303114, 303112, 303001]], # Archon Darianna Althus
    466014 => [[303115, ()]],                                       # Jeneca Orlofen
    467060 => [[303117, ()]],                                       # Dan Hearthpride
    467064 => [[303118, ()]],                                       # Yvette Miller
    467075 => [[303119, ()]],                                       # Viktor Snowborn
    468057 => [[303116, ()]],                                       # Guard Ellery
    456060 => [[303120, ()]],                                       # Diennic Lightheart
    456059 => [[303121, ()], [303122, 303121], [303123, 303122]],   # Armsmaster Vohlen
    456067 => [[303124, ()]],                                       # Supplymaster Kibrek
    456106 => [[303125, ()]],                                       # Banesman Aalthene
    456066 => [[303126, ()]],                                       # Thanuel Mergon
    456098 => [[303130, ()]],                                       # Saleb
    456097 => [[303131, ()], [303132, 303131], [303135, 303132]],   # Andylis V`Shrei
    456105 => [[303133, ()], [303134, 303133]],                     # Jarik K`Ahndar
    457195 => [[303140, ()]],                                       # Innkeeper Grang
    456179 => [[303141, ()]],                                       # Warden Avelyn
    457197 => [[303142, ()], [303143, ()], [303144, ()],
               [303145, ()], [303146, ()]],                         # Parthar
    # Kunark / Field of Scale
    452147 => [[303020, ()], [303021, 303020], [303022, 303021],
               [303023, 303022], [303024, 303023],
               [303062, ()]],                                       # Jaled`Dar
    # Rathe
    476122 => [[303030, ()]],                                       # Sterik Gristmaker
    476115 => [[303031, 303030], [303032, 303031], [303033, 303032]],  # Nedsin Tabbels
    476110 => [[303034, 303033], [303035, 303034], [303036, 303035],
               [303063, ()]],                                       # Ylatra the Vassal
    # Rathe theme solo/partisan/mission tasks (v150): raspersrealm
    # themeRathe achievement lists. Not chain tasks (no flags). The four
    # Hagorn tasks gate Ulgin's four (page's full AND prereqs).
    475008 => [[303147, ()]],                                       # an injured slave
    475002 => [[303148, 303147], [303149, 303148], [303150, 303149],
               [303151, 303150]],                                   # Dwerina Feystalker
    475014 => [[303152, 303147]],                                   # Wazlum
    475010 => [[303153, ()]],                                       # Jink (group)
    475003 => [[303154, 303147], [303155, 303154], [303156, ()]],   # Galadvert Nablisten
    475058 => [[303157, ()]],                                       # Fregg the Tamer
    475029 => [[303158, ()]],                                       # Blurik the Runner
    475066 => [[303159, ()]],                                       # Keruk Garrkol, Beetle Herder
    475005 => [[303160, ()], [303161, ()], [303162, ()]],           # Trilyaris (missions)
    476113 => [[303163, ()]],                                       # Dalikand Darkhammer
    476043 => [[303164, 303163], [303165, 303163], [303166, 303163],
               [303167, 303163]],                                   # Delver Hagorn
    # Discord theme solo/partisan tasks (v152): raspersrealm themeDiscord
    # achievement lists. Not chain tasks (no flags); every completion
    # raises Herald Argoth (1226) via the task faction_reward.
    472039 => [[303172, ()]],                                       # Noble Yemall the Arcane
    472057 => [[303173, ()]],                                       # Noble Ramel the Strategist
    472056 => [[303174, ()]],                                       # Noble Mikuv the Rational
    472051 => [[303175, ()], [303176, ()], [303177, ()], [303178, ()]],  # Commander Prezul
    472022 => [[303179, ()]],                                       # Nahsulen the Tactician
    474016 => [[303180, ()], [303183, ()]],                         # General Azerug the Honorable
    474005 => [[303181, ()]],                                       # Grithyank Avlonnon
    474019 => [[303182, ()]],                                       # Ziven
    474012 => [[303184, ()], [303185, ()]],                         # Citykeeper Nardic the Proud
    474011 => [[303186, ()]],                                       # Givrund the Devoted
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
# Necklace gate (Kithicor theme): raspersrealm -- a faction necklace is
# required to interact with the side givers. Values are any-of item lists:
# Army of Light Pendant 41118 (Scout Talendien 456002), Army of
# Obliteration Medallion 41119 (Scout Zialdiruun 456003). The chain givers
# (Lanys / Barvian / Firiona) stay un-gated.
# ---------------------------------------------------------------------------
my %SOD_NECKLACE_GATES = (
    # Army of Light
    456060 => [41118],                       # Diennic Lightheart
    456172 => [41118],                       # Lord Tephys
    456059 => [41118],                       # Armsmaster Vohlen
    456067 => [41118],                       # Supplymaster Kibrek
    456066 => [41118],                       # Thanuel Mergon
    456106 => [41118],                       # Banesman Aalthene
    # Army of Obliteration
    456175 => [41119],                       # Laarthik V`Shin
    456098 => [41119],                       # Saleb
    456097 => [41119],                       # Andylis V`Shrei
    456105 => [41119],                       # Jarik K`Ahndar
    # Old Commonlands -- either army's colors
    457197 => [41118, 41119],                # Parthar
    456179 => [41118, 41119],                # Warden Avelyn
    457195 => [41118, 41119],                # Innkeeper Grang
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
    # v111 miscProgression bonus raids (givers: Cadmael / Ulgin Darkhammer).
    303078 => { name => 'Queen Malarian',           zone => 'oceangreenhills',
                version => 51, zonein => [-1140, 4542, 73],
                compass => ['oceangreenvillage', 362, -2554, 6] },
    303079 => { name => 'Showdown at the Crystal Core', zone => 'korascian',
                version => 51, zonein => [24, -77, 25],
                compass => ['korascian', -2035, 654, -17] },
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

    # Necklace gate (Kithicor theme; GMs walk through).
    my $gate = $SOD_NECKLACE_GATES{$npc_id};
    if ($gate && !$client->GetGM()) {
        my $wears = 0;
        foreach my $item (@{$gate}) {
            $wears = 1 if $client->CountItem($item) > 0;
        }
        if (!$wears) {
            $client->Message(13, "The armies of Kithicor answer only those "
                . "bearing their colors. Take a pendant from the scouts by "
                . "the rift before asking after their work.");
            return 1;
        }
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

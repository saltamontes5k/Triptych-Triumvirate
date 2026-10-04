# Chronicler Elodin - Server Info & Guide NPC (Guild Lobby)
# Adapted for Triptych/EQS from Ascendant-Server
#   (server/quests/guildlobby/Chronicler_Elodin.pl).
# Pure information NPC. Text re-pointed at the systems that actually exist on
# EQS (multiclassing, Triune of Fate / deity blessings, Enchanted/Legendary
# item tiers, the Bazaar tome/insight system).

sub EVENT_SAY {
    if ($text =~ /hail/i) {
        plugin::Whisper("Greetings, $name. I am Chronicler Elodin, keeper of knowledge and guidance for those who walk these halls.");
        plugin::Whisper("I can share information about our realm's unique features:");
        plugin::Whisper(quest::saylink("server overview", 1)." | ".quest::saylink("deity blessings", 1)." | ".quest::saylink("item tiers", 1)." | ".quest::saylink("aa tome system", 1));
        plugin::Whisper(quest::saylink("transportation", 1)." | ".quest::saylink("hub services", 1));
        if (_is_admin($client)) {
            plugin::Whisper("[Admin] " . quest::saylink("admin shard tools", 1, "Shard Tools"));
        }
    }
    elsif (_is_admin($client) && $text =~ /^admin shard tools$/i) {
        _show_shard_tools($client);
    }
    elsif (_is_admin($client) && $text =~ /^shardmover\s+(\d+)$/i) {
        _preview_shard_move($client, int($1));
    }
    elsif (_is_admin($client) && $text =~ /^confirm shardmover\s+(\d+)$/i) {
        _run_shard_move($client, int($1));
    }
    elsif ($text =~ /server overview/i) {
        my $t = "<c \"#FFFFFF\"><b>Welcome to the Triptych (EQS) Server!</b></c><br><br>";
        $t .= "<c \"#FFD700\"><b>Server Philosophy:</b></c><br>";
        $t .= "A <c \"#00FFFF\">multiclass EverQuest server</c>: every character may take up to three classes and command multiple pets, with content tuned for small groups.<br><br>";
        $t .= "<c \"#FFD700\"><b>Key Features:</b></c><br>";
        $t .= "<c \"#00FF00\">•</c> Multiclassing (up to 3 classes)<br>";
        $t .= "<c \"#00FF00\">•</c> Custom cross-class AA tome training<br>";
        $t .= "<c \"#00FF00\">•</c> Deity blessings and world buffs<br>";
        $t .= "<c \"#00FF00\">•</c> Enchanted and Legendary item tiers<br>";
        $t .= "<c \"#00FF00\">•</c> Progression-gated expansions through Seeds of Destruction<br><br>";
        $t .= "<c \"#808080\">Ask me about a specific feature for more details.</c>";
        $client->Popup2("Server Overview", $t, 0, 0, 0, 0);
    }
    elsif ($text =~ /deity blessings|world buffs/i) {
        my $t = "<c \"#FFCC00\"><b>Blessings of Norrath</b></c><br><br>";
        $t .= "EQS has two blessing paths:<br><br>";
        $t .= "<c \"#FFD700\"><b>Deity Blessings</b></c><br>";
        $t .= "Forge a fired idol of your chosen deity and deliver it to a Keeper of Devotion to begin a ten-rank blessing tree. Blessings trigger from melee, spells, and damage taken.<br><br>";
        $t .= "<c \"#FFD700\"><b>World Buffs (Triune of Fate)</b></c><br>";
        $t .= "<c \"#00FFFF\">Triune of Fate</c> is an alternate currency that drops from kills. It can be spent to extend server-wide buffs that apply to <c \"#00FF00\">all</c> players.<br><br>";
        $t .= "<c \"#808080\">Both are account-friendly and persist across sessions.</c>";
        $client->Popup2("Blessings of Norrath", $t, 0, 0, 0, 0);
    }
    elsif ($text =~ /item tiers/i) {
        my $t = "<c \"#FFCC00\"><b>Enchanted &amp; Legendary Item Tiers</b></c><br><br>";
        $t .= "Many items exist in three forms:<br>";
        $t .= "<c \"#00FF00\">• Base</c> - the ordinary drop<br>";
        $t .= "<c \"#00CCFF\">• Enchanted</c> - upgraded stats<br>";
        $t .= "<c \"#CC66FF\">• Legendary</c> - the strongest form<br><br>";
        $t .= "Higher tiers drop from tougher content, and Khael the Spellforger in this hall can attempt to ascend an item using an Ancient Shard.<br><br>";
        $t .= "<c \"#808080\">Always check whether an upgrade already exists before infusing a shard.</c>";
        $client->Popup2("Item Tiers", $t, 0, 0, 0, 0);
    }
    elsif ($text =~ /aa tome system/i) {
        my $t = "<c \"#FFCC00\"><b>Alternative Advancement Tome System</b></c><br><br>";
        $t .= "Discover powerful abilities from <c \"#FFD700\">other classes</c> through ancient tomes!<br><br>";
        $t .= "<c \"#FFD700\"><b>How It Works:</b></c><br>";
        $t .= "<c \"#00FF00\">1. Find Illegible Tomes</c><br>";
        $t .= "<c \"#808080\">  Drop from NPCs throughout the world</c><br>";
        $t .= "<c \"#808080\">  Three tiers: Greater, Exalted, Ascendant</c><br><br>";
        $t .= "<c \"#00FF00\">2. Decipher the Tome</c><br>";
        $t .= "<c \"#808080\">  Bring an illegible tome and platinum to a class trainer in the Bazaar</c><br><br>";
        $t .= "<c \"#00FF00\">3. Learn the Ability</c><br>";
        $t .= "<c \"#808080\">  Spend the training credit on a cross-class AA rank</c><br>";
        $t .= "<c \"#808080\">  Your own class AAs are still earned through experience</c><br><br>";
        $t .= "<c \"#FFD700\"><b>Key NPCs:</b></c><br>";
        $t .= "<c \"#00FFFF\">• Haliax Greycloak</c> - credit redemption, tome recycling, and The Tomeless<br>";
        $t .= "<c \"#00FFFF\">• Class Trainers</c> - sixteen of them, one per class, in the Bazaar<br><br>";
        $t .= "<c \"#808080\">This system lets you gain powerful cross-class abilities that were previously unavailable to your class!</c>";
        $client->Popup2("AA Tome System", $t, 0, 0, 0, 0);
    }
    elsif ($text =~ /transportation/i) {
        my $t = "<c \"#FFCC00\"><b>Getting Around Norrath</b></c><br><br>";
        $t .= "<c \"#FFD700\"><b>AA Abilities (Always Available):</b></c><br>";
        $t .= "<c \"#00FF00\">• Origin</c> - Returns you to your home city (bind point)<br>";
        $t .= "<c \"#00FF00\">• Marked Passage</c> - Marks your location and returns you to the hub, then back again<br><br>";
        $t .= "<c \"#FFD700\"><b>Hub Travel:</b></c><br>";
        $t .= "<c \"#00FFFF\">• Nyra Silvermark</c> - Direct transport to the Bazaar<br>";
        $t .= "<c \"#00FFFF\">• Wizard spires and druid rings</c> - Standard Norrath portals<br><br>";
        $t .= "<c \"#808080\">Tip: Use Marked Passage to quickly return to the hub from anywhere!</c>";
        $client->Popup2("Transportation Guide", $t, 0, 0, 0, 0);
    }
    elsif ($text =~ /hub services/i) {
        my $t = "<c \"#FFCC00\"><b>Guild Lobby Hub Services</b></c><br><br>";
        $t .= "The Guild Lobby serves as the central hub for all adventurers.<br><br>";
        $t .= "<c \"#FFD700\"><b>Key NPCs:</b></c><br>";
        $t .= "<c \"#00FFFF\">• Aurelian Stoneward</c><br><c \"#808080\">  Era-completion tracker; awards and upgrades the Charm of the Nth Age</c><br><br>";
        $t .= "<c \"#00FFFF\">• Khael the Spellforger</c><br><c \"#808080\">  Attempts Enchanted/Legendary upgrades with an Ancient Shard</c><br><br>";
        $t .= "<c \"#00FFFF\">• Morvain the Diminisher</c><br><c \"#808080\">  Strips tiered items back to their base form</c><br><br>";
        $t .= "<c \"#00FFFF\">• Ben Affactor</c><br><c \"#808080\">  Collects platinum and items for new adventurers</c><br><br>";
        $t .= "<c \"#00FFFF\">• the_temporary_reprieve</c><br><c \"#808080\">  Claims pending tome/AA/platinum refunds as Gold Tokens</c><br><br>";
        $t .= "<c \"#00FFFF\">• Kilven the Quartermaster</c><br><c \"#808080\">  General supplies and provisions</c><br><br>";
        $t .= "<c \"#00FFFF\">• Chronicler Elodin</c> (that's me!)<br><c \"#808080\">  Server information and guidance</c><br><br>";
        $t .= "<c \"#808080\">Hail any NPC to learn more about their services!</c>";
        $client->Popup2("Guild Lobby Hub Services", $t, 0, 0, 0, 0);
    }
}

sub _is_admin {
    my ($client) = @_;
    return $client && $client->Admin() >= 100;
}

sub _show_shard_tools {
    my ($client) = @_;
    my $current_instance = $client->GetInstanceID() || 0;
    my $zone_id = $client->GetZoneID();
    my $zone_name = quest::GetZoneShortName($zone_id);
    my @client_list = $entity_list->GetClientList();
    my $count = scalar @client_list;

    plugin::Whisper("Current zone: $zone_name ($zone_id), instance $current_instance, clients in this process: $count.");
    plugin::Whisper("Say 'shardmover <target_instance_id>' to preview moving everyone in this zone process to another instance of the same zone. Use 0 for the base zone.");
}

sub _preview_shard_move {
    my ($client, $target_instance) = @_;
    my ($valid, $message) = _validate_shard_target($client, $target_instance);
    if (!$valid) {
        plugin::Whisper($message);
        return;
    }

    my $current_instance = $client->GetInstanceID() || 0;
    my @client_list = $entity_list->GetClientList();
    my $count = scalar @client_list;
    my $confirm = quest::saylink("confirm shardmover $target_instance", 1, "Confirm move to instance $target_instance");

    plugin::Whisper("Preview: move $count client(s) from instance $current_instance to instance $target_instance.");
    plugin::Whisper("This preserves each player's current coordinates and heading. $confirm");
}

sub _run_shard_move {
    my ($client, $target_instance) = @_;
    my ($valid, $message) = _validate_shard_target($client, $target_instance);
    if (!$valid) {
        plugin::Whisper($message);
        return;
    }

    my $zone_id = $client->GetZoneID();
    my $current_instance = $client->GetInstanceID() || 0;
    my @client_list = $entity_list->GetClientList();
    my @clients_to_move;
    my $issuer;
    my $issuer_char_id = $client->CharacterID();

    foreach my $move_client (@client_list) {
        next unless $move_client;

        if ($move_client->CharacterID() == $issuer_char_id) {
            $issuer = $move_client;
            next;
        }

        push @clients_to_move, $move_client;
    }

    push @clients_to_move, $issuer if $issuer;

    my $count = scalar @clients_to_move;
    if ($count == 0) {
        plugin::Whisper("No clients were found in this zone process.");
        return;
    }

    plugin::Whisper("Moving $count client(s) from instance $current_instance to instance $target_instance. You will move last.");
    quest::debug("[ShardMover] " . $client->GetCleanName() . " moving $count client(s) in zone $zone_id from instance $current_instance to instance $target_instance");

    my $moved = 0;
    foreach my $move_client (@clients_to_move) {
        next unless $move_client;

        my $char_id = $move_client->CharacterID();
        if ($target_instance > 0 && !quest::CheckInstanceByCharID($target_instance, $char_id)) {
            quest::AssignToInstanceByCharID($target_instance, $char_id);
        }

        $move_client->Message(15, "This Guild Lobby shard is being recycled. Moving you to instance $target_instance.");
        $move_client->MovePCInstance(
            $zone_id,
            $target_instance,
            $move_client->GetX(),
            $move_client->GetY(),
            $move_client->GetZ(),
            $move_client->GetHeading()
        );

        $moved++;
    }

    quest::debug("[ShardMover] Requested moves for $moved client(s) to instance $target_instance");
}

sub _validate_shard_target {
    my ($client, $target_instance) = @_;
    my $zone_id = $client->GetZoneID();
    my $current_instance = $client->GetInstanceID() || 0;

    if ($target_instance < 0 || $target_instance > 65535) {
        return (0, "Enter a valid target instance ID between 0 and 65535.");
    }

    if ($target_instance == $current_instance) {
        return (0, "You are already in instance $target_instance.");
    }

    if ($target_instance == 0) {
        return (1, "");
    }

    my $target_zone_id = quest::GetInstanceZoneIDByID($target_instance);
    if (!$target_zone_id) {
        return (0, "Instance $target_instance does not exist.");
    }

    if ($target_zone_id != $zone_id) {
        my $target_zone_name = quest::GetZoneShortName($target_zone_id);
        my $current_zone_name = quest::GetZoneShortName($zone_id);
        return (0, "Instance $target_instance belongs to $target_zone_name, not $current_zone_name.");
    }

    if (!_instance_is_alive($target_instance, $zone_id)) {
        return (0, "Instance $target_instance is expired or unavailable.");
    }

    return (1, "");
}

sub _instance_is_alive {
    my ($target_instance, $zone_id) = @_;

    my $dbh = plugin::LoadMysql();
    return 1 unless $dbh;

    my ($count) = $dbh->selectrow_array(
        "SELECT COUNT(*) FROM instance_list WHERE id = ? AND zone = ? AND (never_expires = 1 OR (start_time + duration) > UNIX_TIMESTAMP())",
        undef,
        $target_instance,
        $zone_id
    );

    return $count && $count > 0;
}

1;

my $MOUNT_COST = 5; # Echo of Memory per random mount

sub EVENT_SAY {
    my $response = "";
    my $clientName = $client->GetCleanName();

    my $link_services = "[".quest::saylink("link_services", 1, "services")."]";
    my $link_mount    = "[".quest::saylink("link_mount", 1, "a random mount")."]";
    my $link_recycle  = "[".quest::saylink("link_recycle", 1, "recycle")."]";

    if ($text =~ /hail/i) {
        $response = "Hail, $clientName! I'm Stablehand Ponyboy, tender of the finest mounts Lady Glamor's flock can offer. I can summon you a steed, though the good ones cost a bit of coin... or rather, a few Echoes of Memory. Ask about my $link_services to learn more.";
    }
    elsif ($text eq "link_services") {
        $response = "For $MOUNT_COST Echoes of Memory, I'll summon you a random mount to call your very own - a bridle or saddle you can use anytime. If it's not to your liking, hand it back and I'll $link_recycle it into something different, no fee charged! Ready to try your luck on $link_mount?";
    }
    elsif ($text eq "link_mount") {
        my $eom_available = $client->GetAlternateCurrencyValue(6);
        if ($eom_available < $MOUNT_COST) {
            $response = "I'm afraid you don't have enough Echo of Memory, $clientName. You need $MOUNT_COST to summon a mount from me. Come back when you've gathered enough.";
        } else {
            my $random_mount = get_random_mount(0, $client);
            if ($random_mount && plugin::SpendEOM($client, $MOUNT_COST)) {
                $client->SummonItem($random_mount);
                plugin::Whisper("Enjoy your new mount, $clientName! Should it not catch your fancy, bring it back and I'll recycle it into something else for free.");
            } else {
                plugin::Whisper("How strange, $clientName. I seem to be having trouble with my flock. Please try again in a moment.");
            }
        }
    }
    elsif ($text eq "link_recycle") {
        $response = "Simply hand me any mount bridle or saddle that I gave you, and I'll swap it for a different random mount at no cost. Recycling is good for the herd, you know!";
    }

    if ($response) {
        plugin::Whisper($response);
    }
}

sub EVENT_ITEM {
    my $clientName = $client->GetCleanName();

    my $handin_mount_item = 0;
    my $handin_zone = "";
    my $dbh = plugin::LoadMysql();

    # Identify a single handed-in mount item and its mount (teleport_zone)
    foreach my $item_id (keys %itemcount) {
        next if $item_id == 0;
        my $sth = $dbh->prepare(
            "SELECT s.teleport_zone FROM items i JOIN spells_new s ON s.id = i.clickeffect
             WHERE i.id = ? AND s.teleport_zone IN (SELECT filename FROM horses) AND i.clicktype = 5 AND i.id < 1000000"
        );
        $sth->execute($item_id);
        if (my $row = $sth->fetchrow_hashref()) {
            $handin_mount_item = $item_id;
            $handin_zone = $row->{teleport_zone};
            last;
        }
    }

    if ($handin_mount_item && plugin::check_handin(\%itemcount, $handin_mount_item => 1)) {
        # Free recycling: swap for a different random mount
        my $new_mount = get_random_mount($handin_zone, $client);
        if ($new_mount) {
            plugin::Whisper("One mount traded for another, $clientName! Let's see what the herd brings you this time...");
            $client->SummonItem($new_mount);
            $dbh->disconnect();
            return;
        } else {
            plugin::Whisper("So sorry, $clientName - it seems the herd is out of new mounts at the moment. I've returned your mount to you.");
            $dbh->disconnect();
            plugin::return_items(\%itemcount);
            return;
        }
    }

    $dbh->disconnect();
    plugin::return_items(\%itemcount);
    plugin::Whisper("I don't need that, $clientName. I only trade in mount bridles and saddles, and a little Echo of Memory.");
}

# Pick one representative item per distinct mount, preferring the "Fast" variant
# when one exists. Optionally exclude a mount (its teleport_zone) for recycling.
# Delivers only mounts usable by the requesting player's class (unrestricted or
# class-matching), so class-steeds like Holy/Unholy Steed only go to their class.
sub get_random_mount {
    my $exclude_zone = shift;
    my $client = shift;
    my $class_bit = 0;
    if ($client) {
        $class_bit = 1 << ($client->GetClass() - 1);
    }
    my $dbh = plugin::LoadMysql();

    my $sql = q{
        WITH m AS (
          SELECT i.id, s.teleport_zone, i.classes,
                 ROW_NUMBER() OVER (PARTITION BY s.teleport_zone ORDER BY (s.teleport_zone LIKE '%Fast') DESC, i.id ASC) AS rn
          FROM items i
          JOIN spells_new s ON s.id = i.clickeffect
          WHERE s.teleport_zone IN (SELECT filename FROM horses)
            AND i.clicktype = 5
            AND i.id < 1000000
        )
        SELECT id FROM m WHERE rn = 1
    };

    $sql .= " AND (classes = 65535 OR (classes & ?) > 0)";
    my @params = ($class_bit);

    if ($exclude_zone) {
        $sql .= " AND teleport_zone <> ?";
        push @params, $exclude_zone;
    }
    $sql .= " ORDER BY RAND() LIMIT 1";
    $sql .= ";";

    my $sth = $dbh->prepare($sql);
    $sth->execute(@params);

    my $id = $sth->fetchrow();
    $dbh->disconnect();
    return $id;
}

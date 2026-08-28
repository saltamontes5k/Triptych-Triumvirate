sub EVENT_ITEM {
    my $clientName = $client->GetCleanName();
    my $dbh = plugin::LoadMysql();

    # Token of Shifting Glamour (item 24152) exchange: get random armour ornament
    if (plugin::check_handin(\%itemcount, 24152 => 1)) {
        my $random_result = get_random_armour();
        if ($random_result) {
            plugin::Whisper("Ah, recycling old glamours! An environmentally conscious choice, $clientName. Let me craft something new from these...");
            $client->SummonItem($random_result);
            $dbh->disconnect();
            return;
        }
    }

    # 1-1 glamour recycling: hand in 1 glamour ornament, get 1 random new one
    my $glamour_id = 0;
    foreach my $item_id (keys %itemcount) {
        if ($item_id != 0) {
            my $item_name = quest::getitemname($item_id);
            if ($item_name =~ /^Glamour -/) {
                $glamour_id = $item_id;
                last;
            }
        }
    }

    if ($glamour_id && plugin::check_handin(\%itemcount, $glamour_id => 1)) {
        my $random_result = get_random_armour();
        if (defined $random_result) {
            plugin::Whisper("Done! One glamour exchanged for another. Let's see what the fates have in store...");
            $client->SummonItem($random_result);
            $dbh->disconnect();
            return;
        } else {
            plugin::Whisper("How strange. I seem to have misplaced my crafting tools. Please try again later.");
        }
    }

    # 5000 platinum only - no items required
    if (plugin::check_handin(\%itemcount, "platinum" => 5000)) {
        my $random_result = get_random_armour();
        if ($random_result) {
            plugin::Whisper("Here you are, $clientName! A freshly enchanted Hero Forge armour ornament. Augment it into any piece of armour to change its appearance!");
            $client->SummonItem($random_result);
        } else {
            plugin::Whisper("I seem to have run out of enchanting materials. Please try again later, $clientName.");
        }
        $dbh->disconnect();
        return;
    }

    $dbh->disconnect();
    plugin::return_items(\%itemcount);
}

sub EVENT_SAY {
    my $response = "";
    my $clientName = $client->GetCleanName();

    my $link_services         = "[".quest::saylink("link_services", 1, "services")."]";
    my $link_services_2       = "[".quest::saylink("link_services", 1, "do for you")."]";
    my $link_glamour          = "[".quest::saylink("link_glamour", 1, "Glamour")."]";
    my $link_custom_work      = "[".quest::saylink("link_custom_work", 1, "custom enchantments")."]";
    my $link_echo_of_memory   = "[".quest::saylink("link_echo_of_memory", 1, "Echo of Memory")."]";
    my $link_random_glamour   = "[".quest::saylink("link_random_glamour", 1, "random glamour")."]";

    if($text=~/hail/i) {
        if (!$client->GetBucket("ArmourGlamour")) {
            $response = "Hail, $clientName. You may refer to me as the Purveyor of Armour Glamour, master artificer of cosmetic enchantments!
                        I specialise in Hero Forge armour ornaments - augments that change the appearance of your armour without altering its properties.
                        I can already offer some $link_services. My colleague next door handles weapons; I handle the armour side of things.";
        } else {
            $response = "Welcome back, $clientName. What can I $link_services_2 today? ";
        }
    }

    elsif ($text eq "link_services") {
        $response = "I offer a simple service: for a fee of 5000 platinum coins, I will enchant a random Hero Forge armour ornament for you.
                    You can then augment that ornament into any piece of armour to change its visual appearance.
                    I also offer $link_custom_work for those seeking something a little different.";
        $client->SetBucket("ArmourGlamour", 1);
    }

    elsif ($text eq "link_glamour") {
        $response = "Simply hand me 5000 platinum coins and I will produce a random Hero Forge armour ornament for you. No other materials needed!
                    You can then augment that ornament into any piece of armour to change its visual appearance.
                    If you already have a glamour ornament you no longer want, hand it back to me and I'll trade it for a different random one!";
    }

    elsif ($text eq "link_custom_work") {
        $response = "I can produce an armour ornament of remarkable and unique nature, based upon whatever design my muse conjures.
                    There is no predicting what cosmetic enchantment may be produced! I will only embark upon this artistic work in exchange
                    for two $link_echo_of_memory, however. Would you like me to produce a $link_random_glamour for you?";
    }

    elsif ($text eq "link_echo_of_memory") {
        $response = "These are rare fragments of a previous age. Rumor is, only by great service to the realm can you obtain them.";
    }

    elsif ($text eq "link_random_glamour") {
        my $eom_available = $client->GetAlternateCurrencyValue(6);

        if ($eom_available < 2) {
            $response = "I'm sorry, $clientName. You don't have enough Echo of Memory, please return when you have enough to pay me.";
        } else {
            my $random_result = get_random_armour();

            if ($random_result && plugin::SpendEOM($client, 2)) {
                $client->SummonItem($random_result);
            }
        }
    }

    if ($response) {
        plugin::Whisper($response);
    }
}

sub get_random_armour {
    my $dbh = plugin::LoadMysql();

    my $sql = q{
        SELECT id
        FROM items
        WHERE augtype = 1048576
          AND herosforgemodel > 0
          AND name NOT LIKE 'Summoned%'
        ORDER BY RAND()
        LIMIT 1;
    };

    my $sth = $dbh->prepare($sql);
    $sth->execute();

    my $id = $sth->fetchrow();
    if (defined $id) {
        quest::debug("Random Armour Ornament: $id");
    } else {
        $client->Message(13, "ERROR: Unable to retrieve random armour ornament. Seek help on #bugs in Discord.");
    }

    $dbh->disconnect();
    return $id;
}

sub EVENT_ITEM { 
    my $clientName = $client->GetCleanName();
    my $dbh = plugin::LoadMysql();

	if (plugin::check_handin(\%itemcount, 24152 => 1)) {
		my $random_result = get_random_glamour_of_any_type();
		if ($random_result) {
			plugin::Whisper("Ah, recycling old glamours! An environmentally conscious choice, $clientName. Let me craft something new from these..."); 
			$client->SummonItem($random_result);
			return;
		}
	}
    
    # First, check if we have items being handed in that are glamours
    my %glamour_handin;  # Will hold the item IDs and quantities for check_handin
    my $total_glamours = 0;
    
    # Identify glamour items and count them
    foreach my $item_id (keys %itemcount) {
        if ($item_id != 0) {
            my $item_name = quest::getitemname($item_id);
            if ($item_name =~ /^Glamour -/) {
                # This is a glamour item
                $glamour_handin{$item_id} = $itemcount{$item_id};
                $total_glamours += $itemcount{$item_id};
            }
        }
    }
    
    # If we have exactly 4 glamour items, process them for recycling
    if ($total_glamours == 4) {
        if (plugin::check_handin(\%itemcount, %glamour_handin)) {
            # Get a random new glamour
            my $random_result = get_random_glamour_of_any_type();
            
            if (defined $random_result) {
                plugin::Whisper("Ah, recycling old glamours! An environmentally conscious choice, $clientName. Let me craft something new from these..."); 
                $client->SummonItem($random_result);
                return; # Skip the rest of the processing
            } else {
                plugin::Whisper("How strange. I seem to have misplaced my crafting tools. Please try again later.");
            }
        }
    }
    
    # Normal glamour creation process
    foreach my $item_id (keys %itemcount) {
        quest::debug("Item ID: $item_id");
        if ($item_id != 0) {
            my $item_name = quest::getitemname($item_id % 1000000);

            my $sth = $dbh->prepare('SELECT id FROM items WHERE name LIKE ?');
            $sth->execute("Glamour - '" . $item_name . "'");
            if (my $row = $sth->fetchrow_hashref()) {
                if (plugin::check_handin(\%itemcount, $item_id => 1, "platinum" => 5000)) {
                    plugin::Whisper("Perfect! Here, I had a Glamour almost ready. I'll just need to attune it to your $item_name! Enjoy!");
                    $client->SummonFixedItem($row->{id});                          
                } else {
                    plugin::Whisper("I must insist upon my fee $clientName for the $item_name. Please ensure you handed me exactly 5000 platinum coins alongside your item.");
                }
            } else {
                plugin::Whisper("I don't think that I can create a Glamour for that item, $clientName. It must be something that you hold in your hand, such as a weapon or shield.");
            }
        }
    }  
   
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
        if (!$client->GetBucket("Tawnos")) {
            $response = "Hail, $clientName. You may refer to me as the Purveyor of Glamour, master artificer and enchanter! 
                        I am still setting up my facilities here in the Bazaar, but I can already offer some $link_services to eager customers.";
        } else {
            $response = "Welcome back, $clientName. What can I $link_services_2 today? ";
        }    
    }

    elsif ($text eq "link_services") {
        $response = "Primarily, I can create a $link_glamour for you. A speciality of my own invention, these augments can change the 
                    appearance of your equipment to mimic another item that you posess. I do charge a nominal fee, a mere 5000 platinum coins, 
                    for this service AND more importantly, the item you want to glamour WILL be sacrificed. 
                    I aim to offer $link_custom_work for my most discerning customers soon, too.";
        $client->SetBucket("Tawnos", 1);
    }

    elsif ($text eq "link_glamour") {
        $response = "If you are interested in a $link_glamour, simply hand me the item which you'd like me to duplicate, along with my fee. PLEASE NOTE: Any item you hand me WILL be devoured in the glamour process.";
    }

    elsif ($text eq "link_custom_work") {
        $response = "I can produce a Glamour of a remarkable and unique nature, based upon whatever item my muse conjures. 
                    There is no predicting what illusion may be produced! I will only embark upon this artistic work in exchange 
                    for two $link_echo_of_memory, however. Would you like me to produce a $link_random_glamour for you?
                    
                    Alternatively, if you have four Glamours you no longer want, you can hand them to me all at once, and I'll create 
                    a new random Glamour for you. It's quite an efficient method of recycling!";
    }

    elsif ($text eq "link_echo_of_memory") {
        $response = "These are rare fragments of a previous age. Rumor is, only by great service to the realm can you obtain them.";
    }

    elsif ($text eq "link_random_glamour") {
        my $eom_available = $client->GetAlternateCurrencyValue(6);

        if ($eom_available < 2) {
            $response = "I'm sorry, $clientName. You don't have enough Echo of Memory, please return when you have enough to pay me.";
        } else {
            my $random_result = get_random_glamour_of_any_type();
            
            if ($random_result && plugin::SpendEOM($client, 2)) {
                $client->SummonItem($random_result);
            }
        }
    }

    if ($response) {
        plugin::Whisper($response);
    }
}

# Serializer
sub SerializeList {
    my @list = @_;
    return join(',', @list);
}

# Deserializer
sub DeserializeList {
    my $string = shift;
    return split(',', $string);
}

# Function to get a random glamour of any type (weapon or armor)
sub get_random_glamour_of_any_type {
    # Randomly choose between weapon or armor glamour
    if (int(rand(2)) == 0) {
        # Get a random weapon glamour
        quest::debug("Generating random weapon glamour");
        return get_random_glamour();
    } else {
        # Get a random armor glamour
        quest::debug("Generating random armor glamour");
        return get_random_armor();
    }
}

sub get_random_glamour {
    my $dbh = plugin::LoadMysql();
    
    # Prepare the SQL statement
    my $sql = q{
                WITH limited_items AS (
                    SELECT
                        name,
                        idfile,
                        MIN(id) AS lowest_id
                    FROM (
                        SELECT
                            name,
                            idfile,
                            id,
                            ROW_NUMBER() OVER (PARTITION BY idfile ORDER BY id ASC) AS rn
                        FROM
                            items
                        WHERE
                            slots & (16384 | 8192 | 2048)
                            AND races > 0
                            AND classes > 0
                            AND ((slots & 2048 AND itemtype = 5) OR (slots & (16384 | 8192)))
                            AND itemtype != 54
                            AND name NOT LIKE 'Summoned%'
                            AND id < 1000000
                    ) sub
                    WHERE
                        rn <= 10
                    GROUP BY
                        idfile, name
                )
                SELECT
                    i.id
                FROM
                    items i
                JOIN
                    limited_items li ON i.name = CONCAT("Glamour - '", li.name, "'")
                ORDER BY RAND()
                LIMIT 1;
    };

    # Prepare the SQL statement
    my $sth = $dbh->prepare($sql);
    
    # Execute the statement
    $sth->execute();

    # Fetch the result (a random item id)
    my $id = $sth->fetchrow(); 
    if (defined $id) {
        quest::debug("Random Weapon Glamour: $id");
    } else {
        $client->Message(13, "ERROR: Unable to retrieve random ornament. Seek help on #bugs in Discord.");
    }

    # Return the fetched ID
    return $id;
}

sub get_random_armor {
    my $dbh = plugin::LoadMysql();
    
    # Prepare the SQL statement
    my $sql = q{
        SELECT id 
        FROM items
        WHERE (
            Name LIKE 'Glamour - \'Heroic %\'' OR
            Name LIKE 'Glamour - \'Elegant %\'' OR
            Name LIKE 'Glamour - \'Ornate %\'' OR
            Name LIKE 'Glamour - \'Resplendant %\''
        ) AND herosforgemodel
        ORDER BY RAND()
        LIMIT 1;
    };

    # Prepare the SQL statement
    my $sth = $dbh->prepare($sql);
    
    # Execute the statement
    $sth->execute();

    # Fetch the result (a random item id)
    my $id = $sth->fetchrow(); 
    if (defined $id) {
        quest::debug("Random Ornament: $id");
    } else {
        $client->Message(13, "ERROR: Unable to retrieve random ornament. Seek help on #bugs in Discord.");
    }

    # Return the fetched ID
    return $id;
}
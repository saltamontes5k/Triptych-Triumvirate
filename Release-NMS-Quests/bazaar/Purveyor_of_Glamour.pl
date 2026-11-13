sub EVENT_ITEM {
    my $clientName = $client->GetCleanName();
    my $dbh = plugin::LoadMysql();

	if (exists $itemcount{24152} && $itemcount{24152} > 0) {
		unless (has_room_for_glamour($client)) {
			whisper_make_room($client, $clientName);
			$dbh->disconnect();
			plugin::return_items(\%itemcount);
			return;
		}
		if (plugin::check_handin(\%itemcount, 24152 => 1)) {
			my $random_result = get_random_glamour();
			if ($random_result) {
				plugin::Whisper("Ah, recycling old glamours! An environmentally conscious choice, $clientName. Let me craft something new from these...");
				$client->SummonItem($random_result);
				$dbh->disconnect();
				return;
			} else {
				# the pool query failed; hand the token back rather than eating it
				plugin::Whisper("How strange. I seem to have misplaced my crafting tools. Your token is returned - please try again later.");
				$client->SummonItem(24152);
				$dbh->disconnect();
				return;
			}
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
        unless (has_room_for_glamour($client)) {
            whisper_make_room($client, $clientName);
            $dbh->disconnect();
            plugin::return_items(\%itemcount);
            return;
        }
        if (plugin::check_handin(\%itemcount, %glamour_handin)) {
            # Get a random new glamour
            my $random_result = get_random_glamour();

            if (defined $random_result) {
                plugin::Whisper("Ah, recycling old glamours! An environmentally conscious choice, $clientName. Let me craft something new from these...");
                $client->SummonItem($random_result);
                $dbh->disconnect();
                return; # Skip the rest of the processing
            } else {
                # the pool query failed; hand the glamours back rather than eating them
                plugin::Whisper("How strange. I seem to have misplaced my crafting tools. Your Glamours are returned - please try again later.");
                foreach my $glamour_id (keys %glamour_handin) {
                    for (my $i = 0; $i < $glamour_handin{$glamour_id}; $i++) {
                        $client->SummonItem($glamour_id);
                    }
                }
                $dbh->disconnect();
                return;
            }
        }
    }
    
    # Normal glamour creation process
    foreach my $item_id (keys %itemcount) {
        quest::debug("Item ID: $item_id");
        if ($item_id != 0) {
            my $item_name = quest::getitemname($item_id % 1000000);

            my $glamour_id = find_glamour_for_item($dbh, $item_id, $item_name);
            if (defined $glamour_id) {
                unless (has_room_for_glamour($client)) {
                    whisper_make_room($client, $clientName);
                    next;   # the item stays in %itemcount and is returned below
                }
                if (plugin::check_handin(\%itemcount, $item_id => 1, "platinum" => 5000)) {
                    plugin::Whisper("Perfect! Here, I had a Glamour almost ready. I'll just need to attune it to your $item_name! Enjoy!");
                    $client->SummonFixedItem($glamour_id);
                } elsif (plugin::check_handin(\%itemcount, $item_id => 1)
                         && $client->GetAlternateCurrencyValue(6) >= 2
                         && plugin::SpendTriuneOfFate($client, 2)) {
                    # Triune payment: the handin above consumed the item, the purse covers the fee
                    plugin::Whisper("Fate pays as well as coin! Here, I had a Glamour almost ready. I'll just need to attune it to your $item_name! Enjoy!");
                    $client->SummonFixedItem($glamour_id);
                } else {
                    plugin::Whisper("I must insist upon my fee $clientName for the $item_name. Please hand me exactly 5000 platinum coins alongside your item - or hand the item alone and I will take two Triune of Fate from your purse instead.");
                }
            } else {
                plugin::Whisper("I don't think that I can create a Glamour for that item, $clientName. It must be something that you hold in your hand, such as a weapon or shield.");
            }
        }
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
    my $link_triune_of_fate  = "[".quest::saylink("link_triune_of_fate", 1, "Triune of Fate")."]";
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
                    appearance of your equipment to mimic another item that you posess. I do charge a nominal fee, a mere 5000 platinum coins
                    or two Triune of Fate, for this service AND more importantly, the item you want to glamour WILL be sacrificed.
                    I aim to offer $link_custom_work for my most discerning customers soon, too.";
        $client->SetBucket("Tawnos", 1);
    }

    elsif ($text eq "link_glamour") {
        $response = "If you are interested in a $link_glamour, simply hand me the item which you'd like me to duplicate, along with my fee - 5000 platinum coins, or hand the item alone and I will take two Triune of Fate from your purse instead. PLEASE NOTE: Any item you hand me WILL be devoured in the glamour process.";
    }

    elsif ($text eq "link_custom_work") {
        $response = "I can produce a Glamour of a remarkable and unique nature, based upon whatever item my muse conjures. 
                    There is no predicting what illusion may be produced! I will only embark upon this artistic work in exchange 
                    for two $link_triune_of_fate, however. Would you like me to produce a $link_random_glamour for you?
                    
                    Alternatively, if you have four Glamours you no longer want, you can hand them to me all at once, and I'll create 
                    a new random Glamour for you. It's quite an efficient method of recycling!";
    }

    elsif ($text eq "link_triune_of_fate") {
        $response = "These are drops of fate itself, gathered where three tides meet. Rumor is, only by great service to the realm can you obtain them.";
    }

    elsif ($text eq "link_random_glamour") {
        my $triune_of_fate_available = $client->GetAlternateCurrencyValue(6);

        if ($triune_of_fate_available < 2) {
            $response = "I'm sorry, $clientName. You don't have enough Triune of Fate, please return when you have enough to pay me.";
        } else {
            my $random_result = get_random_glamour();

            if ($random_result && has_room_for_glamour($client) && plugin::SpendTriuneOfFate($client, 2)) {
                $client->SummonItem($random_result);
            } elsif ($random_result && !has_room_for_glamour($client)) {
                # no room means no sale: the currency is never spent undelivered
                whisper_make_room($client, $clientName);
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

# The Purveyor must never take payment without handing over the goods. Quest
# summons land on the cursor (or a free bag slot), so a free cursor is a
# sufficient precondition for a guaranteed delivery.
sub has_room_for_glamour {
    my ($client) = @_;
    return ($client->GetItemIDAt(0) == 0) ? 1 : 0;
}

sub whisper_make_room {
    my ($client, $clientName) = @_;
    plugin::Whisper("Make room for the work first, $clientName - empty your cursor, then ask me again. I refuse to take payment I cannot repay with a Glamour.");
}

# Work out which Glamour to hand back for a given item.
#
# Step 1 is the original behaviour: look the item up by name, "Glamour - '<item name>'".
# Step 2 covers de-duplication. Identical-looking Glamours were collapsed down to one
# keeper per (slot mask, appearance) pair, so many base items no longer have a Glamour
# carrying their own name. Every removed Glamour left its name behind in glamour_alias
# pointing at the keeper that absorbed it, so handing in a culled item still returns the
# same look. Nothing is lost - only the redundant duplicate rows are gone.
sub find_glamour_for_item {
    my ($dbh, $item_id, $item_name) = @_;

    return undef if $item_name =~ /^Glamour - /;   # already a Glamour, the recycling paths own these

    my $key = "Glamour - '" . $item_name . "'";

    my $sth = $dbh->prepare('SELECT id FROM items WHERE name LIKE ? LIMIT 1');
    $sth->execute($key);
    my $exact = $sth->fetchrow();
    return $exact if defined $exact;

    my $alias = $dbh->prepare('SELECT glamour_id FROM glamour_alias WHERE name = ? LIMIT 1');
    $alias->execute($key);
    my $keeper = $alias->fetchrow();
    return $keeper;
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
                    id
                FROM (
                    SELECT
                        i.id AS id
                    FROM
                        items i
                    JOIN
                        limited_items li ON i.name = CONCAT("Glamour - '", li.name, "'")
                    UNION
                    SELECT
                        id
                    FROM
                        items
                    WHERE
                        id IN (24112, 24113, 24114, 24115, 24116, 24117, 24139, 24140, 24141, 24142, 24143, 24144)
                ) AS glamour_pool
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
    $dbh->disconnect();
    return $id;
}

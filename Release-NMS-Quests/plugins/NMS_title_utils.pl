# Progression Titles - Earned during Seasonal Play
# Classic -> Hero of Antonica, Hero of Faydwer, Hero of Odus
# Kunark  -> Hero of Kunark
# Velious -> Hero of Velious
# Luclin  -> Hero of Luclin
# Planes (ELEMENTAL UNLOCK) -> Hero of the Planes

sub AddTitleFlag {
    my $title_id = shift;
    my $client = shift || plugin::val('$client');

    # Retrieve and deserialize the account and character title lists
    my @account_titles = plugin::DeserializeList(quest::get_data($client->AccountID() . "-titles-unlocked"));
    my @character_titles = plugin::DeserializeList($client->GetBucket("titles-unlocked"));

    # Add the new title ID to both lists if it is not already present
    push @account_titles, $title_id unless grep { $_ == $title_id } @account_titles;
    push @character_titles, $title_id unless grep { $_ == $title_id } @character_titles;

    # Reserialize the updated lists
    my $serialized_account_titles = plugin::SerializeList(@account_titles);
    my $serialized_character_titles = plugin::SerializeList(@character_titles);

    # Store the updated lists
    quest::set_data($client->AccountID() . "-titles-unlocked", $serialized_account_titles);
    $client->SetBucket("titles-unlocked", $serialized_character_titles);

    EnableTitles($client);
}

sub EnableTitles {
    my $client = shift;
    my $new_title = undef;
    
    # Retrieve and deserialize the account and character title lists
    my @account_titles = plugin::DeserializeList(quest::get_data($client->AccountID() . "-titles-unlocked"));
    my @character_titles = plugin::DeserializeList($client->GetBucket("titles-unlocked"));

    if (!plugin::IsSeasonal($client)) {
        # Iterate over the account titles and enable each one
        foreach my $title_id (@account_titles) {
            if (!quest::checktitle($title_id)) {
                quest::debug("Attempting to enable $title_id for account " . $client->AccountID());
                quest::enabletitle($title_id);
                $new_title = "true";
            }
        }
    }

    # Iterate over the character titles and enable each one
    foreach my $title_id (@character_titles) {
        if (!quest::checktitle($title_id)) {
            quest::enabletitle($title_id);
            $new_title = "true";
        }
    }

    # Notify the client if new titles have been enabled
    if ($new_title) {
        $client->NotifyNewTitlesAvailable();
    }
}

sub HasTitle {
    my $title_id = shift;
    my $client = shift || plugin::val('$client');

    # First check if the title is currently enabled/active
    if (quest::checktitle($title_id)) {
        return 1;
    }

    # Check account-wide titles (if not seasonal)
    if (!plugin::IsSeasonal($client)) {
        my @account_titles = plugin::DeserializeList(quest::get_data($client->AccountID() . "-titles-unlocked"));
        if (grep { $_ == $title_id } @account_titles) {
            return 1;
        }
    }

    # Check character-specific titles
    my @character_titles = plugin::DeserializeList($client->GetBucket("titles-unlocked"));
    if (grep { $_ == $title_id } @character_titles) {
        return 1;
    }

    return 0;
}

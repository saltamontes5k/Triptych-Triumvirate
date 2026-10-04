# argan_initial.pl
# Quest – Argan’s Suffering (Initial + Saryrn Key turn-in)

sub EVENT_SAY {
    my $suffering_link = quest::saylink("What suffering?", 1);
    my $aid_link       = quest::saylink("Yes, I am here to aid you.", 1);
    my $save_link      = quest::saylink("save what is left of your memories", 1);
    my $key_link       = quest::saylink("bring me the key", 1);

    if ($text=~/hail/i) {
        quest::whisper("Argan Milek weakly extends his arms in an effort to ascertain your location, then clutches his eyes and screams, 'Who are you! Back away... leave me alone! Is my current suffering not enough?' $suffering_link");
    }
    elsif ($text=~/what suffering\?/i) {
        quest::whisper("Argan Milek says 'Who are you? Are you here to aid me?' $aid_link");
    }
    elsif ($text=~/yes, I am here to aid you/i) {
        quest::whisper("Argan Milek sobs, 'I am so relieved to hear those words! Please help me to escape this place. She has taken my sight and replaced it with loathsome visions of some distant prison. The Foul Mistress mocks the only thing I once felt a kinship to — my art. I cannot scrub these visions from my eyes. I fear that I will never be able to paint again. Can you $save_link? Once you have restored my sight, you must also $key_link.'");
    }
    elsif ($text=~/save what is left of your memories/i) {
        quest::whisper("Then descend into the horrors and I will meet you there once complete.");

        my $inst_id = $client->GetInstanceID();
        $client->MovePCInstance(207, $inst_id, 434.01, 1200.16, -731.94, 2);

        # Databucket flag (started)
        my $cid = $client->CharacterID();
        my $flag_key = "potor_argan_started_$cid";
        quest::set_data($flag_key, 1);
    }
    elsif ($text=~/bring me the key/i) {
        quest::whisper("Druzzil Ro showed me a vision of a key — a screaming sphere of tormented souls. Bring it to me, and I will unlock further truths of this realm for you.");
    }
}

sub EVENT_ITEM {
    my $cid = $client->CharacterID();

    # Saryrn Key item ID
    my $key_item = 22954;

    # Player handed in Saryrn Key
    if (plugin::check_handin(\%itemcount, $key_item => 1)) {

        quest::whisper("This sphere... the voices scream endlessly. Yes, this is the key to Saryrn’s Citadel. I will infuse it with the clarity granted to me by Druzzil Ro. Take it back — and know that with this, you may face the horrors guarding Saryrn's tower.");

        # Return the key to player
        quest::summonitem($key_item);

        # Set databucket flag
        my $flag_key = "potor_saryrn_key_complete_$cid";
        quest::set_data($flag_key, 1);

        # Additional flavor
        quest::whisper("Seek the tormentors: The Acolyte of Affliction, Maareq the Prophet, Salczek the Fleshgrinder, and Ta'Grusch the Abomination. Only with this key's empowerment will your weapons strike true.");

    }

    plugin::return_items(\%itemcount);
}

1;
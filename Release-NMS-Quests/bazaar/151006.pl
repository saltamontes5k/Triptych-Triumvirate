sub EVENT_SAY {
    my $ip_string = $client->GetIPString();
    $ip_string =~ s/\./-/g;

    my $key = "ExemptionRequest-$ip_string";

    my @eq_passphrases = (
        'innoruuk', 'cazic thule', 'tunare', 'bristlebane', 'karana', 'prexus',
        'rodcet nife', 'quellious', 'mithaniel marr', 'erollisi marr', 'rallos zek',
        'solusek ro', 'the tribunal', 'veeshan', 'bertroxulous', 'brell serilis',
        'lord nagafen', 'lady vox', 'trakanon', 'gorenaire', 'severilous', 'talendor',
        'klandicar', 'zlandicar', 'wuoshi', 'dozekar the cursed', 'kelorek dar',
        'emperor ssraeshza', 'thought horror overfiend', 'the insanity crawler',
        'grieg veneficus', 'xerkizh the creator',
        'saryrn', 'quarm',
        'firiona vie', 'mayong mistmoore', 'phinigel autropos', 'venril sathir',
        'aten ha ra', 'kerafyrm', 'drusella sathir', 'nexona',
        'qeynos', 'freeport', 'halas', 'rivervale', 'akanon',
        'felwithe', 'kelethin', 'kaladim', 'neriak', 'oggok',
        'grobb', 'cabilis', 'erudin', 'shar vahl'
    );

    if ($text =~ /^hail/i) {
        if ($client->GetIPExemption() > 1) {
            plugin::NPCTell("Greetings, $name! You already have an exemption. Have fun! For more, contact a GM or Guide on Discord.");
            return;
        }
        plugin::NPCTell("Greetings, $name! If you often have a companion struggling to meet up due to the restraints of the world, I can [help]!");
        return;
    }

    if ($text =~ /^help/i) {
        plugin::NPCTell("Excellent. This service relies on your honesty. If used for multiboxing, all accounts from your IP will be banned when you are caught. When you're ready, say 'ready'. Your friend must then do the same and choose the matching phrase.");
        return;
    }

    if ($text =~ /^ready/i) {
        my $data = quest::get_data($key);

        if ($data) {
            my ($gnome_id, $passphrase, $choices_str) = split(/\|/, $data);
            if ($gnome_id != $npc->GetID()) {
                my $options_text = "Choose the correct phrase by clicking one of these options:";
                foreach my $choice (split(/,/, $choices_str)) {
                    $options_text .= " [$choice]";
                }
                plugin::NPCTell($options_text);
                return;
            }
        }

        my $chosen = $eq_passphrases[int(rand(@eq_passphrases))];
        my %used = ($chosen => 1);
        my @options = ($chosen);
        while (@options < 10) {
            my $candidate = $eq_passphrases[int(rand(@eq_passphrases))];
            next if $used{$candidate}++;
            push @options, $candidate;
        }

        @options = sort { rand() <=> rand() } @options;
        my $choices_str = join(',', @options);

        my $store_value = join('|', $npc->GetID(), $chosen, $choices_str);
        quest::set_data($key, $store_value, "6s");

        plugin::NPCTell("Understood. Tell your friend to say 'ready' to their gnome. They will be shown a list of options and must choose '$chosen' to complete the exemption request.");
        return;
    }

    if ($text =~ /^(.+)$/i) {
        my $guess = $1;
        my $data = quest::get_data($key);
        if (!$data) {
            return;
        }

        my ($gnome_id, $passphrase, $choices_str) = split(/\|/, $data);
        
        my $is_valid_choice = 0;
        foreach my $option (split(/,/, $choices_str)) {
            if (lc($guess) eq lc($option)) {
                $is_valid_choice = 1;
                last;
            }
        }
        
        if ($is_valid_choice) {
            if (lc($guess) eq lc($passphrase) && $gnome_id != $npc->GetID()) {
                quest::delete_data($key);
                plugin::NPCTell("Your IP exemption has been granted. You and your friend may now play together without restrictions for this session.");
                $client->SetIPExemption(2);
            } else {
                quest::delete_data($key);
                plugin::NPCTell("That was not the correct choice. The request has been cancelled. You and your friend must start over.");
            }
            return;
        }
    }
}
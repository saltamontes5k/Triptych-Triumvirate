sub EVENT_SPELL_EFFECT_CLIENT {
    my $reward = GetRandomReward();

    if ($reward) {
        quest::summonfixeditem($reward);
    }

    my $account_key 	= $client->AccountID() . "-ess-items-opened";
    quest::set_data($account_key, (quest::get_data($account_key) || 0) + 1);
}

sub GetRandomReward() {
    my %my_rewards = (
        700010 => 30, # Red Elf Hat
        700011 => 30, # Green Elf Hat
        700012 => 30, # Glowing Nose
        700013 => 30, # Reindeer Antlers
        700015 => 30, # Top Hat
        700017 => 30, # Helper's Hat
        700018 => 30, # Striped Helper's Hat
        11010  => 600, # Elvish Hot Chocolate
        2828   => 20,  # Rimefrost Kopesh
        2829   => 20,  # Rimefrost Hammer
        2830   => 20,  # Rimefrost Naginata
        2854   => 20,  # Rimefrost Staff
        2855   => 20,  # Rimefrost Bow
        2856   => 20,  # Rimefrost Cestus
        2857   => 20,  # Rimefrost Shield
        4038   => 20,  # Rimefrost Dagger
        700016 => 10,  # Primitive Snow Golem Head
        2001800 => 10, # Decanter of Endless Hot Chocolate
        4041 => 5,
    );

    my $total_weight = 0;
    foreach my $weight (values %my_rewards) {
        $total_weight += $weight;
    }

    my $rand = int(rand($total_weight));

    my $sum = 0;
    foreach my $key (keys %my_rewards) {
        $sum += $my_rewards{$key};
        if ($rand < $sum) {
            return $key;
        }
    }
    return 0;
}
sub EVENT_SAY {
    if ($text=~/hail/i) {
        quest::say("Greetings, $name. I am an envoy from the OESS - Other Elvish Security Services. We are here to collect [items] which were stolen from cities across Norrath!");
    } 

    if ($text=~/items/i) {
        quest::say("Indeed. A number of gifts destined for the children of Norrath were stolen by roving bands of monsters. We are here to collect them and return them to their rightful place. 
                    These gift boxes have been seized by numerous creatures, and I've heard rumors that the shady looking halfling in the corner of the Bazaar may have also
                    claimed a number of them. We are offering a reward for the return of these items, and the individuals who bring us the largest quantity of them before we depart may
                    receive an additional reward!");
    }
}

sub EVENT_ITEM {
    while (plugin::check_handin(\%itemcount, 2827 => 1)) {
        quest::say("Thank you Hero! Your kindness will bring a little more joy to Norrath!");
        my $reward = GetRandomReward();
        if ($reward) {
            quest::summonfixeditem($reward);
        }

        my $account_key 	= $client->AccountID() . "-ess-items-returned";
        quest::set_data($account_key, (quest::get_data($account_key) || 0) + 1);
    }

    plugin::return_items(\%itemcount);
}

sub GetRandomReward {
    my %my_rewards = (
        4040 => 99, 
        2004041 => 1, 
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

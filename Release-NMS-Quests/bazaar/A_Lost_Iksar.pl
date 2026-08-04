my $item1 = 2028043;
my $item2 = 2010366;
my $item3 = 2010142;
my $item4 = 2026997;

my $token_item = 2019100;

my $stage_desc  = "Ruins of Kunark";
my $hero_desc   = "Slay the champions of the Old World; Nagafen and Vox.";
my $stage_key   = "RoK";
my @target_list = ('Lord Nagafen', 
                   'Lady Vox');

sub EVENT_SAY {
    if ($text=~/hail/i) {
        plugin::ConvertFlags($client);
        if (plugin::is_stage_complete($client, $stage_key)) {
            plugin::YellowText("You have access to the $stage_desc.");
        } else {
            if (plugin::is_stage_complete_2($client, $stage_key)) {
                plugin::YellowText("You will have access to the $stage_desc when the time-lock is expired.");
            } else {
                plugin::NPCTell("To gain access to the $stage_desc, two paths lie before you; [hero] and [explorer].");
            }
        }
    }
    elsif (!plugin::is_stage_complete($client, $stage_key)) {
        if ($text =~/hero/i) {
            plugin::NPCTell($hero_desc);
            plugin::list_stage_prereq($client, $stage_key);            
        }
        if (($text =~/explorer/i)){
            my $item1_flag = $client->GetAccountBucket("$item1-flag") || 0;
            my $item2_flag = $client->GetAccountBucket("$item2-flag") || 0;
            my $item3_flag = $client->GetAccountBucket("$item3-flag") || 0;
            my $item4_flag = $client->GetAccountBucket("$item4-flag") || 0;

            my $item1_link = quest::varlink($item1);
            my $item2_link = quest::varlink($item2);
            my $item3_link = quest::varlink($item3);
            my $item4_link = quest::varlink($item4);

            my $response_string = "In that case, all you need to do is bring me one of each of the following: [$item1_link], [$item2_link], [$item3_link], and [$item4_link].";
            if (!plugin::MultiClassingEnabled()) {
                $response_string = $response_string . " Not only will I grant you access to the $stage_desc, but I will give you two tokens so that your companions can present them to me in order to also gain access.";
            }

            plugin::NPCTell($response_string);

            if ($item1_flag) {
                plugin::YellowText("You have collected a [$item1_link].");
            } else {
                plugin::YellowText("You yet to collect a [$item1_link].");
            }

            if ($item2_flag) {
                plugin::YellowText("You have collected a [$item2_link].");
            } else {
                plugin::YellowText("You yet to collect a [$item2_link].");
            }

            if ($item3_flag) {
                plugin::YellowText("You have collected a [$item3_link].");
            } else {
                plugin::YellowText("You yet to collect a [$item3_link].");
            }

            if ($item4_flag) {
                plugin::YellowText("You have collected a [$item4_link].");
            } else {
                plugin::YellowText("You yet to collect a [$item4_link].");
            }
        }
    }
}

sub EVENT_ITEM {
    if (plugin::check_handin(\%itemcount, $token_item => 1)) {
        foreach my $target (@target_list) {
            plugin::SetSubflag($client, $stage_key, $target, 1);
        }

        plugin::NPCTell("You want to call in a favor? Fine. Going forward, you will be able to access the $stage_desc.");
        quest::ding();

        plugin::CommonCharacterUpdate($client);
        return;
    } elsif (!plugin::is_stage_complete($client, $stage_key)) {
        my $item1_flag = $client->GetAccountBucket("$item1-flag") || 0;
        my $item2_flag = $client->GetAccountBucket("$item2-flag") || 0;
        my $item3_flag = $client->GetAccountBucket("$item3-flag") || 0;
        my $item4_flag = $client->GetAccountBucket("$item4-flag") || 0;

        my $item1_link = quest::varlink($item1);
        my $item2_link = quest::varlink($item2);
        my $item3_link = quest::varlink($item3);
        my $item4_link = quest::varlink($item4);

        if (!$item1_flag && plugin::check_handin(\%itemcount, $item1 => 1)) {
            plugin::NPCTell("Perfect, this [$item1_link] is exactly what I needed.");
            $client->SetAccountBucket("$item1-flag", 1);
            $item1_flag = 1;
        }

        if (!$item2_flag && plugin::check_handin(\%itemcount, $item2 => 1)) {
            plugin::NPCTell("Perfect, this [$item2_link] is exactly what I needed.");
            $client->SetAccountBucket("$item2-flag", 1);
            $item2_flag = 1;
        }

        if (!$item3_flag && plugin::check_handin(\%itemcount, $item3 => 1)) {
            plugin::NPCTell("Perfect, this [$item3_link] is exactly what I needed.");
            $client->SetAccountBucket("$item3-flag", 1);
            $item3_flag = 1;
        }

        if (!$item4_flag && plugin::check_handin(\%itemcount, $item4 => 1)) {
            plugin::NPCTell("Perfect, this [$item4_link] is exactly what I needed.");
            $client->SetAccountBucket("$item4-flag", 1);
            $item4_flag = 1;
        }

        if ($item1_flag && $item2_flag && $item3_flag && $item4_flag) {            
            foreach my $target (@target_list) {
                plugin::SetSubflag($client, $stage_key, $target, 1);
            }

            plugin::NPCTell("Excellent, you have collected all of the items which I require. Going forward, you will be able to access the $stage_desc.");
            $client->UnlockWaypoint("dreadlands");
            quest::ding();      
            if (!plugin::MultiClassingEnabled()) {
                plugin::NPCTell("Here are two additional tokens for your companions to also gain access to the $stage_desc");
                quest::summonfixeditem($token_item);
                quest::summonfixeditem($token_item);  
            }

        } else {
            if ($item1_flag) {
                plugin::YellowText("You have collected a [$item1_link].");
            } else {
                plugin::YellowText("You yet to collect a [$item1_link].");
            }

            if ($item2_flag) {
                plugin::YellowText("You have collected a [$item2_link].");
            } else {
                plugin::YellowText("You yet to collect a [$item2_link].");
            }

            if ($item3_flag) {
                plugin::YellowText("You have collected a [$item3_link].");
            } else {
                plugin::YellowText("You yet to collect a [$item3_link].");
            }

            if ($item4_flag) {
                plugin::YellowText("You have collected a [$item4_link].");
            } else {
                plugin::YellowText("You yet to collect a [$item4_link].");
            }
        }   
    }

    plugin::return_items(\%itemcount);
}
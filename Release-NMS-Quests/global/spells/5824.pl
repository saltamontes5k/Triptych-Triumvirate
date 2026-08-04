# Bazaar Portal
sub EVENT_SPELL_EFFECT_CLIENT {
    use List::Util qw(shuffle);
    my $client      = plugin::val('$client');
    my $bind_loc = $client->GetBucket("baz_and_back_bind") || 'bazaar';
    my %locations;

    if ($client->GetInventory()->HasItem(17899,1,2) > 1) {
        $client->Message(13, "Trader's Satchels may not leave the Bazaar.");
        $client->SendMarqueeMessage(13, "Trader's Satchels may not leave the Bazaar.");
        return;
    }

    # Define possible locations in zone 151 (Bazaar)
    my %baz_locations = (
        'safe_location' => [quest::GetZoneSafeX(151), quest::GetZoneSafeY(151), quest::GetZoneSafeZ(151), quest::GetZoneSafeHeading(151)],
        'Location A'    => [-135, -550, 5, 300],
        'Location B'    => [100, -500, 5, 300],
        'Location C'    => [95, -300, 5, 300],
        'Location G'    => [45, -820, 4, 450],
        'Upstairs'      => [15, -655, 27, 290],
        'Aporia 1'      => [217, -578, 2, 3],
        'Aporia 2'      => [-179, -151, -16, 254],
        'Aporia 3'      => [168, -149, -16, 259],
        'Aporia 4'      => [-148, -481, 3, 310],
    );

    # Define possible locations in ecommons zone
    my %ecommons_locations = (
        'Location A'    => [-245, -1558, 4, 0],
        'Location B'    => [-335, -1630, 4, 100],
        'Location C'    => [-340, -1815, 4, 50],
        'Location D'    => [-125, -1800, 4, 100],
        'Location E'    => [-125, -1600, 4, 100],
        'Location F'    => [-55, -1750, 4, 450],
        'Location G'    => [-82, -1550, 4, 100],
    );

    # Assign locations based on $bind_loc
    if ($bind_loc eq 'bazaar') {
        %locations = %baz_locations;
    } elsif ($bind_loc eq 'ecommons') {
        %locations = %ecommons_locations;
    } else {        
        %locations = %baz_locations;
    }

    $bind_loc = quest::GetZoneID($bind_loc);

    # Shuffle the keys and pick a random location
    my @keys = shuffle(keys %locations);
    my $chosen_loc = $locations{$keys[0]};

    # Apply the randomization of +/- 5 to X and Y
    my $randomized_x    = $chosen_loc->[0] + int(rand(11)) - 5;
    my $randomized_y    = $chosen_loc->[1] + int(rand(11)) - 5;
    my $z               = $chosen_loc->[2];
    my $heading         = rand(512);

    if ($zoneid != $bind_loc) {
        # Save the current location
        $client->SetBucket("Return-X", $client->GetX());
        $client->SetBucket("Return-Y", $client->GetY());
        $client->SetBucket("Return-Z", $client->GetZ());
        $client->SetBucket("Return-H", $client->GetHeading());
        $client->SetBucket("Return-Zone", $zoneid);
        $client->SetBucket("Return-Instance", $instanceid);

        my $group = $client->GetGroup();
        if ($group) {
            for (my $count = 0; $count < $group->GroupCount(); $count++) {
                my $player = $group->GetMember($count);
                if ($player && $player->GetID() != $client->GetID() && $client->CalculateDistance($player) <= 200) {
                    foreach $npc (@npc_list)
		            {
                        if ($npc->IsOnHatelist($player)) {
                            return;
                        }
                    }

                    my $tar_zone_ln = quest::GetZoneLongNameByID($bind_loc);

                    my $popup_title = "Return to the Bazaar";
                    my $popup_text  = "Would you like to return to $tar_zone_ln with your groupmate?";
                    my $popup_yes   = 58240;
                    my $popup_no    = 58241;
                    my $popup_duration = 30;

                    $player->Popup2($popup_title, $popup_text, $popup_yes, $popup_no, 2, $popup_duration);
                    $player->SetEntityVariable("bazaar_x", $chosen_loc->[0]);
                    $player->SetEntityVariable("bazaar_y", $chosen_loc->[1]);
                    $player->SetEntityVariable("bazaar_z", $chosen_loc->[2]);
                    $player->SetEntityVariable("bazaar_h", $chosen_loc->[3]);
                    $player->SetEntityVariable("bazaar_zone", $bind_loc);
                }
            }
        }

        # intro quest
        if ($client->IsTaskActivityActive(3, 0)) {
            $client->UpdateTaskActivity(3, 0, 1); #Update 'Travel to Bazaar'
        }

        # Move the player to the Bazaar at a randomized location
        $client->MovePC($bind_loc, $randomized_x, $randomized_y, $z, $heading);
    } else {
        # Return player to the saved location or bind point if no saved location exists
        my $ReturnX = $client->GetBucket("Return-X");
        my $ReturnY = $client->GetBucket("Return-Y");
        my $ReturnZ = $client->GetBucket("Return-Z");
        my $ReturnH = $client->GetBucket("Return-H");
        my $ReturnZone = $client->GetBucket("Return-Zone");
        my $ReturnInstance = $client->GetBucket("Return-Instance");

        if (defined($ReturnX) && $ReturnX ne '' && 
            defined($ReturnY) && $ReturnY ne '' && 
            defined($ReturnZ) && $ReturnZ ne '' && 
            defined($ReturnH) && $ReturnH ne '' && 
            defined($ReturnZone) && $ReturnZone ne '') {
            # Delete the saved location
            $client->DeleteBucket("Return-X");
            $client->DeleteBucket("Return-Y");
            $client->DeleteBucket("Return-Z");
            $client->DeleteBucket("Return-H");
            $client->DeleteBucket("Return-Zone");
            $client->DeleteBucket("Return-Instance");            
        } else {            
            # Use the bind location if no saved location exists
            $ReturnX = $client->GetBindX();
            $ReturnY = $client->GetBindY();
            $ReturnZ = $client->GetBindZ();
            $ReturnH = $client->GetBindHeading();
            $ReturnZone = $client->GetBindZoneID();
            $ReturnInstance = 0;          
        }

        # intro quest
        if ($client->IsTaskActivityActive(3, 4)) {
            $client->UpdateTaskActivity(3, 4, 1); # Update 'return from Bazaar
        }

        # Move the player back to the original location or bind point
        $client->MovePCInstance($ReturnZone, $ReturnInstance, $ReturnX, $ReturnY, $ReturnZ, $ReturnH);
    }
}



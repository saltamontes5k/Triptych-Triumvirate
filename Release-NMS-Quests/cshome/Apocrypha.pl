# Basic Design
# EoM (Server-Wide) buffs work by three methods;
# 1) Send a worldwide client signal, global_player catches it and applies the requested buffs
# 2) Set a bucket value with a 4 hour expiration.
# 3) Zone and Login methods in global_player apply the requested buffs with the requested durations

my $duration_override = 900; #set this value to override 'regular' buffs duration

sub handle_buff_for_level {
    my $buff_map = {
        1 => [2525, 314, 278, 145, 356, 170], # Free - Harnessing of Spirit, Resolution, Spirit of Wolf, Chloroplast, Shield of Thorns, Alacrity
        20 => [2525, 314, 278, 145, 356, 170], # 10pp - Harnessing of Spirit, Resolution, Spirit of Wolf, Chloroplast, Shield of Thorns, Alacrity
        46 => [2530, 2510, 2524, 2528, 2895, 2570], # 250pp - Khura's Focus, Blessing of Aegolism, Spirit of Bih'li, Regrowth of Dark Khura, Speed of the Brood, Koadics Endless Intellect
        61 => [3397, 3479, 2524, 3441, 3178, 3360], # 500pp - Voice of Quellious, Vallons Quickening, Blessing of Replenishment, Spirit of Bih'li, Hand of Virtue, Focus of the Seventh
        # ... more ...
    };

    my $price_map = {
        1  => 0,
        20 => 10,
        46 => 250,
        61 => 500,
    };

    my $client_level = $client->GetLevel();
    my $closest_level = 0;

    # Find the closest level in the map, not exceeding the client's level
    foreach my $level (keys %$buff_map) {
        if ($level <= $client_level && $level > $closest_level) {
            $closest_level = $level;
        }
    }

    # If a matching level was found, perform actions with its associated list
    if ($closest_level > 0) {
        if ($client->TakeMoneyFromPP($price_map->{$closest_level} * 1000)) {
            my $buffs = $buff_map->{$closest_level};

            # Here, do something with the list of buffs
            foreach my $buff (@$buffs) {
                if ($duration_override) {                
                    $client->ApplySpellGroup($buff, $duration_override);
                } else {
                    $client->ApplySpellGroup($buff);
                }
            }

            plugin::Whisper("Enjoy your newfound power.");
        } else {
            plugin::Whisper("You do not have enough coin to afford that.");
        }
    }
}

sub EVENT_SAY {
    my $response = "";
    my $clientName = $client->GetCleanName();
    my $ww_buff = 0;

    if ($text=~/hail/i) {   
        $response = "Hail, Adventurer. I seek to empower your ilk for my own profit. For a [modest fee], I will enhance the power of your group for a time. In exchange for more [exotic payment], I will enhance the power of all adventurers in the world.";
    }

    elsif ($text=~/modest fee/i) {
        $response = "In exchange for a fee of platinum, I will enhance you and your party with several [buffs].";
    }

    elsif ($text=~/exotic payment/i) {
        $response = "In exchange for five [Echo of Memory], I can enchant the entire world! Each should co-exist with over versions of this type of effect, and will last four hours. If the world is already enchanted in this way, purchasing additional enhancement will extend the duration of the current enchantment. Would you like to enhance the [Experience Gain], [Hit Points and Armor Class], [Combat Statistics], [Movement Speed], [Mana Regeneration], [Attack Speed], or [Health Regeneration]? Alternatively, for twenty-five Echoes, I can cast [all of these enchantments]!";
    }

    elsif ($text=~/experience gain/i) {        
        my $buff_id = 43002;
        if (ApplyWorldWideBuff($buff_id)) {
            $response = "Excellent! Your fellow adventurers will appreciate this!";
        } else {
            $response = "You do not have enough [Echo of Memory] to afford that.";
        }
    }
    elsif ($text=~/hit points and armor class/i) {
        my $buff_id = 43003;
        if (ApplyWorldWideBuff($buff_id)) {
            $response = "Excellent! Your fellow adventurers will appreciate this!";
            $ww_buff = 1;
        } else {
            $response = "You do not have enough [Echo of Memory] to afford that.";
        }
    }
    elsif ($text=~/combat statistics/i) {
        my $buff_id = 43004;
        if (ApplyWorldWideBuff($buff_id)) {
            $response = "Excellent! Your fellow adventurers will appreciate this!";
            $ww_buff = 1;
        } else {
            $response = "You do not have enough [Echo of Memory] to afford that.";
        }
    }
    elsif ($text=~/movement speed/i) {
        my $buff_id = 43005;
        if (ApplyWorldWideBuff($buff_id)) {
            $response = "Excellent! Your fellow adventurers will appreciate this!";
            $ww_buff = 1;
        } else {
            $response = "You do not have enough [Echo of Memory] to afford that.";
        }
    }
    elsif ($text=~/mana regeneration/i) {
        my $buff_id = 43006;
        if (ApplyWorldWideBuff($buff_id)) {
            $response = "Excellent! Your fellow adventurers will appreciate this!";
            $ww_buff = 1;
        } else {
            $response = "You do not have enough [Echo of Memory] to afford that.";
        }
    }
    elsif ($text=~/attack speed/i) {
        my $buff_id = 43007;
        if (ApplyWorldWideBuff($buff_id)) {
            $response = "Excellent! Your fellow adventurers will appreciate this!";
            $ww_buff = 1;
        } else {
            $response = "You do not have enough [Echo of Memory] to afford that.";
        }
    }
    elsif ($text=~/health regeneration/i) {
        my $buff_id = 43008;
        if (ApplyWorldWideBuff($buff_id)) {
            $response = "Excellent! Your fellow adventurers will appreciate this!";
            $ww_buff = 1;
        } else {
            $response = "You do not have enough [Echo of Memory] to afford that.";
        }
    }
    elsif ($text=~/all of these enchantments/i) {
        my $eom_avail = $client->GetAlternateCurrencyValue(6);
        if ($eom_avail >= 25) {
            $response = "Excellent! Your fellow adventurers will appreciate this!";
            $client->SetAlternateCurrencyValue(6, $eom_avail - 25);
            for my $value (43002 .. 43008) {
                ApplyWorldWideBuff($value, 1);                
            }
            $ww_buff = 1;
        } else {
            $response = "You do not have enough [Echo of Memory] to afford that.";
        }
    }

    elsif ($text=~/buffs/i) {        
        handle_buff_for_level();
    }

    if ($response) {
        plugin::Whisper($response);
    }

    if ($ww_buff) {
        quest::worldwidesignalclient(100);
    }
}

sub ApplyGroupBuff {
    my $buff_id = shift;

    if ($client->TakeMoneyFromPP($platinum_price * 1000, 1)) {
        $client->ApplySpellGroup($buff_id, 2400);
        return 1;
    } else {
        return 0;
    }    
}

sub convert_seconds {
    my ($seconds) = @_;

    my $hours = int($seconds / 3600);
    $seconds %= 3600;
    my $minutes = int($seconds / 60);
    $seconds %= 60;

    return ($hours, $minutes, $seconds);
}

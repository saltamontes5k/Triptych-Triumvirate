# Basic Design
# EoM (Server-Wide) buffs work by three methods;
# 1) Send a worldwide client signal, global_player catches it and applies the requested buffs
# 2) Set a bucket value with a 4 hour expiration.
# 3) Zone and Login methods in global_player apply the requested buffs with the requested durations

sub EVENT_SAY {
    my $response = "";
    my $clientName = $client->GetCleanName();
    my @buffs = ();  # Array to store buff IDs
    my $cost = 0;

    if ($text =~ /hail/i) {
        $response = "Hail, Adventurer. I seek to empower your ilk for my own profit. In exchange for [exotic payment], I will enhance the power of all adventurers in the world.";
    }
    elsif ($text =~ /exotic payment/i) {
        $response = "In exchange for a number of [Echo of Memory], I can enchant the entire world! Each should co-exist with over versions of this type of effect, and will last four hours. 
                     If the world is already enchanted in this way, purchasing additional enhancement will extend the duration of the current enchantment. 
                     In order to enhance [Experience Gain] or [Movement Speed], I will require five echoes. 
                     Enhancement of [Overall Power] will cost 20 echoes. 
                     For merely ten Echoes, I can [influence the tides of fate] in order to increase the rate that adventurers find rare items in the world!
                     Alternatively, for thirty-five Echoes, I can cast [all of these enchantments]!";
    }
    elsif ($text =~ /experience gain/i) {        
        @buffs = (43002);
        $cost = 5; 
    }
    elsif ($text =~ /movement speed/i) {
        @buffs = (43005);
        $cost = 5;
    }
    elsif ($text =~ /overall power/i) {
        @buffs = (36856);
        $cost = 20;
    }
    elsif ($text =~ /influence the tides of fate/i) {       
        @buffs = (17779);
        $cost = 10;
    }
    elsif ($text =~ /all of these enchantments/i) {
        @buffs = (43002, 43005, 36856, 17779);
        $cost = 35;
    }
    
    if (@buffs && $cost) {
        if (plugin::SpendEOM($client, $cost)) {
            $response = "Excellent! Your fellow adventurers will appreciate this!";
            foreach my $buff_id (@buffs) {
                plugin::ApplyWorldWideBuff($buff_id);
            }
            quest::reload_global_buffs();
        } else {
            $response = "You do not have enough [Echo of Memory] to afford that.";
        }
    }  
    
    if ($response) {
        plugin::Whisper($response);
    }
}

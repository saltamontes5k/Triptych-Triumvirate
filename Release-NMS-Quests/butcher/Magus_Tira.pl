# butcher\Magus_Tira.pl NPCID 68133

sub EVENT_SAY {
    if ($client->KeyRingCheck(41000) || plugin::check_hasitem($client, 41000)) {
        if ($text=~/hail/i) {
            my $name = $client->GetName();
            quest::say("And how are you today, $name? Ready to do some traveling? Hurry up, then. I have lots of things I need to do today. Tell me where you would like to go and I will send you there. I can send you to any of the other camps in [Everfrost], [Commonlands], [Nedaria's Landing], [North Ro], or [South Ro]. Hopefully I won't burn my hands this time! Long story, but my cohort, Gaelan Charhands, didn't tell me one of the words of the spell as a joke. Apparently it's funny for a beautiful gnome like myself to get her hands singed. I'll get him back some day!");
        } 
        elsif ($text=~/everfrost/i && plugin::is_eligible_for_zone($client, 'everfrost', 1)) {
            $client->CastSpell(4180, $client->GetID()); # Spell: Teleport: Everfrost
        } 
        elsif ($text=~/nedaria/i && plugin::is_eligible_for_zone($client, 'nedaria', 1)) {
            $client->CastSpell(4580, $client->GetID()); # Spell: Teleport: Nedaria
        } 
        elsif ($text=~/north ro/i && plugin::is_eligible_for_zone($client, 'nro', 1)) {
            $client->CastSpell(4177, $client->GetID()); # Spell: Teleport: North Ro
        } 
        elsif ($text=~/south ro/i && plugin::is_eligible_for_zone($client, 'sro', 1)) {
            $client->CastSpell(4178, $client->GetID()); # Spell: Teleport: South Ro
        } 
        elsif ($text=~/commonlands/i && plugin::is_eligible_for_zone($client, 'ecommons', 1)) {
            $client->CastSpell(4176, $client->GetID()); # Spell: Teleport: East Commons
        }
    } else {
        if ($text=~/hail/i) {
            quest::say("You will have to excuse me, I am quite busy studying this Farstone and the possibility of using the magic stored inside of it. Perhaps you should talk to those at the Wayfarer camps to see if they have any use for you. I have enough time to send you to [Nedaria's Landing], if you'd like.");
        } elsif ($text=~/nedaria/i && plugin::is_eligible_for_zone($client, 'nedaria')) {
            $client->CastSpell(4580, $client->GetID()); # Spell: Teleport: Nedaria
        }
    }
}

sub EVENT_ITEM {
    plugin::return_items(\%itemcount);
}

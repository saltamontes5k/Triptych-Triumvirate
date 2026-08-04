# everfrost\Magus_Delin.pl NPCID 30088

sub EVENT_SAY {
    if ($client->KeyRingCheck(41000) || plugin::check_hasitem($client, 41000)) {
        if ($text =~ /hail/i) {
            quest::say("You're going to need to have a fair amount of faith in me and my friends. I make it a policy to tell all of the travelers that come to me that this is not a perfected magic and probably never will be. The magic we are using is, in my opinion, not of Norrathian origins. Anyway, enough chatter. Tell me where you would like to go and I will send you there. I can send you to any of the other camps in [Butcherblock], [Commonlands], [Nedaria's Landing], [North Ro], or [South Ro]. Please be still as I do this.");
        }
        elsif ($text =~ /butcherblock/i && plugin::is_eligible_for_zone($client, 'butcher', 1)) {
            $client->CastSpell(4179, $client->GetID()); # Spell: Teleport: Butcherblock
        }
        elsif ($text =~ /commonlands/i && plugin::is_eligible_for_zone($client, 'ecommons', 1)) {
            $client->CastSpell(4176, $client->GetID()); # Spell: Teleport: East Commons
        }
        elsif ($text =~ /nedaria/i && plugin::is_eligible_for_zone($client, 'nedaria', 1)) {
            $client->CastSpell(4580, $client->GetID()); # Spell: Teleport: Nedaria
        }
        elsif ($text =~ /north ro/i && plugin::is_eligible_for_zone($client, 'nro', 1)) {
            $client->CastSpell(4177, $client->GetID()); # Spell: Teleport: North Ro
        }
        elsif ($text =~ /south ro/i && plugin::is_eligible_for_zone($client, 'sro', 1)) {
            $client->CastSpell(4178, $client->GetID()); # Spell: Teleport: South Ro
        }
    } else {
        if ($text =~ /hail/i) {
            quest::say("You will have to excuse me, I am quite busy studying this Farstone and the possibility of using the magic stored inside of it. Perhaps you should talk to those at the Wayfarer camps to see if they have any use for you. I have enough time to send you to [Nedaria's Landing], if you'd like.");
        } elsif ($text =~ /nedaria/i && plugin::is_eligible_for_zone($client, 'nedaria')) {
            $client->CastSpell(4580, $client->GetID()); # Spell: Teleport: Nedaria
        }
    }
}

sub EVENT_ITEM {
    plugin::return_items(\%itemcount);
}

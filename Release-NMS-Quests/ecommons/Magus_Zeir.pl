# ecommons\Magus_Zeir.pl NPCID 22114

sub EVENT_SAY {
    if ($client->KeyRingCheck(41000) || plugin::check_hasitem($client, 41000)) {
        if ($text =~ /hail/i) {
            my $name = $client->GetName();
            quest::say("Welcome, brave $name. You have to be brave to entertain the use of our magic. It's not that I don't trust the spell or my companions, it's just that the auras of the stones we found are so unstable and strange. We are still trying to learn the nature of the magic. It really is unlike any other magic we've seen on Norrath, and it's very powerful. Perhaps I shouldn't talk about that. Tell me where you would like to go and I will send you there. I can send you to any of the other camps in [Butcherblock], [Everfrost], [Nedaria's Landing], [North Ro], or [South Ro].");
        } 
        elsif ($text =~ /butcherblock/i && plugin::is_eligible_for_zone($client, 'butcher', 1)) {
            $client->CastSpell(4179, $client->GetID()); # Spell: Teleport: Butcherblock
        } 
        elsif ($text =~ /everfrost/i && plugin::is_eligible_for_zone($client, 'everfrost', 1)) {
            $client->CastSpell(4180, $client->GetID()); # Spell: Teleport: Everfrost
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

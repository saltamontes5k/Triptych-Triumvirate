# sro\Magus_Jerira.pl NPCID 35066

sub EVENT_SAY {
    if ($client->KeyRingCheck(41000) || plugin::check_hasitem($client, 41000)) {
        if ($text =~ /hail/i) {
            my $name = $client->GetName();
            quest::say("Nice to see you, $name. Am I safe in assuming you wish to travel today? I do admire the adventurers that so willingly take the risk involved with this spell. I enjoy knowing all of my hard work is not in vain. There's only been a few unfortunate folk that haven't, uhm, been so lucky. Frightful mess. I'll be sure to be extra careful where you are concerned. Honestly. A dark elf's word is... Well, forget that. He he. Tell me where you would like to go and I will send you there. I can send you to any of the other camps in [Butcherblock], [Commonlands], [Everfrost], [Nedaria's Landing], or [North Ro].");
        } 
        elsif ($text =~ /butcherblock/i && plugin::is_eligible_for_zone($client, 'butcher', 1)) {
            $client->CastSpell(4179, $client->GetID()); # Spell: Teleport: Butcherblock
        } 
        elsif ($text =~ /commonlands/i && plugin::is_eligible_for_zone($client, 'ecommons', 1)) {
            $client->CastSpell(4176, $client->GetID()); # Spell: Teleport: East Commons
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

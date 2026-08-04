# nro\Magus_Arindri.pl NPCID 34129

sub EVENT_SAY {
    if ($client->KeyRingCheck(41000) || plugin::check_hasitem($client, 41000)) {
        if ($text=~/hail/i) {
            quest::say("You endured the burning heat of the desert to come and use our magic! I'm so excited. We have been getting a lot of customers. We've only lost a few. I sometimes wonder if Vayzl has incorrectly used the spell on purpose to see the odd traveler explode into a spray of magic. I do respect her, but I just don't understand dark elves, I guess. I am far too precise and careful to make any mistakes... Well, not a second time. Tell me where you would like to go and I will send you there. I can send you to any of the other camps in [Butcherblock], [Commonlands], [Everfrost], [Nedaria's Landing], or [South Ro].");
        }
        elsif ($text=~/butcherblock/i && plugin::is_eligible_for_zone($client, 'butcher', 1)) {
            $client->CastSpell(4179, $client->GetID()); # Spell: Teleport: Butcherblock
        }
        elsif ($text=~/commonlands/i && plugin::is_eligible_for_zone($client, 'ecommons', 1)) {
            $client->CastSpell(4176, $client->GetID()); # Spell: Teleport: East Commons
        }
        elsif ($text=~/everfrost/i && plugin::is_eligible_for_zone($client, 'everfrost', 1)) {
            $client->CastSpell(4180, $client->GetID()); # Spell: Teleport: Everfrost
        }
        elsif ($text=~/nedaria/i && plugin::is_eligible_for_zone($client, 'nedaria', 1)) {
            $client->CastSpell(4580, $client->GetID()); # Spell: Teleport: Nedaria
        }
        elsif ($text=~/south ro/i && plugin::is_eligible_for_zone($client, 'sro', 1)) {
            $client->CastSpell(4178, $client->GetID()); # Spell: Teleport: South Ro
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

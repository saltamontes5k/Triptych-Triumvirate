# natimbi\Magus_Releua.pl NPCID 280060

sub EVENT_SAY {
    if ($text =~ /hail/i) {
        quest::say("If you'd like to go to [Nedaria]'s Landing or to the Queen of Thorns in [Abysmal Sea], I can use my Farstone magic to send you. Speak up and tell me where you wish to travel.");
    }
    elsif ($text =~ /nedaria/i && plugin::is_eligible_for_zone($client, 'nedaria', 1)) {
        $client->CastSpell(4580, $client->GetID()); # Spell: Teleport: Nedaria
    }
    elsif ($text =~ /abysmal sea/i && plugin::is_eligible_for_zone($client, 'abysmal', 1)) {
        $client->MovePC(279, 39, -150, 139.05, 180); # Zone: Abysmal Sea
    }
}

sub EVENT_ITEM {
    plugin::return_items(\%itemcount);
}

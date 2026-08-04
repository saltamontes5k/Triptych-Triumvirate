sub EVENT_SAY {
    my $name = $client->GetName();

    if ($text =~ /hail/i) {
        quest::say("Greetings, $name. I can provide travel to other magi in [Butcherblock], [Commonlands], [Everfrost], [North Ro], and [South Ro]. I can also send you to [Natimbi], the shores of Taelosia, or to the Queen of Thorns in [Abysmal Sea]. Just tell me where you'd like to go.");
    }
    elsif ($text =~ /butcherblock/i && plugin::is_eligible_for_zone($client, 'butcher', 1)) {
        $client->CastSpell(4179, $client->GetID()); # Spell: Teleport: Butcherblock
    }
    elsif ($text =~ /everfrost/i && plugin::is_eligible_for_zone($client, 'everfrost', 1)) {
        $client->CastSpell(4180, $client->GetID()); # Spell: Teleport: Everfrost
    }
    elsif ($text =~ /natimbi/i && plugin::is_eligible_for_zone($client, 'natimbi', 1)) {
        $client->MovePC(280, -1557, -853, 241, 180); # Zone: natimbi
    }
    elsif ($text =~ /north ro/i && plugin::is_eligible_for_zone($client, 'nro', 1)) {
        $client->MovePC(34, 914, 2679, -25, 20); # Zone: North Ro
    }
    elsif ($text =~ /south ro/i && plugin::is_eligible_for_zone($client, 'sro', 1)) {
        $client->MovePC(35, 1033, -1447, -23, 166); # Zone: South Ro
    }
    elsif ($text =~ /commonlands/i && plugin::is_eligible_for_zone($client, 'ecommons', 1)) {
        $client->MovePC(22, -140, -1520, 3, 280); # Zone: Commonlands
    }
    elsif ($text =~ /abysmal sea/i && plugin::is_eligible_for_zone($client, 'abysmal', 1)) {
        $client->MovePC(279, 39, -150, 141, 180); # Zone: Abysmal Sea
    }
}

sub EVENT_ITEM {
    plugin::return_items(\%itemcount);
}

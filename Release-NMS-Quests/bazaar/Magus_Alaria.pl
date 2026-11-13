# Old guildlobby\Magus_Alaria.pl NPCID 344013
# LDoN camp ports: our world carries the Butcherblock, Everfrost and Northern
# Ro camp sites (the GoD Magus chain NPCs stand at them); the Rujarkian Hills
# and Deepest Guk camps were never populated here and the adventure engine is
# not installed, so only the three existing camps are wired.

sub EVENT_SAY {
    if ($text =~ /hail/i) {
        my $name = $client->GetName();
        quest::say("Greetings, $name. As you may have guessed, I used to be a member of the Wayfarers Brotherhood. While the dungeons we once sought are lost again, I know that I am meant to assist those that still need our magic. The old [Mistmoore] camp in the Butcherblock Mountains, the [Miragul] camp in the Everfrost Peaks and the [Takish-Hiz] camp in the Northern Desert of Ro are all within my reach, as is [Nedaria's Landing]. Prepare yourself. From what I can still remember, it will not be a pleasant journey.");
    }
    elsif ($text =~ /mistmoore/i) {
        if (plugin::is_eligible_for_zone($client, 'butcher', 1)) {
            $client->MovePC(68, -2463, -1076, -1.5, 0); # Butcherblock: Mistmoore Catacombs camp, beside Magus Tira
        }
    }
    elsif ($text =~ /miragul/i) {
        if (plugin::is_eligible_for_zone($client, 'everfrost', 1)) {
            $client->MovePC(30, -5028, 1798, -60.1, 0); # Everfrost: Miragul's Menagerie camp, beside Magus Delin
        }
    }
    elsif ($text =~ /takish/i) {
        if (plugin::is_eligible_for_zone($client, 'northro', 1)) {
            $client->MovePC(392, -560, 7912, 98.5, 0); # Northern Ro: Takish-Hiz camp, beside Magus Arindri
        }
    }
    elsif ($text =~ /nedaria/i) {
        if (plugin::is_eligible_for_zone($client, 'nedaria', 1)) {
            $client->MovePC(182, 1463, 1053, 82.86, 136); # Zone: nedaria
        }
    }
    else {
        quest::say("I did not understand. Tell me where you wish to travel.");
    }
}

sub EVENT_ITEM {
    plugin::return_items(\%itemcount);
}

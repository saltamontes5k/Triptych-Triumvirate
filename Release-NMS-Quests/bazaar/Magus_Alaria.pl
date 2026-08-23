# Old guildlobby\Magus_Alaria.pl NPCID 344013

sub EVENT_SAY {
    if ($text =~ /hail/i) {
        my $name = $client->GetName();
        quest::say("Greetings, $name. As you may have guessed, I used to be a member of the Wayfarers Brotherhood. While the dungeons we once sought are lost again, I know that I am meant to assist those that still need our magic. As I understand it, the Gates of Discord have been opened again... I think I still know how to get your kind to [Nedaria's Landing]. Prepare yourself. From what I can still remember, it will not be a pleasant journey.");
    }
    elsif ($text =~ /nedaria/i && plugin::is_eligible_for_zone($client, 'nedaria', 1)) {
        $client->MovePC(182, 1463, 1053, 82.86, 136); # Zone: nedaria
    }
}

sub EVENT_ITEM {
    plugin::return_items(\%itemcount);
}
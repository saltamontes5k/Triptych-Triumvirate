# #Argan_Milek.pl
# Return NPC after A Horrifying Vision - Databucket flag for avatar access

sub EVENT_SAY {
    my $info_link    = quest::saylink("What information?", 1);
    my $saryrn_link  = quest::saylink("What about Saryrn?", 1);
    my $return_link  = quest::saylink("ready", 1);

    if ($text=~/hail/i) {
        quest::whisper("Friends, you have returned my vision! I wish that I could find the means to thank you enough! Friends, should Druzzil Ro choose to have us meet again on this chaotic canvas of time, I will make this up to you! I feel my body waking and I am quite ready to forget the image of this place. I have some information that may help you, and when you are ready, I will return your sight to you. $info_link");
    }
    elsif ($text=~/what information/i) {
        quest::whisper("While I was blind, Druzzil Ro came to me in a vision. In this vision, she walked to the door of Saryrn's Citadel. When I set my gaze upon the door I began to make out some sort of picture. The inscription on the door seemed to shift and change, as if it were fluid. At one point, I was able to make out several distinct shapes. These shapes depicted one of those things with the four mouths spitting out four other similar creatures. I think that the things with four mouths are the key to the door. It was then that I asked Druzzil Ro about Saryrn. $saryrn_link");
    }
    elsif ($text=~/what about saryrn/i) {
        quest::whisper("Druzzil Ro told me that Saryrn formed this place from her own tortured will. Saryrn was insane as a mortal and found some means of transforming that insanity into something more. Many of the entities that you will find in this place are voices that came to her during the inception of her madness. They will be the key to dissolving her power. Seek out the Avatars of this realm to move into her tower. Now, I must leave. Are you $return_link?");
    }
    elsif ($text=~/ready/i) {
        quest::whisper("Then be gone from this twisted realm. Walk free!");

        my $cid = $client->CharacterID();
        my $flag_key = "potor_argan_complete_$cid";

        # Databucket progression flag
        quest::set_data($flag_key, 1);

        my $inst_id = $client->GetInstanceID();
        $client->MovePCInstance(207, $inst_id, -308.58, 1704.73, -487.93, 194);

        quest::depop();
    }
}

1;
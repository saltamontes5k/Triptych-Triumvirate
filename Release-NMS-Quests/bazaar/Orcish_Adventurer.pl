my $stage_desc  = "Seeds of Destruction";
my $hero_desc   = "Kerafyrm must be destroyed within the Sleeper's Tomb, and again within Crystallos, Lair of the Awakened.";
my $stage_key   = "SoD";

sub EVENT_SAY {
    if ($text=~/hail/i) {
        plugin::ConvertFlags($client);
        if (plugin::is_stage_complete($client, $stage_key)) {
            plugin::YellowText("You have access to the $stage_desc.");
        } else {
            if (plugin::is_stage_complete_2($client, $stage_key)) {
                plugin::YellowText("You will have access to the $stage_desc when the time-lock is expired.");
            } else {
                plugin::NPCTell("To gain access to the $stage_desc, the path of the [hero] lies before you.");
            }
        }
    }
    elsif (!plugin::is_stage_complete($client, $stage_key)) {
        if ($text =~/hero/i) {
            plugin::NPCTell($hero_desc);
            plugin::list_stage_prereq($client, $stage_key);
        }
    }
}

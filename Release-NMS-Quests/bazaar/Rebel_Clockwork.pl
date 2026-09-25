my $stage_desc  = "Secrets of Faydwer";
my $hero_desc   = "Solusek Ro and Mayong Mistmoore must both be slain upon Solteris, the Throne of Ro.";
my $stage_key   = "SoF";

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

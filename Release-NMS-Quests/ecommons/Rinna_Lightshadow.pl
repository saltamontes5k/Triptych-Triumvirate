sub EVENT_SAY {
my %STAGE_PREREQUISITES = (
    'RoK' => ['Lord Nagafen', 'Lady Vox'],
    'SoV' => ['Trakanon', 'Gorenaire', 'Severilous', 'Talendor'],
    'SoL' => ['Klandicar', 'Zlandicar', 'Wuoshi', 'Dozekar the Cursed', 'Kelorek`Dar'],
    'PoP' => ['Thought Horror Overfiend', 'The Insanity Crawler', 'Grieg Veneficus', 'Xerkizh the Creator', 'Emperor Ssraeshza'],
#    'GoD' => ['Saryrn'],
#    'OoW' => ['Disabled'],
#    'DoN' => ['Disabled'],
#    'FNagafen' => ['Quarm'],
    # ... and so on for each stage
);
    my $is_gm = $client->GetGM();
    if($is_gm){
    if ($text=~/hail/i) {

        foreach my $key (keys %STAGE_PREREQUISITES) {
                foreach my $flag (@{$STAGE_PREREQUISITES{$key}}) {
                        plugin::YellowText("Setting flag: $key -> $flag");
                        plugin::SetSubflag($client, $key, $flag);
                }
        }
        return;
        plugin::ConvertFlags($client);
        if (plugin::is_stage_complete($client, $stage_key)) {
            plugin::YellowText("You have access to the $stage_desc.");
        } else {
        foreach my $target (@target_list) {
            plugin::SetSubflag($client, $stage_key, $target, 1);
        }
            }
        }
}
}

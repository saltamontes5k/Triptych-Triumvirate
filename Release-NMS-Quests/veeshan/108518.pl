sub EVENT_TICK {
    my $phara_dar = $entity_list->GetNPCByNPCTypeID(108048);
    if ($phara_dar) {
        my @pd_hatelist = $phara_dar->GetHateList();
        if (@pd_hatelist) {
            my $rand_hater = $pd_hatelist[int(rand(@pd_hatelist))];  # Ensure rand produces an integer
            if ($rand_hater) {
                $npc->AddToHateList($rand_hater->GetEnt(), 1000);  # Add the random hater to the hate list
            }

            foreach my $hle (@pd_hatelist) {  # For each value in the array, do something
                if ($hle) {
                    $npc->AddToHateList($hle->GetEnt(), 1);  # Add each hater to the hate list
                }
            }
        }
    }
}
sub EVENT_TICK {

    my $ventani = $entity_list->GetMobByNpcTypeID(128091);
    my $tukaarak = $entity_list->GetMobByNpcTypeID(128092);
    my $hraashna = $entity_list->GetMobByNpcTypeID(128093);
    my $nanzata = $entity_list->GetMobByNpcTypeID(128090);

    if (!$ventani && !$tukaarak && !$hraashna && !$nanzata) {
        quest::shout("FOOLS! You have unleashed your doom!");
        quest::depop_withtimer(128094);
        quest::spawn2(128089, 0, 0, -1481, -2373, -1034, 520);
    }
}
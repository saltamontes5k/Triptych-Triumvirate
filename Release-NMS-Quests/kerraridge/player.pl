sub EVENT_ENTER_ZONE {
    # Spawn Marl Kastane as needed
    if (plugin::HasClassName($client, "ShadowKnight") && !$entity_list->GetNPCByNPCTypeID(74089)) {
        $faction = $client->GetCharacterFactionLevel(404); # Faction: Truespirit
        if ((($faction >= 43) && plugin::check_hasitem(143761)) ||
            (($faction >= 51) && plugin::check_hasitem(14381)) ||
            (($faction >= 58) && plugin::check_hasitem(14379))) {
                quest::spawn2(74089, 0, 0, 63, 565, 17.75, 509.5);
            }
    }
}
sub EVENT_TICK {
  my $counter   = $npc->GetEntityVariable("counter") || 0;
  my $check     = !$entity_list->GetMobByNpcTypeID(124077) && # Lady_Mirenilla
                  !$entity_list->GetMobByNpcTypeID(124076) && # Lady_Nevederia
                  !$entity_list->GetMobByNpcTypeID(124008) && # Lord_Feshlak
                  !$entity_list->GetMobByNpcTypeID(124010) && # Aaryonar
                  !$entity_list->GetMobByNpcTypeID(124074) && # Lord_Kreizenn
                  !$entity_list->GetMobByNpcTypeID(124017);   # Lord_Vyemm

  if ($check && !$entity_list->GetMobByNpcTypeID(124155)) {
    $npc->Shout("Intruders! Your doom is upon you! Vulak`Aerr comes to humble you, and return you to your pathetic Gods.");
    quest::spawn2(124155, 0, 0, -739.4, 517.2, 121, 510); # Vulak`Aerr
  } elsif ($counter % 100 == 0 && !$entity_list->GetMobByNpcTypeID(124155)) {
    my $entity = 0;
    while (!$entity_list->GetMobByNpcTypeID($entity)) {
      $entity = quest::ChooseRandom((124077, 124076, 124008, 124010, 124074, 124017));
    }

    my $entity_name = $entity_list->GetMobByNpcTypeID($entity)->GetCleanName();
    my @messages = (
          "Intruders threaten our domain, $entity_name. Ensure their demise swiftly!",
          "$entity_name, what is the status of your patrols? Report immediately!",
          "The tribute from $entity_name is overdue. Ensure it arrives at once!",
          "$entity_name, our king grows impatient. Have you dealt with the intruders?",
          "$entity_name, the preparations for Vulak`Aerr's awakening must not be delayed.",
          "$entity_name, we must not let our guard down. The temple must be secure.",
          "$entity_name, are the defenses of the temple holding strong?",
          "The vigilance of $entity_name is crucial. Do not fail us now.",
          "Ensure the sanctity of the temple, $entity_name. The hour of reckoning approaches.",
          "$entity_name, maintain your watch. The time of Vulak`Aerr's return is near.",
          "Report your status, $entity_name. The intruders must be eliminated.",
          "$entity_name, your vigilance is key. The temple's security must not falter.",
          "Have you secured the perimeter, $entity_name? We cannot afford breaches.",
          "The strength of $entity_name is needed. Keep the temple inviolable.",
          "$entity_name, the intruders grow bolder. Redouble your efforts.",
          "Ensure no stone is left unturned, $entity_name. The temple's safety is paramount.",
          "The eyes of our king are upon you, $entity_name. Do not disappoint him.",
          "$entity_name, the sanctity of the temple must be maintained at all costs.",
          "The might of $entity_name will crush the intruders. Show them our power!",
          "$entity_name, let no intruder escape your sight. The temple must be defended."
        );

    $npc->Shout(quest::ChooseRandom(@messages));
  }
  $npc->SetEntityVariable("counter", $counter + 1);
}

sub EVENT_SPAWN {
  quest::doanim(16);
  quest::say("Uhhh... I'm not feeling so good.  Someone call for a cleric.");
}

sub EVENT_AGGRO { # have all body guards attack
  quest::say("Yer messin with the wrong Coldain, prepare ta meet yer ancestors!");
  my $bgStoneberg = $entity_list->GetMobByNpcTypeID(116100);
  my $bgNergan = $entity_list->GetMobByNpcTypeID(116059);
  my $bgPersevil = $entity_list->GetMobByNpcTypeID(116061);
  my $bgMarganel = $entity_list->GetMobByNpcTypeID(116060);

  if ($bgStoneberg){
    $bgStoneberg->AddToHateList($client, 1);
  }

  if ($bgNergan){
    $bgNergan->AddToHateList($client, 1);
  }

  if ($bgPersevil){
    $bgPersevil->AddToHateList($client, 1);
  }

  if ($bgMarganel){
    $bgMarganel->AddToHateList($client, 1);
  }
}

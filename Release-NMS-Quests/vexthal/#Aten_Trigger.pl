sub EVENT_TICK {
  my $counter   = $npc->GetEntityVariable("counter") || 0;
  my @named_mobs = (
    158013, # #Kaas_Thox_Xi_Ans_Dyek
    158014, # #Diabo_Xi_Va
    158015, # #Diabo_Xi_Xin
    158012, # #Diabo_Xi_Xin_Thall
    158008, # #Thall_Va_Kelun
    158010, # #Diabo_Xi_Va_Temariel
    158011, # #Thall_Xundraux_Diabo
    158009, # #Va_Xi_Aten_Ha_Ra
    158007  # #Kaas_Thox_Xi_Aten_Ha_Ra
  );

  # Check if all the named mobs are dead
  my $check = 1;
  foreach my $mob_id (@named_mobs) {
    if ($entity_list->GetMobByNpcTypeID($mob_id)) {
      $check = 0;
      last;
    }
  }

  if ($check && !$entity_list->GetMobByNpcTypeID(158096)) {
    my $ahr_id = quest::unique_spawn(158096,0,0,1417,0,236,384);
    my $ahr = $entity_list->GetMobByID($ahr_id);
    $ahr->Shout("Bow before Aten Ha Ra, High Priestess of Luclin, or face eternal darkness!");
  } elsif ($counter % 100 == 0) {
    my @alive_mobs = grep { $entity_list->GetMobByNpcTypeID($_) } @named_mobs;
    if (@alive_mobs) {
      my $mob_id = quest::ChooseRandom(@alive_mobs);
      if (my $mob = $entity_list->GetMobByNpcTypeID($mob_id)) {
        my @messages = (
          "Xau xaui rentha sa akha!",   # I guard the city against invaders!
          "Xin thosu xeturis!",         # Warriors, dishonor the intruders!
          "Xys ril xeturisun!",         # He is dishonored!
          "Tarveuel kel draeth!",       # Torture the lone enemy!
          "Ans dariar visis sa rentha!",# The minions agree to defend the city!
          "Ura aus xeturisun!",         # You have dishonored!
          "Xys xenuek sivuela!",        # He wields against the outsider!
          "Phet ka xauiim!",            # We are guarding!
          "Ans xin dabo sivuela!",      # The warrior destroys the outsider!
          "Kel dariar xaui!",           # One minion guards!
          "Dabo draeths sa rentha!",    # Destroy the enemies of the city!
          "Xaus air aus xeturisun!",    # I shall have dishonored!
          "Xenturis ans sivuela!",      # Dishonor the outsider!
          "Ka vis sa akha!",            # Agree to the defense!
          "Ans tarveuel akha kel!",     # The torture begins now!
          "Iashtu kel xin sa akha!",    # Worship the lone warrior defending!
          "Dariar ka xi rentha!",       # Minions are in the city!
          "Xys ia ka!",                 # He is now!
          "Ans xenuek sa sivuela!",     # Wield against the outsider!
          "Ura ial di xeturisun!",      # You will be dishonored!
          "Xaus ril xeturisun sa akha!",# I am dishonored by these invaders!
          "Vius Xi Kaas, Xeturis Vyla!",# Defend the city, dishonor the weak!
          "Xin Akelha Xetra!",          # Warriors of the dark, arise!
          "Kaas thox xi aken, sivuela!",# Our city stands against the outsiders!
          "Dariar xaui sa Ruluor!",     # The minions guard with fury!
          "Xys ril xentu sa akha!",     # He is the shield of the city!
          "Ura dabo sa akha!",          # You will destroy for the city!
          "Tarveuel vius ka!",          # Torture for our cause!
          "Ans vius xi akelha!",        # The city must stand!
          "Kaas Thox Xi, Riluor Xetra!" # Defend with the fury of shadows!
        );
        $mob->Shout(quest::ChooseRandom(@messages));
      }
    }
  }

  $npc->SetEntityVariable("counter", $counter + 1);
}

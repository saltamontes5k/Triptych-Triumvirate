#Altar_Adherent (294640)
sub EVENT_SPAWN {
  if(!defined($qglobals{$instanceid.adhere5})) {
    $adhere = int(rand(4)) + 1;
    quest::setglobal($instanceid.adhere5,$adhere,3,"H6");
  }
  else {
    $adhere = $qglobals{$instanceid.adhere5};
  }
}

sub EVENT_DEATH_COMPLETE {
  if ($status >= 80 ) {
	quest::ze(0,"The adherent's debris litters the ground. It has been beaten.");
    }
  elsif(((plugin::HasClassName($client, "Bard")) || (plugin::HasClassName($client, "Beastlord")) || (plugin::HasClassName($client, "Paladin")) || (plugin::HasClassName($client, "Ranger")) || (plugin::HasClassName($client, "Shadowknight"))) && ($qglobals{$instanceid.adhere5} == 2)) {
	quest::ze(0,"The adherent's debris litters the ground. It has been beaten.");
  }
  elsif(((plugin::HasClassName($client, "Berserker")) || (plugin::HasClassName($client, "Monk")) || (plugin::HasClassName($client, "Rogue")) || (plugin::HasClassName($client, "Warrior"))) && ($qglobals{$instanceid.adhere5} == 3)) {
	quest::ze(0,"The adherent's debris litters the ground. It has been beaten.");
  }
  elsif(((plugin::HasClassName($client, "Cleric")) || (plugin::HasClassName($client, "Druid")) || (plugin::HasClassName($client, "Shaman"))) && ($qglobals{$instanceid.adhere5} == 4)) {
	quest::ze(0,"The adherent's debris litters the ground. It has been beaten.");
  }
  elsif(((plugin::HasClassName($client, "Enchanter")) || (plugin::HasClassName($client, "Magician")) || (plugin::HasClassName($client, "Necromancer")) || (plugin::HasClassName($client, "Wizard"))) && ($qglobals{$instanceid.adhere5} == 1)) {
	quest::ze(0,"The adherent's debris litters the ground. It has been beaten.");
  }
  else {
    quest::spawn2(294640 ,0,0,$x,$y,$z,$h); # NPC: #Altar_Adherent____
	quest::ze(0,"Your energy didn't match that required to kill the stone worker.");
    if($adhere == 1) {
      quest::ze(0,"The creature will perish under the strength of intelligent magic");
    }
    if($adhere == 2) {
      quest::ze(0,"The creature appears weak to the combined effort of might and magic!");
    }
    if($adhere == 3) {
      quest::ze(0,"The creature appears weak to the combined effort of strength and cunning!");
    }
    if($adhere == 4) {
      quest::ze(0,"The creature cannot stand up to the power of healers");
    }
	quest::ze(0,"It reforms instantly!");
  }
}

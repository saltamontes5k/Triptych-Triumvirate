sub EVENT_SAY {
  my $group_flg       = $client->CheckWaypointGroupFeature(); 
  my $eom_link        = quest::varlink(46779);

  my $bind_loc        = $client->GetBucket("baz_and_back_bind") || 'bazaar';
  my $revind_text     = "";

  if ($text=~/hail/i) {        
    if (!$group_flg) { 
      $group_flg = " Should you choose to more firmly [anchor yourself] to this world, the map can also transport your entire group at once, or allow you to directly return to your expeditions." 
    } else { 
      $group_flg = "" 
    };
    
    if (!($bind_loc eq $zonesn)) {
      $rebind_text = " I see that you are not personally attuned to this location! Would you like to [".quest::saylink("attune your Bazaar and Back", 1)."] ability to return you here?";
    } else {
      $rebind_text = "";
    }

    plugin::NPCTell("Greetings, $name. I am Timmy son of Tearel, the Keeper of the Other Map. The map beside me can transport you to many places where you have [attuned yourself], simply examine it to explore the world.". $group_flg . $rebind_text);

    return;
  }

  if ($text =~ /attune your Bazaar and Back/i) {
    plugin::NPCTell("Excellent! You will now return to this vicinity whenever you use your Bazaar and Back ability!");
    $client->SetBucket("baz_and_back_bind", $zonesn);
    return;
  }

  if ($text=~/attuned yourself/i) {
    plugin::NPCTell("As you travel throughout Norrath and beyond, you may find circles of glowing runic stones upon the ground. Remnants of a Combine transportation network, simply approach one to form a resonance between that location and your soul.")
  }

  if ($text=~/anchor yourself/i) {
    if ($group_flg) {
      plugin::NPCTell("You already have performed this ritual, and have these abilities available to you.");
    } else {
      plugin::NPCTell("If you can provide me with Five [".$eom_link."], I will [perform this ritual] for you to become more highly attuned to the Map.");
      plugin::YellowText("Once unlocked, the group transport and instance return abilities will be available to all characters on this account.");
    }
    return;
  }

  if ($text=~/perform this ritual/i) {
    if ($group_flg) {
      plugin::NPCTell("You already have performed this ritual, and have these abilities available to you.");
    } else {
      if (plugin::SpendEOM($client, 5)) {
        $client->EnableWaypointGroupFeature();
        plugin::NPCTell("$name, forevermore you and yours can transport your entire group to anywhere you have [attuned].");
      } else {
        plugin::NPCTell("I'm sorry, $name, you do not have enough [".$eom_link."] available to you right now. When you have more...");
      }
    }
  }
}  

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
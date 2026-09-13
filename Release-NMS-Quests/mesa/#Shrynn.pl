# Shrynn - Goru`kar Mesa
# The Serpent's Spine :: "A Fair Trade" (task 600230)
# Kills dromrek giants for the Drakkin Youngling Sword (58768), trades it
# for the Dromrek Worry Stone (58729) - a Charm of Lore artifact.
# Perched on a rock outcrop in the northwest, guarded by three harpies.
# Located at approximately +2890, +1740.

sub EVENT_SAY {
  my $guards = 0;
  foreach my $e ($entity_list->GetNPCList()) {
    next unless $e;
    my $tid = $e->GetNPCTypeID();
    if (($tid == 397248 || $tid == 397252 || $tid == 397254) && $e->CalculateDistance($x, $y, $z) < 150) {
      $guards++;
    }
  }
  if ($text=~/hail/i) {
    if ($guards > 0) {
      quest::say("Shreee! Not one step closer, softskin. My harpy sisters do not take kindly to strangers poking about our roost.");
    }
    elsif (!quest::istaskcompleted(600230) && !quest::istaskactive(600230)) {
      quest::say("Vasha, traveler. You have some nerve climbing up here. I collect curiosities, and there is one trinket I have wanted for a long while. The dromrek giants camped near the pass to the Steppes hauled off a [" . quest::saylink("Drakkin sword") . "] from one of their raids. Bring it to me and I will part with something from my collection.");
    }
    elsif (quest::istaskactive(600230)) {
      quest::say("The dromrek hunters and shamans near the Steppes pass still have it. Crack some skulls until the youngling sword turns up, then bring it here.");
    }
    else {
      quest::say("That sword sang when it left your hands, and my worry stone will keep you company on the road. We are square, " . $name . ".");
    }
  }
  if ($text=~/sword/i && $guards == 0 && !quest::istaskactive(600230) && !quest::istaskcompleted(600230)) {
    quest::say("A Drakkin Youngling Sword. Light blade, dragonbone hilt -- the dromreks fear it, which is precisely why I want it. Slay their hunters and shamans until you find it. I will trade you a stone of my own for it, one I have carried since I was a whelp.");
    quest::assigntask(600230);
  }
}

sub EVENT_ITEM {
  my $guards = 0;
  foreach my $e ($entity_list->GetNPCList()) {
    next unless $e;
    my $tid = $e->GetNPCTypeID();
    if (($tid == 397248 || $tid == 397252 || $tid == 397254) && $e->CalculateDistance($x, $y, $z) < 150) {
      $guards++;
    }
  }
  if ($guards > 0) {
    quest::say("Shreee! My sisters are watching. Get rid of them first if you want to trade.");
    plugin::return_items(\%itemcount);
    return;
  }
  if (plugin::check_handin(\%itemcount, 58768 => 1)) {
    quest::emote("turns the Drakkin Youngling Sword over in his claws, eyeing the dragonbone hilt with obvious delight.");
    quest::say("Ha! The dromreks will be weeping over this one for a season. A deal is a deal, " . $name . " -- here is my worry stone. I have rubbed it smooth worrying over the years, but it still carries a piece of the old clan's luck.");
    quest::summonitem(58729); # Dromrek Worry Stone
    $client->AddLevelBasedExp(10, 0);
  }
  plugin::return_items(\%itemcount);
}

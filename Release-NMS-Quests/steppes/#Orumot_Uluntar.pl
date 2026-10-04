# Orumot Uluntar - The Steppes
# The Serpent's Spine :: Serric Lives (task 600599).

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (quest::istaskactive(600599)) {
      quest::say("The [tabbard] would be in the Vergalid Mines, on whatever walks its deep tunnels. Bring it to me.");
    }
    elsif (!quest::istaskcompleted(600599)) {
      quest::say("My brother Serric marched into the Vergalid Mines and never marched out. His [tabbard] is all I ask of the dark.");
    }
    else {
      quest::say("I buried the tabbard beside our mother's stone. He is home, $name. Thank you.");
    }
  }
  if ($text=~/tabbard/i && !quest::istaskactive(600599) && !quest::istaskcompleted(600599)) {
    quest::say("Enter the Vergalid Mines and recover a piece of Serric's tabbard from the shadows there. Deliver it to me and he will have a grave worth the name.");
    quest::assigntask(600599);
  }
}

sub EVENT_ITEM {
  # Consume the tabbard only while Serric Lives is active (task system
  # handles completion); anything else is returned.
  if (quest::istaskactive(600599)) {
    plugin::check_handin(\%itemcount, 36153 => 1);
  }
  plugin::return_items(\%itemcount);
}

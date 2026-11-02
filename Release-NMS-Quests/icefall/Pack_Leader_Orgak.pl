# Pack Leader Orgak - Icefall Glacier
# The Serpent's Spine :: Free the Wolves (task 600712)
# Items: Meat for Orgak's Wolves 36199

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (quest::istaskactive(600712)) {
      quest::say("The cages are in the far northwest caves. Say [" . quest::saylink("meat") . "] and I will give you cuts for the captives. Then kill ten kobolds for every cage they built.");
    }
    elsif (quest::istaskcompleted(600712)) {
      quest::say("The pack runs free and the kobolds pay in blood. Good.");
    }
    else {
      quest::say("The kobolds cage my [" . quest::saylink("wolves") . "] in their caves. I will see them free.");
    }
  }
  if ($text=~/I go get/i || $text=~/wolves/i) {
    if (!quest::istaskactive(600712) && !quest::istaskcompleted(600712)) {
      quest::say("Break the cages, feed my wolves, and cull the kobolds. Say [" . quest::saylink("meat") . "] when you are ready.");
      quest::assigntask(600712);
    }
  }
  if ($text=~/meat/i && quest::istaskactive(600712)) {
    quest::summonitem(36199);
    quest::summonitem(36199);
    quest::summonitem(36199);
    quest::say("Feed each captive wolf and the pack will remember your scent.");
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}

# Costica - Goru`kar Mesa
# The Serpent's Spine :: Minohten camp tasks (600661-600662).

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (quest::istaskactive(600661)) {
      quest::say("Two [tents], traveler. Flatten them and my herders will sleep easier.");
    }
    elsif (quest::istaskactive(600662)) {
      quest::say("The [dromrek] still waylay the caravans. Clear the road, then carry word to Nurel yourself.");
    }
    elsif (!quest::istaskcompleted(600661)) {
      quest::say("Strangers keep raising [tents] on our grazing grounds. Our patience is thinner than our milk.");
    }
    elsif (!quest::istaskcompleted(600662)) {
      quest::say("There is a [delivery] that never arrived - and a scribe in Direwind Cliffs who still waits for it.");
    }
    else {
      quest::say("The road to Direwind runs clean again. The herders speak your name kindly, $name.");
    }
  }
  if ($text=~/tents/i && !quest::istaskactive(600661) && !quest::istaskcompleted(600661)) {
    quest::say("Destroy two of the squatters' tents and speak with me. The grass will thank you, and so will I.");
    quest::assigntask(600661);
  }
  if ($text=~/delivery/i && quest::istaskcompleted(600661) && !quest::istaskactive(600662) && !quest::istaskcompleted(600662)) {
    quest::say("Dromrek bashers raid the caravans at the pass. Slay eight of them, then carry word of the cleared road to Scribe Nurel Uralu in Direwind Cliffs.");
    quest::assigntask(600662);
  }
  if ($text=~/dromrek/i && quest::istaskactive(600662)) {
    quest::say("They stalk near the pass north of here. Nurel Uralu waits beyond, in Direwind Cliffs.");
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}

# Armorer Arkin - Sunderock Springs
# The Serpent's Spine :: Elite's Insignia (600429)
# Repeatable faction task for Crusade of the Scale (1095). Turn in an
# Insignia of Ashengate's Elite (85699), then hail to close the exchange.

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if ($client->GetLevel() < 65) {
      quest::say("The Crusade needs veterans, $name, not recruits.");
      return;
    }
    if (quest::istaskactive(600429)) {
      quest::say("Hand me the insignia when you have it, $name.");
    }
    else {
      quest::say("The elite of Ashengate wear insignias worth more than their lives. Bring me one and I will see the [" .
                 quest::saylink("Crusade") . "] rewards you.");
    }
  }

  if ($text=~/crusade/i) {
    if ($client->GetLevel() >= 65 && !quest::istaskactive(600429)) {
      quest::assigntask(600429);
    }
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}

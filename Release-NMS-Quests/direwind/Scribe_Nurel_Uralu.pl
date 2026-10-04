# Scribe Nurel Uralu - Direwind Cliffs
# The Serpent's Spine :: hail target for Costica's Delivery to Nurel
# (task 600662, final step).

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (quest::istaskactive(600662)) {
      quest::say("Costica's word? Then the pass is clear at last! The caravans will run, and I will finally finish this [ledger].");
    }
    elsif (quest::istaskcompleted(600662)) {
      quest::say("The pass holds, $name. Ink dries on open roads now instead of graves.");
    }
    else {
      quest::say("I keep the accounts of every caravan that crosses the Cliffs - and lately the accounts are all in red. Tell Costica the scribe still waits.");
    }
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}

# Wraithguard Heimgul - Valdeholm
# The Serpent's Spine :: Bypass Heimgul (hand-in gate to Fergarin's missions)
# 3x Mark of Rallos Zek (67999) earns passage to Fergarin Bardon I.

sub EVENT_SAY {
  if ($text=~/hail/i) {
    my $passed = quest::get_data("valdeholm_bypass_heimgul_$userid");
    if ($passed >= 1) {
      quest::say("You have paid the toll of marks, $name. Fergarin Bardon I waits beyond - do not waste his time.");
    }
    else {
      quest::say("None pass into the inner hall without proof. Three [" . quest::saylink("marks") . "] of Rallos Zek, taken from the dead of Frostcrypt, and you may pass.");
    }
  }
  if ($text=~/marks/i) {
    quest::say("The shades of Frostcrypt carry them. Three marks, placed in my hand, and Fergarin's door opens to you.");
  }
}

sub EVENT_ITEM {
  my $marks = 0;
  $marks += $itemcount{67999} if exists $itemcount{67999};
  if ($marks >= 3) {
    quest::set_data("valdeholm_bypass_heimgul_$userid", '1', '0');
    quest::say("The marks are paid, and your name will be spoken to Fergarin. Pass, ally of the Wraithguard.");
    quest::faction(1104, 50); # Wraithguard
    quest::faction(1105, 50); # Wraithguard Leadership
    if ($marks > 3) {
      plugin::return_items(\%itemcount);
    }
    return 1;
  }
  plugin::return_items(\%itemcount);
}

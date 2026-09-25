# Drake Handler Rolkor - Sunderock Springs
# The Serpent's Spine :: Travel to the Battlelines
# Requires Ally faction with Crusade of the Scale (1095). The ally threshold is
# Faction:AllyFactionMinimum = 1100 in rule_values. Teleports are one way.

use constant CRUSADE => 1095;
use constant ALLY_MIN => 1100;

sub ally {
  return $client->GetCharacterFactionLevel(CRUSADE) >= ALLY_MIN;
}

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (!ally()) {
      quest::say("Rolkor only flies for friends of the Crusade, $name. Prove yourself first.");
      return;
    }
    quest::say("Where to, $name? I run the [" . quest::saylink("Green Legion") . "] at the mine gate, the [" .
               quest::saylink("Gray Legion") . "] in the south of Direwind, and the [" .
               quest::saylink("Black Legion") . "] up by the Ashengate gate.");
  }

  if (!ally()) {
    return;
  }

  if ($text=~/green legion/i) {
    quest::say("Green Legion. Hold on.");
    quest::movepc(403, 745, -1615, 375, 0);
  }
  elsif ($text=~/gray legion/i) {
    quest::say("Gray Legion. Mind the cliffs.");
    quest::movepc(405, -1280, -1930, 3, 0);
  }
  elsif ($text=~/black legion/i) {
    quest::say("Black Legion, by the gate. Watch yourself up there.");
    quest::movepc(405, -100, 2800, 378, 0);
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}

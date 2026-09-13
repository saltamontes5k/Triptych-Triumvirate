# Quartermaster Thatun - Crescent Reach (near the training dummies)
# The Serpent's Spine :: Ithakis' Challenge (task 600243)
# Gives the Breath of the Red Lord (84206) and Flame-Sealed Box (84207).

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (quest::istaskactivityactive(600243, 0)) {
      quest::say("Ah, one of Ithakis' hopefuls. Very well. You wish to understand the [flame] of the drakkin?");
    }
    elsif (quest::istaskactive(600243)) {
      quest::say("Strike the dummy with your own hands. Then light the torch with the breath I gave you, and see Drawlyn about the blade.");
    }
    else {
      quest::say("Mind the dummies - they break faster than you would think.");
    }
  }
  if ($text=~/flame/i or $text=~/understand/i) {
    quest::say("Then we begin. Take this sealed box and this vial of the Red Lord's breath. Do not open the box away from your torch - the flame of the blood answers only to the torch of the blood. Strike the training dummy, light your torch, and be about it.");
    quest::summonitem(84206); # Breath of the Red Lord
    quest::summonitem(84207); # Flame-Sealed Box
    if (quest::istaskactivityactive(600243, 0)) {
      quest::updatetaskactivity(600243, 0, 1);
    }
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}

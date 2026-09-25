# a caravan supplies crate - Sunderock Springs
# The Missing Caravan (600435). Opening the wrecked caravan yields the note
# that Captain Zheren is waiting for.

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (quest::countitem(36149) > 0) {
      quest::say("The note has already been recovered from this wreck.");
    }
    else {
      quest::emote("splinters open, scattering trade goods across the sand. A sealed note lies among them.");
      quest::summonitem(36149, 1);
    }
  }
}

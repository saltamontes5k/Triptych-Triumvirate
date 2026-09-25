#--------------------------------------------------------------------------
# TBS: Paza - Jewel of Atiiki (423914)
# Spawned by Mahatototarit. Grants Efreeti Death Visage (79515), then depops.
#--------------------------------------------------------------------------
sub EVENT_SAY {
  if ($text=~/hail/i) {
    quest::say("Brother, my time is short. I have done as Xanxionusus commanded... take my mask so that my soul is released from this torment before I am drawn over once again.");
    quest::summonitem(79515);
    quest::depop();
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}

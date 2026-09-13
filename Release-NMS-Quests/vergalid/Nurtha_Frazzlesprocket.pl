# Nurtha Frazzlesprocket - Vergalid Mines (TSS instanced, Vergalid's End / The Pretender)
# npc: 600142   dz template: 6007

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (quest::istaskactive(600022)) {
      quest::say("So Zhubis sent you. He always was too curious for his own good. You want the [" . quest::saylink("truth") . "]? Fine. Dyn`leth is no god - he is a machine that I built to keep the Legion in line.");
    }
    else {
      quest::say("You should not be here, little one. My contraptions will make short work of you.");
    }
  }
  if ($text=~/truth/i) {
    quest::say("Vergalid is the engine, not the master. The Legion marches to a gnome's ticking heart. Now - I have said too much. Say goodbye.");
  }
}

sub EVENT_AGGRO {
  quest::say("Contraptions, defend your creator!");
  quest::emote("hurls a spanner at you and ducks behind a churning machine.");
}

sub EVENT_DEATH_COMPLETE {
  quest::shout("Nurtha Frazzlesprocket's contraptions grind to a halt... for now.");
}

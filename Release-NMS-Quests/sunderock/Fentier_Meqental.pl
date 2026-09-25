# Fentier Meqental - Sunderock Springs
# The Serpent's Spine :: Into the Void (600432)
# Requires Inner Vergalid access (the statue door east of the Shrine of Zek,
# keyed by the Flawless Indicolite Shard). Kill voidspawn and bonefiends in
# the pit for chunks of blackvein ore.

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if ($client->GetLevel() < 65) {
      quest::say("Not for the likes of you yet, $name.");
      return;
    }
    if (quest::istaskactive(600432)) {
      quest::say("Four chunks of blackvein ore, $name. The pit below will not give them up easily.");
    }
    else {
      quest::say("There is a blackness beneath the mines, $name, and it bleeds [" . quest::saylink("ore") .
                 "]. Enter the inner pit and bring me four chunks of blackvein ore.");
    }
  }

  if ($text=~/ore/i && $client->GetLevel() >= 65 && !quest::istaskactive(600432)) {
    quest::assigntask(600432);
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}

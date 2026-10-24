# Grenrik the Addled - Frostcrypt, Throne of the Shade King
# The Serpent's Spine :: Maze raid event.
# Hand him a Jagged Ice Key (88195) and the addled old man sheds his disguise,
# becoming a frost giant that attacks. Lose aggro and he reverts, non-kos.
# Loot: the maze event drops.

sub EVENT_SAY {
  if ($text=~/hail/i) {
    quest::say("Cold... so cold. Have you seen my [" . quest::saylink("key") . "]? I dropped my key. I cannot get home without my key.");
  }
  if ($text=~/key/i) {
    quest::say("A jagged key, of ice. The corner-things keep it. Crush, Fleshless, Haze, Fallow - they hoard what is not theirs.");
  }
}

sub EVENT_ITEM {
  if (defined $itemcount{88195} && $itemcount{88195} >= 1) {
    quest::emote("clutches the jagged key. His eyes go clear - and then red. 'MY HOME. MINE!' Grenrik the Addled swells into a towering frost giant!");
    quest::shout("GUARDS! GUARDS OF THE ICE! THE MAZE IS BREACHED!");
    quest::attack($name);
    return 1;
  }
  plugin::return_items(\%itemcount);
}

sub EVENT_COMBAT {
  if ($combat_state == 0) {
    quest::emote("shrinks back into his addled, wandering form, muttering about keys.");
    quest::say("Cold... so cold. Have you seen my key?");
  }
}

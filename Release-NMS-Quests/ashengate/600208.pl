# Shade of Veldyn - Ashengate North raid (NPC 600208)
# Mini-boss (skippable). Seven disciples with auras attend her.

sub EVENT_AGGRO {
  quest::shout("Veldyn's disciples shall drag you into her shade!");
  quest::emote("stirs, seven shrouded disciples answering her call.");
}

sub EVENT_DEATH_COMPLETE {
  quest::shout("The Shade of Veldyn dissipates with a sigh.");
}

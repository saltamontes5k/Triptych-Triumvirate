# Goru Uldrock, the Reincarnate - Vergalid Mines (TSS instanced, Vergalid's End / Severing the Strings)
# npc: 600143   dz template: 6007
# Made to walk again; the six Stone Protectors in the shrine room feed his life force.

sub EVENT_AGGRO {
  quest::shout("I was dead! I was at peace! Why have you dragged me back to this crumbling stone?");
  quest::emote("shambles forward, ancient stone grinding with every step.");
}

sub EVENT_DEATH_COMPLETE {
  quest::shout("At last... let me rest...");
}

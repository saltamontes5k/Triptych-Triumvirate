# Sleepers 2.0 -- Kerafyrm (128089), the sealed boss of Kerafyrm's Chamber.
#
# The old wake chain (globals, door 46, the #Kerafyrm_ walk-out, and the
# spawn-condition swap) is no longer used. The bubble / five-seal gate lives in
# encounters/sleeper_custom.lua.
#
# plugin::handle_death spawns the memory NPC (global/26000.pl) with the SoD
# "kerafyrm" objective when the kill happens in a qualifying instance.
sub EVENT_SLAY {
	quest::shout("Begone insect, I have much slaying yet to do!");
}

sub EVENT_NPC_SLAY {
	quest::shout("Begone insect, I have much slaying yet to do!");
}

sub EVENT_DEATH_COMPLETE {
	plugin::handle_death($npc, $x, $y, $z, $entity_list);
}

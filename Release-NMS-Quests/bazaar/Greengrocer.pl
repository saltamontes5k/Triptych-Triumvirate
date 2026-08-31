############################################
# ZONE: Bazaar
# VERSION: 1.0
# TYPE: Custom (NMS)
#
# *** NPC INFORMATION ***
#
# NAME: Greengrocer
# RACE: Halfling
# LEVEL: 65
#
# *** PURPOSE ***
#
# Campfire provisioner - hail to receive a stack
# of Heroes' Blessing and Legends' Blessing.
#
############################################

sub EVENT_SAY {
	if ($text =~ /hail/i) {
		quest::summonitem(25866, 20);
		quest::summonitem(25865, 20);
	}
}
# END of FILE Zone:bazaar -- Greengrocer.pl

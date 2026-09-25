# Sleeper's Tomb 1.0 -- the awakened Kerafyrm (instance version 1 only).
# Versioned by NPC id, so this shadows the base #Kerafyrm.pl (which drives the
# 2.0 door/global behaviour) inside the v1 expedition.
#
# The Dragonslayer title (title_set 200) is awarded to everyone present when the
# Sleeper is set loose.
sub EVENT_SPAWN {
	foreach my $pc ($entity_list->GetClientList()) {
		plugin::AddTitleFlag(200, $pc);
	}
}

# Sleepers 2.0 -- Kildrukaun the Ancient (128041). One of the five seals.
#
# This seal no longer despawns while Kerafyrm is present. Seal tracking and the
# unlock of Kerafyrm are handled by encounters/sleeper_custom.lua.
sub EVENT_DEATH_COMPLETE {
	quest::shout("The seal of poison is broken... the prison weakens.");
}

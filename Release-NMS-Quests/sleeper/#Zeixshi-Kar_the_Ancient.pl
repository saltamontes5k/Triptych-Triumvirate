# Sleepers 2.0 -- Zeixshi-Kar the Ancient (128044). One of the five seals.
#
# This seal no longer despawns while Kerafyrm is present. Seal tracking and the
# unlock of Kerafyrm are handled by encounters/sleeper_custom.lua.
sub EVENT_DEATH_COMPLETE {
	quest::shout("The seal of frost is broken... the prison weakens.");
}

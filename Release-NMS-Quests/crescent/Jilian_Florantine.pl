# Jilian Florantine - Crescent Reach, by the river near the caves.
# 2009 "Haunted Cave" (task 620012): clear the two haunted caves.
# Seasonal (peq_halloween); spawn is flag-gated.
sub EVENT_SAY {
	if (!quest::is_content_flag_enabled('peq_halloween')) {
		quest::say("The caves are quiet tonight... return during the Nights of the Dead.");
		return;
	}
	if ($text=~/hail/i) {
		quest::say("Something is wrong in the caves by the river. Are you [willing] to look into it?");
		if (quest::istaskactive(620012)) { quest::updatetaskactivity(620012, 2, 1); }
	}
	elsif ($text=~/willing|help/i) {
		if (!quest::istaskactive(620012)) {
			quest::say("Bless you! The Nokk cave east of the river is haunted by a Ghost of All Hallows Eve, and the undead cave north of it crawls with its Shadows. Clear them both, then come back to me.");
			quest::assigntask(620012);
		} else {
			quest::say("The caves, friend! The Nokk cave east of the river, then the undead cave north of it.");
		}
	}
}

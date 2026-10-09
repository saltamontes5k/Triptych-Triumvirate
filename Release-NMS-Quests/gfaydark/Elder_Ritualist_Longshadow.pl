# Elder Ritualist Longshadow - Greater Faydark pocket.
# Finishes "Under Your Skin" (task 620016) after the true Skinwalker falls.
sub EVENT_SAY {
	if (!quest::is_content_flag_enabled('peq_halloween')) {
		quest::say("The ritual is dormant... return during the Nights of the Dead.");
		return;
	}
	if ($text=~/hail/i) {
		if (quest::istaskactive(620016) && quest::istaskactivityactive(620016, 1)) {
			quest::updatetaskactivity(620016, 2, 1);
			quest::say("The circle holds. What wore those skins is unmade - and its stolen shape returns to the moon. Take this vial; a sliver of the wild moon swims in it.");
			# neutralize the true/fake pick and clear any leftover fakes
			quest::setglobal('notd_uys_true', 0, 7, 'H1');
			foreach my $tid (1500200076, 1500200077, 1500200078) {
				for (my $tries = 0; $tries < 24; $tries++) {
					my $m = $entity_list->GetNPCByNPCTypeID($tid);
					last if !$m;
					$m->Depop();
				}
			}
		} else {
			quest::say("The rite waits on the creature that wears the stolen skin.");
		}
	}
}

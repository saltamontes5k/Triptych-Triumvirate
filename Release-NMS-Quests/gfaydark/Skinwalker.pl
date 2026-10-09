# Skinwalker - Greater Faydark, far east pocket (world's rim).
# Starter for "Under Your Skin" (task 620016).  Picks the true Skinwalker via
# the zone qglobal notd_uys_true, then spawns the three look-alikes.
# Seasonal (peq_halloween); spawn is flag-gated.
sub EVENT_SAY {
	if (!quest::is_content_flag_enabled('peq_halloween')) {
		quest::say("*The thing wearing a face smiles wrong* ...return during the Nights of the Dead.");
		return;
	}
	if ($text=~/hail/i) {
		if (quest::istaskactive(620016)) {
			my $up = 0;
			foreach my $tid (1500200076, 1500200077, 1500200078) {
				if ($entity_list->GetNPCByNPCTypeID($tid)) { $up = 1; }
			}
			if ($up) {
				quest::say("Which of us is ME? Kill wisely, little thing.");
			} else {
				quest::updatetaskactivity(620016, 0, 1);
				quest::setglobal('notd_uys_true', int(rand(3)) + 1, 7, 'H2');
				quest::spawn2(60020077, 0, 0, 4420, 1850, 5, 0);
				quest::spawn2(60020078, 0, 0, 4460, 1850, 5, 0);
				quest::spawn2(60020079, 0, 0, 4440, 1900, 5, 0);
				quest::say("Clever little thing, following me here. But can you tell which of us is ME?");
			}
		} else {
			quest::say("*It wears a face that is not its own* Rhaeda sent you? Then come back carrying her errand.");
		}
	}
}

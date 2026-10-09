# Edmund Strangeways - Plane of Knowledge, evil quarter.
# 2009 "Digging Their Graves" (620013, repeatable; 14h lockout via the
# notd_graves_last bucket) and the master quest "The Hunt for Tattooed Flesh"
# (620014; unlocks after 5 completions, tracked in notd_graves_count /
# notd_master_prog).
# Seasonal (peq_halloween); spawn is flag-gated.
my $LOCKOUT = 14 * 3600;

sub lockout_left {
	my $last = quest::get_data('notd_graves_last') || 0;
	my $left = ($last + $LOCKOUT) - time();
	return $left > 0 ? $left : 0;
}

sub EVENT_SAY {
	if (!quest::is_content_flag_enabled('peq_halloween')) {
		quest::say("The graves keep their secrets... return during the Nights of the Dead.");
		return;
	}
	my $count = quest::get_data('notd_graves_count') || 0;
	if ($text=~/hail/i) {
		if (quest::istaskactive(620014)) {
			quest::say("The ledger is still short. Each burial duty you finish - flesh and shovel to me, then hail me, and we square one more line.");
		}
		elsif ($count >= 5 && !quest::istaskcompleted(620014)) {
			quest::say("Five graves dug and still they rise... you have the feel of it now. There is a [hunt] I would put your name to.");
		}
		elsif (quest::istaskactive(620013)) {
			quest::say("The disturbed earth lies scattered - Nektulos Forest, the Lake of Ill Omen, Firiona Vie, the Emerald Jungle, Goru'Kar Mesa, the Barren Coast, the Steppes, the Buried Sea, the Loping Plains, even the Field of Scale. Target the disturbed earth and dig with the shovel.");
		}
		else {
			quest::say("You there. The dead are restless this season, and I pay in secrets. [Bring] me what the graves cough up.");
		}
	}
	elsif ($text=~/hunt/i && $count >= 5 && !quest::istaskactive(620014) && !quest::istaskcompleted(620014)) {
		quest::say("They call it the Hunt for Tattooed Flesh. Five more burial duties - dig, slay, and report back to me after each. Do this and I will see your name writ where it matters.");
		quest::set_data('notd_master_prog', 0);
		quest::assigntask(620014);
	}
	elsif ($text=~/bring/i) {
		if (quest::istaskactive(620013)) {
			quest::say("You still carry my shovel. Target the disturbed earth and dig!");
		}
		elsif (my $left = lockout_left()) {
			quest::say("The graves need time to settle. Come back in " . int($left / 3600) . " hours and " . int(($left % 3600) / 60) . " minutes.");
		}
		else {
			quest::say("Take this shovel. Find the disturbed earth - target it and dig. Slay whatever claws its way out and bring me the flesh, and my shovel, back.");
			quest::assigntask(620013);
			quest::summonitem(3001008);
		}
	}
}

sub EVENT_ITEM {
	if ($itemcount{3001009} >= 1 && $itemcount{3001008} >= 1 && quest::istaskactive(620013)) {
		quest::updatetaskactivity(620013, 1, 1);
		my $count = (quest::get_data('notd_graves_count') || 0) + 1;
		quest::set_data('notd_graves_count', $count);
		quest::set_data('notd_graves_last', time());
		quest::say("Fine work. That makes $count by my ledger.");
		if (quest::istaskactive(620014)) {
			my $prog = quest::get_data('notd_master_prog') || 0;
			if ($prog < 5) {
				quest::updatetaskactivity(620014, $prog, 1);
				quest::set_data('notd_master_prog', $prog + 1);
				if ($prog + 1 >= 5) {
					quest::say("That closes the ledger. The writ you are owed will find you - and when folk ask who put the dead back down, you may now tell them truthfully.");
				}
			}
		}
	}
	else {
		plugin::return_items(\%itemcount);
	}
}

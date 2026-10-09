# Illis Taberish - Plane of Knowledge, by the tree near the main bank.
# 2010 mini-mission "Terror of Illis Taberish" (task 620015): slay four
# skinwalker nameds in the zone matching your band and bring back their
# soul shards.  Seasonal (peq_halloween); spawn is flag-gated.
sub EVENT_SAY {
	if (!quest::is_content_flag_enabled('peq_halloween')) {
		quest::say("The skins hang quiet... return during the Nights of the Dead.");
		return;
	}
	if ($text=~/hail/i) {
		if (!quest::istaskactive(620015)) {
			quest::say("They wear our skins while we sleep, you know. Skinwalkers. [Bring] me four of their soul shards and I will show you how they slip away.");
		} else {
			quest::say("Four shards. Hunt the band that fits you: Nektulos Forest for the young, the Lake of Ill Omen, Firiona Vie, the Emerald Jungle, Goru'Kar Mesa, the Barren Coast, the Steppes, and the Loping Plains for the old.");
		}
	}
	elsif ($text=~/bring/i && !quest::istaskactive(620015)) {
		quest::say("Slay four of them - the ones wearing faces near your own strength: Nektulos Forest (10), Lake of Ill Omen (20), Firiona Vie (30), the Emerald Jungle (40), Goru'Kar Mesa (50), the Barren Coast (60), the Steppes (70), the Loping Plains (80). Each carries a piece of its stolen soul.");
		quest::assigntask(620015);
	}
}

sub EVENT_ITEM {
	if ($itemcount{3001011} >= 4 && quest::istaskactive(620015)) {
		quest::updatetaskactivity(620015, 1, 1);
		quest::say("Four shards, still warm. Here - the bat's form, so you may slip away the way they do.");
	}
	else {
		plugin::return_items(\%itemcount);
	}
}

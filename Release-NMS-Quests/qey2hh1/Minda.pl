sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Hello. Nice to make your acquaintance. Be careful in the plains. There are many creatures. Just stay close to the guard towers.");
	}
	elsif ($text=~/follower of karana/i) {
		quest::say("Yes. I am a follower of Karana, the Rainkeeper. It is He who keeps the plains fertile.");
	}
	elsif ($text=~/karana's blessings/i) {
		quest::say("Of the things I desire, I can think of nothing I wish for more than the blessings of Karana. By drinking from the temple chalice of a Karana cleric I can attain this.");
	}
	elsif ($text=~/karana bandits/i) {
		quest::say("The Karana bandits are rogues who operate in the plains. I have heard there are bounties for the bandits. Within the Temple of Thunder in Qeynos, Cleric Gehna offers one for bandit spectacles and Paladin Chesgard offers one for bandit sashes.");
	}
}

sub EVENT_ITEM {
	#:: Match a 12103 - Full Chalice
	if (plugin::check_handin(\%itemcount, 12103 => 1)) {
		quest::say("May the Rainkeeper keep you safe. I thank you. Here is the empty chalice. By the way, inform your superior that the operations of the [Karana bandits] are getting closer to Qeynos.");
		#:: Give a 12104 - Empty Chalice
		quest::summonitem(12104);
		#:: Ding
		quest::ding();
		#:: Set factions
		quest::faction(345, 5);			#:: + Karana Residents
		quest::faction(262, 1);			#:: + Guards of Qeynos
		quest::faction(341, 1);			#:: + Priests of Life
		quest::faction(280, 1);			#:: + Knights of Thunder
		#:: Grant a small amount of experience
		quest::exp(500);
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}

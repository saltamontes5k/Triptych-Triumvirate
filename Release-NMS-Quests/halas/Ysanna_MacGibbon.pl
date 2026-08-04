sub EVENT_SPAWN {
	#:: Create a proximity, 100 units across, 100 units tall, and enable proximity say
	quest::set_proximity($x - 50, $x + 50, $y - 50, $y + 50, $z - 50, $z + 50, 1);
	#:: Also enable proximity say
	quest::enable_proximity_say();
}
	
sub EVENT_PROXIMITY_SAY {
	if ($text=~/gnoll fur/i) {
		quest::say("You should not be asking where or what a gnoll is, but asking how I make use of that patch fur I find on their corpse. It is quite simple, take four pieces of gnoll fur and sew them together. Take the result and sew four of them together. And again with that product. In the end you will have a bundle of tailored gnoll fur. You can either return it to me or keep it for yourself.");
	}
}

sub EVENT_SIGNAL {
	#:: Match signal sent from halas/Cappi_McTarnigal.pl
	if ($signal == 1) {
		quest::say("The mammoth calf hides are used to shield our beasts of burden from the icy wind. You are probably now asking what shields us Northmen from that same icy wind eh? Well, along with many other furs and leathers, we have come to find that [gnoll fur] of all things is a good insulator against the cold. Look at their tiny bodies and it's obvious their fur does something good.");
	}
}

sub EVENT_ITEM {
	#:: Match a 1330 - Patched Gnoll Fur Bundle
	if (plugin::check_handin(\%itemcount, 1330 => 1)) {
		quest::say("You have done well. Here is a small reward for your effort.");
		#:: Give a 1349 - Fang of the Wolf
		quest::summonitem(11349);
		#:: Ding!
		quest::ding();
		#:: Set faction
		quest::faction(305, 5);		#:: + Rogues of the White Rose
		#:: Grant a small amount of experience
		quest::exp(125);
		#:: Create a hash for storing cash - 1000 to 1300cp
		my %cash = plugin::RandomCash(1000,1300);
		#:: Grant a random cash reward
		quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}

sub EVENT_SAY { 
	if ($text=~/hail/i) {
		quest::say("Hey, hey, hey! Welcome to the Fool's Gold. Don't bet more than you can afford to lose, pal! You don't want to end up like ol' [Kevlin].");
	}
	elsif ($text=~/kevlin/i) {
		quest::say("Kevlin Diggs. His family sells armor here in Rivervale. He has a nice shop right across from us here. But he owes us Deeppockets some [gold] that we need to collect. We can't rough him up because he is a friend of Mayor Gubbin. We need someone to steal it.");
	}
	elsif ($text=~/gold/i) {
		quest::say("He keeps his money in a sack on his bed. But he has a mean pet wolf, named Mangler, who mangled the last cutpurse we sent after it. If you were to wait until he leaves his shop, then sneak past Mangler and bring me the money he owes us, I will make it worth your time.");
	}
}

sub EVENT_ITEM {
	#:: Match a 13182 - Kevlin's Debt
	if (plugin::check_handin(\%itemcount, 13182 => 1)) {
		quest::say("Heh heh! You got a career ahead of ya kid! Good work. Here is your cut.");
		#:: Ding!
		quest::ding();
		#:: Grant a small amount of experience
		quest::exp(300);
		#:: Create a hash for storing cash - 40 to 60cp
		my %cash = plugin::RandomCash(40,60);
		#:: Grant a random cash reward
		quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}

sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Stand at attention!! You don't look fit enough to toe-wrestle my grandma!! You cannot be in my squad!! Are you [petitioning] or are you a [visitor]?");
	}
	elsif ($text=~/hello/i) {
		quest::say("Do I look like your best friend?!! Well I'm not, bixie buster!! You will address an officer with the word 'Hail' like every other deputy. Stand up straight, hunchback, or you'll be patrolling Rivervale till dawn!");
	}
	elsif ($text=~/visitor/i) {
		quest::say("Well, why didn't you say so?! Forgive me for hollering. Allow me to introduce myself. I am Marshal Anrey Leadladle, commander of the [Leatherfoot Raiders].");
	}
	elsif ($text=~/petitioning/i) {
		quest::say("So you want to be a [Leatherfoot Raider]? What kind of joke is this? Look at you! You're a mess! Where are you [from]?");
	}
	elsif ($text=~/leatherfoot raider/i) {
		quest::say("You must be a visitor. The Leatherfoot Raiders are the elite force of the Guardians of the Vale. I command them. It is good to meet an outsider.");
	}
	elsif ($text=~/from rivervale/i) {
		quest::say("So you're from Rivervale?!! You must be some kind of freak. No halfling from Rivervale would look, smell and act anything like you. Well, freak, if you think you're stout enough to be a Leatherfoot Raider, you prove it!! You travel the lands and return to me a polar bear skin, a grizzly bear skin, a shark skin and an alligator skin. Then maybe, just maybe, I will let you wear the cap of a Leatherfoot Raider.");
	}
	elsif ($text=~/from freeport/i) {
		quest::say("What!! The only thing from there are gnolls and trolls!! Which one are you?!! You kind of look like a troll, but you smell like a gnoll. Get out of my sight or you will be cleaning the latrine with a toothbrush.");
	}
}

sub EVENT_ITEM {
	#:: Match a 13749 - Alligator Skin, a 13761 - Polar Bear Skin, a 13075 - Shark Skin, and a 13756 - Thick Grizzly Bear Skin
	if (plugin::check_handin(\%itemcount, 13749 => 1, 13761 => 1, 13075 => 1, 13756 => 1)) {
		quest::say("Good work, $name. You passed the first test. If you think you are one of us, return this cap to me along with a dagger from a Dark Elf for your true reward.");
		#:: Give a 13941 - Leatherfoot Skullcap
		quest::summonitem(13941);
		#:: Ding!
		quest::ding();
		#:: Grant a moderate amount of experience
		quest::exp(1000);
		#:: Create a hash for storing cash - 15 to 20cp
		my %cash = plugin::RandomCash(15,20);
		#:: Grant a random cash reward
		quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
	}		
	#:: Match a 13942 - Dragoon Dirk and 13941 = Leatherfoot Skullcap
	elsif (plugin::check_handin(\%itemcount, 13942 => 1, 13941 => 1)) {
		quest::say("Wonderful, $name. You have proven yourself to the Leatherfoot Squad. Take this and wear it with honor.");
		#:: Give item 12259 - Leatherfoot Raider Skullcap
		quest::summonitem(12259);
		#:: Ding!
		quest::ding();
		#:: Grant a large amount of experience
		quest::exp(5000);
		#:: Create a hash for storing cash - 1225 to 1250cp
		my %cash = plugin::RandomCash(1225,1250);
		#:: Grant a random cash reward
		quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
	}		
	#:: Return unused items
	plugin::return_items(\%itemcount);
}

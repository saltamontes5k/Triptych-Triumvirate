sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Hello, $name.  I am Lanena Wickystick, marshal of all Vale concerns.  If there are any troubles brewing in our fine town which concern the Guardians of the Vale, please inform me.  You must be a [new deputy] or are you an [outsider]?");
	}
	if ($text=~/new deputy/i) {
		#:: Match if faction is better than indifferent
		if ($faction < 5) {
			quest::say("It is good to see such fine stock in the ranks of the Guardians.  Being new, there is much to learn, in battle, and in life itself.  If you are not presently obligated, we have need of you here in the hollow.  There seems to be a [small problem].");
		}
		else {
			quest::say("You are not yet in good standing with the Guardians of the Vale. Continue with your good work and then we may speak.");
		}
	}
	if ($text=~/outsider/i) {
			quest::say("Well, then!! You should not be in here.  This place is restricted to all outsiders.  You will leave at once!  Thank you and good day.");
	}
	if ($text=~/small problem/i) {
		#:: Match if faction is better than indifferent
		if ($faction < 5) {
			quest::say("For months, Fiddy Bobick has petitioned the marshals to assist him with a problem he has.  With the addition of new deputies such as yourself, we can now give him the assistance he requires.  Just go down to Bobick's shop near the lake.  Tell him I sent you.");
		}
		else {
			quest::say("You are not yet in good standing with the Guardians of the Vale. Continue with your good work and then we may speak.");
		}
	}
	if ($text=~/rantho rapier/i) {
		#:: Match if faction is better than indifferent
		if ($faction < 5) {
			quest::say("The Rantho Rapier was crafted by the great blacksmith Rantho Goobler.  It was designed for use by the warriors of the wee folk.  With its light weight and special two-hand hilt, it becomes a formidable weapon in the hands of our younger deputies.  Only a [new deputy] has the right to earn one.");
		}
		else {
			quest::say("You are not yet in good standing with the Guardians of the Vale. Continue with your good work and then we may speak.");
		}
	}
}

sub EVENT_ITEM {
	#:: Match a 13870 - Piranha Tooth
	if (plugin::check_handin(\%itemcount, 13870 => 1)) {
		#:: Match if faction is better than indifferent
		if ($faction < 5) {
			quest::say("What was I thinking?!! Piranha are coming downstream and eating our supply of fish! We have never had a problem like this!!  Where are these little beasts coming from?  For now we must collect more. Take this bag. Collect enough teeth to fill the bag. Don't worry, if it takes a while I shall reward you with the [Rantho Rapier].  We will need to examine the teeth.");
			#:: Give a 17968 - Piranha Bag
			quest::summonitem(17968);
			#:: Ding!
			quest::ding();
			#:: Grant a small amount of experience
			quest::exp(200);
			#:: Create a hash for storing cash - 9 to 10cp
			my %cash = plugin::RandomCash(9,10);
			#:: Grant a random cash reward
			quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
			#:: Set factions
			quest::faction(263,10); 	#:: + Guardians of the Vale
			quest::faction(286,10); 	#:: + Mayor Gubbin
			quest::faction(355,10); 	#:: + Storm Reapers
			quest::faction(292,10); 	#:: + Merchants of Rivervale
			quest::faction(334,-10); 	#:: - Dreadguard Outer
		}
		else {
			quest::say("You are not yet in good standing with the Guardians of the Vale. Continue with your good work and then we may speak.");
			#:: Give back a 13870 - Piranha Tooth
			quest::summonitem(13870);
		}
	}		
	#:: Match a 12155 - Bag of Piranha Teeth
	if (plugin::check_handin(\%itemcount, 12155 => 1)) {
		#:: Match if faction is better than indifferent
		if ($faction < 5) {
			quest::say("Fine work. We shall continue to study these and shall determine if we need to seek the source.");
			#:: Give a 5423 - Rantho Rapier
			quest::summonitem(15423);
			#:: Ding!
			quest::ding();
			#:: Grant a large amount of experience
			quest::exp(5000);
			#:: Create a hash for storing cash - 9 to 11cp
			my %cash = plugin::RandomCash(9,11);
			#:: Grant a random cash reward
			quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
			#:: Set factions
			quest::faction(263,10); 	#:: + Guardians of the Vale
			quest::faction(286,10); 	#:: + Mayor Gubbin
			quest::faction(355,10); 	#:: + Storm Reapers
			quest::faction(292,10); 	#:: + Merchants of Rivervale
			quest::faction(334,-10); 	#:: - Dreadguard Outer
		}
		else {
			quest::say("You are not yet in good standing with the Guardians of the Vale. Continue with your good work and then we may speak.");
			#:: Give 12155 - Bag of Piranha Teeth
			quest::summonitem(12155);
		}
	}		
	#:: Return unused items
	plugin::return_items(\%itemcount);
}

sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Oh, hi.  Listen, um.. $name, was it?  Listen, pal,  I really don't have time for the friendly-friendly, so why don't you just move on?");
	}
	elsif ($text=~/new dishwasher/i) {
		#:: Match if faction is Amiable or better
		if ($faction <= 4) {
			quest::say("Dishwasher, huh?  You must not mind getting your feet wet then, huh?  Well, I do have a job for you.  It seems one of our younger employees got a little nevous around a Deputy and ditched his um..  recent purchase into the river.  We sent the fool after it but ol' [Chomper] got him.  He said he had dropped it off the docks but the currents might have moved it from there.  It should be in an old pouch.  Return the merchandise to me.  Well?  Get going!");
		}
		#:: Match if faction is indifferent
		elsif ($faction == 5) {
			quest::say("You need to prove your dedication to our cause before I can discuss such matters with you.");
		}
		else {
			quest::say("Oh, hi.  Listen, um.. $name, was it?  Listen, pal.  I really don't have time for the friendly-friendly, so why don't you just move on?");
		}
	}
	elsif ($text=~/chomper/i) {
		#:: Match if faction is Amiable or better
		if ($faction <= 4) {
			quest::say("Chomper is a big, mean ol' fish.  He looks like a normal fish, but a little bigger, and boy, oh boy, is he mean!");
		}
		#:: Match if faction is indifferent
		elsif ($faction == 5) {
			quest::say("You need to prove your dedication to our cause before I can discuss such matters with you.");
		}
		else {
			quest::say("Oh, hi.  Listen, um.. $name, was it?  Listen, pal, I really don't have time for the friendly-friendly, so why don't you just move on?");
		}
	}
}

sub EVENT_ITEM {
	#:: Match a 13785 - Torn Old Pouch
	if (plugin::check_handin(\%itemcount, 13785 => 1)) {
		#:: Match if faction is Indifferent or better
		if ($faction <= 5) {		
			quest::say("What is this?  The pouch is empty!  Where is the Ruby?!  What do you mean you don't have it?  Oh no.  I bet [Chomper] swallowed it!  Get it back and bring it to me.");
			#:: Ding!
			quest::ding();
			#:: Set factions
			quest::faction(241, 5);			#:: + Deeppockets
			quest::faction(223, 1);			#:: + Circle of Unseen Hands
			quest::faction(292, -1);		#:: - Merchants of Rivervale
			quest::faction(336, 1);			#:: + Coalition of Tradefolk Underground
			quest::faction(329, 1);			#:: + Carson McCabe
			#:: Grant a moderate amount of experience
			quest::exp(1500);
			#:: Create a hash for storing cash - 900 to 2000cp
			my %cash = plugin::RandomCash(900,2000);
			#:: Grant a random cash reward
			quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
		}
		else {
			quest::say("Oh, hi.  Listen, um.. $name, was it?  Listen, pal,  I really don't have time for the friendly-friendly, so why don't you just move on?");
			#:: Give a 13785 - Torn Old Pouch
			quest::summonitem(13785);
		}
	}
	#:: Match a 13786 - Large Ruby
	if (plugin::check_handin(\%itemcount, 13786 => 1)) {
		#:: Match if faction is Indifferent or better
		if ($faction <= 5) {		
			quest::say("You found it!  Heh.  Good thing you brought it back bub.  This thing isn't priceless, its worthless but at least you proved you are loyal.  Poor ol' Chomper..");
			#:: Ding!
			quest::ding();
			#:: Set factions
			quest::faction(241, 10);		#:: + Deeppockets
			quest::faction(223, 1);			#:: + Circle of Unseen Hands
			quest::faction(292, -1);		#:: - Merchants of Rivervale
			quest::faction(336, 1);			#:: + Coalition of Tradefolk Underground
			quest::faction(329, 1);			#:: + Carson McCabe
			#:: Grant a moderate amount of experience
			quest::exp(1000);
			#:: Create a hash for storing cash - 900 to 2000cp
			my %cash = plugin::RandomCash(1800,4000);
			#:: Grant a random cash reward
			quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
		}
		else {
			quest::say("Oh, hi.  Listen, um.. $name, was it?  Listen, pal, I really don't have time for the friendly-friendly, so why don't you just move on?");
			#:: Give a 13786 - Large Ruby
			quest::summonitem(13786);
		}
	}	
	#:: Return unused items
	plugin::return_items(\%itemcount);
}

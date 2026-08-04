sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Hail. good citizen!  You have entered the Hall of Truth.  What is it you seek?  Many citizens come to request aid in dealing with the local rogues or the oppression of our sworn enemies. the Freeport Militia.  A few valiant ones have been [summoned to the Hall of Truth].");
	}
	elsif ($text=~/summoned to the Hall of Truth/i) {
		quest::say("You have been summoned? You do not have the look of nobility. You must be a [squire]. There are many squires who have been summoned to our Hall. Not all pass the [Test of Truth].");
	}
	elsif ($text=~/squire/i) {
		quest::say("Then I welcome you, Squire . Being a squire is the first step to becoming a true knight of the Hall of Truth. Remember always to protect and serve the meek. I have a [small task] which suits a squire perfectly.");
	}
	elsif ($text=~/small task/i) {
		quest::say("Venture to the Commonlands and seek out our noble friend Altunic Jartin. He lives and works out of his home. Hand him this note.");
		#:: Summon 18896 - A Note (Note to Altunic)
		quest::summonitem(18896);		
	}
	elsif ($text=~/token of generosity/i) {
		quest::say("Go to the deserts of North Ro. Seek out the desert tarantulas. Stand and face this dreaded creature. If you are lucky, you will find a venom sac. This is what I require. When you return, hand it to me.");
	}
	elsif ($text=~/test of truth/i) {
		quest::say("Only when a [squire] is ready, may he tempt his fate. All he need do is hand the tokens of bravery and generosity to me. If the squire survives his ordeal, then he or she shall enter the order of the Knights of Truth. The squire will be given the Testimony of Truth and become a respected knight.");
	}
	elsif ($text=~/Who is willia/i) {
		quest::say("She is my niece. Lucan ordered her to kill my wife.. She did. She now belongs to the Freeport Militia. As part of the militia, she must die!! Let no militia member stand in the way of nobility.");
	}
}

sub EVENT_ITEM {
	#:: Turn in for 14018 - Spider Venom Sac
	if (plugin::check_handin(\%itemcount, 14018 => 1 )) {
		quest::say("You have earned the token of bravery. Now you must ask yourself if you are ready to face true fear. You will have but one chance. If you feel you are powerful enough to easily slay that desert tarantula, then hand me both tokens earned and you shall face the Test of Truth.");
		#:: Give item 12144 - Token of Bravery
		quest::summonitem(12144);
		#:: Give a small amount of xp
		quest::exp(100);
		#:: Ding!
		quest::ding();
		#:: Set faction
		quest::faction(362,1); 		#:: + Priests of Marr
		quest::faction(271,-1); 		#:: - Dismal Rage
		quest::faction(281,1); 		#:: + Knights of Truth
		quest::faction(311,1); 		#:: + Steel Warriors
		quest::faction(330,-1); 	#:: - Freeport Militia
	}
	#:: Turn in for 12144 - Token of Bravery & 13865 - Token of Generosity
	if (plugin::check_handin(\%itemcount, 12144 => 1, 13865 =>1 )) {
		quest::say("Go to the open sewer across the way. Inside you shall find your opponent. Victory shall bring your final token. Return it to me. Remember our ways and remember our foes. Send them to their judgement in the afterlife. Be swift with your thoughts. May Marr be with you.");
		#:: Spawn 8110 - Guard Willia
		quest::spawn2(8110,0,0,-257,132,-17,120);
		#:: Give a small amount of xp
		quest::exp(100);
		#:: Ding!
		quest::ding();
		#:: Set faction
		quest::faction(362,1); 		#:: + Priests of Marr
		quest::faction(271,-1); 		#:: - Dismal Rage
		quest::faction(281,1); 		#:: + Knights of Truth
		quest::faction(311,1); 		#:: + Steel Warriors
		quest::faction(330,-1); 	#:: - Freeport Militia
	}
	#:: Turn in for 13866 - Token of Truth
	if (plugin::check_handin(\%itemcount, 13866 => 1)) {
		quest::say("You have performed well. You have shown your allegiance to truth and cast aside the Freeport Militia. The militia will surely despise you from now on. This is how they treat the Knights of Truth. Beware. The followers of Marr stand alone in this city.");
		#:: Give item 18828 - Testimony
		quest::summonitem(18828);
		#:: Give a small amount of xp
		quest::exp(100);
		#:: Ding!
		quest::ding();
		#:: Set faction
		quest::faction(362,1); 		#:: + Priests of Marr
		quest::faction(271,-1); 		#:: - Dismal Rage
		quest::faction(281,1); 		#:: + Knights of Truth
		quest::faction(311,1); 		#:: + Steel Warriors
		quest::faction(330,-1); 	#:: - Freeport Militia
		#:: Create a hash for storing cash - 900 to 2000cp
		my %cash = plugin::RandomCash(900,2000);
			#:: Grant a random cash reward
			quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}	

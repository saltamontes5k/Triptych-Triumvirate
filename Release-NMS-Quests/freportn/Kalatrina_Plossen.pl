sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Hail!  Welcome to the Hall of Truth.  We. the Knights of Truth. are all the hope this city has of loosening the grip of Lucan D'lere and his militia.  I seek a young knight to [serve the will of the Truthbringer].");
	}
	elsif ($text=~/what/i) {
		quest::say("Shame on you.  To set foot into the Hall of Truth and not know for whom it was built.  Still. it is never too late to see the light.  Mithaniel Marr is our deity.  He is the Truthbringer.  By living our lives in valor and crushing all those who suppress His beliefs. We serve Him.");
	}
	elsif ($text=~/serve the will of the Truthbringer/i) {
		#:: Match if faction is better than indifferent
		if ($faction < 5) {	
		quest::say("Stand tall then, knight! We have need of your services. We have sent a man to infiltrate the militia. We fear he may soon be found out. Take him this note of warning. Say the words, 'Truth is good,' and you shall find him. Be careful, young knight. The militia does not take prisoners.");
		#:: Summon 18817 - A Sealed Letter (To Alayle)
		quest::summonitem(18817);
		}
		else {
			quest::say("Work on the ways of valor before we discuss such things. You are on the righteous path of the Truthbringer, but there is more work to do.");
		}
	}
	elsif ($text=~/Zimel's Blades/i) {
		#:: Match if faction is better than indifferent
		if ($faction < 5) {	
		quest::say("Why would Lucan visit a condemned building? He must be searching for something. When I last visited the local forge, I heard rumors of Lucan searching for a sword named Soulfire. If this is true, you must find it first! No more power should go his way. Seek this sword out!");
		}
		else {
			quest::say("Work on the ways of valor before we discuss such things. You are on the righteous path of the Truthbringer, but there is more work to do.");
		}
	}
}

sub EVENT_ITEM {
	#:: Turn in for 18818 - A Tattered Flier
	if (plugin::check_handin(\%itemcount, 18818 => 1 )) {
		quest::say("Zimel's Blades?! Hmmmmm. It doesn't ring a bell and the remainder of the writing is too hard to make out. It kind of looks like a list of prices. You know, down at the Office of the People they might be able to tell us if this place exists. Go speak with Rashinda. She knows all about Freeport. If [Zimel's Blades] existed, you must report back to me what happened to it.");
		#:: Ding!
		quest::ding();
		#:: Give item 18818 - a tattered flier
		quest::summonitem(18818);
		#:: Set faction
		quest::faction(281,1); 	#:: + Knights of Truth
		quest::faction(271,-1); #:: - Dismal Rage
		quest::faction(311,1); 	#:: + Steel Warriors
		quest::faction(330,-1);	#:: - The Freeport Militia
		quest::faction(362,1);	#:: + Priests of Marr
		#:: Grant a small amount of experience
		quest::exp(500);
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}	

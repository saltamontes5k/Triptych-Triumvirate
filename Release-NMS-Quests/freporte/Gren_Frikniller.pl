sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Aya, howdy there, $name.  The name's Gren Frikniller. 'Niller the Killer' they used to call me back in [Rivervale]. Anyways, I'm [Elisi]'s personal body guard. Anyone tries to get to her, they gotta through me first. And let me tell ya, I'm the quickest blade this side of Highpass my friend. The only person who can give me a run for my money is my [sister], Falia.");
	}
	elsif ($text=~/sister|falia/i) {
		quest::say("Ah, my sister Falia has traveled here all the way from Rivervale. I hear that she's been staying up in North Freeport, but I haven't had a chance to find her yet. If you get some spare time, could you take this letter to her for me? Thanks, $name, you're really not so bad after all.");
		#:: Give a 18925 - Letter to Falia
		quest::summonitem(18925);
	}
	elsif ($text=~/rivervale/i) {
		quest::say("Rivervale?  Well, it's far from here, thank Fizzlethorpe.  They got more wanted posters with my face on 'em than they got trees there.  I mean, 'tweren't my fault either.  Just a friendly game of cards, and this little weasel catches me with an extra ace up my sleeve.  Can you believe this kid calls ol' Grenny here a cheater, right in front of the whole bar?!!  So, you know, I gave him a quick cut, ear to ear, with me dagger...  just to shut him up, you know.  Suddenly, I'm a murderer?  For simply defending myself?! Go figure!");
	}
	elsif ($text=~/elisi/i) {
		quest::say("Elisi runs the show around here.  She's usually a pretty busy lady.  Dang smart, too.  And it's my sworn duty to protect her at any cost, even with my very own life.");
	}
}

sub EVENT_ITEM {
	#:: Turn in for 13159 -  Broken Heirloom Necklace
	if (plugin::check_handin(\%itemcount, 13159 => 1)) {
		quest::say("What's this? Oh, ol' Grandpa Frikniller's lucky necklace, huh? I'll bet this broken piece of junk won't even get me a sip of ale up at the bar. And lucky? How lucky could this thing be? Poor gramps was lonely and copperless his whole life. Bah!! Oh, well. Here's some coin for your efforts, thanks, $name.");
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(336, 10); 		#:: + Coalition of Tradefolk Underground
		quest::faction(229, 10); 		#:: + Coalition of Trade Folk
		quest::faction(329, 1); 		#:: + Carson McCabe
		quest::faction(230, 1); 		#:: + Corrupt Qeynos Guards
		quest::faction(330, 1); 		#:: - Freeport Militia
		#:: Grant a small amount of experience
		quest::exp(200);
		#:: Create a hash for storing cash - 10 to 20cp
		my %cash = plugin::RandomCash(10,20);
		#:: Grant a random cash reward
		quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}

sub EVENT_SIGNAL {
	#:: Match a signal '1' from /freporte/Elisi_Nasin.pl
	if ($signal == 1) {
		quest::say("Yea.. Bite that tongue of yours, there shorty, or I might just have to cut it off to shut you up for good.");
	}
}

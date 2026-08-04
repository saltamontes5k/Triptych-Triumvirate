sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Listen. this is a pretty busy [operation] I run here.  I certainly don't have any spare time to sit around and chit-chat with you all day. got it?");
	}
	elsif ($text=~/operation/i) {
		quest::say("Look, $name, I don't have time for this.  Let's just say importing exotic goods is our main interest, along with a few other profitable ventures.  Now quit pestering me, or you'll force me to sic Grenny here on ya.");
		#:: Send a signal '1' to East Freeport >> Gren_Frikniller (10122) with a three second delay
		quest::signal(10122, 1, 3);
	}
}

sub EVENT_ITEM {
	#:: Match a 18745 - A Tattered Note
	if (plugin::check_handin(\%itemcount, 18745 => 1)) {
		quest::say("Welcome to the Coalition of Tradesfolk underground. We like to keep a low profile around here and not draw any unneeded attention to our operations. you following me? I hope so, for your sake, Anyways, Nestral T'Gaza is in charge with helping out our newest members. Go see her as soon as you get a chance.");
		#:: Give item 13568 - Brown Faded Tunic
		quest::summonitem(13568);
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(336, 100); 		#:: + Coalition of Tradefolk Underground
		quest::faction(229, 100);		#:: + Coalition of Trade folk
		quest::faction(329, 10); 		#:: + Carson McCabe
		quest::faction(230, 5); 		#:: + Corrupt Qeynos Guards
		quest::faction(330, 15); 		#:: + The Freeport Militia
		#:: Grant a small amount of experience
		quest::exp(100);
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}

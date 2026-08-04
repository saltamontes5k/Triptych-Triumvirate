sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Enough talk there. chatterbox.  You buy lots of herbs.  I gotta make a living. not more friends.");
	}
	elsif ($text=~/temple of life/i) {
		quest::say("Oh, yes.. They always come for Kizzie's [honey jum]. They should have sent you next week. There is a problem");
	}	
	elsif ($text=~/problem/i) {
		quest::say("You see.. Joogl Honeybugger is hurt. He usually collects the [Honeycombs]. Only he knows where to get them. I need the Honeycombs to make the Honey Jum. Go and speak with Joogl. He is at his burrow outside of Rivervale. He says he cannot work. Tell him you need the Honeycombs.");
	}	
	elsif ($text=~/Honeycombs/i) {
		quest::say("If Kizzie knew that, then she would not hire Joogl Honeybugger!  Go talk to him in the Misty Thicket.");
	}		
	elsif ($text=~/make/i) {
		quest::say("No, no, no!!  You will not get honey jum until you give Kizzie three honeycombs and thirty gold coins.  Honey jum is valuable.  Kizzie raised the fee!!  That is how it works.");
	}	
	elsif ($text=~/honey jum/i) {
		quest::say("It's a secret!!  I get the honeycombs and combine them with the secret sauce and..presto.. honey jum!!  It is used by only the wisest as a component.  And you can only get it from Kizzie.  It is also good on batwing crunchies.  If you like.. Kizzie can [make] honey jum for you?");
	}		
} 

sub EVENT_ITEM {
	#:: Match three 13953 - Honeycomb and 30 gold pieces
	if (plugin::check_handin(\%itemcount, 13953 => 3, "gold" => 30)) {
		quest::say("You are one lucky bixie buster. I just made a batch of honey jum. Here. No waiting for you.  One jar for your good work. Bye, now!");
		#:: Give item 13952 - Honey Jum
		quest::summonitem(13952);
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(241, 1);			#:: + Deeppockets
		quest::faction(286, 1);			#:: + Mayor Gubbin
		quest::faction(292, 1);			#:: + Merchants of Rivervale
		quest::faction(263, 1);			#:: + Guardians of the Vale
		quest::faction(336, -1);		#:: - Coalition of Tradefolk Underground
		#:: Grant a small amount of experience
		quest::exp(500);
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}

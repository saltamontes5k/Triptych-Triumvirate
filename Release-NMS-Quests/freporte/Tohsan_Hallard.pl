sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Greetings and welcome to Hallard's!  You will find many aged weapons begging you to shine them up and make them great once more.  We will gladly pay you top dollar for any rusty weapons you may have found littering the Commonlands.  I have a [special offer] for those who have obtained orc pawn picks.");
	}
	elsif ($text=~/special offer/i) {
		quest::say("I will pay some silver pieces for every four orc pawn picks returned to me.  I shall also throw in a ticket to the Highpass Hold lottery.  It could be a winner!!");
	}
}

sub EVENT_ITEM {
	#:: Match four 13885 - Orc Pawn Pick
	if (plugin::check_handin(\%itemcount, 13885 => 4)) {
		quest::say("As I promised, some silver and of course, the Highpass lottery ticket. Oh yes, I forgot to mention the ticket was for last season's lottery. Ha Ha!! You now own a losing Highpass lottery ticket, lucky you! Ha!!");
		#:: Give a random reward: 12264 - Lottery Ticket # 14350, 12265 - Lottery Ticket # 14001, 12261 - Lottery Ticket # 15600, 12262 - Lottery Ticket # 15601, 12263 - Lottery Ticket # 15602, 12266 - Lottery Ticket # 16568
		quest::summonitem(quest::ChooseRandom(12264, 12265, 12261, 12262, 12263, 12266));
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(229, 4); 		#:: + Coalition of Tradefolk
		quest::faction(281, 4); 		#:: + Knights of Truth
		quest::faction(291, 3); 		#:: + Merchants of Qeynos
		quest::faction(336, 4); 		#:: + Coalition of Tradesfolk Underground
		#:: Grant a small amount of experience
		quest::exp(100);
		#:: Create a hash for storing cash - 50 to 100cp
		my %cash = plugin::RandomCash(50,100);
		#:: Grant a random cash reward
		quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}

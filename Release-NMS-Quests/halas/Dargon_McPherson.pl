sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Hail, mighty $name! I assume ye must be a [warrior o' the Wolves]. Why else would ye approach a trainer such as meself, then?");
	}
	elsif ($text=~/the wolves/i) {
		#:: Match if faction is Amiable or better
		if ($faction <= 4) {
			quest::say("Aye, 'tis as I thought. I'm glad t' see we've warriors such as yerself amongst the Wolves o' the North. Lately, Kylan's been allowing too many scrawny warriors in, methinks. Nor have they fared well in Everfrrost. Many frreeze to death, ye know... Will ye assist me and [deliver an elixir] to young warriors in Everfrost?");
		}
		#:: Match if faction is Indifferent
		elsif ($faction == 5) {
			quest::say("The Wolves o' the North show ye no ill will, but there's much ye must do t' earn our trust.  Perhaps ye should speak with Lysbith and inquire o' the gnoll bounty.");
		}
		else {
			quest::say("Run while ye still can!! The Wolves o' the North will not tolerate yer presence!");
		}
	}
	elsif ($text=~/deliver an elixir/i) {
		#:: Match if faction is Amiable or better
		if ($faction <= 4) {
			quest::say("Ach, 'tis good o' ye! Take this bottle of elixir to Everfrost Peaks. Find Talin O'Donal. He'll take the first sip, and then instruct ye on who else ye need to find. Do that, and I'll give ye a fine reward when ye return the empty elixir bottle. Good luck, then. Don't die.");
			#:: Give a 13241 - Full Bottle of Elixir
			quest::summonitem(13241);
		}
		#:: Match if faction is Indifferent
		elsif ($faction == 5) {
			quest::say("The Wolves o' the North show ye no ill will, but there's much ye must do t' earn our trust.  Perhaps ye should speak with Lysbith and inquire o' the gnoll bounty.");
		}
		else {
			quest::say("Run while ye still can!! The Wolves o' the North will not tolerate yer presence!");
		}
	}
}

sub EVENT_ITEM {
	#:: Match a 13245 - Empty Bottle of Elixir
	if (plugin::check_handin(\%itemcount, 13245 => 1)) {
		#:: Match if faction is Amiable or better
		if ($faction <= 4) {
			quest::say("Ye've proven yerself to be a cut above the rest and aided yer fellow warriors, no matter how worthless they were. Ye may take this. It was found in the snow by one of our foraging parties. I hope it can be of use to a warrior like yerself.");
			#:: Give a random reward: 2012 - Leather Boots, 17001 - Wrist Pouch, 10004 - Copper Band, 10017 - Turquoise, 1038 - Tattered Cloth Sandal, 10016 - Lapis Lazuli, 13877 - Corroded Buckler, 2135 - Large Patchwork Pants, 7007 - Rusty Dagger, 8008 - Throwing Axe, 10009 - Bead Necklace, 13007 - Ration, 5014 - Rusty Axe, 13003 - Small Lantern
			quest::summonitem(quest::ChooseRandom(2012, 17001, 10004, 10017, 1038, 10016, 13877, 2135, 7007, 8008, 10009, 13007, 5014, 13003));
			#:: Ding!
			quest::ding();
			#:: Set factions
			quest::faction(328, 1);			#:: + Merchants of Halas
			quest::faction(327, 1);			#:: + Shamen of Justice
			quest::faction(311, 1);			#:: + Steel Warriors
			quest::faction(320, 5);			#:: + Wolves of the North
			#:: Grant a small amount of experience
			quest::exp(125);
			#:: Create a hash for storing cash - 3000 to 3200cp
			my %cash = plugin::RandomCash(3000,3200);
			#:: Grant a random cash reward
			quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
		}
		#:: Match if faction is Indifferent
		elsif ($faction == 5) {
			quest::say("The Wolves o' the North show ye no ill will, but there's much ye must do t' earn our trust.  Perhaps ye should speak with Lysbith and inquire o' the gnoll bounty.");
			#:: Return a 13245 - Empty Bottle of Elixir
			quest::summonitem(13245);
		}
		else {
			quest::say("Run while ye still can!! The Wolves o' the North will not tolerate yer presence!");
			#:: Return a 13245 - Empty Bottle of Elixir
			quest::summonitem(13245);
		}
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}

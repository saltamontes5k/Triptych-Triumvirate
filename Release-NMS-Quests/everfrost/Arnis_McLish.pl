sub EVENT_SPAWN {
	#:: Set running true (run)
	quest::SetRunning(1);
}

sub EVENT_SAY {
	if ($text=~/hail/i) {
		#:: Match if faction is Amiable or better
		if ($faction <= 4) {
			quest::say("My word!! I cannot believe how cold it is out here. I must keep running around just to keep warm.");
		}
		#:: Match if faction is indifferent
		elsif ($faction == 5) {
			quest::say("The Wolves o' the North show ye no ill will, but there's much ye must do t' earn our trust.  Perhaps ye should speak with Lysbith and inquire o' the [gnoll bounty].");
		}
		else {
			quest::say("Run while ye still can!! The Wolves o' the North will not tolerate yer presence!");
		}
	}
	elsif ($text=~/Megan/i) {
		#:: Match if faction is Amiable or better
		if ($faction <= 4) {
			quest::say("I heard she got lost on the plains. You should go ask her dog, Snowflake, where she is. I hear she is somewhere around the pass to Halas.");
		}
		#:: Match if faction is indifferent
		elsif ($faction == 5) {
			quest::say("The Wolves o' the North show ye no ill will, but there's much ye must do t' earn our trust.  Perhaps ye should speak with Lysbith and inquire o' the [gnoll bounty].");
		}
		else {
			quest::say("Run while ye still can!! The Wolves o' the North will not tolerate yer presence!");
		}
	}
}

sub EVENT_ITEM {
	#:: Match a 13243 - One Half of Elixir
	if (plugin::check_handin(\%itemcount, 13243 => 1)) {
		quest::say("Mmmm.. Thank you stranger. I feel a lot warmer now. You should now go and find [Megan] O'Reilly.");
		#:: Give a 13244 - One Quarter of Elixir
		quest::summonitem(13244);
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(328, 1);		#:: + Merchants of Halas
		quest::faction(327, 1);		#:: + Shaman of Justice
		quest::faction(311, 1);		#:: + Steel Warriors
		quest::faction(320, 1);		#:: + Wolves of the North
		#:: Grant a small amount of experience
		quest::exp(150);
	}
	#:: Return unused items
	plugin::returnUnusedItems();
}

# Converted to Perl by SS

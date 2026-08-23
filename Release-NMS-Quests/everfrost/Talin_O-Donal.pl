sub EVENT_ITEM {
	#:: Match 13241 - Full Bottle of Elixir
	if (plugin::check_handin(\%itemcount, 13241 => 1)) {
		quest::say("Mmmm.. I feel much warmer. Thank you. You should now find Bryndin McMill. He could use a swig also. I saw him hanging around two other guards.");
		#:: Give 13242 - One Quarter of Elixir
		quest::summonitem(13242);
		quest::ding();
		#:: Set Factions
		quest::faction(328,1);	#:: Merchants of Halas
		quest::faction(327,1);	#:: Shaman of Justice
		quest::faction(311,1);	#:: Steel Warriors
		quest::faction(320,1);	#:: Wolves of the North
		quest::exp(150);
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}

# Converted to Perl by SS

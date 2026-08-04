sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Welcome. my friend! We are the Craftkeepers. We study the circle of magic called enchantment. What circle do you [study]?");
	}
	elsif ($text=~/study/i) {
		quest::say("Then I welcome you into our circle. It is good to see new blood. I have a favor to ask of you. Do you wish to [assist Toresian] or do you not have the time?");
		#:: Match The Erudin Palace >> Slansin (23080) or The Erudin Palace >> Slansin (23001)
		if (!$entity_list->IsMobSpawnedByNpcTypeID(23080) || !$entity_list->IsMobSpawnedByNpcTypeID(23001)) {
			#:: Randomly spawn Slansin (23080) [Shopkeeper] or Slansin (23001) [Enchanter]
			quest::unique_spawn(quest::ChooseRandom(23080,23001),0,0,575,683,-12.13,78);
		}
	}
	elsif ($text=~/assist Toresian/i) {
		#:: Match if faction is amiable or better
		if ($faction <= 4) {
			quest::say("Ahhhhh $name.  Slansin used to have need of those potions, however he mysteriously disappeared long ago. The only person I know of who still wants them is a cleric of the Church of Marr in Freeport.");			
			#:: Give a 13983 - Inert Potion
			quest::summonitem(13983);
		}
		else {
			quest::say("You are lucky to be standing. Leave here immediately or suffer grave consequences! You are not welcome amongst the Craftkeepers.");
		}
	}
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::returnUnusedItems();
}

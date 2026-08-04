sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Hail yerself. I'm sure ye've better things to do than to bother a man makin' his potions, then, eh?");
	}
	elsif ($text=~/potion of sorrow/i) {
		quest::say("Ach! What'd ye be needin' that fer? Only those of dark magicks require such a thing and by me mother's eyes, never could I sell to such a soul.  If yer soul be clean, then put yer [money] in this enchanted pouch and I'll know yer intent.  If yer soul be rotten, I'll knowin', and ye'll be dead.  Tis indifferent I'd better be to yer actions.");
	}
	elsif ($text=~/money/i) {
		quest::say("Sure'n ye dinnae think I'd give ye a potion fer free, then?  I'll be needin' five hundred gold coins to make such an item.  'Tis hard t' make and few are the uses fer such a potion.");
	}
}

sub EVENT_ITEM {
	#:: Match 500 gold pieces
	if (plugin::takeCoin(0, 0, 500, 0)) {
		quest::say("Aye, I guess ye truly are a good soul.  Good luck on whatever ye needed such a dread item fer.");
		#:: Give a 7113 - Potion of Sorrow
		quest::summonitem(17113);
		#:: Ding!
		quest::ding();
		#:: Grant a moderate amount of experience
		quest::exp(1250);
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}

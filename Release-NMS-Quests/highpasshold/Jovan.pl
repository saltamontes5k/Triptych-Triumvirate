sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Not so loud! My head is spinning so! What I wouldn't give for a [Tumpy's Tonic] right now! They were always just the thing for the hair of the gnoll that bit me.");
	}
	elsif ($text=~/tumpy's tonic/i) {
		quest::say("Ahh! If you need to ask, you've never had one. Tumpy Irontoe in Kaladim made me drink one of his special brews when I lost a game of King's Court with him. I would give anything I own for one of those right now!");
	}
}

sub EVENT_ITEM {
	#:: Match a 12114 - Tumpy Tonic
	if (plugin::check_handin(\%itemcount, 12114 => 1)) {
		quest::say("<SLURP!!>  Ahh thhhhat'thh betterr. Take thithhh. <BURP!>");
		#:: Give a 19006 - Icon of the Fervent
		quest::summonitem(19006);
		#:: Ding!
		quest::ding();
		#:: Depop with spawn timer active
		quest::depop_withtimer();
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}

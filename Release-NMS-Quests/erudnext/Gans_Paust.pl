sub EVENT_SPAWN {
	#:: Create a proximity, 100 units across, 100 units tall, without proximity say
	quest::set_proximity($x - 50, $x + 50, $y - 50, $y + 50, $z - 50, $z + 50, 0);
}

sub EVENT_ENTER {
	#:: Match a 18724 - Tattered Note
	if (plugin::check_hasitem($client, 18724)) {
		$client->Message(15,"A commanding, yet kind looking Erudite turns towards you as you attempt to get your bearings. 'Do not be startled. I am Gans Paust, Guild Master of the Deepwater Knights and you are to become one of us. Read the note in your inventory and hand it to me when you are ready to begin your training. I look forward to working with you.'");
	}
}

sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::emote("glances at you and hurriedly makes a gesture of religious meaning before you and says, 'Yes, yes, I hereby bless you in the name of Prexus. May your catch be plentiful and your nets never snag. Are there any other fishermen seeking a blessing? I'm very busy.'");
	}
	elsif ($text=~/your brother/i) {
		quest::say("What? How do you know fo my brother? Ahh I assume Breya told you. He's been gone for quite some time with no word sent on his progress or his wellbeing. I need to find someone to [check on him].");
	}
	elsif ($text=~/check on him/i) {
		quest::say("Thank you, $name. He's one of our people's most knowledgeable geologists and has left to survey an island out in Erud's Crossing. He was sending monthly reports until two weeks ago when his report never showed up. I'm worried something may have happened to him. Take this note to Yelesom and bring back something to assure me of his safety. A reward fitting a Deepwater Knight shall be yours upon your success..");
		#:: Give item 18173 - Gans's note to Yelesom
		quest::summonitem(18173);
	}
	elsif ($text=~/trades/i) {
		quest::say("I thought you might be one who was interested in the various different trades, but which one would suit you? Ahh, alas, it would be better to let you decide for yourself, perhaps you would even like to master them all! That would be quite a feat. Well, lets not get ahead of ourselves, here, take this book. When you have finished reading it, ask me for the [second book], and I shall give it to you. Inside them you will find the most basic recipes for each trade. These recipes are typically used as a base for more advanced crafting, for instance, if you wished to be a smith, one would need to find some ore and smelt it into something usable. Good luck!");
		#:: Give item 51121 - Tradeskill Basics : Volume I
		quest::summonitem(51121);
	}
	elsif ($text=~/second book/i) {
		quest::say("Here is the second volume of the book you requested, may it serve you well!");
		#:: Give item 51122 - Tradeskill Basics : Volume II
		quest::summonitem(51122);
	}
}

sub EVENT_ITEM {
	#:: Match a 18724 - Tattered Note
	if (plugin::check_handin(\%itemcount, 18724 => 1)) {
		quest::say("Yes. welcome friend! Here is your guild tunic. You'll make a fine addition to the Deepwater Knights.  Go see Lumi Stergnon, he will get you started in your studies. Return to me when you have become more experienced in our art, I will be able to further instruct you on how to progress through your early ranks, as well as in some of the various [trades] you will have available to you.");
		#:: Give a 13544 - Old Blue Tunic*
		quest::summonitem(13544);
		#:: Ding!
		quest::ding();
		#:: Set faction
		quest::faction(242, 100);		#:: + Deepwater Knights
		quest::faction(266, 15);		#:: + High Council of Erudin
		quest::faction(265, -15);		#:: - Heretics
		#:: Grant a small amount of experience
		quest::exp(100);
	}
	#:: Match a 1771 - Yelesom's Reports
	elsif (plugin::check_handin(\%itemcount, 1771 => 1)) {
		quest::say("Excellent! Thank you for checking on my brother, I am glad to hear that he is well.  Here is something that shall help you on your way.");
		#:: Give a 1763 - Midnight Sea Mail Sleeves
		quest::summonitem(11763);
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(242, 25);		#:: + Deepwater Knights
		quest::faction(266, 3);			#:: + High Council of Erudin
		quest::faction(265, -3);		#:: - Heretics
		#:: Grant a small amount of experience
		quest::exp(100);
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}

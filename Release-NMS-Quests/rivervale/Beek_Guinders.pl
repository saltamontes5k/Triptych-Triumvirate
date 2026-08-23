sub EVENT_SPAWN {
	#:: Create a proximity, 100 units across
	$x = $npc->GetX();
	$y = $npc->GetY();
	quest::set_proximity($x - 50, $x + 50, $y - 50, $y + 50);
}

sub EVENT_ENTER {
	#:: Match a 18731 - Tattered Note
	if (plugin::check_hasitem($client, 18731)) { 
		$client->Message(15,"A jovial yet commanding halfling speaks to you. 'Why hello there. friend! I am Beek Guinders, your new Guild Master. Read the note in your inventory and when you are ready to begin your training, hand it to me!'");
	}
}

sub EVENT_SAY { 
	if ($text=~/hail/i) {
		quest::doanim(29);
		quest::emote("waves enthusiastically");
		quest::say("Hay, ho, there, young $race!  I'd love to yak it up with you but I'm a bit busy at the moment, trying to find some [help].");
	}
	if ($text=~/help/i) {
		quest::say("Well, we're experimenting with some tanning methods but we're running low on supplies. We need to find someone to go out and [gather some things]. Seems no one wants to do an honest day's work any more. I'd do it myself but, errrr, my, uhhh, foot hair has been hurting lately... yes, that's it.");
	}
	if ($text=~/gather some things/i) {
		quest::say("Ahhh, excellent! Okay, first, we'll need a couple of wolf pelts. They don't have to be perfect, completely ruined would work just fine, hehe. I'll also need a black wolf skin and a handful of berries. The berries you should be able to find out in the Thicket. I hear they grow in a small canyon near the lone tower. Hurry, hurry!");
	}
	if ($text=~/trades/i) {
		quest::say("I thought you might be one who was interested in the various different trades, but which one would suit you? Ahh, alas, it would be better to let you decide for yourself, perhaps you would even like to master them all! That would be quite a feat. Well, lets not get ahead of ourselves, here, take this book. When you have finished reading it, ask me for the [second book], and I shall give it to you. Inside them you will find the most basic recipes for each trade. These recipes are typically used as a base for more advanced crafting, for instance, if you wished to be a smith, one would need to find some ore and smelt it into something usable. Good luck!");
		#:: Give a 51121 - Tradeskill Basics : Volume I
		quest::summonitem(51121);
	}
	if ($text=~/second book/i) {
		quest::say("Here is the second volume of the book you requested, may it serve you well!");
		#:: Give a 51122 - Tradeskill Basics : Volume II
		quest::summonitem(51122);
	}
}

sub EVENT_ITEM {
	#:: Match a 18731 - Tattered Note
	if (plugin::check_handin(\%itemcount, 18731 => 1)) {
		quest::say("Aye. Welcome, my fur-footed friend. My name is Beek Guinders, and I am guildmaster here at the Chapel of Mischief. Here is our guild tunic. Wear it with pride, as it will set you apart from the crowd. Once you are ready to begin your training please make sure that you see Thekela Meepup, she can assist you in experienced in our art, I will be able to further instruct you on how to progress through your early ranks, as well as in some of the various [trades] you will have available to you.");
		#:: Give a 13538 - Faded Gold Felt Tunic*
		quest::summonitem(13538);
		#:: Ding!
		quest::ding();
		#:: Grant a small amount of experience
		quest::exp(100);
		#:: Set factions
		quest::faction(300, 100);	#:: + Priests of Mischief
		quest::faction(286, 15);	#:: + Mayor Gubbin
		quest::faction(263, 15);	#:: + Guardians of the Vale
	}
	#:: Match a 13045 - Berries, two 13782 - Ruined Wolf Pelt, and a 13758 - Black Wolf Skin
	elsif (plugin::check_handin(\%itemcount, 13045 => 1, 13782 => 2, 13758 => 1)) {
		quest::say("Hey, great! You found the materials! We'll get to work right away. If you find any more, please come by again. Here's a little something for your troubles, friend.");
		#:: Give a random reward: 15014 - Spell: Strike, 15201 - Spell: Flash of Light, 15207 - Spell: Divine Aura, 15208 - Spell: Lull, 16303 - Spell: Gate
		quest::summonitem(quest::ChooseRandom(15014,15201,15207,15208,16303));
		#:: Ding!
		quest::ding();
		#:: Grant a small amount of experience
		quest::exp(100);
		#:: Create a hash for storing cash - 150 to 200cp
		my %cash = plugin::RandomCash(150,200);
		#:: Grant a random cash reward
		quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
		#:: Set factions
		quest::faction(300, 10);	#:: + Priests of Mischief
		quest::faction(286, 10);	#:: + Mayor Gubbin
		quest::faction(263, 10);	#:: + Guardians of the Vale
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}

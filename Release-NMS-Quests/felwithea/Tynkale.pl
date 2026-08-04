sub EVENT_SPAWN {
	#:: Set up a proximity, 50 units across
	$x = $npc->GetX();
	$y = $npc->GetY();
	quest::set_proximity($x - 50, $x + 50, $y - 50, $y + 50);
}

sub EVENT_ENTER {
	#:: Check for 18781 - A Tattered Note
	if (plugin::check_hasitem($client, 18781)) {
		$client->Message(15,"As you get your bearings, Tynkale, an important looking High Elf turns to greet you. 'Welcome young paladin of Tunare. I am Guild Master Tynkale. Read the note in your inventory and once you are ready to begin your training, hand me your note. I welcome you to our crusade against evil.'");
	}
}

sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Hail noble, $name!  Can you be of [service to the Clerics of Tunare] or are you not from our order?");
	}
	if ($text=~/trades/i) {
		quest::say("I thought you might be one who was interested in the various different trades, but which one would suit you? Ahh, alas, it would be better to let you decide for yourself, perhaps you would even like to master them all! That would be quite a feat. Well, lets not get ahead of ourselves, here, take this book. When you have finished reading it, ask me for the [second book], and I shall give it to you. Inside them you will find the most basic recipes for each trade. These recipes are typically used as a base for more advanced crafting, for instance, if you wished to be a smith, one would need to find some ore and smelt it into something usable. Good luck!");
		#:: Give item 51121 - Tradeskill Basics: Volume I
		quest::summonitem(51121);
	}
	if ($text=~/second book/i) {
		quest::say("Here is the second volume of the book you requested, may it serve you well!");
		#:: Give item 51122 - Tradeskill Basics: Volume II
		quest::summonitem(51122);
	}
	if ($text=~/service to the clerics of tunare/i) {
		#:: Match if faction is better than indifferent
		if ($faction < 5) {
			quest::say("That is good. Prove yourself, then.  Are you [new to Felwithe] or have I been conversing with a [veteran of the good fight]?");
		}
		#:: Match if faction is Indifferent or worse
		else {
			quest::say("When you have furthered your service to the Paladins of Tunare, we shall make conversation.");
		}
	}
	if ($text=~/new to felwithe/i) {
		#:: Match if faction is better than indifferent
		if ($faction < 5) {
			quest::say("Then stand at attention when I speak.  I want you to venture to Kelethin and seek out Tandan Nybright.  He is an old member of ours.  He had some hardships and he fell from Tunare's grace, yet he is still a member of our family.  He will be the one who reeks of elven wine.  Greet him by name.  We are worried for him.");
		}
		#:: Match if faction is Indifferent or worse
		else {
			quest::say("When you have furthered your service to the Paladins of Tunare, we shall make conversation.");
		}
	}
	if ($text=~/veteran of the good fight/i) {
		#:: Match if faction is better than indifferent
		if ($faction < 5) {
			quest::say("I command you to venture to Innothule and seek a beast called Jojongua, a name penned by the trolls.  It is said to be ten feet tall and nothing but fury.  Some say it resembles a kobold, but how can that be?  You bring this beast's hide to me and then I will believe you to be a veteran.  Beware!  Innothule is a very dangerous place even for a noble veteran.");
		}
		#:: Match if faction is Indifferent or worse
		else {
			quest::say("When you have furthered your service to the Paladins of Tunare, we shall make conversation.");
		}
	}
}

sub EVENT_ITEM {
	#:: Turn in for 18781 -  A Tattered Note
	if (plugin::check_handin(\%itemcount, 18781 => 1)) {
		quest::say("Greetings. young paladin!  I am Master Tynkale of the Clerics of Tunare.  Here, we shall teach and train you in the skills needed to defeat our evil and diseased enemies.  Take this, our guild tunic - it will help protect you.  Once you are ready to begin your training please make sure that you see Seria Woodwind, she can assist you in experienced in our art, I will be able to further instruct you on how to progress through your early ranks, as well as in some of the various [trades] you will have available to you.");
		#:: Give item 13591 - Used Gold Training Tunic*
		quest::summonitem(13591);
		#:: Ding!
		quest::ding();
		#:: Give a small amount of xp
		quest::exp(100);
		#:: Set faction
		quest::faction(226,100); 	#:: + Clerics of Tunare
		quest::faction(279,100); 	#:: + King Tearis Thex
		quest::faction(5001,75); 		#:: + Anti-mage
	}
	#:: Turn in for 13351 -  A Very Large Pelt
	if (plugin::check_handin(\%itemcount, 13351 => 1)) {
		#:: Match if faction is better than indifferent
		if ($faction < 5) {
			quest::say("So you have proven yourself to be a great slayer of beasts. Now it is time to prove yourself to be an asset to the Crown. You are to meet a man named Tolon Nurbyte, he will be at the local inn. Go to him and repeat the phrase, 'The glory of the Mother shines bright.' I can say no more.");
			#:: Ding!
			quest::ding();
			#:: Give a small amount of xp
			quest::exp(150);
			#:: Set faction
			quest::faction(226,10); 		#:: + Clerics of Tunare
			quest::faction(279,10); 	#:: + King Tearis Thex
			quest::faction(5001,10); 		#:: + Anti-mage
		}
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}

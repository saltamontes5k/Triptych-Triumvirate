sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Greetings! I would love to chat with you, but I just realized something.. I do not waste time with whelps.");
	}
	elsif ($text=~/lens/i) {
		quest::say("So, you seek the Spare Lens. Yes, I have it. There are only two ways you can obtain it, [fight] the great Zenita or [play a game of chance].");
	}
	elsif ($text=~/play a game of chance/i) {
		quest::say("Great! It is rather simple. I have five cards and only one is King Naythox. Find it. In order to get one card, all you need to do is buy me a bottle of Innoruuk's Kiss of Death from the barkeep in Chops 'n Hops. One bottle for one card. Return the King Naythox card to me and you shall get the spare lens.");
	}
	elsif ($text=~/fight/i) {
		quest::say("Darn!! I was hoping not to hear that word, fight. Oh well.");
		quest::attack($name);
	}
}

sub EVENT_ITEM {
	#:: Match a 22298 - King Card
	if (plugin::check_handin(\%itemcount, 22298 => 1)) {
		quest::say("Why I will be.. You got it!! I thought I took it out of the deck. Very well. You win the Spare Lens fair and square. Here you are. Now get out of my sight.");
		#:: Give item 13279 - Telescope Lens (Phiz's Lens)
		quest::summonitem(13279);
		#:: Ding!
		quest::ding();
		#:: Grant a small amount of experience
		quest::exp(500);
	}
	#:: Match a 13121 - Innoruuk's Kiss of Death
	elsif (plugin::check_handin(\%itemcount, 13121 => 1)) {
		quest::say("Let see what card you pulled.");
		#:: Give a random reward:  22293 - Castle Card, 22294 - Beggar Card, 22295 - Joker Card, 22296 - Wild Card, 22297 - Queen Card, 22298 - King Card, 22299 - Knight Card
		quest::summonitem(quest::ChooseRandom(22293, 22294, 22295, 22296, 22297, 22298, 22299));
	}
	#:: Match any Card other than King or Joker 
	elsif ((plugin::check_handin(\%itemcount, 22299 => 1)) || (plugin::check_handin(\%itemcount, 22297 => 1)) || (plugin::check_handin(\%itemcount, 22296 => 1)) || (plugin::check_handin(\%itemcount, 22294 => 1)) || (plugin::check_handin(\%itemcount, 22293 => 1))) {
		quest::say("Bad luck must be one of your strong suits. You should have been a beggar because you sure aren't a very good $class. You lose! $name");
	}
	#:: Match a 22295 -  Joker Card
	elsif (plugin::check_handin(\%itemcount, 22295 => 1)) {
		quest::say("I see you have drawn the card that best represents a $class such as yourself. You lose! $name");
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}

sub EVENT_SPAWN {
	#:: Create a proximity, 100 units across, 100 units tall, without proximity say
	quest::set_proximity($x - 50, $x + 50, $y - 50, $y + 50, $z - 50, $z + 50, 0);
}

sub EVENT_ENTER {
	#:: Match a 18790 - Tattered Note
	if (plugin::check_hasitem($client, 18790)) {
		$client->Message(15,"As your eyes adjust to the darkness, a large troll decked out in grimy metal armor turns towards you. 'I be Ranjor. You look weak now but mebbe me can make you strong! You read note in inventory and hand to me to start training!'");
	}
}

sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Ya wanna be a member a Da Bashers. duz ya?  What making ya tink yooz is good nuff ta be one o' us?  Can ya proves ta me why I shouldn't oughtta just eat yer smelly hide?  I gonna tests ya, ya big, ugly peece o' meet.  Ya [willin ta test] or duz I just eats ya now?");
	}
	elsif ($text=~/willin ta test/i) {
		quest::say("Stoopid meat.  I gonna eats ya anyways sumday.  Brings me a froglok meat and two dem li'l froglok tadpole fleshes.  Dey berry good.");
	}
}

sub EVENT_ITEM {
	#:: Match 18790 - Tattered Note
	if (plugin::check_handin(\%itemcount, 18790 => 1)) {
		quest::say("Arhh.. Ranjor mighty warrior.. Ranjor teach you warrior.. you fight for Ranjor now.");
		#:: Give a 13528 - Mud Covered Tunic*
		quest::summonitem(13528);
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(235, 100);	#:: + Da Bashers
		quest::faction(222, -15);	#:: - Broken Skull Clan
		#:: Grant a small amount of experience
		quest::exp(100);
	}
	#:: Match a 13409 - Froglok Meat and two 13187 - Froglok Tadpole Flesh
	elsif (plugin::check_handin(\%itemcount, 13409 => 1, 13187 => 2)) {
		quest::say("You is berry slow. Me too hungry. Me shood eats you for being slow. Gib me dat stuff. Here, take dis and git more stuff fer us. You much kllin, come backs sees me. I teeches ya hows ta kill bedder. Now git and kill stuff. We be Da Bashers fer a reesun.");
		#:: Give a 5025 - Rusty Two Handed Battle Axe
		quest::summonitem(15025);
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(235, 5);		#:: + Da Bashers
		quest::faction(222, -1);	#:: - Broken Skull Clan
		#:: Grant a small amount of experience
		quest::exp(250);
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}

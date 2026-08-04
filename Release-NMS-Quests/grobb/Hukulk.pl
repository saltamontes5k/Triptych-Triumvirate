sub EVENT_SPAWN {
	#:: Create a proximity, 50 units across, 50 units tall, without proximity say
	quest::set_proximity($x - 25, $x + 25, $y - 25, $y + 25, $z - 25, $z + 25, 0);
}

sub EVENT_ENTER {
	#:: Match a 18792 - Tattered Note
	if (plugin::check_hasitem($client, 18792)) {
		$client->Message(15,"As your eyes adjust to the darkness, a large troll decked out in grimy metal armor turns towards you. 'I be Hukulk. You read note in inventory and hand to me to start training!'");
	}
}

sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("What you want!! You make fun of [helm of Hukulk]?!! Me smash you!! Maybe you come learn ways of Hate and Fear! You be dark power. You be Pain. You [want join Nightkeep]?");
	}
	elsif ($text=~/helm of hukulk/i) {
		quest::say("Oh!!  Yooz tink you great enough to wear helm of Hukulk?  Me have another just like it. Me make deal with yooz.  If yooz want helm den yooz help Hukulk get revenge.  Youz better be strong or yooz useless!!  So.. Yooz [make deal with Hukulk]?");
	}
	elsif ($text=~/make deal with Hukulk/i) {
		quest::say("Yooz smart!!  Yooz go and walks to dark elf city.  Yooz finds one whos make Lynuga breaks up with Hukulk!  Maybe first yooz find Lynuga.  Find who she visits in dark elf city!!  Den yooz go and top off him head!!  Bash Lynuga too, if she no give me back [happy love bracer]!!  Me want head of dat home wrecker an' me happy love bracers, den me give yooz helm of Hukulk.");
	}
	elsif ($text=~/happy love bracer/i) {
		quest::say("Happy love bracers are mines!!  Me make dem for Lynuga.  Dey all shiny and green like da forests me see in adventures when me young.  Dey make Hukulk all warm and happy.  Den me give to Lynuga and.. and <sob>.. and.. AND LYNUGA RIP OUT HUKULK HEART!!  Yooz makes Lynuga give back happy love bracers!!");
	}
	elsif ($text=~/want join nightkeep/i) {
		quest::say("Good. Hate and Pain. Innoruuk teach power, I teach power. Me make you power. You do what me say. You no mess up, I no kill you. We no like dead creature we no own. Go, kill dem. Bring four bone chips. I make you power.");
	}
}

sub EVENT_ITEM {
	#:: Match a 18792 - Tattered Note
	if (plugin::check_handin(\%itemcount, 18792 => 1)) {
		quest::say("Haaah!! Bow to Hukulk!! Hukulk make you feared.. make you powered! Dark power flow through you! Hate and Fear in your blood!");
		#:: Give a 13530 - Black and Green Tunic*
		quest::summonitem(13530);
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(308, 100);	#:: + Shadowknights of Night Keep
		quest::faction(261, -15);	#:: - Green Blood Knights
		quest::faction(222, -25);	#:: - Broken Skull Clan
		quest::faction(235, 5);		#:: - Da Bashers
		#:: Grant a small amount of experience
		quest::exp(100);
	}
	#:: Match four 13073 - Bone Chips
	elsif (plugin::check_handin(\%itemcount, 13073 => 4)) {
		quest::say("You good. Take dis. Make much pain and hurt. Make tings bleeds. Kill, hurt all. Innoruuk and me say do, now go. You do much, come bak. Teach you how more hurt and pain make. Go.");
		#:: Give a 5023 - Rusty Two Handed Sword
		quest::summonitem(15023);
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(308, 10);		#:: + Shadowknights of Night Keep
		quest::faction(261, -10);		#:: - Green Blood Knights
		quest::faction(222, -25);		#:: - Broken Skull Clan
		quest::faction(235, 10);		#:: - Da Bashers
	}
	#:: Match a 12201 - Troll Head and 12202 - Happy Love Bracers
	elsif (plugin::check_handin(\%itemcount, 12201 => 1, 12202 => 1)) {
		quest::say("Ha!! Ha!! Who have last laugh now!! You do good werk.  Now me give you extra helm of Hukulk. Now go away!!");
		#:: Give a 3316 - Helm of Hukulk
		quest::summonitem(13316);
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(308, 10);		#:: + Shadowknights of Night Keep
		quest::faction(261, -10);		#:: - Green Blood Knights
		quest::faction(222, -15);		#:: - Broken Skull Clan
		quest::faction(235, 10);		#:: - Da Bashers
		#:: Grant a small amount of experience
		quest::exp(250);
		#:: Create a hash for storing cash - 4000 to 9000cp
		my %cash = plugin::RandomCash(4000,9000);
		#:: Grant a random cash reward
		quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}

sub EVENT_SPAWN {
	#:: Create a proximity, 100 units across, 100 units tall, without proximity say
	quest::set_proximity($x - 50, $x + 50, $y - 50, $y + 50, $z - 50, $z + 50, 0);
}

sub EVENT_ENTER {
	#:: Match a 18791 - Tattered Note
	if (plugin::check_hasitem($client, 18791)) {
		$client->Message(15,"As your eyes adjust to the darkness, a pretty troll (pretty by trollish standards) turns toward you. 'I be Kaglari. You read note in inventory and hand to me to start training!'");
	}
}

sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("<SNORT!>  HHUUUUCCCSSH..  Peh!  You speak at Kaglari, High Priestess of Dark Ones.  Children of Hate.  Spawn of Innoruuk.  $name, speak or be gone!  <SNORT!>  You [wish majik power]?");
	}
	elsif ($text=~/wish majik power/i) {
		quest::say("GOOD! <SNORT> Innoruuk needs more childrens.  You show majik skill or I give you to Innoruuk.  You bring two froglok tadpole fleshes and two bone chips ..<SNORT>..  from old bones.  I teach you majik.  GO!  <SNORT!!>");
	}
	elsif ($text=~/help innoruuk/i) {
		quest::say("Me hears orcs nearby are trubble. Da werd frum Neriak is dey wants us ta kills dem before dey organize. Dark elf say ta looks for Deathfist Clan. Say dey called cen-tu-ri-ons. Dey try ta gets big orc army. Shows me ya can strike fear and hate inta dem orcs.. dey needs be more scared a us den dem humies. Brings me a Deathfist slashed belt.");
	}
}

sub EVENT_ITEM {
	#:: Match two 13073 - Bone Chips and two 13187 - Froglok Tadpole Flesh
	if (plugin::check_handin(\%itemcount, 13073 => 2, 13187 => 2)) {
		quest::say("Good. Innoruuk get special gift. Not you, dis time. Here. Learning majik wid dis. You more want to [help Innoruuk]?");
		#:: Give a 15093 - Spell: Burst of Flame
		quest::summonitem(15093);
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(237, 5);		#:: + Dark Ones
		quest::faction(308, 5);		#:: + Shadowknights of Night Keep
		quest::faction(251, -10);	#:: - Frogloks of Guk
		#:: Grant a small amount of experience
		quest::exp(100);
	}
	#:: Match a 13916 - Deathfist Slashed Belt
	elsif (plugin::check_handin(\%itemcount, 13916 => 1)) {
		quest::say("Good job. Dat help lerns um. Takes dis ta help ya lerns how ta do more hateful tings. Ya gots a good starts fer Him ta be prouds a ya.");
		#:: Give a 15272 - Spell: Spirit Pouch
		quest::summonitem(15272);
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(237, 5);		#:: + Dark Ones
		quest::faction(308, 5);		#:: + Shadowknights of Night Keep
		quest::faction(251, -10);	#:: - Frogloks of Guk
		#:: Grant a small amount of experience
		quest::exp(150);
	}							
	#:: Match a 18791 - Tattered Note
	elsif (plugin::check_handin(\%itemcount, 18791 => 1)) {
		quest::say("Good.. Kaglari need you help.. Kaglari teach you majik now.  When you ready for task you tell Kaglari!!  Yooz reeturn to mez when yooz ar strongur, mez teech yooz bout da mor advanced tings.");
		#:: Give a 13529 - Muck Stained Tunic*
		quest::summonitem(13529);
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(237, 100);	#:: + Dark Ones
		quest::faction(308, 25);	#:: + Shadowknights of Night Keep
		quest::faction(251, -15);	#:: - Frogloks of Guk
		#:: Grant a small amount of experience
		quest::exp(100);
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}

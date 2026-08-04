sub EVENT_SAY {
	if ($text=~/hail/i) {
		#:: Match if faction is Indifferent or better
		if ($faction <= 5) {
			quest::say("Hi, kid! You seem to be a stranger in these parts. Heed my words, this city is dangerous to new blood!");
			#:: Send a signal "1" to East Freeport >> Bronto_Thudfoot (10135) with no delay
			quest::signalwith(10135, 1, 0);
		}
		else {
			quest::say("Run while ye still can!!  The Wolves o' the North will not tolerate yer presence!");
		}
	}
	#::
	#::
	#::COMMENTING OUT FOR CLASSIC PRE KUNARK
	#::
	#::
#::	elsif ($text=~/toala sent me/i) {
#::		#:: Match if faction is Indifferent or better
#::		if ($faction <= 5) {
#::			quest::say("She does not even have the courtesy to come herself. Some old friend!! Listen, some rogue in this city broke into the [Beast] and stole a pouch containing a voucher ticket for a part I need to repair the Beast. I can't get the part back without the ticket. I did not see the rogue. I did not sleep on the Beast that night. Bronto was there. Ask him if he saw the rogue.");
#::		}
#::		else {
#::			quest::say("Run while ye still can!!  The Wolves o' the North will not tolerate yer presence!");
#::		}
#::	}
#::	elsif ($text=~/beast/i) {
#::		#:: Match if faction is Indifferent or better
#::		if ($faction <= 5) {
#::			quest::say("You're joking, right? You have never heard of the Blue Beast?!! She is the fastest ship in Norrath. She made the [Kunark run] in under three weeks. She was designed by [Bronto].");
#::		}
#::		else {
#::			quest::say("Run while ye still can!!  The Wolves o' the North will not tolerate yer presence!");
#::		}
#::	}
#::	elsif ($text=~/kunark run/i) {
#::		#:: Match if faction is Indifferent or better
#::		if ($faction <= 5) {
#::			quest::say("The Kunark run is the most dangerous run between Freeport and [Firiona Vie], in Kunark. If the seas don't rip your hull to splinters and the pirates and sea wyrms don't kill you, you can make a quick run back and forth, avoiding any unwanted inspections.");
#::		}
#::		else {
#::			quest::say("Run while ye still can!!  The Wolves o' the North will not tolerate yer presence!");
#::		}
#::	}
#::	elsif ($text=~/bronto/i) {
#::		#:: Match if faction is Indifferent or better
#::		if ($faction <= 5) {
#::			quest::say("My trusted friend. Together we travel the world aboard the [Beast]. He is quite skilled at boat making and other mechanical skills. He has a heart and brain far superior to any ogre I have ever met, as well as most other races.");
#::		}
#::		else {
#::			quest::say("Run while ye still can!!  The Wolves o' the North will not tolerate yer presence!");
#::		}
#::	}
#::	elsif ($text=~/firiona vie/i) {
#::		#:: Match if faction is Indifferent or better
#::		if ($faction <= 5) {
#::			quest::say("Firiona Vie is an elven outpost on the continent of Kunark. Every so often I run supplies to and from there. Do not even think about asking me to take you there. It will be months before I can make improvements on the Blue Beast to make it impervious to aerial attacks.");
#::		}
#::		else {
#::			quest::say("Run while ye still can!!  The Wolves o' the North will not tolerate yer presence!");
#::		}
#::	}
	elsif ($text=~/journal strongbox/i) {
		#:: Match if faction is Indifferent or better
		if ($faction <= 5) {
			quest::say("You must be from the Academy of Arcane Science.  Well, kid, bad news.  I was docked at the isle in the Ocean of Tears when I was boarded by the Freeport Militia.  To say the least, I panicked and dropped all my cargo.  It is still there.  Mostly illegal alcohol, but the strongbox is still out there, too.  Directly out from the dock.");
			#:: Data bucket to verify quest has been started appropriately
			$key = $client->CharacterID() . "-strongbox";
			#:: Set a data bucket, quest started, expire in 3600 seconds (1 hour)
			quest::set_data($key, 1, 3600);
		}
		else {
			quest::say("Run while ye still can!!  The Wolves o' the North will not tolerate yer presence!");
		}
	}
	elsif ($text=~/^blue beast$/i) {
		#:: Match if faction is Indifferent or better
		if ($faction <= 5) {
			quest::say("The Blue Beast? She's around. Doing fine and faster than ever. Afraid I don't carry passengers any more. Contraband... er, I mean, freight is where all the coin's at.");
		}
		else {
			quest::say("Run while ye still can!!  The Wolves o' the North will not tolerate yer presence!");
		}
	}
}

sub EVENT_ITEM {
	#:: Match a 13818 - Boat Beakon
	if (plugin::check_handin(\%itemcount, 13818 => 1)) {
		quest::say("Oh!! You must work for that Erudite named Palatos. I guess he won't have to spend anymore money drinking in Freeport. Here. Here is the portrait I kept until he could get me a new boat beacon.");
		#:: Give item 12146 - Ak'anon's Portrait
		quest::summonitem(12146);
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(320, 5); 		#:: + Wolves of the North
		quest::faction(327, 1); 		#:: + Shaman of Justice
		quest::faction(328, 1); 		#:: + Merchants of Halas
		quest::faction(311, 1); 		#:: + Steel Warriors
		#:: Grant a small amount of experience
		quest::exp(100);
	}
	#:: Match a 13814 - L.S. Pouch
	elsif (plugin::check_handin(\%itemcount, 13814 => 1)) {
		quest::say("You found my pouch! Thanks kid. Let me buy you A drink and this is for the good work. Hmmmm. It looks as though they took my voucher. Darn it! Hey... It looks like they were using my bag to hold items they were stealing. Here you go. You can have it. It looks like junk.");
		#:: Give a random reward:  13922 - Snapped Pole or 13923 - Moggok's Right Eye
		quest::summonitem(quest::ChooseRandom(13922, 13923));
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(320, 5); 		#:: + Wolves of the North
		quest::faction(327, 1); 		#:: + Shaman of Justice
		quest::faction(328, 1); 		#:: + Merchants of Halas
		quest::faction(311, 1); 		#:: + Steel Warriors
		#:: Grant a small amount of experience
		quest::exp(200);
		#:: Create a hash for storing cash - 35 to 45cp
		my %cash = plugin::RandomCash(35,45);
		#:: Grant a random cash reward
		quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}

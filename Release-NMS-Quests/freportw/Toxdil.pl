sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Correct. Toxdil is my name. No last name. I swear allegiance to no house nor guild. What brings you down here? Perhaps you seek my [deadly liquid], perhaps not. Whatever your reasons, I warn you to keep an eye out for the militia. They have begun to patrol the sewers.");
	}
	elsif ($text=~/deadly liquid/i) {
		quest::say("The deadly liquid I offer to rogues is called spider venom. I will be glad to make it for you, but first you must supply me with two snake venom sacs and my fee of 20 gold pieces. You may find the sacs upon the giant snakes of the Commonlands.");
	}
	elsif ($text=~/gem of righteousness/i) {
		quest::say("That gem is worthless!! If you want it, you can have it. Oh, but I forgot! I sold it to some gem merchant. I can't seem to remember her name, but she paid highly for it. Ha!! Imagine that. Worthless hunk of crystal. Do not bother looking for it.");
	}
}

sub EVENT_ITEM {
	if (plugin::HasClassName($client, "Rogue")) {
		#:: Match a 12353 - A Sparkling Sapphire
		if (plugin::check_handin(\%itemcount, 12353 => 1)) {
			quest::say("The gem!! I would notice it's sparkle anywhere!! I cannot believe you are handing it back to me!! What a fool. Here you are fool. You can have this worthless key now.");
			#:: Give a 12351 - A Tiny Key
			quest::summonitem(12351);
			#:: Ding!
			quest::ding();
			#:: Grant a large amount of experience
			quest::exp(15000);
		}
		#:: Match two 14017 - Snake Venom Sac and 20 gold pieces
		elsif (plugin::check_handin(\%itemcount, 14017 => 2, "gold" => 20)) {
			quest::say("Here is your snake venom. May you... shall we say... apply it to good use.");
			#:: Give item 14016 - Snake venom
			quest::summonitem(14016);
			#:: Ding!
			quest::ding();
			#:: Grant a small amount of experience
			quest::exp(100);
		}
		#:: Match one 14017 - Snake Venom Sac and 20 gold pieces
		elsif (plugin::check_handin(\%itemcount, 14017 => 2, "gold" => 20)) {
			quest::say("I require two snake venom sacs and my fee of 20 gold coins before I shall create the snake venom");
			#:: Return a 14017 - Snake Venom Sac
			quest::summonitem(14017);
		}
		#:: Match two 14017 - Snake Venom Sac
		elsif (plugin::check_handin(\%itemcount, 14017 => 2)) {
			quest::say("I require two snake venom sacs and my fee of 20 gold coins before I shall create the snake venom");
			#:: Return two 14017 - Snake Venom Sac
			quest::summonitem(14017);
			quest::summonitem(14017);
		}
		#:: Return unused items
		plugin::return_items(\%itemcount);
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}

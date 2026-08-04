sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("I am Toala Nehron. You must be another young warrior aspiring to join the ranks of the Steel Warriors. We welcome all who would try.");
	}
	elsif ($text=~/opal/i) {
		quest::say("Opal Darkbriar is a little plague rat.  She has used her knowledge of arcane arts to charm Cain Darkmoore.  I know that is what happened.  Why else would he be in love with her?  He is a mighty warrior and she is nothing more than a sickly little librarian for the Academy of Arcane Science.  He must truly yearn for a bold hearted female warrior such as myself.  Not that I care, of course.");
	}
	elsif ($text=~/cain darkmoore/i) {
		quest::say("Cain Darkmoore is only the most handsome of warriors!  He is also the strongest and most bold.  He has slain the mightiest of fiends.  He is truly the manliest man around.  It is no wonder he is the guildmaster of the Steel Warriors.");
	}
}


sub EVENT_ITEM {
	#:: Match a 18814 - Sealed Letter
	if (plugin::check_handin(\%itemcount, 18814 => 1)) {
		#:: Match if faction with Steel Warriors is Amiable or better
		if ($faction <= 4) {
			quest::say("Why, that little trollop! What is she up to? Cain will never believe this! She must be in league with some faction of the dark elves, but why? Neither the Academy of Arcane Science nor Cain will believe this note. I will see what I can do. As for you, I command you to kill this Shintl and her dark elf courier Hollish!! Put their heads into this box and combine them. We shall cut the link. Bring me thier heads.");
			#:: Give a 17971 - Toala's Box for heads
			quest::summonitem(17971);
			#:: Ding!
			quest::ding();
			#:: Grant a moderate amount of experience
			quest::exp(2000);
		}
		#:: Match if faction with Steel Warriors is Indifferent
		elsif ($faction == 5) {
			quest::say("The Steel Warriors have no cause to dislike you, but you have yet to prove your worth to this guild.");
			#:: Return a 18814 - Sealed Letter
			quest::summonitem(18814);
		}
		else {	
			quest::say("Your head shall look grand mounted on the wall of the Steel Warriors Arena!!");
			#:: Return a 18814 - Sealed Letter
			quest::summonitem(18814);
		}
	}
	#:: Match a 12246 - Box with Two heads
	elsif (plugin::check_handin(\%itemcount, 12246 => 1)) {
		#:: Match if faction with Steel Warriors is Amiable or better
		if ($faction <= 4) {
			quest::say("Good work!! We will soon catch Opal. I have started to formulate a plan to stop her. When I complete it, I shall notify you. Here. Take this small reward. I am sure killing Shintl was no trouble. She was just a halfling.");
			#:: Ding!
			quest::ding();
			#:: Set factions
			quest::faction(311, 10);	 	#:: + Steel Warriors
			quest::faction(262, 2); 		#:: + Guards of Qeynos
			quest::faction(281, 2); 		#:: + Knights of Truth
			quest::faction(230, -1); 		#:: - Corrupt Qeynos Guards
			quest::faction(330, -1); 		#:: - The Freeport Militia
			#:: Grant a moderate amount of experience
			quest::exp(2000);
			#:: Create a hash for storing cash - 300 to 350cp
			my %cash = plugin::RandomCash(300,350);
			#:: Grant a random cash reward
			quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
		}
		#:: Match if faction with Steel Warriors is Indifferent
		elsif ($faction == 5) {
			quest::say("The Steel Warriors have no cause to dislike you, but you have yet to prove your worth to this guild.");
			#:: Return a 12246 - Box with Two heads
			quest::summonitem(12246);
		}
		else {	
			quest::say("Your head shall look grand mounted on the wall of the Steel Warriors Arena!!");
			#:: Return a 12246 - Box with Two heads
			quest::summonitem(12246);
		}
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}

sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Come forward and speak.  What is it you seek within these walls?  Let it be the knowledge of wizardry, for that is what we are.  Only a [servant of wizardry] should be within these walls.");
	}
	elsif ($text=~/servant of wizardry/i) {
		quest::say("A servant. you say?  If you be a young apprentice, perhaps you might assist me? I could use you to [collect components].  If you believe yourself to be beyond such things, you may wish to assist me with a [special matter].");
	}
	elsif ($text=~/collect components/i) {
		#:: Match if faction is Amiable or better
		if ($faction <= 4) {
			quest::say("Of course you may assist me!! We have much need of a certain item which can only be found in the frigid peaks of Everfrost. There you shall find creatures called ice goblins. Take this bag and fill it with ice goblin beads and be sure to combine them before you return them. Well, then... Off with you!! And be quick about it and I shall give you a fine wizard's weapon. None of this rust-covered garbage offered by our associates!");
			#:: Give item 17944 - Empty Bag (*Bag for Ice Necklaces)
			quest::summonitem(17944);
		}
		#:: Match if faction is Indifferent
		elsif ($faction == 5) {
			quest::say("The Crimson hands have no quarrel with you, but we cannot truly trust you as yet.");
		}
		else {
			quest::say("The Crimson Hands will have nothing to do with you.  Perhaps only your death shall improve our relations.");
		}
	}
	elsif ($text=~/special matter/i) {
		#:: Match if faction is Amiable or better
		if ($faction <= 4) {
			quest::say("An old friend of mine cannot rest till he his research is finished.  If I only knew what he was working on. Go to the forest of Toxxulia and seek him out. Bring me back what information you can find about what he was researching before his demise.");
		}
		#:: Match if faction is Indifferent
		elsif ($faction == 5) {
			quest::say("The Crimson hands have no quarrel with you, but we cannot truly trust you as yet.");
		}
		else {
			quest::say("The Crimson Hands will have nothing to do with you.  Perhaps only your death shall improve our relations.");
		}
	}
}
				
sub EVENT_ITEM {
	#:: Match a 13898 - Bag of Ice Necklaces
	if (plugin::check_handin(\%itemcount, 13898 => 1)) {
		#:: Match if faction is Amiable or better
		if ($faction <= 4) {
			quest::say("Well done, my young apprentice. I call you apprentice for you are nothing but a spark to my fire. This is the final component for my greatest creation. AHA!! I call it - iced tea!! Never again shall I boil under the hot sun. As for you, take this. It should serve you well. Now go away. There is no iced tea for you");
			#:: Give item 12208 - Servant's Staff
			quest::summonitem(12208);
			#:: Ding!
			quest::ding();
			#:: Set factions
			quest::faction(233, 15);		#:: + Crimson Hands
			quest::faction(266, 1);			#:: + High Council of Erudin
			quest::faction(265, -2);		#:: - Heretics
			quest::faction(267, 2);			#:: + High Guard of Erudin							
			#:: Grant a moderate amount of experience
			quest::exp(1000);
			#:: Create a hash for storing cash - 550 to 750cp
			my %cash = plugin::RandomCash(550,750);
			#:: Grant a random cash reward
			quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
		}
		#:: Match if faction is Indifferent
		elsif ($faction == 5) {
			quest::say("The Crimson hands have no quarrel with you, but we cannot truly trust you as yet.");
			#:: Return a 13898 - Bag of Ice Necklaces
			quest::summonitem(13898);
		}
		else {
			quest::say("The Crimson Hands will have nothing to do with you.  Perhaps only your death shall improve our relations.");
			#:: Return a 13898 - Bag of Ice Necklaces
			quest::summonitem(13898);
		}
	}
	#:: Match a 12207 - Half of a Spell
	elsif (plugin::check_handin(\%itemcount, 12207 => 1)) {
		#:: Match if faction is Amiable or better
		if ($faction <= 4) {
			quest::say("Go now and use his research to aid yourself. Seems that I lack the will to use Ilanic's knowledge for my better good.");
			#:: Give item 15380 - Spell: Column of Frost
			quest::summonitem(15380);
			#:: Ding!
			quest::ding();
			#:: Set factions
			quest::faction(233, 5);			#:: + Crimson Hands
			quest::faction(266, 1);			#:: + High Council of Erudin
			quest::faction(265, -1);		#:: - Heretics
			quest::faction(267, 1);			#:: + High Guard of Erudin	
			#:: Grant a moderate amount of experience
			quest::exp(1000);
		}
		#:: Match if faction is Indifferent
		elsif ($faction == 5) {
			quest::say("The Crimson hands have no quarrel with you, but we cannot truly trust you as yet.");
			#:: Return a 12207 - Half of a Spell
			quest::summonitem(12207);
		}
		else {
			quest::say("The Crimson Hands will have nothing to do with you.  Perhaps only your death shall improve our relations.");
			#:: Return a 12207 - Half of a Spell
			quest::summonitem(12207);
		}
	}
	#:: Return unused items
	plugin::returnUnusedItems();
}

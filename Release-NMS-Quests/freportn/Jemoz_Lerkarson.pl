sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Bless you, my friend!  We always welcome new converts into our Hall of Truth.  The righteous army of the twin deities must assemble.  The battle draws near.  The blessings of the Truthbringer are passed to all who are [devoted to truth].");
	}
	elsif ($text=~/fallen knight/i) {
		quest::say("The fallen knight is Sir Lucan D'Lere. The organizer and leader of the Freeport Militia. He once stood beside us. Now he shall burn!! We will end him. We shall [crush the Freeport Militia]. Truth shall reign once again.");
	}
	elsif ($text=~/true organizer/i) {
		quest::say("Captain Hazran is the commander of the Freeport Militia. Lucan has no time to waste on relegating duties. Hazran is the one who keeps these brutes together as a militia. Stop him and maybe the militia will collapse. Find a way to return his head to me. That would surely bring great thanks from this temple.");
	}
	elsif ($text=~/devoted to truth/i) {
		#:: Match if faction is better than indifferent
		if ($faction < 5) {
			quest::say("May the hand of Marr shield you from harm. Welcome to our world. The war begins here in Freeport. The [fallen knight] has masked the truth from the world, but he cannot mask his evil from the Truthbringer. He once followed our ways. Now he is our enemy and yours. We must end his rule. We must [crush the Freeport Militia]!!");
			#:: Cast spell 11 - Holy Armor
			$npc->CastSpell(11,$userid);
		}
		else {
			quest::say("Work on the ways of valor before we discuss such things. You are on the righteous path of the Truthbringer, but there is more work to do.");
		}
	}
	elsif ($text=~/crush the freeport militia/i) {
		#:: Match if faction is better than indifferent
		if ($faction < 5) {
			quest::say("Our goal is to end their rule. To retake our city in the name of Marr. Let it begin with their blood!! Slay the militia!! They have no souls and hail from the back alleys and prison cells of darkness and depravity. Thieves and murderers, nothing more. Slay any you can and, as proof, return their militia helms to me. We shall see what bounty you deserve.");
		}
		else {
			quest::say("Work on the ways of valor before we discuss such things. You are on the righteous path of the Truthbringer, but there is more work to do");
		}
	}
}

sub EVENT_ITEM {
	#:: Turn in for 13921 - Damaged Militia Helm
	if (plugin::check_handin(\%itemcount, 13921 => 1 )) {
		quest::say("Bless you, my child. Marr is grateful, as are we. Here is our thanks. Let it bring you greater strength to defeat the Militia. Go and continue the crusade. Soon you will be strong enough to slay the [true organizer].");
		#:: Ding!
		quest::ding();
		#:: Grant a large amount of experience
		quest::exp(5000);
		#:: Give a random reward: 15019 - Spell: Armor of Faith, 15013 - Spell: Complete Healing, 15045 - Spell: Pacify
		quest::summonitem(quest::ChooseRandom(15019, 15013, 15045));
		#:: Set factions
		quest::faction(362, 3); 		#:: + Priests of Marr
		quest::faction(336, -10); 		#:: - Coalition of Tradefolk Underground
		quest::faction(281, 3); 		#:: + Knights of Truth
		quest::faction(311, 10); 		#:: + Steel Warriors
		#:: Cast spell 12 - Healing
		$npc->CastSpell(12,$userid);
	}
	#:: Turn in for 12142 - Human Head
	if (plugin::check_handin(\%itemcount, 12142 => 1 )) {
		quest::say("We heard of your assault. We even attempted to slay Lucan. Alas, we failed. You have done your part and as such have earned our thanks. Beware of the Freeport Militia. They will no doubt be on the lookout for you. May Marr protect you. Perhaps you should speak with Valeron Dushire, paladin of the Knights of Truth. He seeks other to slay the fallen knight.");
		#:: Give a random reward: 15560 - Spell: Furor, 15230 - Spell: Root, 15219 - Spell: Center, 15229 - Spell: Fear, 15222 - Spell: Invigor, 15012 - Spell: Healing
		quest::summonitem(quest::ChooseRandom(15560,15230,15219,15229,15222,15012));
		#:: Ding!
		quest::ding();
		#:: Grant a large amount of experience
		quest::exp(5000);
		#:: Set factions
		quest::faction(362, 3); 		#:: + Priests of Marr
		quest::faction(336, -10); 		#:: - Coalition of Tradefolk Underground
		quest::faction(281, 3); 		#:: + Knights of Truth
		quest::faction(311, 10);	 	#:: + Steel Warriors
		quest::faction(330, -10); 		#:: - Freeport Militia
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}

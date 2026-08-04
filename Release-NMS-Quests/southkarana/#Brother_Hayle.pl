sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("This is no place for you. These Splitpaws are very fierce. Only the power of Rodcet Nife will guide them to the light. By the way, I might warn you that the cells here lock behind you.");
	}
	elsif ($text=~/proof of nobility/i) {
		quest::say("I require the returned note I gave you, a Testimony of Truth, a Sword of Faith and finally the hilt of Soulfire. The Testimony and Sword of Faith are earned in the Hall of Truth, but for the hilt of Soulfire you shall have to battle [Xicotl].");
	}
	elsif ($text=~/xicotl/i) {
		quest::say("Xicotl is the evil troll who attempted to steal Soulfire from the vaults of the Temple of Life. The hilt of Soulfire broke off during the battle and now rests in the hands of this troll shadowknight. From what I have heard, he is frequently an invited guest at the castle called Mistmoore. Woe to any paladin who dares set foot upon the land of Mistmoore, but should you attempt it you might search the guest rooms for the troll. May Rodcet Nife walk with you.");
	}
}

sub EVENT_ITEM {
	#:: Match a 18927 - Temple Summons
	if (plugin::check_handin(\%itemcount, 18927 => 1)) {
		quest::say("I am needed!! What am I doing here? I must return to the Temple of Life to commune with the Prime Healer. Rodcet Nife will give me more strength to finish this job. Thank you, young one! Take this key as a reward. Turn it into Tyokan in the temple shop. Safe journey to you!");
		#:: Give a 13306 - T.O.L. 2020
		quest::summonitem(13306);
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(341, 20);			#:: + Priest of Life
		quest::faction(280, 6);				#:: + Knights of Thunder
		quest::faction(262, 10);			#:: + Guards of Qeynos
		quest::faction(221, -5);			#:: - BloodSabers
		quest::faction(219, 3);				#:: + Antonious Bayle
		#:: Grant a small amount of experience
		quest::exp(200);
	}
	#:: Match a 18936 - Sealed Note
	elsif (plugin::check_handin(\%itemcount, 18936 => 1)) {
		quest::say("Finally!! I see that Ariska has found a noble knight to retrieve Soulfire. Per Ariska's orders I am not to give Soulfire to you until you can show me [proof of nobility]. You must honor both the Temple of Life as well as the Hall of Truth and to a high degree. Only then shall you hold Soulfire.");
		#:: Give a 18937 - Note
		quest::summonitem(18937);
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(341, 10);			#:: + Priest of Life
		quest::faction(280, 3);				#:: + Knights of Thunder
		quest::faction(262, 5);				#:: + Guards of Qeynos
		quest::faction(221, -2);			#:: - BloodSabers
		quest::faction(219, 1);				#:: + Antonious Bayle
		#:: Grant a small amount of experience
		quest::exp(200);
	}
	#:: Match a 18937 - Note, a 13947 - Brilliant Sword of Faith, a 18828 - Testimony, and a 12197 - Glowing Sword Hilt
	elsif (plugin::check_handin(\%itemcount, 18937 => 1, 13947 => 1, 18828 => 1, 12197 => 1)) {
		#:: Match if faction is Kindly or better
		if ($faction <= 2) {
			quest::say("You have proven yourself worthy to hold Soulfire. Do not let her slip into the hands of evil. There are many who wish to free the many trapped souls of shadowknights and necromancers trapped inside the blade. The power of the blade can be called upon to heal you if need be. May Rodcet Nife and the twins of Marr hold you in their glory.");
			#:: Give a 5504 - SoulFire
			quest::summonitem(15504);
			#:: Ding!
			quest::ding();
			#:: Set factions
			quest::faction(341, 100);		#:: + Priest of Life
			quest::faction(280, 30);		#:: + Knights of Thunder
			quest::faction(262, 50);		#:: + Guards of Qeynos
			quest::faction(221, -25);		#:: - BloodSabers
			quest::faction(219, 15);		#:: + Antonious Bayle
			#:: Grant a small amount of experience
			quest::exp(200);
		}
		#:: Else eat the items
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}

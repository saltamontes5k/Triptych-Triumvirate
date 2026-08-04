sub EVENT_SPAWN {
	#:: Create a timer 'ready' that loops every 30 seconds
	quest::settimer("ready", 30);
}

sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Nice to meet you, $name. I hope you stay to hear my fine compositions.");
	}
}

sub EVENT_TIMER {
	#:: Match timer 'ready'
	if ($timer eq "ready") {
		quest::say("What a cheerful crowd.");
		#:: Stop the timer
		quest::stoptimer("ready");
	}
}

sub EVENT_SIGNAL {
	#:: Match a signal '1' from /freporte/Henna_Treghost.pl
	if ($signal == 1) {
		#:: Create a scalar to store a random number
		my $singasong = quest::ChooseRandom(1, 2, 3, 4, 5);
		if ($singasong == 1) {
			quest::say("My city is mighty and all shall learn to cower. We are nothing less than the ultimate power. My city is pure and filled with beautiful charm. I shall conquer you to save you from harm. My city shall first send its guards to back you in times of need. Soon you shall learn to live under my laws, indeed. So bow down when you see me and give out my favorite cheer, 'All Hail Antonius Bail!' My city is Qeynos and there is nothing to fear.");
			#:: Send a signal '1' to East Freeport >> Sir_Edwin_Motte (10199) with no delay
			quest::signalwith(10199, 1, 0);
			#:: Send a signal '2' to East Freeport >> Imxil_Tbrow (10012) with a three second delay
			quest::signalwith(10012, 2, 3);
		}
		elsif ($singasong == 2) {
			quest::say("All clap and pass the ale. Sir Lucan is in charge so don't set sail. All clap and pass the ale. Sir Lucan is in charge and he shall never fail. He saved our fair city when the others had fled. Off on a crusade, or so they said. All clap  and pass the ale, Sir Lucan is in charge so don't you bail. All clap and pass the ale, Sir Lucan is in charge so sing or go to jail. All clap and pass the ale, Sir Lucan beat the orcs and next is Bayle. Thank you. I hope the Freeport citizens liked that one.");
			#:: Send a signal '2' to East Freeport >> Sir_Edwin_Motte (10199) with no delay
			quest::signalwith(10199, 2, 0);
		}
		elsif ($singasong == 3) {
			quest::say("Here is one for my former lover, Joffrey Clay. You look the lute. It was my favorite one. A little white lute, and went off to Qeynos. You took the songs. They were all special ones. Packed them all up. Off to Qeynos. You killed the plant. Put it in a deep freeze. Dumped it in the trunk. With the rest of the refuse. You, left to Qeynos. You, left to Qeynos. You, left to Qeynos. You, left to Qeynos.");
			#:: Send a signal '2' to East Freeport >> Talym_Shoontar (10182) with no delay
			quest::signalwith(10182, 2, 0);
		}
		elsif ($singasong == 4) { 
			quest::say("Life is dull and dreary when you know it all. To the planes of the gods, is their next call. An Erudite, an Erudite has come to drink. All the knowledge in the world, or so they think. One drink, two drinks, grab and down the ale! Then they step off their stools and their faces begin to pale. For all their love of music and their great schools of magic, up come their lunches, how very tragic. So let all sit back and be ready with Hijinks, an Erudite has come to the Seafarer to down a few drinks.");
			#:: Send a signal '4' to East Freeport >> Sir_Edwin_Motte (10199) with no delay
			quest::signalwith(10199, 4, 0);
		}
		elsif ($singasong == 5) {
			quest::say("Yo ho, in the merry old harbor of Sir D'lere. There lived a small man who lived in fear. Fear of the pawns and fear of the fish, but most of all fear of the bottle. One day as he sailed overseas, he encountered a spat. A lovely lady being harrassed by a buccaneer, tall and fat. He hid all his fear and yelled 'Let her go!' The buccaneer said that he would do so. 'I will do so if you can drink from this bottle, oblong and of weight, for twenty whole seconds. Will you test your fate?' So as the ship did thread the needle around a quater to live, foolish Turgin drank, passed out and took a dive. Under went he and the evil bottle too. Now all should fear the bottle of ochre goo.");
			#:: Send a signal '4' to East Freeport >> Sir_Edwin_Motte (10199) with no delay
			quest::signalwith(10199, 4, 0);
		}
	}
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}

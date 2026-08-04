sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Company?! Way out here in the desert of Ro? This is a pleasant surprise! Won't you stay for a while? I am sure the desert has dried your throat. I have supplies if necessary. At a price, of course. Are you [traveling] or are you here on [business]?");
	}
	elsif ($text=~/traveling/i) {
		quest::say("Oh, wonderful! Then you must need water and rations for your long journey. Be sure to approach any camp you may find in Ro with caution. There are many bandits in the desert. If it were not for Ortallius, they would have gutted me and thieved all my merchandise by now. If you have any use of magic then I believe I may have an [offer] for you.");
	}
	elsif ($text=~/business/i) {
		quest::say("Of course. You do not look like a traveling merchant or a lost adventurer. Someone has sent you to Rathmana. Well then, let's not waste time. Give me the item, or items, and my fee of twenty gold coins. It must be gold. I have no use for any other metals.");
	}
	elsif ($text=~/offer/i) {
		quest::say("My offer to you is this, you give me thirty gold and I allow you to reach into my scroll bag and retrieve one scroll and only one. It may be the spell of a wizard or maybe not. The school of magic will not be known beforehand. The only knowledge you will have is that Rathmana will not exchange the spell for another. You get what you take. Do you wish to reach into my bag? Then give Rathmana his thirty gold coins.");
	}
	elsif ($text=~/ortallius/i) {
		quest::say("Pay no mind to him. He is my friend. I found him as a child, dying under the blazing sun of Ro. He was curled up next to his dead mother's body. I raised him since then. He is quite the opposite of what you would expect of an orc. He is a good person. To me, anyway.");
	}
}

sub EVENT_ITEM {
	#:: Match thirty gold pieces
	if (plugin::takeCoin(0, 0, 30, 0)) {
		quest::say("Good luck, my friend. May Solusek Ro guide your hand.");
		#:: Give a random reward: 15022 - Spell: Force Snap, 15035 - Spell: Bind Affinity, 15038 - Spell: Lightning Bolt, 15039 - Spell: Quickness, 15303 - Spell: Whirl till you hurl, 15328 - Spell: Column of Fire, 15355 - Spell: Engulfing Darkness, 15364 - Spell: Banshee Aura, 15445 - Spell: Lifedraw, 16425 - Spell: Charm, 13360 - Rotted Illegible Scroll
		quest::summonitem(quest::ChooseRandom(15022, 15035, 15038, 15039, 15303, 15328, 15355, 15364, 15445, 16425, 13360, 13360, 13360, 13360, 13360, 13360, 13360, 13360, 13360, 13360, 13360, 13360, 13360, 13360, 13360, 13360, 13360, 13360, 13360, 13360));
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(415, 5);		#:: + Temple of Solusek Ro
		quest::faction(416, -1);	#:: - Shadowed Men
		#:: Grant a small amount of experience
		quest::exp(100);
	}
	#:: Match a 18808 - Bayle List I, 18809 - Bayle List II, 18810 - Bayle List III, and 20 gold
	elsif (plugin::check_handin(\%itemcount, 18808 => 1, 18809 => 1, 18810 => 1, "gold" => 20)) {
		quest::say("A simple code. Why do you even bother Rathmana with such child's play? Here is your translation. That was the easiest twenty gold coins I ever earned.");
		#:: Give a 18961 - Translated Parchment
		quest::summonitem(18961);
		#:: Ding!
		quest::ding();
		quest::faction(415, 5);		#:: + Temple of Solusek Ro
		quest::faction(416, -1);	#:: - Shadowed Men
		#:: Grant a moderate amount of experience
		quest::exp(1000);
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}

sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Hmmph.");
	}
	if ($text=~/avenge my brother/i) {
		quest::say("My brother was part of a raiding party that adventured into the Caverns of Guk. Somewhere within he was betrayed and left for dead by the dastardly brother of Karg IceBear - Martar. I want you to find me what remains of my brothers body and bring it back to me. I am told that he died within a mine shaft.");
	}
}

sub EVENT_ITEM {
	#:: Match 10528 - Shadowed Ball
	if (plugin::check_handin(\%itemcount, 10528 => 1)) {
		quest::say("You must be another one from Vilissia. I will tell you what I tell all the others--you must help me [avenge my brother] before I will help you attain Tishan's Kilt.");
		#:: Give a 18797 - Tattered Note
		quest::summonitem(18797);
		quest::ding();
		quest::exp(500);
	}
	#:: Match 10556 - Barbarian Head
	if (plugin::check_handin(\%itemcount, 10556 => 1)) {
		quest::say("Oh Wulfthan, look what has become of you. I told you that you should not have trusted Martar.  $name, as a final service, I want you to kill Martar IceBear for me. He is known to roam these parts. Bring me the Warthread Kilt that he wears and my two reminder notes, and I will give to you Tishan's Kilt.");
		#:: Give a 18798 - Tattered Note
		quest::summonitem(18798);
		quest::ding();
		quest::exp(500);
	}
	#:: Match 18797 - Tattered Note, 18798 - Tattered Note, 1347 - Warthread Kilt
	if (plugin::check_handin(\%itemcount, 18797 => 1, 18798 => 1, 1347 => 1)) {
		quest::say("Ah, Wulfthan, you are at last avenged. Thank you, $name please take this kilt as a reward for services well done.");
		#:: Give a 18798 - Tattered Note
		quest::summonitem(18798);
		quest::ding();
		quest::exp(1500);
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}
# Converted to Perl by SS

sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Hello, $name!  It's hard to believe just how cold it gets here!  It really has been wearing me down. Especially after the [journey] from Qeynos.");
	}
	elsif ($text=~/journey/i) {
		quest::say("I have been traveling the face of Norrath to unravel the mystery of why my beloved [brother] attacked a group of traveling bards.  He didn't survive the fight.  It's been so long. I can't really remember what he looked like!  I miss him so much...  Now all I have are his [diary] and some brewing recipes he sold before his death.");
	}
	elsif ($text=~/brother/i) {
		quest::say("My brother was Delius Thyme. I think he was a great man. $name, have you ever lost someone close? I don't know if I can ever forgive myself for letting him travel on his own after his sanity began to fade. Oh, Delius, please forgive me!");
	}
	elsif ($text=~/diary/i) {
		quest::say("The diary?  It's one of the two connections I still have to my brother.  Sadly, [pages] are missing from it.  I've been looking for them.");
	}
	elsif ($text=~/pages/i) {
		quest::say("I believe the pages contain the events that drove my brother to insanity.  I have been searching for the remaining three missing pages.  There is some hope; I found a couple of pages over in Everfrost Mountains.");
	}
}

sub EVENT_ITEM {
	#:: Match a 18136 - Delius Thyme's Diary Pg. 74, 18137 - Delius Thyme's Diary Pg. 75, 18138 - Delius Thyme's Diary Pg. 76
	if (plugin::check_handin(\%itemcount, 18136 => 1, 18137 => 1, 18138 => 1)) {
		quest::say("Thank you, thank you. Let me read them. Oh! How could I want these brewing recipes after they made my brother insane? Where are they? I think this is all of them. Take them away from me! Delius can smile upon me now.");
		#:: Give a 18139 - Garsen's Brewing List
		quest::summonitem(18139);
		#:: Ding!
		quest::ding();
		#:: Grant a small amount of experience
		quest::exp(200);
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}

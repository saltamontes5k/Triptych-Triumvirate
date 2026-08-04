sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Hello. If you are in need of any cloth armor I would be glad to show you my wares.");
	}
	elsif ($text=~/twippie/i) {
		quest::say("Twippie Diggs is my younger brother. He sells armor also. His specialty is leather armor.");
	}
	elsif ($text=~/kevlin/i) {
		quest::say("Kevlin is my brother. Our family has been in the armor business for many years.");
	}
	elsif ($text=~/lashinda/i) {
		quest::say("She is my brother Kevlin's bride. She is very nice. She works at the Fool's Gold, but when she has time she will help out with the shop by cleaning up or taking the day's profit over to the vault in the Guardian Stronghold.");
	}
	elsif ($text=~/sonsa/i) {
		quest::say("Oh, my! Do not mention that name to me! She used to be wed to my older brother, Kevlin. All I can say about her is that she would make a better rogue than a tailor.");
	}
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}

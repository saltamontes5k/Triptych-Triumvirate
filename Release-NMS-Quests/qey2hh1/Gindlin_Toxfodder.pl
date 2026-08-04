sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Enough with the formalities. I don't make it to these parts often and I only plan on being here a couple days. My time is precious. You must be a rogue in search of the [death juice].");
	}
	elsif ($text=~/death juice/i) {
		quest::say("Spider Venom. No doubt you can't mix it yourself. If you want, I can do it. I'll need Two Spider Venom sacs from the Giant Spiders. There's some around these plains. I also demand a fee of 20 Gold Pieces, oh yeah!!.. I have been banished from Qeynos,.. I also want a bottle of my favorite brew, Crow's special brew, purchased from Crow himself in North Qeynos.");
	}
}

sub EVENT_ITEM {
	#:: Match 20 gold pieces, two 14018 - Spider Venom Sac, and a 13795 - Crow's Special Brew
	if (plugin::check_handin(\%itemcount, 14018 => 2, 13795 => 1, "gold" => 20)) {
		quest::say("Here.  I could care less what you do with this.  Hopefully you'll lay some on the Circle of Unseen Hands.");
		#:: Give a 14015 - Spider Venom
		quest::summonitem(14015);
		#:: Ding!
		quest::ding();
		#:: Grant a small amount of experience
		quest::exp(1000);
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}

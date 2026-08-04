sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Hello, friend.");
	}
	elsif ($text=~/battle staff/i) {
		quest::say("I was hired to steal a High Guard battle staff from the High Guard of Erudin. It is a gift for Carson McCabe. I guess he collects weapons.");
	}
	elsif ($text=~/tallus holton/i) {
		quest::say("Tallus Holton was my partner on my last mission. He is actually a wizard, but instead of yearning for knowledge, he yearns for money. He likes to hang around the Karana Bandits. They like him, he can ignite a campfire in a snap.");
	}
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}

sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("<BARK!>  Hiya!  <Bark!>  <Bark!>  My name is Furball Miller.  I work here on my father's farm.  Of course, he is not my real [father] but he is the one who raisd me from a pup.  I hope to go back to [Blackburrow] some day and try to get them to stop all the senseless fighting with the humans of Qeynos.");
	}
	elsif ($text=~/blackburrow/i) {
		quest::say("Blackburrow is home to a clan of gnolls called the Sabertooths. It is [where] I am from but I really don't remember being there. Pa tells me the gnolls there are always fighting with the <BARK> humans of Qeynos. I wish they would stop and realize that humans and gnolls are not as different as they like to think. <BARK!>");
	}
	elsif ($text=~/where/i) {
		quest::say("Blackburrow is northwest of here. <Bark!> But I wouldn't go there $name. They don't like folks like you very much. I wish they were not so <BARK!> stubborn.");
	}
	elsif ($text=~/cleet|father/i) {
		quest::say("Cleet and Henina Miller are the only parents I have ever known. They found me hurt in their field and raised me as if I was one of their own children. I love them very much. I don't remember my true parents at all but I know they came from Blackburrow.");
	}
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}

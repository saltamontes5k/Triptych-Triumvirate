sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Shhhh... Greetings, $name. Welcome to the Library of Erudin. Please respect the other patrons and speak softly.");
	}
	elsif ($text=~/testament of vanear/i) {
		quest::say("Oh my!! You have not heard?! The Testament of Vanear was stolen from the library! It was checked out by a man named Moodoro. He is an Erudite, but I believe he was executed for some crime. Now the book is lost forever. You should speak with Tol Nicelot. He used to know Moodoro. Tol is most likely upstairs.");
	}
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}

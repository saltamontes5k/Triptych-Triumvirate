sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Welcome to the Temple of Divine Light.  We are the Peacekeepers. followers of Quellious.  If you are a paladin of this temple. you can assist us by showing a desire to [protect the peace].");
	}
	elsif ($text=~/protect the peace/i) {
		#:: Match if faction is Amiable or better
		if ($faction <= 4) {
			quest::say("It was a fine decision.  We are in need of your services.  It seems there is a disturbance in Toxxulia Forest.  There are poachers from other nations who have sought to cause turbulence among the creatures there.  Will you help us [catch the poachers]  or are you skeptical about this mission?");
		}
		#:: Match if faction is Indifferent
		elsif ($faction == 5) {
			quest::say("You have not done much to upset the Peacekeepers of this temple, but we must ask you to prove yourself to us before we may discuss things such as this.");
		}
		else {
			quest::say("Leave my sight at once! You are no friend to the Peacekeepers of the Temple of Divine Light.");
		}
	}
	elsif ($text=~/catch the poachers/i) {
		#:: Match if faction is Amiable or better
		if ($faction <= 4) {
			quest::say("The infidels are in Toxxulia Forest.  They have begun hunting the kobolds.  We have no love of the kobolds, but cannot allow the lands of Odus to be overrun by outsiders.  The ways of tranquility are balanced with harmony.  We will not allow chaos to take hold of our land.  Go and find these poachers.  Bring me their heads!!");
		}
		#:: Match if faction is Indifferent
		elsif ($faction == 5) {
			quest::say("You have not done much to upset the Peacekeepers of this temple, but we must ask you to prove yourself to us before we may discuss things such as this.");
		}
		else {
			quest::say("Leave my sight at once! You are no friend to the Peacekeepers of the Temple of Divine Light.");
		}
	}
	elsif ($text=~/skeptical/i) {
		#:: Match if faction is Amiable or better
		if ($faction <= 4) {
			quest::say("The Temple of Divine Light is at your disposal. May you find true peace within our walls.");
		}
		#:: Match if faction is Indifferent
		elsif ($faction == 5) {
			quest::say("You have not done much to upset the Peacekeepers of this temple, but we must ask you to prove yourself to us before we may discuss things such as this.");
		}
		else {
			quest::say("Leave my sight at once! You are no friend to the Peacekeepers of the Temple of Divine Light.");
		}
	}
}

sub EVENT_ITEM {
	#:: Match a 13825 - Poacher's Head
	if (plugin::check_handin(\%itemcount, 13825 => 1)) {
		#:: Match if faction is Amiable or better
		if ($faction <= 4) {
			quest::say("You have served us well. The harmony of the forest shall be preserved. I have word that theses infidels were all working for one man. Find me evidence pertaining to this man. Surely one of these poachers has something which could aid in finding this man. We must stop him to stop the poachers. Go in peace.");
			#:: Give item 10004 - Copper Band
			quest::summonitem(10004);
			#:: Ding!
			quest::ding();
			#:: Set factions
			quest::faction(298, 5); 		#:: + Peace Keepers
			quest::faction(266, 1); 		#:: + High Council of Erudin
			quest::faction(265, -1); 		#:: - Heretics
			#:: Grant a small amount of experience
			quest::exp(500);
			#:: Create a hash for storing cash - 10 to 60cp
			my %cash = plugin::RandomCash(10,60);
			#:: Grant a random cash reward
			quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
		}
		#:: Match if faction is Indifferent
		elsif ($faction == 5) {
			quest::say("You have not done much to upset the Peacekeepers of this temple, but we must ask you to prove yourself to us before we may discuss things such as this.");
			#:: Return a 13825 - Poacher's Head
			quest::summonitem(13825);
		}
		else {
			quest::say("Leave my sight at once! You are no friend to the Peacekeepers of the Temple of Divine Light.");
			#:: Return a 13825 - Poacher's Head
			quest::summonitem(13825);
		}
	}
	#:: Match a 13913 - Barbarian Head
	elsif (plugin::check_handin(\%itemcount, 13913 => 1)) {
		#:: Match if faction is Amiable or better
		if ($faction <= 4) {
			quest::say("It is done! Quellious will look favorably upon our church and we will look favorably upon you. Go in peace");
			#:: Give item 15202 - Spell: Courage
			quest::summonitem(15202);
			#:: Ding!
			quest::ding();
			#:: Set factions
			quest::faction(298, 10); 		#:: + Peace Keepers
			quest::faction(266, 2); 		#:: + High Council of Erudin
			quest::faction(265, -2); 		#:: - Heretics
			#:: Grant a moderate amount of experience
			quest::exp(1000);
			#:: Create a hash for storing cash - 100 to 120cp
			my %cash = plugin::RandomCash(100,120);
			#:: Grant a random cash reward
			quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
		}
		#:: Match if faction is Indifferent
		elsif ($faction == 5) {
			quest::say("You have not done much to upset the Peacekeepers of this temple, but we must ask you to prove yourself to us before we may discuss things such as this.");
			#:: Return a 13913 - Barbarian Head
			quest::summonitem(13913);
		}
		else {
			quest::say("Leave my sight at once! You are no friend to the Peacekeepers of the Temple of Divine Light.");
			#:: Return a 13913 - Barbarian Head
			quest::summonitem(13913);
		}
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}

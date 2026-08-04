sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Peace and tranquility be with you. $name.  Are you a [new acolyte of peace] or are you [here to pay homage] to the child of tranquility?");
	}
	elsif ($text=~/new acolyte of peace/i) {
		quest::say("Then you shall learn the ways of Quellious and learn to do as you are told by higher ranking members. It is time for you to do the lesser duties of a young priest. Which will it be? [Retrieve the Peacekeeper staffs] or [battle the undead]?");
	}
	elsif ($text=~/retrieve the peacekeeper staffs/i) {
		#:: Match if faction is Amiable or better
		if ($faction <= 4) {
			quest::say("Then take this note to the woodworker in Toxxulia Forest. His name is Emil Parsini. He shall have the staff to be returned to the temple.");
			#:: Give item 18833 - A Sealed Letter for Emil Parsini
			quest::summonitem(18833);
		}
		#:: Match if faction is Indifferent
		elsif ($faction == 5) {
			quest::say("You have not done much to upset the Peacekeepers of this temple, but we must ask you to prove yourself to us before we may discuss things such as this.");
		}
		else {
			quest::say("Leave my sight at once!  You are no friend to the Peacekeepers of the Temple of Divine Light.");
		}
	}
	elsif ($text=~/battle the undead/i) {
		#:: Match if faction is Amiable or better
		if ($faction <= 4) {
			quest::say("Then you shall venture to Toxxulia Forest. There has been an increase in skeleton sightings lately. I do not know their origin, but I believe that your efforts will reduce their numbers! Take this box. Return it to me when you have filled it with the bones of these undead creatures and combined it. May Quellious' light guide you.");
			#:: Give item 17941 - Box for Bones
			quest::summonitem(17941);
		}
		#:: Match if faction is Indifferent
		elsif ($faction == 5) {
			quest::say("You have not done much to upset the Peacekeepers of this temple, but we must ask you to prove yourself to us before we may discuss things such as this.");
		}
		else {
			quest::say("Leave my sight at once!  You are no friend to the Peacekeepers of the Temple of Divine Light.");
		}
	}
	elsif ($text=~/important missions/i) {
		#:: Match if faction is Amiable or better
		if ($faction <= 4) {
			quest::say("We have need of skilled priests. We have learned that a High Guard battle staff has been stolen. We require a priest to [track down the staff].");
		}
		#:: Match if faction is Indifferent
		elsif ($faction == 5) {
			quest::say("You have not done much to upset the Peacekeepers of this temple, but we must ask you to prove yourself to us before we may discuss things such as this.");
		}
		else {
			quest::say("Leave my sight at once!  You are no friend to the Peacekeepers of the Temple of Divine Light.");
		}
	}
	elsif ($text=~/track down the staff/i) {
		#:: Match if faction is Amiable or better
		if ($faction <= 4) {
			quest::say("In the mountain keep called High Hold, we have heard there is a person hiring mercenaries for an attempt to obtain a High Guard battle staff. We are missing one of our staffs and believe this person has it. Go to Highpass Hold and find this person. Return the High Guard battle staff to me!");
		}
		#:: Match if faction is Indifferent
		elsif ($faction == 5) {
			quest::say("You have not done much to upset the Peacekeepers of this temple, but we must ask you to prove yourself to us before we may discuss things such as this.");
		}
		else {
			quest::say("Leave my sight at once!  You are no friend to the Peacekeepers of the Temple of Divine Light.");
		}
	}
	elsif ($text=~/here to pay homage/i) {
		quest::say("Then respect our temple and keep your prayers silent.");
	}
}

sub EVENT_ITEM {
	#:: Match a 13882 - Box of Bones
	if (plugin::check_handin(\%itemcount, 13882 => 1)) {
		#:: Match if faction is Amiable or better
		if ($faction <= 4) {
			quest::say("This is fabulous work, my friend! You have served your people well. Take this as a gift. I hope it can be of use to you. We need proof of these skeletons' origins. Continue the eradication of the undead and find out who creates them. Once you know, bring their head to me.");
			#:: Give a random reward:  17005 - Backpack, 17002 - Belt Pouch, 10018 - Hematite, 2144 - Raw-hide Sleeves, 2145 - Raw-hide Wristbands, 2146 - Raw-hide Gloves, 6011 - Rusty Mace, 6016 - Rusty Morning Star, 15203 - Spell: Cure Poison, 15207 - Spell: Divine Aura, 15201 - Spell: Flash of Light, 15209 - Spell: Spook the Dead, 15014 - Spell: Strike, 15205 - Spell: True North, 15210 - Spell: Yaulp, 6012 - Worn Great Staff
			quest::summonitem(quest::ChooseRandom(17005, 17002, 10018, 2144, 2145, 2146, 6011, 6016, 15203, 15207, 15201,15208, 15209, 15014, 15205, 15210, 6012));
			#:: Ding!
			quest::ding();
			#:: Set factions
			quest::faction(298, 10);	 	#:: + Peace Keepers
			quest::faction(266, 2); 		#:: + High Council of Erudin
			quest::faction(265, -2); 		#:: - Heretics
			#:: Grant a small amount of experience
			quest::exp(200);
			#:: Create a hash for storing cash - 400 to 450cp
			my %cash = plugin::RandomCash(400,450);
			#:: Grant a random cash reward
			quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
		}		
		#:: Match if faction is Indifferent
		elsif ($faction == 5) {
			quest::say("You have not done much to upset the Peacekeepers of this temple, but we must ask you to prove yourself to us before we may discuss things such as this.");
			#:: Return a 13882 - Box of Bones
			quest::summonitem(13882);
		}
		else {
			quest::say("Leave my sight at once!  You are no friend to the Peacekeepers of the Temple of Divine Light.");
			#:: Return a 13882 - Box of Bones
			quest::summonitem(13882);
		}
	}
	#:: Match a 13816 - Peacekeeper staff
	elsif (plugin::check_handin(\%itemcount, 13816 => 1)) {
		#:: Match if faction is Amiable or better
		if ($faction <= 4) {
			quest::say("You have done well, neophyte. Let me add the touch of harmony to finish the job.. Here, then. Take these supplies. I am sure you'll need them. Soon you may be able to assist us in [important missions]");
			#:: Give a random reward:  17005 - Backpack, 17002 - Belt Pouch, 10018 - Hematite, 2144 - Raw-hide Sleeves, 2145 - Raw-hide Wristbands, 2146 - Raw-hide Gloves, 6011 - Rusty Mace, 6016 - Rusty Morning Star, 6012 - Worn Great Staff
			quest::summonitem(quest::ChooseRandom(17005, 17002, 10018, 2144, 2145, 2146, 6011, 6016, 6012));
			#:: Ding!
			quest::ding();
			#:: Set factions
			quest::faction(298, 10);	 	#:: + Peace Keepers
			quest::faction(266, 2); 		#:: + High Council of Erudin
			quest::faction(265, -2); 		#:: - Heretics
			#:: Grant a small amount of experience
			quest::exp(600);
			#:: Create a hash for storing cash - 100 to 150cp
			my %cash = plugin::RandomCash(100,150);
			#:: Grant a random cash reward
			quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
		}
		#:: Match if faction is Indifferent
		elsif ($faction == 5) {
			quest::say("You have not done much to upset the Peacekeepers of this temple, but we must ask you to prove yourself to us before we may discuss things such as this.");
			#:: Return a 13816 - Peacekeeper staff 
			quest::summonitem(13816);
		}
		else {
			quest::say("Leave my sight at once!  You are no friend to the Peacekeepers of the Temple of Divine Light.");
			#:: Return a 13816 - Peacekeeper staff
			quest::summonitem(13816);
		}
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}

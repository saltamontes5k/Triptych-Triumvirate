sub EVENT_SPAWN {
	#:: Create a proximity, 100 units across, 100 units tall, without proximity say
	quest::set_proximity($x - 50, $x + 50, $y - 50, $y + 50, $z - 50, $z + 50, 0);
}

sub EVENT_ENTER {
	#:: Match a 18725 - Tattered Note
	if (plugin::check_hasitem($client, 18725)) {
		$client->Message(15,"Weligon Steelherder tells you, 'Greetings, A young recruit perhaps? I am Weligon Steelherder, Guild Master of the Deepwater Knights. Read the note in your inventory and then hand it to me when you are ready to begin your training. Truth awaits!'");
	}
}

sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Hail, $name! This is the Deepwater Temple. Here you shall find the wisdom and courage of Prexus, the Ocean Lord. I am glad to see you have an interest. Forgive me if I cut our conversation short, but I have many [Deepwater tasks] to complete.");
	}
	elsif ($text=~/deepwater tasks/i) {
		#:: Match if faction is Amiable or better
		if ($faction <= 4 ) {
			quest::say("We here at the Deepwater Temple must tend to the [Peacekeeper battlestaff] and the [Deepwater harpoon] as well as other duties such as [ocean protection]. There is always something we must do.");
		}
		#:: Match if faction is Indifferent
		elsif ($faction == 5 ) {
			quest::say("There is no reason to dislike you, but we of the Deepwater Knights must see more done for our cause before we truly accept you.");
		}
		else {
			quest::say("We, the Deepwater Knights, know of your vile ways. You had best leave while you can.");
		}
	}
	elsif ($text=~/peacekeeper battlestaff/i) {
		#:: Match if faction is Amiable or better
		if ($faction <= 4 ) {
			quest::say("Every sentinel in Erudin carries a High Guard battlestaff.  The creation of these weapons is the duty of the Deepwater Temple and the Temple of Divine Light.  Our portion of the task is to send young members to [collect the Pearls of Odus].  These are imbedded into the staff and used to store mystical power.");
		}
		#:: Match if faction is Indifferent
		elsif ($faction == 5 ) {
			quest::say("There is no reason to dislike you, but we of the Deepwater Knights must see more done for our cause before we truly accept you.");
		}
		else {
			quest::say("We, the Deepwater Knights, know of your vile ways. You had best leave while you can.");
		}
	}
	if ($text=~/ocean protection/i) {
		#:: Match if faction is Amiable or better
		if ($faction <= 4 ) {
			quest::say("In the name of Prexus, we are sworn to protect all ocean creatures.  We have heard reports of a shark carrying a deadly malady.  We believe she is pregnant.  If she delivers her young to the ocean, it will endanger all other creatures.  We need to find a young paladin to [hunt the diseased shark].");
		}
		#:: Match if faction is Indifferent
		elsif ($faction == 5 ) {
			quest::say("There is no reason to dislike you, but we of the Deepwater Knights must see more done for our cause before we truly accept you.");
		}
		else {
			quest::say("We, the Deepwater Knights, know of your vile ways. You had best leave while you can.");	
		}
	}
	elsif ($text=~/hunt the diseased shark/i) {
		#:: Match if faction is Amiable or better
		if ($faction <= 4 ) {
			quest::say("Ah, yes!  Take this bag with you.  When you have collected the remains of the diseased shark and no fewer than three of her young in it, combine them in it and return it to me.  Then, you shall get your reward.");
			#:: Give item 17938 - Empty Shark Bag
			quest::summonitem(17938);
		}
		#:: Match if faction is Indifferent
		elsif ($faction == 5 ) {
			quest::say("There is no reason to dislike you, but we of the Deepwater Knights must see more done for our cause before we truly accept you.");
		}
		else {
			quest::say("We, the Deepwater Knights, know of your vile ways. You had best leave while you can.");	
		}
	}
	elsif ($text=~/collect the pearls of odus/i) {
		#:: Match if faction is Amiable or better
		if ($faction <= 4 ) {
			quest::say("Then venture to the harbor of Erudin. There, you shall dive into the shark-infested water and search for the Pearls of Odus. They lie upon the grounds of our waters.  Fill the bag I have given you, combine it, and return it to me.  Good luck.");
			#:: Give item 17939 - Empty  Bag
			quest::summonitem(17939);
		}
		#:: Match if faction is Indifferent
		elsif ($faction == 5 ) {
			quest::say("There is no reason to dislike you, but we of the Deepwater Knights must see more done for our cause before we truly accept you.");
		}
		else {
			quest::say("We, the Deepwater Knights, know of your vile ways. You had best leave while you can.");	
		}
	}
	elsif ($text=~/deepwater harpoon/i) {
		#:: Match if faction is Amiable or better
		if ($faction <= 4 ) {
			quest::say("We do not award the Deepwater harpoon to just any paladin. Nobility is all well and good, but you must still prove yourself. We have heard rumors of a very distressing matter. Perhaps it is your calling. Are you ready to [prove allegiance to Erudin] and earn the Deepwater harpoon?");
		}
		#:: Match if faction is Indifferent
		elsif ($faction == 5 ) {
			quest::say("There is no reason to dislike you, but we of the Deepwater Knights must see more done for our cause before we truly accept you.");
		}
		else {
			quest::say("We, the Deepwater Knights, know of your vile ways. You had best leave while you can.");	
		}
	}
	elsif ($text=~/prove allegiance to erudin/i) {
		#:: Match if faction is Amiable or better
		if ($faction <= 4 ) {
			quest::say("Yes, you are ready. We have heard rumors of a great bridge which will connect Antonica with Odus!! This must not happen! We must shield ourselves from the savage and evil ways of the other races. They say that a list exists. A list of three grand architects who wish to see this bridge erected. You will venture to Qeynos and find the list, then exterminate these three men. Return the list along with their heads and the Deepwater Harpoon is yours. Go!!");
		}
		#:: Match if faction is Indifferent
		elsif ($faction == 5 ) {
			quest::say("There is no reason to dislike you, but we of the Deepwater Knights must see more done for our cause before we truly accept you.");
		}
		else {
			quest::say("We, the Deepwater Knights, know of your vile ways. You had best leave while you can.");	
		}
	}
}

sub EVENT_ITEM {
	#:: Match a 18725 - Tattered Note
	if (plugin::check_handin(\%itemcount, 18725 => 1)) {
		quest::say("Greetings and welcome to the Deepwater Knights. Here is your guild tunic. Wear it with pride, and Prexus will keep a watchful eye on you. Go find sister Laoni, she will help you get started with your studies.");
		#:: Give a 13544 - Old Blue Tunic*
		quest::summonitem(13544);
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(242, 100);	 		#:: + Deepwater Knights
		quest::faction(266, 15); 			#:: + High Council of Erudin
		quest::faction(265, -15); 			#:: - Heretics
		#:: Grant a small amount of experience
		quest::exp(100);
	}
	#:: Match a 13876 - Bag of Shark remains
	elsif (plugin::check_handin(\%itemcount, 13876 => 1)) {
		#:: Match if faction is Amiable or better
		if ($faction <= 4 ) {
			quest::say("Very good, my dear young follower of Prexus. You will learn that swimming is a strong skill among the Deepwater Knights. Keep this up and you may wield a Deepwater harpoon soon enough. For now, you shall wear this barnacle breastplate. It is strong enough to aid a young knight in his quest for perfection.");
			#:: Give a 12194 - Barnacle Breastplate
			quest::summonitem(12194);
			#:: Ding!
			quest::ding();
			#:: Set factions
			quest::faction(242, 20);	 	#:: + Deepwater Knights
			quest::faction(266, 3); 		#:: + High Council of Erudin
			quest::faction(265, -3); 		#:: - Heretics
			#:: Grant a small amount of experience
			quest::exp(100);
		}
		#:: Match if faction is Indifferent
		elsif ($faction == 5 ) {
			quest::say("There is no reason to dislike you, but we of the Deepwater Knights must see more done for our cause before we truly accept you.");
			#:: Return a 13876 - Bag of Shark remains
			quest::summonitem(13876);
		}
		else {
			quest::say("We, the Deepwater Knights, know of your vile ways. You had best leave while you can.");	
			#:: Return a 13876 - Bag of Shark remains
			quest::summonitem(13876);
		}
	}
	#:: Match a 13879 - Full bag of pearls
	elsif (plugin::check_handin(\%itemcount, 13879 => 1)) {
		#:: Match if faction is Amiable or better
		if ($faction <= 4 ) {
			quest::say("Fine work, Deepwater Knight. You have proven yourself an excellent addition to our ranks. These shall be used to create more Peacekeeper staffs. Oh yes, I almost forgot your reward. Here you are. Now, go, and serve Prexus.");
			#:: Give a random reward: 2104 - Patchwork Tunic, 2106 - Patchwork Cloak, 2108 - Patchwork Sleeves, 2111 - Patchwork Pants, 2112 - Patchwork Boots
			quest::summonitem(quest::ChooseRandom(2104, 2106, 2108, 2111, 2112));
			#:: Ding!
			quest::ding();
			#:: Set factions
			quest::faction(242, 5);	 		#:: + Deepwater Knights
			quest::faction(266, 1); 		#:: + High Council of Erudin
			quest::faction(265, -1); 		#:: - Heretics
			#:: Grant a small amount of experience
			quest::exp(100);
		}
		#:: Match if faction is Indifferent
		elsif ($faction == 5 ) {
			quest::say("There is no reason to dislike you, but we of the Deepwater Knights must see more done for our cause before we truly accept you.");
			#:: Return a 13879 - Full bag of pearls
			quest::summonitem(13879);
		}
		else {
			quest::say("We, the Deepwater Knights, know of your vile ways. You had best leave while you can.");	
			#:: Return a 13879 - Full bag of pearls
			quest::summonitem(13879);
		}
	}
	#:: Match a 18835 - Sealed List, a 13838 - Human Decapitated Head, a 13839 - Dwarf Decapitated Head, and a 13840 - Gnome Decapitated Head
	elsif (plugin::check_handin(\%itemcount, 18835 => 1, 13838 => 1, 13839 => 1, 13840 => 1)) {
		#:: Match if faction is Amiable or better
		if ($faction <= 4 ) {
			quest::say("It is done!! I pray to Prexus that the knowledge of the bridge's design has departed from this world with the passing of these intelligent men. A pity they had to die. As for you, the other states may not tolerate your presence any longer, but you have proven that allegiance to Erudin is paramount among all Erudites. I am afraid the [Deepwater harpoon] is no more!! I bestow upon you Deep Six, my personal cutlass!! May you wield it in the name of Erudin.");
			#:: Give a 5377 - Deep Six Cutlass
			quest::summonitem(15377);
			#:: Ding!
			quest::ding();
			#:: Set faction
			quest::faction(242, 25); 		#:: + Deepwater Knights
			quest::faction(266, 3); 		#:: + High Council of Erudin
			quest::faction(265, -3); 		#:: - Heretics
			#:: Grant a small amount of experience
			quest::exp(100);
		}
		#:: Match if faction is Indifferent
		elsif ($faction == 5 ) {
			quest::say("There is no reason to dislike you, but we of the Deepwater Knights must see more done for our cause before we truly accept you.");
			#:: Return a 18835 - Sealed List, a 13838 - Human Decapitated Head, a 13839 - Dwarf Decapitated Head, and a 13840 - Gnome Decapitated Head
			quest::summonitem(18835);
			quest::summonitem(13838);
			quest::summonitem(13839);
			quest::summonitem(13840);
		}
		else {
			quest::say("We, the Deepwater Knights, know of your vile ways. You had best leave while you can.");	
			#:: Return a 18835 - Sealed List, a 13838 - Human Decapitated Head, a 13839 - Dwarf Decapitated Head, and a 13840 - Gnome Decapitated Head
			quest::summonitem(18835);
			quest::summonitem(13838);
			quest::summonitem(13839);
			quest::summonitem(13840);
		}
	}
	#:: Return unused items
	plugin::returnUnusedItems();
}

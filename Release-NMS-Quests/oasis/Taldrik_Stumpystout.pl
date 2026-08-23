sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Move along dere yer blocking me view lad. I await me friend that has gone off to fetch me some water. It sure is hot out here.");
	}
	elsif ($text=~/recipe/i) {
		quest::say("Well ya see lad I had an ancient recipe passed down to me that told one how to create the holiest of ale. Its far gone now, however I recently had a vision of the ingredients and where they might be found. Do you wish to seek out the components for me?");
	}
	elsif ($text=~/components/i) {
		quest::say("Excellent lad! Let meh see here if I can remember correctly. I know that you need to Preserved hops and a Battleworn canteen. I know that these were carried by my good friend Torklar back when I was still a young lad in training like you. However one day he adventured to an undead estate with a friend of his that was a very skilled brewer. I believe they went there in search of some ingredients they needed for a recipe however neither of them ever returned. But before you go any further I must tell ye that you will need a specific kind of cask to combine these items in.");
	}
	elsif ($text=~/cask/i) {
		quest::say("Why a holy cask is what ye will need of course! Find the ingredients that I asked you for before and combine them within this holy cask along with barley from the forests of Kithicor and water summoned from none other than yourself. After doing this if the gods have smiled upon you a thick and hearty keg of Brells Blessed Stout will be created. Give this to me along with a Rat sandwich to enjoy while I sip the finest of ales as well as your Initiate symbol that you carry now and I will be sure to reward you.");
		#:: Give a 17070 - Holy Cask
		quest::summonitem(17070);
	}
}

sub EVENT_ITEM {
	#:: Match a 13943 - Freeport Stout, 13036 - Dwarven Ale, 13035 - Elven Wine
	if (plugin::check_handin(\%itemcount, 13943 => 1, 13036 => 1, 13035 => 1)) {
		quest::say("Ah ha! So ye are Bronlor's chosen aye? Well den these fine brews can only mean one thing! Yep its dat youre a drinker like meh! Arg, if I only had me recipe.");
		#:: Ding!
		quest::ding();
		#:: Grant a small amount of experience
		quest::exp(100);
	}
	#:: Match a 2440 - Keg of Brells Blessed Stout, 13474 - Rat Sandwich, 1430 - Initiate Symbol of Brell Serilis
	elsif (plugin::check_handin(\%itemcount, 2440 => 1, 13474 => 1, 1430 => 1)) {
		quest::say("Ye are a true Priest of Brell Serillis! And ye make me both proud and happy to have met ye so that I could enjoy this sweet drink once again! Please take this Initiate Symbol of Brell Serillis which will I have crafted to enable you to turn water into this blessed ale for you have truly earned it!");
		#:: Give a 1431 - Disciple Symbol of Brell Serilis
		quest::summonitem(11431);
		#:: Ding!
		quest::ding();
		#:: Grant a small amount of experience
		quest::exp(100);
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}

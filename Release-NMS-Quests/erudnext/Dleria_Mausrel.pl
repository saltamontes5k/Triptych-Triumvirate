sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Hail! You appear to be a [new priest]. Ah, I so enjoy the presence of youth within Deepwater Temple. I am sure Prexus is smiling upon us as we speak.");
	}
	elsif ($text=~/new priest/i) {
		#:: Match if faction is Amiable or better
		if ($faction <= 4) {
			quest::say("As I suspected. I shall assist you with your training and you shall assist the temple with your service. A young priest can help out by asking to [convert fishermen in Qeynos] or maybe even something truly great such as requesting to [protect the depths].");
		}
		#:: Match if faction is Indifferent
		elsif ($faction == 5) {
			quest::say("There is no reason to dislike you, but we of the Deepwater Knights must see more done for our cause before we truly accept you.");
		}
		else {
			quest::say("We, the Deepwater Knights, know of your vile ways. You had best leave while you can.");
		}
	}
	elsif ($text=~/convert fishermen in qeynos/i) {
		#:: Match if faction is Amiable or better
		if ($faction <= 4) {
			quest::say("So you wish to journey to Qeynos? So be it. Go to Qeynos and find me a willing convert. Ask them if they wish the blessing of Prexus. If so, they should snap their pole in two and you will return it to me. Do this and be rewarded.");
		}
		#:: Match if faction is Indifferent
		elsif ($faction == 5) {
			quest::say("There is no reason to dislike you, but we of the Deepwater Knights must see more done for our cause before we truly accept you.");
		}
		else {
			quest::say("We, the Deepwater Knights, know of your vile ways. You had best leave while you can.");
		}
	}
	elsif ($text=~/protect the depths/i) {
		#:: Match if faction is Amiable or better
		if ($faction <= 4) {
			quest::say("We have heard of zombies inhabiting the depths of Erud's Crossing. Go and seek them out. Destroy them. This evil should not exist within the realm of the Ocean Lord. Take this bag. Fill it with their rotting flesh. combine it and return it to me. May Prexus guide you.");
			#:: Give a 17939 - Empty Bag (*Zombie Flesh Bag)
			quest::summonitem(17939);
		}
		#:: Match if faction is Indifferent
		elsif ($faction == 5) {
			quest::say("There is no reason to dislike you, but we of the Deepwater Knights must see more done for our cause before we truly accept you.");
		}
		else {
			quest::say("We, the Deepwater Knights, know of your vile ways. You had best leave while you can.");
		}
	}
}

sub EVENT_ITEM {
	#:: Match a 13922 - Snapped Pole
	if (plugin::check_handin(\%itemcount, 13922 => 1)) {
		#:: Match if faction is Amiable or better
		if ($faction <= 4) {
			quest::say("Good work, young priest. Soon you shall carry the word of the Ocean Lord to distant lands. For now, continue your training. As for your reward, I have this which has been sitting in our vault. I hope it can be of use to a young priest such as yourself.");
			#:: Give a random reward: 2144 - Raw-hide Sleeves, 2146 - Raw-hide Gloves, 2147 - Raw-hide Leggings, 17005 - Backpack
			quest::summonitem(quest::ChooseRandom(2144, 2146, 2147, 17005));
			#:: Ding!
			quest::ding();
			#:: Set factions
			quest::faction(242, 5);			#:: + Deepwater Knights
			quest::faction(266, 1);			#:: + High Council of Erudin
			quest::faction(265, -1);		#:: - Heretics
			#:: Grant a small amount of experience
			quest::exp(100);
			#:: Create a hash for storing cash - 450 to 550cp
			my %cash = plugin::RandomCash(450,550);
			#:: Grant a random cash reward
			quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
		}
		#:: Match if faction is Indifferent
		elsif ($faction == 5) {
			quest::say("There is no reason to dislike you, but we of the Deepwater Knights must see more done for our cause before we truly accept you.");
			#:: Return a 13922 - Snapped Pole
			quest::summonitem(13922);
		}
		else {
			quest::say("We, the Deepwater Knights, know of your vile ways. You had best leave while you can.");
			#:: Return a 13922 - Snapped Pole
			quest::summonitem(13922);
		}
		
	}
	#:: Match a 13880 - Bag of Zombie Flesh
	elsif (plugin::check_handin(\%itemcount, 13880 => 1)) {
		#:: Match if faction is Amiable or better
		if ($faction <= 4) {
			quest::say("Peeuww!! That most certainly is zombie flesh!! Here is your reward. You have done a fine service in the name of Prexus. Soon you shall advance and we may tell you of greater dangers lurking in the depths.");
			#:: Ding!
			quest::ding();
			#:: Set factions
			quest::faction(242, 10);		#:: + Deepwater Knights
			quest::faction(266, 1);			#:: + High Council of Erudin
			quest::faction(265, -1);		#:: - Heretics
			#:: Grant a small amount of experience
			quest::exp(100);
			#:: Create a hash for storing cash - 350 to 450cp
			my %cash = plugin::RandomCash(350,450);
			#:: Grant a random cash reward
			quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
		}
		#:: Match if faction is Indifferent
		elsif ($faction == 5) {
			quest::say("There is no reason to dislike you, but we of the Deepwater Knights must see more done for our cause before we truly accept you.");
			#:: Return a 13880 - Bag of Zombie Flesh
			quest::summonitem(13880);
		}
		else {
			quest::say("We, the Deepwater Knights, know of your vile ways. You had best leave while you can.");
			#:: Return a 13880 - Bag of Zombie Flesh
			quest::summonitem(13880);
		}
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}

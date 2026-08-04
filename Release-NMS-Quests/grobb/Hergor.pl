sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Whats you wants! Me great master of da bashers. Me tinks yooz must be lookin' fer trainin'. Yooz looks like a weaklin'. Me train yooz and yooz helps me get fatter. Well! Are yooz gonna [helps Hergor get fatter]?!");
	}
	elsif ($text=~/helps hergor get fatter/i || $text=~/help hergor get fatter/i) {
		#:: Match if faction is Amiable or better
		if ($faction <= 4) {
			quest::say("Yooz makes da good choice.  Me nevers get enuff ta eats.  Eats more and gets more stronger, me always say.  Yooz gos and speaks wit carver Cagrek.  Yooz tell him Hergor wants his [fungus dung pie].  Yooz duz dis and me gives you sum rawhide armer or tatters armer.");
		}
		#:: Match if faction is indifferent
		elsif ($faction == 5) {
			quest::say("More service to da bashers, den me listen.");
		}
		#:: Match if faction is worse than indifferent
		else {
			quest::say("Me smell death coming your way!  Da bashers no like you. Hey!  Me am basher!");
		}
	}
}

sub EVENT_ITEM {
	#:: Match a 12210 - Fungus Dung Pie
	if (plugin::check_handin(\%itemcount, 12210 => 1)) {
		quest::say("Mmmmm..Mm..Mmm!!! Dat smells gud!! Me gets more fat and get more strength. You dus gud job weekiling. Me gives you dis armer. Now gos away. Me no share pie wit weekling.");
		#:: Give a random reward: 2125 - Large Tattered Skullcap, 2126 - Large Tattered Mask, 2127 - Large Tattered Gorget, 2129 - Large Tattered Shoulderpads, 2131 - Large Tattered Belt, 2133 - Large Tattered Wristbands, 2134 - Large Tattered Gloves, 2161 - Large Raw-hide Skullcap, 2162 - Large Raw-hide Mask
		#:: 2163 - Large Raw-hide Gorget, 2164 - Large Raw-hide Tunic, 2165 - Large Raw-hide Shoulderpads, 2166 - Large Raw-hide Cloak, 2167 - Large Raw-hide Belt, 2168 - Large Raw-hide Sleeves, 2169 - Large Raw-hide Wristbands, 2170 - Large Raw-hide Gloves, 2171 - Large Raw-hide Leggings, 2172 - Large Raw-hide Boots
		quest::summonitem(quest::ChooseRandom(2125, 2126, 2127, 2129, 2131, 2133, 2134, 2161, 2162, 2163, 2164, 2165, 2166, 2167, 2168, 2169, 2170, 2171, 2172));
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(235, 5);		#:: + Da Bashers
		quest::faction(222, -1);	#:: - Broken Skull Clan
		#:: Grant a small amount of experience
		quest::exp(145);
		#:: Create a hash for storing cash - 150 to 250cp
		my %cash = plugin::RandomCash(150,250);
		#:: Grant a random cash reward
		quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}

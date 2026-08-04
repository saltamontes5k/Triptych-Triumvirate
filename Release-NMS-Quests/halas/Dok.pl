sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Fine day to ye, $name.  Welcome to me shop.  If ye're searchin' fer a [cigar], ye won't be findin' any, more's th' pity.");
	}
	elsif ($text=~/cigar/i) {
		quest::say("I was hoping to perfect me creation I was callin' the 'cigar.' but I'm afraid I just couldn't get it right.  To keep from settin' meself on fire, I switched me talents to makin' candles.  I could use help from a person such as yerself.  Ye could [collect the wax] fer me - the candle-makin's.");
	}
	elsif ($text=~/collect the wax/i) {
		quest::say("Grreatt!!  Take this wax jarr.  Head to any place ye can find the wee ones they call bixies. I'm afraid ye're going to hafta bash 'em and search to find out if they're carrying any honeycombs.  If they are, then ye can fill the jar with them and combine them, then return the full honeycomb jar to me. I'll be givin' ye a special candle if ye can do that fer me.");
		#:: Give a 17958 - Empty Jar
		quest::summonitem(17958);
	}
	elsif ($text=~/crime/i) { 
		quest::say("Aye. I happened upon the crime scene, but too late, more's the pity.  I grabbed fer one of the rogues and got only a handful of his shirt.  Before I knew it, I was left holding his sweaty shirt and he was far from the scene.  I called fer the guards and they summoned the shaman.  Methinks one died and one got away in the chase.  I've heard rumors that the leader of [Clan McMannus] has spotted the culprit.  Ye should go to the leader of Clan McMannus and tell him ye're [searching for the fugitive].");
	}
	elsif ($text=~/clan mcmannus/i) {
		quest::say("Methinks it is Einhorst McMannus.");
	}
	elsif ($text=~/sweaty/i) {
		quest::say("Now, why would ye be wantin' that smelly thing?!!  I no longer have it.  [Tundra Jack] came into me shop and bought it from me.  He says he can wash it good and make a new collar for Iceberg out of it.");
	}
	elsif ($text=~/tundra jack/i) {
		quest::say("Well, now, let's see...  His name is Tundra Jack.. me first guess would be that ye might find him on the frozen tundra of Everfrost, eh?");
	}
	elsif ($text=~/candle of bravery/i) {
		quest::say("I can make ye a Candle o' Bravery. I'll need th' candlestick, or pieces of it!! And I need a honeycomb. Oh!! And I need a pouch o' Underfoot soil as well.");
	}
}

sub EVENT_ITEM {
	#:: Match a 12222 - Full Honeycomb Jar
	if (plugin::check_handin(\%itemcount, 12222 => 1)) {
		quest::say("Great work!! Now I can make more candles! Here ye are, me friend. I call this the Everburn Candle. It has a wee bit o' magic in it. I hope ye like it.");
		#:: Give a 12220 - Everburn Candle
		quest::summonitem(12220);
		#:: Ding!
		quest::ding();
		#:: Set Factions
		quest::faction(328, 25); 	#:: + Merchants of Halas
		quest::faction(320, 18);	#:: + Wolves of the North
		quest::faction(327, 18);	#:: + Shamen of Justice
		#:: Grant a small amount of experience
		quest::exp(250);
		#:: Create a hash for storing cash - 900 to 1100cp
		my %cash = plugin::RandomCash(900,1100);
		#:: Grant a random cash reward
		quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
	}
	#:: Match 12275 - Foot of Candlestick, 12276 - Stem of Candlestick, 12282 - Soil of Underfoot and 13953 - Honeycomb
	elsif (plugin::check_handin(\%itemcount, 12275 => 1, 12276 => 1, 12282 => 1, 13953 => 1)) {
		quest::say("Here is your Candle o' Bravery.");
		#:: Give a 12277 - Candle of Bravery
		quest::summonitem(12277);
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(328, 5); 	#:: + Merchants of Halas
		quest::faction(320, 3);		#:: + Wolves of the North
		quest::faction(327, 3);		#:: + Shamen of Justice
		#:: Grant a large amount of experience
		quest::exp(50000);
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}

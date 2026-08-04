sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Greetings, $name!  To enter these grounds is to proclaim your faith in the Truthbringer.  In this city you shall find no greater allies than the Knights of Truth.  We urge all knights and clerics who oppose the hand of the Freeport Militia to [join the crusade].");
	}
	elsif ($text=~/friend of arathur/i) {
		quest::say("Oh! You hail from Qeynos, do you? How is old Arathur? He probably has told you about some of the troubles we are having here. Are you looking to [join the crusade] against the Freeport Militia?");
	}
	elsif ($text=~/join the crusade/i) {
		quest::say("Then take arms against the Freeport Militia!  They serve no one save Sir Lucan, the fallen knight.  From this day forth, I put a bounty upon all militia members.  For every bashed milita helm, a reward!!  If you are not prepared to battle the militia just yet, you may [assist in other areas].");
	}
	elsif ($text=~/assist in other areas/i) {
		quest::say("I have need of one such as you.  I have been awaiting a message. I will need a young acolyte to [retrieve the message] for me or there are also some [fishing duties] I wish to delegate.");
	}
	elsif ($text=~/retrieve the message/i) {
		quest::say("Thank you, $name. Venture to the Commonlands.  There, by a lake, will be a courier from the great city of Qeynos.  Tell him you are from the Hall of Truth.  He will have a message for you to deliver to Eestyana Naestra.");
	}
	elsif ($text=~/fishing duties/i) {
		quest::say("I have been creating shields for the crusade.  Right now I work on the sharkskin shield for the knights.  I require two shark skins. Unfortunately, most sharks are too dangerous for the squires.  I have begun using [reef shark] skins.  Will you hunt the reef sharks?");
	}
	elsif ($text=~/reef shark/i) {
		quest::say("Reef sharks are the smallest and most docile of the sharks.  Even a young acolyte can slay one.  I have heard there are some in the Ocean of Tears.  I need a young acolyte to [hunt] reef sharks.  I require their skins.?");
	}
	elsif ($text=~/hunt/i) {
		quest::say("I thought I spied the shoulders of a swimmer upon you! Take this large sack. Travel to the Ocean of Tears. There are numerous reef sharks there. I shall require no fewer than two shark skins. When the full sack is combined and returned to me, I shall reward you.");
		#:: Summon 17937 - Empty Shark Sack
		quest::summonitem(17937);
	}
}

sub EVENT_ITEM {
	#:: Match a 13921 - Damaged Militia Helm
	if (plugin::check_handin(\%itemcount, 13921 => 1)) {
		quest::say("Fantastic work, my young knight.  Here is a small token of the my appreciation.  I would offer you a sharkskin shield, but I have made only a few and the paladins are testing them.");
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(281, 25); 		#:: + Knights of Truth
		quest::faction(362, 5); 		#:: + Priests of Marr
		quest::faction(311, 2); 		#:: + Steel Warriors
		quest::faction(271, -3); 		#:: - Dismal Rage
		quest::faction(330, -3); 		#:: - Freeport Militia
		#:: Grant a small amount of experience
		quest::exp(500);
		#:: Create a hash for storing cash - 2500 to 3500cp
		my %cash = plugin::RandomCash(2500,3500);
		#:: Grant a random cash reward
		quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
	}
	#:: Match a 13873 - Sack of Sharkskins
	elsif (plugin::check_handin(\%itemcount, 13873 => 1)) {
		quest::say("Fantastic work, my young knight. Here is a small token of my appreciation -- a fine Sharkskin Shield. It should serve you well in battle.");
		#:: Give a 13868 - Sharkskin Shield
		quest::summonitem(13868);
		#:: Ding!
		quest::ding();
		#:: Confirmed no faction reward
		#:: Grant a small amount of experience
		quest::exp(500);
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}

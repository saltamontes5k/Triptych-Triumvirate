sub EVENT_SPAWN {
	#:: create a timer called 'visit' that triggers every 600 seconds (10 min)
	quest::settimer("visit", 600);
}

sub EVENT_TIMER {
	#:: Match timer 'visit'
	if ($timer eq "visit") {
		#:: Stop the timer 'visit' from triggering
		quest::stoptimer("visit");
		#:: Depop
		quest::depop();
	}
}

sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Didn't your mother teach you not to walk in other people's rooms without knocking?! You didn't even have the courtesy to close the door behind you!!");
	}
	elsif ($text=~/princess lenya thex/i) {
		quest::say("What?!!  You have word of the Princess?  She has been missing for quite a while.  I sent Tearon to Tunaria to search for her, but he has not reported back.  If you wish to help, you'd better prove yourself worthy first. I believe you should talk to Tynkale.");
	}
	elsif ($text=~/the glory of the mother shines bright/i) {
		#:: Match if faction is Amiable or better
		if ($faction <= 4) {
			quest::say("So you're the slayer of Jojongua. Funny, I thought you would be taller. I guess you will have to do. I am Tolon Nurbyte of the Silent Watch. We do all the dirty work of King Tearis Thex. No one knows of us. So I hope you accept this mission or I will have to kill you. Do you [accept the mission] or do you [wish to leave]?");
		}
		else {
			quest::say("When you have furthered your service to the Paladins of Tunare, we shall make conversation.");
		}
	}
	elsif ($text=~/wish to leave/i) {
		#:: Match if faction is Amiable or better
		if ($faction <= 4) {
			quest::say("There is only insufferable labor and merciless torment here, stranger. Kaya Rishareth has condemned her eternal self to servitude in the War Forge -- her selfless act malignantly repaid by the gods with this existence. Her spirit died here long ago and her life's effort and struggles were ultimately for naught.");
			#:: Attack the player who triggered the event
			quest::attack($name);
		}
		else {
			quest::say("When you have furthered your service to the Paladins of Tunare, we shall make conversation.");
		}					
	}
	elsif ($text=~/accept the mission/i) {
		#:: Match if faction is Amiable or better
		if ($faction <= 4) {
			quest::say("In her mortal life, Kaya Rishareth was a keeper of tranquility and served her beloved child-like goddess with every fiber of her being. A native to the free city of Freeport, Kaya found herself traveling on her own as soon as her master would allow. Erudin was the destination she chose and it was the temples dedicated to The Tranquil where she sought to learn more about her goddess and perhaps share philosophies and knowledge with the High Men. Erudin received her graciously and for nearly a year, she studied the High Men's way of worship and reverence to their shared deity. However, tranquility is easily disrupted and those who seek it, must also defend it.");			
		}
		else {
			quest::say("When you have furthered your service to the Paladins of Tunare, we shall make conversation.");
		}
	}
	elsif ($text=~/silent watch/i) {
		#:: Match if faction is Amiable or better
		if ($faction <= 4) {
			quest::say("The Silent Watch was established in the early years of Felwithe. King Tearis Thex had many cruel deeds to do. The regular Koad'Vie were too righteous to carry out any of the necessary missions and we dare not bring in the Fier'Dal. After all, some of the operations were against Kelethin.  King Tearis formed our group from Koada'Dal not of such prim and proper breeding. Now we act as his secret guard and report only to him.");
		}
		else {
			quest::say("When you have furthered your service to the Paladins of Tunare, we shall make conversation.");
		}
	}
}

sub EVENT_ITEM {
	#:: Match a 18841 - Sealed Letter
	if (plugin::check_handin(\%itemcount, 18841 => 1)) {
		quest::say("So I see you completed your mission. Good work. You just may be a member of the Silent Watch someday. Well my friend. I will be keeping my eye on you. No doubt we will meet again. Oh, I almost forgot. The Princess wanted you to have this. Now show yourself the door.");
		#:: Give a 13353 - Thex Dagger
		quest::summonitem(13353);
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(5001, 10);			#:: + Anti-Mage
		quest::faction(226, 25); 			#:: + Clerics of Tunare
		quest::faction(279, 25); 			#:: + King Tearis Thex
		#:: Grant a moderate amount of experience
		quest::exp(2000);
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}

sub EVENT_SAY { 
    if($text=~/Hail/i) {
        quest::say("Welcome. friend!  If armor is what you seek. let the house of Gaxx provide you with the finest.  Our metalwork is second to none.  Every now and again we may even create [rare armor] for the general public to purchase.");
        return;
    }
    if($text=~/rare armor?/i) {
        quest::say("I have found many exotic materials in Kunark with which I can create rare armor.  I currently am working on the [Guard of Ik] and the [Hate Tail Guard] shields.  I have no armor as of yet. but I am experimenting with new designs.");
        return;
    }
    if($text=~/guard of ik/i) { # https://wiki.project1999.com/Guard_of_Ik_Quest , Not doable at this time due to a missing spawn on the server
        # quest::say("The Guards of Ik are made from shields found in the jungles.  I would be selling them if it were not for the unfortunate fact that the shields are spectral and vanish overnight.  Another bit of bad news is that the formula I was working on to stabilize the essence of the metal was stolen by local pirates.  I need two more shields and my formula.  Bring these to me and I shall not charge you."); 
        quest::say("I am still working on these special guards, come check back with me at a later time when I am finished."); 
        return;
    }
    if($text=~/hate tail guard/i) { # This quest was never finished on live so we have this so it doesnt lead to a unresponsive NPC https://wiki.project1999.com/Hate_Tail_Guard_Shield
        quest::say("I am still working on these special guards, come check back with me at a later time when I am finished."); 
        return;
    }
}

sub EVENT_ITEM { # You cannot complete this quest right now as the Pirate Cartographer with the Scribbled Note does not spawn
  if(quest::handin({ 12883 => 2, 12971 => 1 })) { # Item(s): Trooper Shield (12883), Scribbled Note (12971)
        quest::emote("places the formula in a box which appears to have similar copies in it.");
        quest::say("Thank you!! I can now reward you with this Guard of Ik shield I had lying around.");
        quest::summonitem(12972); # Item(s): Guard of Ik (12972);
        quest::exp(10000);
        return;
    }
    quest::say("Hey?!! We had a deal!! I get two ik shields and my ik formula!!");
}
#END of FILE Zone:firiona  ID:84185 -- Gearin_Gaxx 
#Author: Shadestrike
#NPCs Involved: Captain Nealith
#Items Involved: A Canine( ItemID#12977)
#Zone: Firiona Vie
##############
# items: 12977, 13155, 18076, 12978

sub EVENT_SAY {
  if($text=~/Hail/i){
    quest::say("Hail. adventurer!! Stand tall and fight for the forest folk and all good races of Norrath. We shall claim this land for the kingdom of Thex! My warriors shall not fail. Already we patrol deepin the wilds of Kunark. We welcome all mercenaries and urge adventurers to [join the defense of the outpost].");
    return;
  }
  if($text=~/join the defense/i){
    quest::say("I salute you!! Join the hunt. Reports from the front line indicate a rise in the drolvarg population. Abandon your fear and slay these beasts for the greater good. Already, they have taken far too many lives, even my [" . quest::saylink("sibling", false, "sibling's") . "]!! I shall pay you your wages upon the return of four drolvarg teeth.");
    return;
  }
  if($text=~/sibling/i){ #Captain Nealith's Brother quest
    quest::emote("appears saddened by the mention of his sibling. 'My brother Marltek has been missing for quite some time. I found coarse Drolvarg hair inside his tent which leads me to believe he has become a meal for the dogs. CURSE THE EVIL DOGS!! I shall see them all dead!!'");
    return;
  }
}

sub EVENT_ITEM {
  if(quest::handin({ 12977 => 4 })){
    quest::emote("tosses the teeth into a very large cask full of similar teeth.");
    quest::say("Fine work, $name. I wish all my own troops showed the same tenacity. I salute you. This will keep you well fed during your long patrols. Use your wages to better equip yourself. Continue the fight!! The General is pleased.");
    quest::summonitem(13155,7); # Item: Elven Trail Mix
    quest::exp(10000);
    quest::givecash(7,12,3,0);
    quest::faction(248,1); #inhabitants of firiona
    quest::faction(326,1); #emerald warriors
    quest::faction(312,1); #storm guard
    quest::faction(441,-3); #legion of cabilis
    quest::faction(313,-3); #pirates of gunthak
    return;
  }
  if (quest::handin({ 18076 => 1 })) { #blood soaked note Captain Nealith's Brother quest
    quest::emote ("nearly faints after reading the letter. 'Dear Marltek!! I shall miss you. There is more evil in this land!! Madness beyond description. Thank you $name. You put my soul at ease and give me new direction. Please accept my brothers blade. He found it in the wilds. May you use it to slay many Drolvarg!!'");
    quest::exp(25580); #no clue actual amount of xp
    quest::givecash(0,0,0,14); #14pp another guess
    quest::summonitem(12978); #Glaive of Marltek
    quest::faction(248,10); #inhabitants of firiona
    quest::faction(326,10); #emerald warriors
    quest::faction(312,10); #storm guard
    quest::faction(441,-30); #legion of cabilis
    quest::faction(313,-30); #pirates of gunthak
    return;
  }
  quest::emote("holds the canine in his palm."); #These next two lines are most likely if you don't turn in enough teeth.
  quest::say("Good work, but you will have to slay more than this to earn your wages.");
} 
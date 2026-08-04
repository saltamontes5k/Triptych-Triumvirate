sub EVENT_SAY {
  if ($text=~/hail/i) {
    quest::say(" Hail $name. I need your [help]...");
  }
  if ($text=~/help/i) {
	quest::say("I wasn't always like this. A cockatrice I mean. I was a guard of Kelethin. It was around this time last year... A band of dark elves attacked, and well, I ran away. Due to my cowardice, [children] died.")
  }  
   if ($text=~/children/i) {
	quest::say("It so happened that one of the children that died was the son of Willaen, the richest man in Kelethin. That bastard must have paid some one to curse me. Look, I know I messed up, but I am desperate for the cure. If you could [assist] me, I would reward you greatly.")
  }
  if ($text=~/assist/i) {
	quest::say("Seek Willaen out. The last time I got close to Kelethin, they tried to kill me.");
  }
}

sub EVENT_ITEM {
  if(plugin::check_handin(\%itemcount, 13227 => 1)){
	quest::summonitem(1399);
  quest::say("That bastard! Cursed to live forever! Without a heart! Well... take this reward. Happy Thanksgiving...")
  }
}






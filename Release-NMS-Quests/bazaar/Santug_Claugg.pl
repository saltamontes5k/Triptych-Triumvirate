sub EVENT_SAY {
  
 
  if ($text=~/hail/i) {
    quest::say(" Hoe Hoe Hoe! Christsmash is rihte around teh corner $name. Wud you check teh [highway] for me before the big day? I ken also helpe wit [birdies]");
  }
  
   if ($text=~/highway/i) {
	quest::say("Miragul ofe corse. How els wud you think I git around? ON REINDER?!... Wile yer lookin, can you kep an eye out for the missus?");
  }
   if ($text=~/birdies/i) {
	quest::say("Gimeh yer guise");
  }
  }



sub EVENT_ITEM {
  if(plugin::check_handin(\%itemcount, 1399 => 1)){
	quest::summonitem(1399);
  quest::say("Merry Christmas $name");
   }

  if(plugin::check_handin(\%itemcount, 12261 => 1)){
	quest::summonitem(31856);
  quest::say("Merry Christmas $name");
   }
    if(plugin::check_handin(\%itemcount, 12262 => 1)){
	quest::summonitem(60398);
  quest::say("Merry Christmas $name");
   }
    if(plugin::check_handin(\%itemcount, 12263 => 1)){
	quest::summonitem(57862);
  quest::say("Merry Christmas $name");
   }
   
    if(plugin::check_handin(\%itemcount, 12264 => 1)){
	quest::summonitem(54978);
  quest::say("Merry Christmas $name");
   }
   
    if(plugin::check_handin(\%itemcount, 12265 => 1)){
	quest::summonitem(26502);
  quest::say("Merry Christmas $name");
   }

   
    if(plugin::check_handin(\%itemcount, 12266 => 1)){
	quest::summonfixeditem(27840);
  quest::say("Merry Christmas $name");
   }

   if(plugin::check_handin(\%itemcount, 67713 => 1)){
	quest::summonitem(995);
  quest::say("This can't be... Well, I always reward a good deed. Here you go. Merry Christmas $name");
   }
   plugin::return_items(\%itemcount);
}







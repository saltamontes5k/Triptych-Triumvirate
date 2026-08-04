
sub EVENT_SPAWN {
  quest::settimer("appearance", 1);
}

sub EVENT_TIMER {
  quest::stoptimer("appearance");
  $npc->SetAppearance(3);
}


sub EVENT_SAY {
    if($text=~/hail/i) {
        quest::say("Hello, $name. If you give me a rose colored or apocryphal iksar hide mask, I can change you permanently into an Iksar.");
    }
}

sub EVENT_ITEM 
{    
    if (plugin::check_handin(\%itemcount, 72741 => 1)  || # Rose Colored Iksar Hide Mask
        plugin::check_handin(\%itemcount, 82741 => 1)) # Apocryphal Iksar Hide Mask
    {
        quest::say("Mmmph!!.. *Pop!!* Ouch, my thumb!! Here you are.");
        quest::say("Cabilis welcomes you.");
        $client->SetBaseRace(128);
        quest::faction(440,2000);
        quest::faction(441,2000);
        quest::faction(442,2000);
        quest::faction(443,2000);
        quest::faction(444,2000);
        quest::faction(445,2000);
        quest::changedeity(203);
        
    }
    plugin::return_items(\%itemcount);
}
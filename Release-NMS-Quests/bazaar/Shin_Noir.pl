sub EVENT_SPAWN {
  quest::settimer("appearance", 1);
}

sub EVENT_TIMER {
  quest::stoptimer("appearance");
  $npc->SetAppearance(1);
}

sub EVENT_SAY {
    if (plugin::IsNMS()) {
        return;
    }

    if($text=~/hail/i) {
        quest::say("Hello, $name. If you give me a rose colored or apocryphal dark elf illusion mask, I can change you permanently into a Dark Elf.");
    }
}

sub EVENT_ITEM 
{    
    if (plugin::IsNMS()) {
        return;
    }


    if (plugin::check_handin(\%itemcount, 1002469 => 1)  || # Rose Colored Guise of the Deceiver
        plugin::check_handin(\%itemcount, 2002469 => 1) || # Apocryphal Guise of the Deceiver
        plugin::check_handin(\%itemcount, 1002472 => 1) || # Rose Colored Mask of Deception
        plugin::check_handin(\%itemcount, 2002472 => 1))   # Apocryphal Mask of Deception
    {
        quest::say("Mmmph!!.. *Pop!!* Ouch, my thumb!! Here you are.");
        quest::say("(Log out to see your changes)");
        quest::permarace(6);
        #$client->SetBaseRace(6);
    }
    plugin::return_items(\%itemcount);
}
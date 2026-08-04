# EPIC CLERIC (Timorous deep)
# items: 28023, 5532

sub EVENT_ITEM {
  if (plugin::check_handin(\%itemcount, 28023 => 1)) { #Orb of the triumvirate
    quest::emote("takes the orb from you. The avatar has determined that you are worthy!");
    quest::summonfixeditem(2005532); # Water Sprinkler of Nem Ankh 
    quest::exp(2000000); 
    quest::ding();
    quest::depop();
  }
  plugin::return_items(\%itemcount); # return unused items
}
#End of File, Zone:timorous  NPC:96086 -- Avatar of Water
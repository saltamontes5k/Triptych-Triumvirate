# Longbrow - Icefall Glacier
# The Serpent's Spine :: Claws of War (600703), Skinning the Mammoth (600708),
#                        Tusks of Battle (600710)

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (!quest::istaskcompleted(600703) && !quest::istaskactive(600703)) {
      quest::say("I [" . quest::saylink("get things") . "] for the camp. Bear claws, mammoth hides, tusks - the ice provides, if you work for it.");
    }
    elsif (!quest::istaskcompleted(600708) && !quest::istaskactive(600708)) {
      quest::say("The [" . quest::saylink("hides") . "] of the great mammoths keep us warm through the long dark.");
    }
    elsif (!quest::istaskcompleted(600710) && !quest::istaskactive(600710)) {
      quest::say("Bring me [" . quest::saylink("tusks") . "] and I will carve a feast worthy of the Nightmoon.");
    }
    else {
      quest::say("The camp eats well because of you, $name.");
    }
  }
  if ($text=~/get things/i && !quest::istaskactive(600703) && !quest::istaskcompleted(600703)) {
    quest::say("Ten bears roam the tundra. Thin them and bring me their claws.");
    quest::assigntask(600703);
  }
  if ($text=~/hides/i && !quest::istaskactive(600708) && !quest::istaskcompleted(600708)) {
    quest::say("Take the hides of ten mammoths. Mind the tusks - those are for the feast.");
    quest::assigntask(600708);
  }
  if ($text=~/tusks/i && !quest::istaskactive(600710) && !quest::istaskcompleted(600710)) {
    quest::say("Four tusks will do. The herds walk the western ice.");
    quest::assigntask(600710);
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}

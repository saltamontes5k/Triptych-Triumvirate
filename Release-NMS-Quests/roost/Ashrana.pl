# Ashrana - Blackfeather Roost
# The Serpent's Spine :: griffon taming / Queen's palace
# Tasks: 600044 Reach the Royal Throne, 600045 Kill the Queen of the Harpies!
# Items: Royal Crest 28672, Royal Emblem 28673

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (!quest::istaskcompleted(600044)) {
      quest::say("There is one snag to our fine plan - reaching my dear older sister the Queen. Only specially trained Royal Griffons can carry you there, and to ride them you need a [" . quest::saylink("Royal Crest") . "].");
    }
    elsif (!quest::istaskcompleted(600045)) {
      quest::say("Now we can finally [" . quest::saylink("accomplish") . "] our goal! Your prize waits for you if you can slay the Queen. Return with proof and I will see that you are rewarded.");
    }
    else {
      quest::say("My sister is dead and the roost is ours. You have my thanks, $name.");
    }
  }
  if ($text=~/Royal Crest/i) {
    if (!quest::istaskactive(600044) && !quest::istaskcompleted(600044)) {
      quest::say("Captain Slarus leads the Queen's personal guard, and she and her lieutenants alone carry the Crests. Kill Slarus and her Royal Guards, and bring me a Crest.");
      quest::assigntask(600044);
    }
    else {
      quest::say("Slarus still holds the Mesa. Bring me a Royal Crest.");
    }
  }
  if ($text=~/accomplish/i) {
    if (quest::istaskcompleted(600044) && !quest::istaskactive(600045) && !quest::istaskcompleted(600045)) {
      quest::say("Queen Eletyl must die. Take the Royal Griffon to her palace, slay her and her guards, and bring me the Royal Emblem as proof.");
      quest::assigntask(600045);
    }
  }
}

sub EVENT_ITEM {
  if (plugin::check_handin(\%itemcount, 28672 => 1)) { #Royal Crest
    quest::say("You have done it. Take the crest, and may the Royal Griffons bear you swiftly.");
  }
  elsif (plugin::check_handin(\%itemcount, 28673 => 1)) { #Royal Emblem
    quest::say("Aha! Well done, $name. Now we can finally accomplish our goal! The roost is ours.");
  }
  plugin::return_items(\%itemcount);
}

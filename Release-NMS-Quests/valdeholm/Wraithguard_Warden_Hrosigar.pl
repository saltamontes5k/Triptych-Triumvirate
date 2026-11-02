# Wraithguard Warden Hrosigar - Valdeholm
# The Serpent's Spine :: Warning Signs (600727), Orcish Dissention (600728)

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (!quest::istaskcompleted(600727) && !quest::istaskactive(600727)) {
      quest::say("The pit breeds vermin faster than we can ward against them. Lend me your blade or your [" . quest::saylink("defenses") . "].");
    }
    elsif (!quest::istaskcompleted(600728) && !quest::istaskactive(600728)) {
      quest::say("The [" . quest::saylink("orcs") . "] of Icefall raise a champion. Silence them before they march.");
    }
    else {
      quest::say("The walls hold, thanks to you.");
    }
  }
  if ($text=~/defenses/i && !quest::istaskactive(600727) && !quest::istaskcompleted(600727)) {
    quest::say("Cull the pit oozes - ten of them - and the wardens can set the warning signs without being eaten.");
    quest::assigntask(600727);
  }
  if ($text=~/orcs/i && !quest::istaskactive(600728) && !quest::istaskcompleted(600728)) {
    quest::say("Thirty Coldeye orcs and their champion Sayrook. Bring the pack down in Icefall and report back.");
    quest::assigntask(600728);
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}

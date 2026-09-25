# Vahna, Dryad of Direwind - Direwind Cliffs
# The Serpent's Spine :: Vahna arc, source raspersrealm open_Direwind:
#   600415 The Direwind Boneyard
#   600217 Direwind #2: The Direwind Plaguebearers (pre-existing)
#   600416 The Direwind Ritual Glade
#   600417 Allies Against the Wind  (rewards Windwillow Leaf + Vengeance)
#   600418 Severan the Windcaller   (raid finale)
# Vahna's Tear (85728) is handed out when 600417 is assigned.

my @chain = (600415, 600217, 600416, 600417, 600418);

sub next_task {
  foreach my $t (@chain) {
    return $t if !quest::istaskcompleted($t);
  }
  return 0;
}

sub EVENT_SAY {
  if ($text=~/hail/i) {
    my $t = next_task();
    if (!$t) {
      quest::say("The winds carry the Direwind's stench no further than the boneyard, $name. Severan's staff lies shattered and the wilds breathe again.");
    }
    elsif ($t == 600415) {
      quest::say("Word of the cliffs' plight has reached even the dryads. The gnolls' [boneyard] churns ceaselessly -- will you help me quiet it?");
    }
    elsif ($t == 600217) {
      quest::say("You have brought hope to this forsaken land. But the [corruption] spreads still.");
    }
    elsif ($t == 600416) {
      quest::say("The ratkin [ritualists] drum in the glade night and day. Their totems feed the Direwind. End them.");
    }
    elsif ($t == 600417) {
      quest::say("There are allies older than any legion sleeping at the spires of [Sunderock Springs]. I would wake them.");
    }
    else {
      quest::say("One [warlord] stands above the gnoll clans. Severan the Direwind Caller. Only his fall will end this.");
    }
  }

  if ($text=~/boneyard/i) {
    if (!quest::istaskactive(600415) && !quest::istaskcompleted(600415)) {
      quest::say("Destroy the stitched golems and the carrionmancers that sew them, and bring me the golem stitching as proof.");
      quest::assigntask(600415);
    }
  }

  if ($text=~/corruption/i) {
    if (quest::istaskcompleted(600415) && !quest::istaskactive(600217) && !quest::istaskcompleted(600217)) {
      quest::say("Kill the Clan Direwind plague bearers and dispel the Direwind Currents. Bring me a Blight Pyre Ember and we will push back the corruption.");
      quest::assigntask(600217);
    }
    else {
      quest::say("The corruption spreads. Kill the plague bearers and dispel the currents.");
    }
  }

  if ($text=~/ritualists/i) {
    if (quest::istaskcompleted(600217) && !quest::istaskactive(600416) && !quest::istaskcompleted(600416)) {
      quest::say("Slay the ratkin and their callers in the glade, destroy Axxanderan's Animated Remains, and bring me four of their rat skull totems.");
      quest::assigntask(600416);
    }
  }

  if ($text=~/Sunderock Springs/i) {
    if (quest::istaskcompleted(600416) && !quest::istaskactive(600417) && !quest::istaskcompleted(600417)) {
      quest::say("Take my tear. At each of the four spires, silence the Keeper who holds the sleep upon the Ancestral Golem, then give the golem my tear. Wake all four and return to me.");
      quest::assigntask(600417);
      quest::summonitem(85728);
    }
  }

  if ($text=~/warlord/i) {
    if (quest::istaskcompleted(600417) && !quest::istaskactive(600418) && !quest::istaskcompleted(600418)) {
      quest::say("He stands amid his four totems above the gnoll camps. The winds he calls will strip the flesh from your bones -- gather strong companions. Bring me his shattered staff.");
      quest::assigntask(600418);
    }
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}

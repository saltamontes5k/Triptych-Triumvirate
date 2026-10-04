# Marilena - Goru`kar Mesa
# The Serpent's Spine :: Windwillow feather and plume tasks (600655-600658).

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (quest::istaskactive(600655)) {
      quest::say("The [feathers], dear. Eight sleek ones, from the mesa griffons.");
    }
    elsif (quest::istaskactive(600656)) {
      quest::say("The [plumes] of the harpies. Eight, and watch their tempers.");
    }
    elsif (quest::istaskactive(600657)) {
      quest::say("The [hunters] and songstresses still circle. They will not miss six of each.");
    }
    elsif (quest::istaskactive(600658)) {
      quest::say("The [watchers] and their griffonmasters. The windwillow thanks you in advance.");
    }
    elsif (!quest::istaskcompleted(600655)) {
      quest::say("Welcome to the Windwillow, traveler. My weavings need [feathers], and the griffons shed plenty.");
    }
    elsif (!quest::istaskcompleted(600656)) {
      quest::say("Griffon feathers weave strong. Harpy [plumes] weave pretty. Eight of those next.");
    }
    elsif (!quest::istaskcompleted(600657)) {
      quest::say("Pretty is not the same as peaceful. The harpies [harass] every walker on these roads.");
    }
    elsif (!quest::istaskcompleted(600658)) {
      quest::say("Birds of a feather flock together, and the [worst] of them guard the high nests.");
    }
    else {
      quest::say("The windwillow is calm when you are near, $name. Sit, rest, listen to the leaves.");
    }
  }
  if ($text=~/feathers/i && !quest::istaskactive(600655) && !quest::istaskcompleted(600655)) {
    quest::say("Pluck eight sleek griffon feathers - the young ones preen and drop them everywhere - then hail me here at the Windwillow.");
    quest::assigntask(600655);
  }
  if ($text=~/plumes/i && quest::istaskcompleted(600655) && !quest::istaskactive(600656) && !quest::istaskcompleted(600656)) {
    quest::say("Collect eight harpy plumes and hail me when your arms are full.");
    quest::assigntask(600656);
  }
  if ($text=~/harass/i && quest::istaskcompleted(600656) && !quest::istaskactive(600657) && !quest::istaskcompleted(600657)) {
    quest::say("Then harp on them a little! Six harpy hunters and six songstresses. Hail me when the skies are quieter.");
    quest::assigntask(600657);
  }
  if ($text=~/worst/i && quest::istaskcompleted(600657) && !quest::istaskactive(600658) && !quest::istaskcompleted(600658)) {
    quest::say("Six harpy watchers and six of their harpy griffonmasters. Birds of a feather, indeed - hail me at the end.");
    quest::assigntask(600658);
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}

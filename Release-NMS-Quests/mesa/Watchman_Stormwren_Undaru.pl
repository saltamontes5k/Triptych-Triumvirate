# Watchman Stormwren Undaru - Goru`kar Mesa
# The Serpent's Spine :: Rites of Passage tasks (600663-600664).

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (quest::istaskactive(600663)) {
      quest::say("The [roost] will test you. Walk its nesting ledges and return to me.");
    }
    elsif (quest::istaskactive(600664)) {
      quest::say("The [hedgehog] of the hotsprings still snorts and stomps. End its reign.");
    }
    elsif (!quest::istaskcompleted(600663)) {
      quest::say("You wish to be counted among the mesa's protectors? Every [rite] begins with a climb.");
    }
    elsif (!quest::istaskcompleted(600664)) {
      quest::say("One rite remains, and it is a [hunt].");
    }
    else {
      quest::say("The watch recognizes you, $name. The mesa is yours to guard now, as much as any man's.");
    }
  }
  if ($text=~/rite/i && !quest::istaskactive(600663) && !quest::istaskcompleted(600663)) {
    quest::say("Search the griffon nesting ledges of Blackfeather Roost, slay three griffon nest guardians, and return to me. The roost does not forgive the careless.");
    quest::assigntask(600663);
  }
  if ($text=~/hunt/i && quest::istaskcompleted(600663) && !quest::istaskactive(600664) && !quest::istaskcompleted(600664)) {
    quest::say("In Sunderock Springs dwells a hotsprings hedgehog of terrible temper and considerable size. Slay it and return with the tale - and the trophy.");
    quest::assigntask(600664);
  }
  if ($text=~/roost/i && quest::istaskactive(600663)) {
    quest::say("East of here. The egg tenders brood on the high ledges, and the guardians watch them jealously.");
  }
  if ($text=~/hedgehog/i && quest::istaskactive(600664)) {
    quest::say("Sunderock Springs, by the boiling springs. Bring back its head as a trophy if you can pry it loose.");
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}

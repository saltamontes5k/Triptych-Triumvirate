# Yavia - The Steppes
# The Serpent's Spine :: Web of Curiosity (task 600603).

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (quest::istaskactive(600603)) {
      quest::say("The [webs] are all curiosity and no caution. Twelve spiders, and I will finally sleep.");
    }
    elsif (!quest::istaskcompleted(600603)) {
      quest::say("The [spiders] here spin all night and I hear every thread. It is maddening.");
    }
    else {
      quest::say("Silence at last, or near enough. The wind, the grass, and no skittering. Thank you, $name.");
    }
  }
  if ($text=~/spiders/i && !quest::istaskactive(600603) && !quest::istaskcompleted(600603)) {
    quest::say("The wasp spiders and their broods nest along the rocks. Slay twelve of them and speak with me. Curiosity killed no one, but the webs may yet.");
    quest::assigntask(600603);
  }
  if ($text=~/webs/i && quest::istaskactive(600603)) {
    quest::say("They nest among the stones south of the gnoll roads. Watch the low places.");
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}

# Hanook - Goru`kar Mesa
# The Serpent's Spine :: satyr task series (tasks 600627-600629).
# The Tuffein stole his lucky trinket and worse; he wants it all back.

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (quest::istaskactive(600627)) {
      quest::say("The [trinket] is out there with the guards. Bring it home.");
    }
    elsif (quest::istaskactive(600628)) {
      quest::say("Their camp lies west, past the widows. Scout it, thin it, and come back breathing.");
    }
    elsif (quest::istaskactive(600629)) {
      quest::say("The [satyrs] of their kind think they own these woods. Show them otherwise.");
    }
    elsif (!quest::istaskcompleted(600627)) {
      quest::say("I have had the worst [dream], friend. The Tuffein took something of mine.");
    }
    elsif (!quest::istaskcompleted(600628)) {
      quest::say("You found my trinket? Ha! Then perhaps you will [help] me again.");
    }
    else {
      quest::say("Stand with us, $name, and the mesa will stand with you.");
    }
  }
  if ($text=~/dream/i && !quest::istaskactive(600627) && !quest::istaskcompleted(600627)) {
    quest::say("Tuffein guards jumped me on the road and took my trinket. Slay eight of them, take the trinket back, and bring it to me.");
    quest::assigntask(600627);
  }
  if ($text=~/help/i && quest::istaskcompleted(600627) && !quest::istaskactive(600628) && !quest::istaskcompleted(600628)) {
    quest::say("Their camp breeds trouble like a swamp breeds flies. Scout the encampment, slay ten guards, and tell me what you see.");
    quest::assigntask(600628);
  }
  if ($text=~/satyrs/i && !quest::istaskactive(600629) && !quest::istaskcompleted(600629) && quest::istaskcompleted(600628)) {
    quest::say("Tuffein satyrs, mocking our kind while they strip these hills bare. Twelve of them. Then stand with us, and we will stand with you.");
    quest::assigntask(600629);
  }
  if ($text=~/trinket/i && quest::istaskactive(600627)) {
    quest::say("A little charm of horn and amber. The guards carry it like they own it.");
  }
}

sub EVENT_ITEM {
  # Consume the trinket only while Hanook #1 is active (task system handles
  # completion); anything else is returned by the handin system.
  if (quest::istaskactive(600627)) {
    plugin::check_handin(\%itemcount, 21490 => 1);
  }
  plugin::return_items(\%itemcount);
}

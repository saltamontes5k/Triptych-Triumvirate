# Library Assistant Ginae - Crescent Reach (the library)
# The Serpent's Spine :: library supply tasks (600544-600547) and
# A Tapestry of Words (600569).

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (!quest::istaskcompleted(600569)) {
      quest::say("Hello there. You are welcome to look around the library. Please keep your voice down, people like to study here. Though - if you have time, the [sporelings] present a curious problem.");
    }
    else {
      quest::say("Hello there. You are welcome to look around the library. Please keep your voice down, people like to study here. The [ink], the [quill], the [book], the [binding] - the library always needs supplies.");
    }
  }

  # A Tapestry of Words (600569)
  if ($text=~/sporeling/i) {
    if (!quest::istaskactive(600569) && !quest::istaskcompleted(600569)) {
      quest::say("A [tapestry] of words, Librarian Hemfar calls it - the sporelings of the Hollows carry living text in their caps. Bring me enough of them and we may read what the Nokk buried.");
      quest::assigntask(600569);
    }
    elsif (quest::istaskactive(600569)) {
      quest::say("The sporelings, friend. Twelve of them. Their caps carry the words.");
    }
    else {
      quest::say("The tapestry reads, at last. Hemfar is very excited.");
    }
  }
  # Library supply tasks (600544-600547)
  if ($text=~/ink/i) {
    if (!quest::istaskactive(600544) && !quest::istaskcompleted(600544)) {
      quest::say("We are out of [ink] again. A Simple Ink, from the alchemists' recipe - one bottle.");
      quest::assigntask(600544);
    }
    elsif (quest::istaskactive(600544)) {
      quest::say("A Simple Ink. The scribes wait.");
    }
  }
  if ($text=~/quill/i) {
    if (!quest::istaskactive(600545) && !quest::istaskcompleted(600545)) {
      quest::say("And a [quill] that will not split - a Simple Quill.");
      quest::assigntask(600545);
    }
    elsif (quest::istaskactive(600545)) {
      quest::say("A Simple Quill. Cut it true.");
    }
  }
  if ($text=~/book/i && $text!~/binding/i) {
    if (!quest::istaskactive(600546) && !quest::istaskcompleted(600546)) {
      quest::say("A [book] to hold the new accessions - a Simple Blank Book.");
      quest::assigntask(600546);
    }
    elsif (quest::istaskactive(600546)) {
      quest::say("A Simple Blank Book. The shelves wait.");
    }
  }
  if ($text=~/binding/i) {
    if (!quest::istaskactive(600547) && !quest::istaskcompleted(600547)) {
      quest::say("And a [binding] for the worn ones - a Simple Book Binding.");
      quest::assigntask(600547);
    }
    elsif (quest::istaskactive(600547)) {
      quest::say("A Simple Book Binding. The old ones fall apart as we speak.");
    }
  }
}

sub EVENT_ITEM {
  if (quest::istaskactive(600544)) {
    plugin::check_handin(\%itemcount, 98293 => 1);
  }
  if (quest::istaskactive(600545)) {
    plugin::check_handin(\%itemcount, 98292 => 1);
  }
  if (quest::istaskactive(600546)) {
    plugin::check_handin(\%itemcount, 98295 => 1);
  }
  if (quest::istaskactive(600547)) {
    plugin::check_handin(\%itemcount, 98294 => 1);
  }
  plugin::return_items(\%itemcount);
}

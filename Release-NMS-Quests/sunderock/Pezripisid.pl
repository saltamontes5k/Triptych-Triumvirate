# Pezripisid - Sunderock Springs
# The Serpent's Spine :: Infiltrators and Traitors of Ashengate faction arc (1135)
# tasks: 600310 The Armies of Dyn`leth, 600311 Unchecked Aggression,
#        600312 Bittersweet Memories, 600313 Violence Begets Violence (repeatable faction grind)
# Requires Captain Zheren's first four tasks (600013) for Ashengate access.

my @chain = (600310, 600311, 600312, 600313);

sub next_task {
  my @c = @chain;
  foreach my $t (@c) {
    return $t if !quest::istaskcompleted($t);
  }
  return $c[0];
}

sub offer_task {
  my $t = shift;
  if (!quest::istaskactive($t)) {
    quest::assigntask($t);
  }
}

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (!quest::istaskcompleted(600013)) {
      quest::say("The way into Ashengate is not yet open to you, $name. Complete Captain Zheren's work in Sunderock Springs first.");
    }
    else {
      my $t = next_task();
      if ($t == 600310) {
        quest::say("Dyn`leth's Black Legion masses in the northeast of Direwind. Help me blunt their offensive. Say the [" . quest::saylink("word") . "] and I will tell you what must be done.");
      }
      elsif ($t == 600311) {
        quest::say("Their aggression goes unchecked. We must answer it. Should you accept the [" . quest::saylink("task") . "], you will thin their ranks further.");
      }
      elsif ($t == 600312) {
        quest::say("The eggtenders hoard the dragons' last memories. A bitter deed, but a necessary one. Say the [" . quest::saylink("word") . "] if you will lend your blade.");
      }
      else {
        quest::say("The Sentries watch every approach to Ashengate. Violence begets violence, and we must be the ones to finish it. Seek the [" . quest::saylink("task") . "].");
      }
    }
  }

  if ($text=~/word/i || $text=~/task/i) {
    if (quest::istaskcompleted(600013)) {
      offer_task(next_task());
    }
    else {
      quest::say("Not yet, $name.");
    }
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}
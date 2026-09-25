# Zhureni - Sunderock Springs
# The Serpent's Spine :: Scholars of Solusek faction arc (1134)
# tasks: 600340 Tidying Up in the Temple, 600341 Squeaky Clean,
#        600342 Scrubbing the Statues, 600343 Evidence of Corruption,
#        600344 Unmake Solusek's Magic (repeatable faction grind, all inside Ashengate)
# Requires Captain Zheren's first four tasks (600013) for Ashengate access.

my @chain = (600340, 600341, 600342, 600343, 600344);

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
      if ($t == 600340) {
        quest::say("The temple of Ashengate chokes on the debris of Dyn`leth's wars. Say the [" . quest::saylink("word") . "] and I will set you to clearing it.");
      }
      elsif ($t == 600341) {
        quest::say("Ashen goo clings to every surface of the temple. Say the [" . quest::saylink("word") . "] to take on the scrubbing.");
      }
      elsif ($t == 600342) {
        quest::say("Brimstone defiles the statues of the faithful. Say the [" . quest::saylink("word") . "] to away with them.");
      }
      elsif ($t == 600343) {
        quest::say("I need proof of the corruption spreading through Ashengate. Say the [" . quest::saylink("word") . "] to gather it.");
      }
      else {
        quest::say("Solusek's magic has been woven into fragments throughout the temple. Say the [" . quest::saylink("word") . "] and I will task you with unmaking it.");
      }
    }
  }

  if ($text=~/word/i) {
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
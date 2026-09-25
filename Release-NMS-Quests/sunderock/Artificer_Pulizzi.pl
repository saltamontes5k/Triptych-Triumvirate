# Artificer Pulizzi - Sunderock Springs
# The Serpent's Spine :: Scholars of Solusek faction arc (1134)
# tasks: 600330 Slicing Clay, 600331 A Brim Task, 600332 Dark Guardians of Ashengate
#        (repeatable faction grind, all inside Ashengate)
# Requires Captain Zheren's first four tasks (600013) for Ashengate access.

my @chain = (600330, 600331, 600332);

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
      if ($t == 600330) {
        quest::say("The clay guardians bar the way to the reliquary. I study the constructs Solusek Ro breathed life into. Say the [" . quest::saylink("word") . "] if you wish to help me slice through them.");
      }
      elsif ($t == 600331) {
        quest::say("The brimstone seeps through the temple's heart. My studies require specimens destroyed, not collected. Say the [" . quest::saylink("word") . "] to take on the task.");
      }
      else {
        quest::say("The darkshard guardians ward the depths, and the galvanized guardian stands at the forges' heart. Say the [" . quest::saylink("word") . "] to shatter them.");
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
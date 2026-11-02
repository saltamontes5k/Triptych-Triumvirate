#--------------------------------------------------------------------------
# TBS Katta Castrum - Guard Captain Parvus (416035)
# Orux mission: Stone Tongue of Ateleka (620100) - dz template 6110, Atiiki.
# Urn tasks: The Serpent Slayer (620113), Beheading the Snake (620114),
# Battling the Shissar (620133) -> Dusty Pottery Splinter/Fragment and the
# Smooth Urn Handle.
#--------------------------------------------------------------------------
my $MISSION = 620100;
my $MZONE   = 418;   # atiiki

my @order = (620113, 620114, 620133);
my %tasks = (
  620113 => ['serpents', 'The shissar multiply in every dark corner of the Castrum. Kill [serpents] -- twenty of them -- and I will know the guard has teeth.'],
  620114 => ['head', 'Zzarishazum drills them in the lower halls. [head] him. Bring me the Commander\'s head and the dark will whisper of it.'],
  620133 => ['prepared', 'Last: show me the guard is [prepared]. Five each of templers, firetongues, shadowslithers, revenants, and arbiters.'],
);
my %prereq = (620114 => 620113, 620133 => 620113);

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (quest::istaskactive($MISSION)) {
      quest::say("The golem Guardian still holds the old tongue. Say [enter] when your companions are gathered.");
      return;
    }
    if (quest::istaskcompleted($MISSION) && !quest::get_data($client->CharacterID() . "-tbsm-$MISSION")) {
      quest::say("The tongue is ours to translate now. Your Orux, soldier -- well earned.");
      quest::set_data($client->CharacterID() . "-tbsm-$MISSION", 1);
      return;
    }
    my $next = -1;
    for my $t (@order) {
      next if quest::istaskcompleted($t);
      if (my $p = $prereq{$t}) { next if !quest::istaskcompleted($p); }
      $next = $t; last;
    }
    if ($next >= 0) {
      quest::say($tasks{$next}[1]);
      return;
    }
    quest::say("You have done more than enough for the guard, $name. The Castrum stands because of you.");
    return;
  }
  if ($text=~/undertake|mission/i) {
    if (!quest::istaskactive($MISSION) && !quest::istaskcompleted($MISSION)) {
      quest::assigntask($MISSION);
      quest::say("The golems of Atiiki remember the Stone Tongue. Say [enter] when prepared.");
    } elsif (quest::istaskactive($MISSION)) {
      quest::say("Say [enter] - the Guardian waits.");
    } else {
      quest::say("It is decided, and well.");
    }
    return;
  }
  if ($text=~/enter/i) {
    if (quest::istaskactive($MISSION)) {
      quest::say("Atiiki remembers him. Make it forget.");
      $client->MovePCDynamicZone($MZONE, 0);
    }
    return;
  }
  for my $tid (@order) {
    my $trig = $tasks{$tid}[0];
    next if $text !~ /\Q$trig\E/i;
    if (quest::istaskcompleted($tid)) {
      quest::say("It is done, and well.");
    } elsif (quest::istaskactive($tid)) {
      quest::say("Finish it, $name. The guard is watching.");
    } elsif (my $p = $prereq{$tid}) {
      if (!quest::istaskcompleted($p)) {
        quest::say("One thing at a time. See to my [serpents] first.");
      } else {
        quest::assigntask($tid);
        quest::say("Good. Go.");
      }
    } else {
      quest::assigntask($tid);
      quest::say("Good. Go.");
    }
    return;
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}

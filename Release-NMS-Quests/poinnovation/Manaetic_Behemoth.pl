# NPCID: 206046 - Manaetic_Behemoth (dormant, untargetable) - Plane of Innovation
# The event controller (spider_controller, 206087) starts the wake-up by signaling 2.
# Power carriers that reach the machine signal 1, feeding it power and resetting the wake-up.
# Signal 99 stops/resets the event.

my $goactive = 0;
my $counting = 0;

sub EventBucket {
  return "poinnovation_mb_event_active_" . ($instanceid || 0);
}

sub EVENT_SPAWN {
  $counting = 0;
  $goactive = 0;
}

sub EVENT_SIGNAL {
  if($signal == 99) {
    #event stopped (timeout, or the behemoth activated)
    quest::stoptimer(1);
    $counting = 0;
    $goactive = 0;
  } elsif($signal == 2 && quest::get_data(EventBucket()) && $counting == 0) {
    #deprived of incoming power, the Behemoth slowly begins to wake.
    quest::settimer(1,5);
    $counting = 1;
    $goactive = 0;
  } elsif($signal == 1 && quest::get_data(EventBucket()) && $counting == 1) {
    #a carrier reached the Behemoth and fed it power: reset the wake-up.
    if($goactive > 0) {
      quest::ze(15, "A clockwork carrier reaches the Manaetic Behemoth and detonates, feeding it power -- it sinks back into dormancy!");
    }
    $goactive = 0;
  }
}

sub EVENT_TIMER {
  if($timer == 1) {
    #increment $goactive
    $goactive++;
    #increments at +1 per 5 seconds means $goactive == 60 is 5 minutes.
    if($goactive == 60) {
      quest::stoptimer(1);
      BEGIN_MB_EVENT();
    } elsif($goactive == 12) {
      quest::ze(15, "Power to the Manaetic Behemoth is failing -- it begins to stir... (1/5).");
    } elsif($goactive == 24) {
      quest::ze(15, "The Manaetic Behemoth stirs as its power continues to wane... (2/5).");
    } elsif($goactive == 36) {
      quest::ze(15, "The Manaetic Behemoth shudders, starved of power... (3/5).");
    } elsif($goactive == 48) {
      quest::ze(15, "The Manaetic Behemoth thrashes violently -- it is nearly awake! (4/5).");
    } elsif($goactive > 60) {
      #reset all the counters and start over, something went wrong
      $counting = 0;
      $goactive = 0;
    }
  }
}

sub BEGIN_MB_EVENT {
  quest::ze(15, "Starved of power at last, the Manaetic Behemoth awakens in a fury and becomes vulnerable!");
  quest::delete_data(EventBucket());
  #spawn the targetable version and depop the dormant version with its respawn timer active.
  quest::spawn2(206074,0,0,$x,$y,$z,0); # NPC: #Manaetic_Behemoth
  quest::depop_withtimer();
}

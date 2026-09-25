#--------------------------------------------------------------------------
# TBS Orux missions - Sergeant Zetren (416034)
# Mission: The Great Invasion (620101) - dz template 6111, Jewel of Atiiki.
# Speak to Akarahotuten inside, defend the temple with the efreeti.
#--------------------------------------------------------------------------
my $TASK = 620101;
my $ORUX = 6;
my $ZONE = 418;   # atiiki

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (quest::istaskcompleted($TASK) && !quest::get_data($client->CharacterID() . "-tbsm-$TASK")) {
      quest::say("The temple still stands. Katta pays its debts - Orux, as promised.");
      quest::summonitem(79911, $ORUX);
      quest::set_data($client->CharacterID() . "-tbsm-$TASK", 1);
    } elsif (quest::istaskactive($TASK)) {
      quest::say("Akarahotuten commands the defense atop the pyramid. Say [enter] to join it.");
    } else {
      quest::say("The shissar test our walls nightly, $name. The efreeti Akarahotuten holds the pyramid, but he cannot hold it [alone].");
    }
  }
  if ($text=~/alone|mission/i) {
    if (quest::istaskcompleted($TASK)) {
      quest::say("You have done your part, soldier.");
    } elsif (quest::istaskactive($TASK)) {
      quest::say("Say [enter] and stand with the efreeti.");
    } else {
      quest::say("Join the defense and cut down the invaders before they reach the sanctum. Will you [serve]?");
    }
  }
  if ($text=~/serve|yes/i) {
    if (!quest::istaskactive($TASK) && !quest::istaskcompleted($TASK)) {
      quest::assigntask($TASK);
      quest::say("Then move out. Say [enter] when your group is ready.");
    }
  }
  if ($text=~/enter/i) {
    if (quest::istaskactive($TASK)) {
      quest::say("Good hunting, $name.");
      $client->MovePCDynamicZone($ZONE, 0);
    }
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}

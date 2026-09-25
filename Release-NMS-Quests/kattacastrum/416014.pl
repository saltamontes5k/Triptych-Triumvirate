#--------------------------------------------------------------------------
# TBS Orux missions - Sorcerer Hearah (416014)
# Mission: Coral Diving (620104) - dz template 6114, Thalassius, the Coral
# Keep. Harvest fire coral and thin the kedge.
#--------------------------------------------------------------------------
my $TASK = 620104;
my $ORUX = 6;
my $ZONE = 417;   # thalassius

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (quest::istaskcompleted($TASK) && !quest::get_data($client->CharacterID() . "-tbsm-$TASK")) {
      quest::say("Ah, the warmth of fire coral for my experiments! Your Orux, diver.");
      quest::summonitem(79911, $ORUX);
      quest::set_data($client->CharacterID() . "-tbsm-$TASK", 1);
    } elsif (quest::istaskactive($TASK)) {
      quest::say("The caves north of here hold the coral. Say [enter] to dive.");
    } else {
      quest::say("The kedge infest the coral caves, $name, and the [fire] coral burns unharvested.");
    }
  }
  if ($text=~/fire|mission/i) {
    if (quest::istaskcompleted($TASK)) {
      quest::say("Enough coral for a season, thanks to you.");
    } elsif (quest::istaskactive($TASK)) {
      quest::say("Say [enter] - mind the water, it is deeper than it looks.");
    } else {
      quest::say("Bring me ten cuttings of fire coral and cull the kedge while you are down there. Will you [dive]?");
    }
  }
  if ($text=~/dive|yes/i) {
    if (!quest::istaskactive($TASK) && !quest::istaskcompleted($TASK)) {
      quest::assigntask($TASK);
      quest::say("Say [enter] when your group is ready to get wet.");
    }
  }
  if ($text=~/enter/i) {
    if (quest::istaskactive($TASK)) {
      quest::say("Breathe deep, $name.");
      $client->MovePCDynamicZone($ZONE, 0);
    }
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}

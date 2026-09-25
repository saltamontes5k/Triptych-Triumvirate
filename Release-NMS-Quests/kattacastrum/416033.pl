#--------------------------------------------------------------------------
# TBS Orux missions - Structural Engineer Dewas (416033)
# Mission: The Domes are Cracking (620108) - dz template 6118, Zhisza.
# Seal the dome cracks and survive the shissar ambushes.
#--------------------------------------------------------------------------
my $TASK = 620108;
my $ORUX = 7;
my $ZONE = 419;   # zhisza

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (quest::istaskcompleted($TASK) && !quest::get_data($client->CharacterID() . "-tbsm-$TASK")) {
      quest::say("Three cracks sealed, three ambushes buried. Structural integrity restored! Your Orux, engineer's honor.");
      quest::summonitem(79911, $ORUX);
      quest::set_data($client->CharacterID() . "-tbsm-$TASK", 1);
    } elsif (quest::istaskactive($TASK)) {
      quest::say("The cracks wait for no one. Say [enter] and take the device to them.");
    } else {
      quest::say("The shissar domes are [failing], $name, and when they crack, everything inside dies with them.");
    }
  }
  if ($text=~/failing|mission/i) {
    if (quest::istaskcompleted($TASK)) {
      quest::say("The domes will outlive us all now, thanks to you.");
    } elsif (quest::istaskactive($TASK)) {
      quest::say("Say [enter]. Clear the area, survive the ambush, then seal the crack with the device.");
    } else {
      quest::say("I will give you my repair device - find each crack, fight off what pours out, and seal it. Say [doit] and I will send you.");
    }
  }
  if ($text=~/doit|do it|yes/i) {
    if (!quest::istaskactive($TASK) && !quest::istaskcompleted($TASK)) {
      quest::assigntask($TASK);
      quest::summonitem(9910010, 1);   # Dome Repair Device
      quest::say("Take the device. Say [enter] when your group is ready.");
    }
  }
  if ($text=~/enter/i) {
    if (quest::istaskactive($TASK)) {
      quest::say("Mind the domes, $name - and yourself.");
      $client->MovePCDynamicZone($ZONE, 0);
    }
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}

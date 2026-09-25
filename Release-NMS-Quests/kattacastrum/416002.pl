#--------------------------------------------------------------------------
# TBS Orux missions - Tuzart Relenfold (416002)
# Mission: Fate of the Combine (620102) - dz template 6112, Jewel of Atiiki.
# Hunt Emperor Zhizuzun with Akarahotuten.
#--------------------------------------------------------------------------
my $TASK = 620102;
my $ORUX = 6;
my $ZONE = 418;   # atiiki

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (quest::istaskcompleted($TASK) && !quest::get_data($client->CharacterID() . "-tbsm-$TASK")) {
      quest::say("The Emperor's fate is the Combine's answer to the Empress. Your Orux, as agreed.");
      quest::summonitem(79911, $ORUX);
      quest::set_data($client->CharacterID() . "-tbsm-$TASK", 1);
    } elsif (quest::istaskactive($TASK)) {
      quest::say("Akarahotuten waits atop the pyramid. Say [enter] and finish the hunt.");
    } else {
      quest::say("An emperor of the old blood hides within the temple's memory, $name. His fate is ours to [decide].");
    }
  }
  if ($text=~/decide|mission/i) {
    if (quest::istaskcompleted($TASK)) {
      quest::say("It is decided, and well.");
    } elsif (quest::istaskactive($TASK)) {
      quest::say("Say [enter] - Akarahotuten will show you the way.");
    } else {
      quest::say("Seek out Emperor Zhizuzun and end his pretense. Will you [undertake] it?");
    }
  }
  if ($text=~/undertake|yes/i) {
    if (!quest::istaskactive($TASK) && !quest::istaskcompleted($TASK)) {
      quest::assigntask($TASK);
      quest::say("Say [enter] when your companions are gathered.");
    }
  }
  if ($text=~/enter/i) {
    if (quest::istaskactive($TASK)) {
      quest::say("The temple remembers him. Make it forget.");
      $client->MovePCDynamicZone($ZONE, 0);
    }
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}

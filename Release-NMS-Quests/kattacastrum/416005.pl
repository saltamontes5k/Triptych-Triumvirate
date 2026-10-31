#--------------------------------------------------------------------------
# TBS Orux missions - Head Attendant Haestus (416005)
# Mission: Gorillas in the Garden (620103) - dz template 6113, Jewel of Atiiki.
# Subdue escaped garden gorillas for Shelfezmaken the sphinx.
#--------------------------------------------------------------------------
my $TASK = 620103;
my $ORUX = 7;
my $ZONE = 418;   # atiiki

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (quest::istaskcompleted($TASK) && !quest::get_data($client->CharacterID() . "-tbsm-$TASK")) {
      quest::say("The garden is quiet again - the sphinx herself is pleased. Your Orux, wrangler.");
      quest::set_data($client->CharacterID() . "-tbsm-$TASK", 1);
    } elsif (quest::istaskactive($TASK)) {
      quest::say("Shelfezmaken waits in the garden. Say [enter] and mind the bugs.");
    } else {
      quest::say("The dome garden has gone [wild], $name. Gorillas loose everywhere, and the matriarch worst of all.");
    }
  }
  if ($text=~/wild|mission/i) {
    if (quest::istaskcompleted($TASK)) {
      quest::say("Rest, wrangler. The garden owes you.");
    } elsif (quest::istaskactive($TASK)) {
      quest::say("Say [enter] - and use the prod, do not kill them!");
    } else {
      quest::say("Shelfezmaken can wrangle them if you weaken them first. Assist her? Say [assist].");
    }
  }
  if ($text=~/assist|yes/i) {
    if (!quest::istaskactive($TASK) && !quest::istaskcompleted($TASK)) {
      quest::assigntask($TASK);
      quest::say("Bless you. Say [enter] when prepared.");
    }
  }
  if ($text=~/enter|prepared/i) {
    if (quest::istaskactive($TASK)) {
      quest::say("The garden is through the portal. Go on, $name.");
      $client->MovePCDynamicZone($ZONE, 0);
    }
  }
}

sub EVENT_ITEM {
  # Tsaph Katta's Urn of Rejuvenation recharge: hand the drained urn back
  # and it returns with its five charges of Deep Stasis renewed.
  if (plugin::check_handin(\%itemcount, 79980 => 1)) {
    quest::say("The Urn of Rejuvenation, drained dry. Tsaph's gift does not run dry while the Combine stands -- take it renewed, and mind where you spend it.");
    quest::summonitem(79980);
  } else {
    plugin::return_items(\%itemcount);
  }
}

#--------------------------------------------------------------------------
# TBS Orux missions - Associate Researcher Plik (416011)
# Solteris Access arc endpoint + mission: Stone Tongue of Ateleka (620100)
# Task instance: dz template 6110 (Jewel of Atiiki). Orux = alt currency 11.
#--------------------------------------------------------------------------
my $TONGUE = 620100;
my $TONGUE_ORUX = 5;
my $TONGUE_ZONE = 418;   # atiiki

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (quest::istaskcompleted($TONGUE) && !quest::get_data($client->CharacterID() . "-tbsm-$TONGUE")) {
      quest::say("The Stone Tongue is whole again! Take this Orux for your trouble - the traders of Katta prize it.");
      quest::summonitem(79911, $TONGUE_ORUX);
      quest::set_data($client->CharacterID() . "-tbsm-$TONGUE", 1);
    } elsif (quest::istaskactive($TONGUE)) {
      quest::say("The golems of Ateleka wait upon the pyramid. Tell me [enter] when you are ready to face them, and bring back all four fragments of the Tongue.");
    } elsif (quest::istaskcompleted(620050)) {
      quest::say("Good to see you again, $name. The sphinx studies continue - and I could use hands for a matter of the [tongue].");
    } elsif (quest::istaskactive(620050)) {
      quest::say("Ahh, so Prime Researcher Elnot sent you to speak with the sphinx about our [problem], yes? Then you have done what he asked - return to him and tell him what we discussed.");
    } else {
      quest::say("The Prime Researcher has theories enough for all of us. Speak with him if you wish to [help] the city.");
    }
  }
  if ($text=~/problem|help/i) {
    quest::say("The Pellarus Satum dims and the protective domes weaken with it. If you wish to serve, Elnot will point your feet.");
  }
  if ($text=~/tongue|mission/i) {
    if (quest::istaskcompleted($TONGUE)) {
      quest::say("You have already proven the tongue of Ateleka speaks true, $name.");
    } elsif (quest::istaskactive($TONGUE)) {
      quest::say("The golems wait. Say [enter] and I will send you to the pyramid.");
    } else {
      quest::say("Deep atop the pyramid of Atiiki sits Osinzuhazhfet, keeper of a stone tongue that predates the Combine. Bring down his guardians and we shall learn what it says. Will you [undertake] it?");
    }
  }
  if ($text=~/undertake|yes/i) {
    if (!quest::istaskactive($TONGUE) && !quest::istaskcompleted($TONGUE)) {
      quest::assigntask($TONGUE);
      quest::say("Wear the Combine's blessing. Say [enter] when you are ready.");
    }
  }
  if ($text=~/enter/i) {
    if (quest::istaskactive($TONGUE)) {
      quest::say("The pyramid awaits, $name. Take your companions with you.");
      $client->MovePCDynamicZone($TONGUE_ZONE, 0);
    }
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}

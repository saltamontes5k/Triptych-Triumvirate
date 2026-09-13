# Sergeant Kazzar - Sunderock Springs
# The Serpent's Spine :: Ashengate raid access
# tasks: 600020 Into the Leviathan's Lair (DZ 6006), 600021 Vergalid's End (DZ 6007)
# Requires Captain Zheren's first four tasks (600010-600013) to request.

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (!quest::istaskcompleted(600013)) {
      quest::say("Speak with Captain Zheren first, $name. We cannot open the way to the mines until the valley is scouted and Dyn`leth's hold is broken.");
    }
    elsif (!quest::istaskcompleted(600020)) {
      quest::say("The Crusade is ready to strike. We have found a way into the Vergalid Mines. Do you wish to enter the [" . quest::saylink("Leviathan's Lair") . "]?");
    }
    elsif (!quest::istaskcompleted(600021)) {
      quest::say("Kellak is dead, but Vergalid stirs below. Are you ready to bring his [" . quest::saylink("End") . "]?");
    }
    else {
      quest::say("The Crusade is in your debt, $name. The Scale of Veeshan will be reclaimed because of you.");
    }
  }

  if ($text=~/Leviathan/i) {
    if (quest::istaskcompleted(600013)) {
      if (!quest::istaskactive(600020) && !quest::istaskcompleted(600020)) {
        quest::say("Enter the mines and slay Kellak the Serpent Lord. Beware his offspring. Say [" . quest::saylink("enter") . "] when you are ready.");
        quest::assigntask(600020);
      }
      else {
        quest::say("Kellak awaits. Say [" . quest::saylink("enter") . "] when you are ready.");
      }
      $client->CreateExpeditionFromTemplate(6006);
    }
    else {
      quest::say("Finish your work for Captain Zheren first.");
    }
  }

  if ($text=~/^End$/i) {
    if (quest::istaskcompleted(600020)) {
      if (!quest::istaskactive(600021) && !quest::istaskcompleted(600021)) {
        quest::say("Destroy Nurtha and her contraptions, banish Goru Uldrock, power the life force, and destroy Vergalid himself. Say [" . quest::saylink("enter") . "] when you are ready.");
        quest::assigntask(600021);
      }
      else {
        quest::say("Vergalid waits below. Say [" . quest::saylink("enter") . "] when you are ready.");
      }
      $client->CreateExpeditionFromTemplate(6007);
    }
    else {
      quest::say("You must first slay Kellak in the Leviathan's Lair.");
    }
  }

  if ($text=~/^enter$/i) {
    if (quest::istaskactive(600020)) {
      $client->MovePCDynamicZone(404, 1);
    }
    elsif (quest::istaskactive(600021)) {
      $client->MovePCDynamicZone(404, 2);
    }
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}

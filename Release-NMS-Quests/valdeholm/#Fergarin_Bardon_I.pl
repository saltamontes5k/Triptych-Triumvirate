# Fergarin Bardon I - Valdeholm
# The Serpent's Spine :: Frostcrypt raid progression (group chain)
# tasks: 600000 Intercepted Correspondence, 600001 Lost Letter, 600002 Confession
# items: 88178 Incriminating Note, 88179 Sealed Letter
# faction: Wraithguard Leadership (1105)
#
# Fergarin is located in the back room behind Wraithguard Heimgul at -770, -780, -25.

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (!quest::istaskcompleted(600002)) {
      quest::say("Greetings, $name. I have heard of your work for the Wraithguard lately. Perhaps you would be willing to assist me and my followers in a small [" . quest::saylink("journey") . "]. Or, if you are more interested in doing me a more... Personal favor, there is some [" . quest::saylink("information") . "] that you could gather for me. It might even be possible for us to help [" . quest::saylink("each other") . "].");
    }
    elsif (!quest::istaskcompleted(600003)) {
      quest::say("You have done much for my people, $name. There is, however, a [dangerous threat] in the highest parts of the glacier that I would ask you and a few friends to face.");
    }
    elsif (!quest::istaskcompleted(600004)) {
      quest::say("There is a more delicate matter I could use your help with, $name. One of my own has turned against the king. Would you [deal with a traitor]?");
    }
    elsif (!quest::istaskcompleted(600005)) {
      quest::say("Now that the traitor is gone, there is one small thing left to [take care of], $name.");
    }
    elsif (!quest::istaskcompleted(600006)) {
      quest::say("You have done all I could ask of you here, $name. But the true war waits within [Frostcrypt]. Say the word and I will see you and your allies to the front.");
    }
    else {
      quest::say("You have done all I could ask, $name. The Wraithguard will remember your deeds.");
    }
  }

  if ($text=~/each other/i) {
    quest::say("I need evidence before I can act. Rumors of treason are not enough. Gather what you can from the guards and citizens of our city and bring it to me.");
  }

  if ($text=~/information/i) {
    quest::say("I have been hearing rumors of treason among my own people. It's shameful to admit that I believe these rumors to be true. In order to protect my people and the great city, I need your help to gather evidence to prove, or perhaps disprove, these rumors.");
    if (!quest::istaskactive(600000) && !quest::istaskcompleted(600001)) {
      quest::assigntask(600000);
    }
  }

  if ($text=~/further assistance/i) {
    if (quest::istaskcompleted(600000) && !quest::istaskactive(600001) && !quest::istaskcompleted(600001)) {
      quest::say("Your note was a start, but the trail grows cold. Search the trash of Valdeholm for a Sealed Letter and bring it to me.");
      quest::assigntask(600001);
    }
  }

  if ($text=~/complete the task/i) {
    if (quest::istaskcompleted(600001) && !quest::istaskactive(600002) && !quest::istaskcompleted(600002)) {
      quest::say("The letter was intended for a Drakkin officer in Direwind. Find Telgrith, the Black Legion Captain, in the camp outside Ashengate and kill him. Then return to me.");
      quest::assigntask(600002);
    }
  }

  if ($text=~/dangerous threat/i) {
    if (!quest::istaskcompleted(600002)) {
      quest::say("Prove yourself against the traitors first, $name. I cannot entrust this to you yet.");
    }
    else {
      if (!quest::istaskactive(600003) && !quest::istaskcompleted(600003)) {
        quest::say("There is a massive spider in the highest parts of the glacier. She comes down to the lake to feed on her young, and on my people. I have prepared an expedition for you. Say [" . quest::saylink("enter") . "] when you are ready and I will see you to her.");
        quest::assigntask(600003);
      }
      else {
        quest::say("The beast awaits you at the lake. Say [" . quest::saylink("enter") . "] when you are ready.");
      }
      $client->CreateExpeditionFromTemplate(6003);
    }
  }

  if ($text=~/deal with a traitor/i) {
    if (quest::istaskcompleted(600003)) {
      if (!quest::istaskactive(600004) && !quest::istaskcompleted(600004)) {
        quest::say("One of my own has turned against the king and calls him a coward. I cannot act openly against him, but if 'invaders' were to storm the Lorekeeper's Pit... Do you believe in [" . quest::saylink("coincidence") . "]?");
        quest::assigntask(600004);
      }
      else {
        quest::say("Udengar still speaks in the Lorekeeper's Pit. Say [" . quest::saylink("enter") . "] when you are ready to move against him.");
      }
      $client->CreateExpeditionFromTemplate(6004);
    }
    else {
      quest::say("First deal with the spider queen, $name.");
    }
  }

  if ($text=~/coincidence/i) {
    quest::say("Well, coincidence is what you make it. The guards at the pit may yet be swayed if you show them the evidence you carry. Speak to them before you strike.");
  }

  if ($text=~/take care of/i) {
    if (quest::istaskcompleted(600004)) {
      if (!quest::istaskactive(600005) && !quest::istaskcompleted(600005)) {
        quest::say("I have done my best to ensure King Odeen that you are worth speaking with. Avoid confrontations with the citizens on your way. Say [" . quest::saylink("enter") . "] when you are ready.");
        quest::assigntask(600005);
      }
      else {
        quest::say("The king awaits. Say [" . quest::saylink("enter") . "] when you are ready.");
      }
      $client->CreateExpeditionFromTemplate(6005);
    }
    else {
      quest::say("There is still the matter of the traitor, $name.");
    }
  }

  if ($text=~/^enter$/i) {
    if (quest::istaskactive(600003)) {
      $client->MovePCDynamicZone(401, 1);
    }
    elsif (quest::istaskactive(600004)) {
      $client->MovePCDynamicZone(401, 2);
    }
    elsif (quest::istaskactive(600005)) {
      $client->MovePCDynamicZone(401, 3);
    }
  }

  if ($text=~/frostcrypt/i) {
    if (!quest::istaskcompleted(600005)) {
      quest::say("The way to Frostcrypt is not yet open to you, $name. Prove yourself against the king first.");
    }
    elsif (!quest::istaskactive(600006) && !quest::istaskcompleted(600006)) {
      quest::say("Then it begins. The Wraithguard will open the way. Seek Sergeant Thavin at the Frostcrypt gate and tell him [" . quest::saylink("Fergarin sent me") . "]. Hold nothing back, $name.");
      quest::assigntask(600006);
      $client->CreateExpeditionFromTemplate(6011);
    }
    else {
      quest::say("Frostcrypt waits. Tell Sergeant Thavin [" . quest::saylink("Fergarin sent me") . "] and see it done.");
      $client->CreateExpeditionFromTemplate(6011);
    }
  }
}

sub EVENT_ITEM {
  # Deliver activities are pre-marked by the task system; consuming the item here
  # finalizes the hand-in (quest NPCs do not auto-consume task deliverables).
  if (plugin::check_handin(\%itemcount, 88178 => 1)) {
    quest::say("This is exactly the evidence I feared we would find. A guard paid to look away... Thank you, $name.");
  }
  elsif (plugin::check_handin(\%itemcount, 88179 => 1)) {
    quest::say("Sealed by a lorekeeper's hand and unsigned. Your efforts have proven my suspicions correct, $name.");
  }
  plugin::return_items(\%itemcount);
}

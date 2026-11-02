# Council Aide Mystrana - Crescent Reach (council chamber, upper floor)
# Reconstructed retail chain: 505746 City Charter -> 505747 For Those Gone
# Before Us -> the native Prove Your Worth banner step (Tailor Meikolu).
# NMS preserved from the retired scraped script: the TSS "Tears of the
# Betrayed" bounty (600568) and the charter keepsake refund on hand-in.
# Charter bookshelf: a_book_on_a_table on the floor above.

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (!quest::istaskcompleted(505746)) {
      quest::say("$name, can't you see how busy I am with [" . quest::saylink("council business") . "]? I clearly don't have time to stand here and chat with you, but I thank you for your interest in the daily business of the Council of the Six, the lords and ladies of Crescent Reach. Good day to you!");
    }
    else {
      quest::say("Well, well $name you are persistent. I like that! You show a genuine interest in how our fine city is being put together. As you can clearly see for yourself this city is not of drakkin origins. I would like you to [" . quest::saylink("learn more") . "] about this city's history before we speak any further.");
    }
  }
  if ($text=~/council business/i) {
    quest::say("What? Didn't I just very politely suggest we chat another time? If you are so interested in the Scions of the Six then why don't you take a look at our [" . quest::saylink("charter") . "]? That should fill you in on the basics of how our city is run. Now if there's nothing else, I will say udra to you. That means 'goodbye!'");
  }
  if ($text=~/charter/i) {
    if (!quest::istaskactive(505746) && !quest::istaskcompleted(505746)) {
      quest::say("The charter? It's in the library of course! Where else would it be?");
      quest::taskselector(505746); #Getting to Know You: The City Charter
    }
    else {
      quest::say("Sorry $name, I don't have anything for someone with your abilities.");
    }
  }
  if (($text=~/learn more/i) && quest::istaskcompleted(505746) && !quest::istaskactive(505747) && !quest::istaskcompleted(505747)) {
    quest::say("There is a book in a hidden room that you should study. Enter Gekkdar's Haunt on the third level and locate the hidden room. Once you have read the book you will find there return to me and I will have more to say to you. Good day to you, $name.");
    quest::taskselector(505747); # Getting to Know You: For Those Gone Before Us
  }
  # NMS preserved: Tears of the Betrayed (600568)
  if ($text=~/tears/i || $text=~/betrayed/i) {
    if (!quest::istaskactive(600568) && !quest::istaskcompleted(600568)) {
      quest::say("There is one more matter, $name - the [betrayed] of the farm still weep in the soil. The risen elders and their soldier kin will not stop until someone quiets them.");
      quest::assigntask(600568);
    }
    elsif (quest::istaskactive(600568)) {
      quest::say("The betrayed, $name. Ten risen elders and eight of their soldiers.");
    }
    else {
      quest::say("The farm is quiet at last. The council notes your service, $name.");
    }
  }
}

sub EVENT_ITEM {
  if (plugin::check_handin(\%itemcount, 85088 => 1)) { #Crescent Citizen's Declaration
    quest::say("Ah, so you are interested in gaining favor with the Scions of the Six, the council that stands before the great moontable? Very good. Let us begin!");
  }
  if (plugin::check_handin(\%itemcount, 57974 => 1)) { #Crescent Reach City Charter
    quest::say("The charter, safe and sound. Study it well, $name - a citizen who knows the charter is a citizen worth having.");
    quest::summonitem(57974); # the charter is the keepsake reward
  }
  plugin::return_items(\%itemcount);
}

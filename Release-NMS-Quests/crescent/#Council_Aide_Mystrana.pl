# Council Aide Mystrana - Crescent Reach (council chamber, upper floor)
# The Serpent's Spine :: Getting to Know You series + Prove Your Worth
#   505746 Getting to Know You: The City Charter (taskselector on hail)
#   6802   Getting to Know You: The Council's Aid (note hand-in, 85088)
#   600240 Getting to Know You: For Those Gone Before Us (book 57975, talk)
#   600241 Prove Your Worth (banner delivered to a Councilmember)
# Charter bookshelf: a_book_on_a_table on the floor above.

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (!quest::istaskcompleted(505746)) {
      quest::say("$name, can't you see how busy I am with [" . quest::saylink("council business") . "]? I clearly don't have time to stand here and chat with you, but I thank you for your interest in the daily business of the Council of the Six, the lords and ladies of Crescent Reach. Good day to you!");
    }
    elsif (quest::istaskactive(600240)) {
      quest::say("Gekkdar's Haunt is on the third level. Find the hidden room behind the curtain and study what you find there. Return to me when you have read it.");
    }
    elsif (!quest::istaskcompleted(600240)) {
      quest::say("Well, well $name you are persistent. I like that! You show a genuine interest in how our fine city is being put together. As you can clearly see for yourself this city is not of drakkin origins. I would like you to [" . quest::saylink("learn more") . "] about this city's history before we speak any further.");
    }
    elsif (!quest::istaskcompleted(600241) && !quest::istaskactive(600241)) {
      quest::say("You have shown a great deal of interest in this city and have prepared yourself well for what lies ahead of you, $name. I think you are now [" . quest::saylink("ready") . "] to meet the Council Members.");
    }
    elsif (quest::istaskactive(600241)) {
      quest::say("Combine the materials from Tailor Meikolu in the sewing kit, return the cloth to her, and give the finished banner to one of the Councilmembers.");
    }
    else {
      quest::say("Go speak to the Council of Six at your leisure, but please conduct yourself with the utmost dignity and don't embarrass me!");
    }
  }
  if ($text=~/council business/i) {
    quest::say("What? Didn't I just very politely suggest we chat another time? If you are so interested in the Scions of the Six then why don't you take a look at our [" . quest::saylink("charter") . "]? That should fill you in on the basics of how our city is run. Now if there's nothing else, I will say udra to you. That means 'goodbye!'");
  }
  if ($text=~/charter/i) {
    if (!quest::istaskcompleted(505746)) {
      quest::say("The charter? It's in the library of course! Where else would it be?");
      quest::taskselector(505746); # Getting to Know You: The City Charter
    }
    else {
      quest::say("Sorry $name, I don't have anything for someone with your abilities.");
    }
  }
  if ($text=~/learn more/i) {
    if (quest::istaskcompleted(505746) && !quest::istaskcompleted(600240) && !quest::istaskactive(600240)) {
      quest::say("There is a book in a hidden room that you should study. Enter Gekkdar's Haunt on the third level and locate the hidden room. Once you have read the book you will find there return to me and I will have more to say to you. Good day to you, $name.");
      quest::assigntask(600240); # Getting to Know You: For Those Gone Before Us
    }
    else {
      quest::say("Sorry $name, I don't have anything for someone with your abilities.");
    }
  }
  if ($text=~/ready/i) {
    if (quest::istaskcompleted(600240) && !quest::istaskcompleted(600241) && !quest::istaskactive(600241)) {
      quest::say("Go speak to the Council of Six at your leisure, but please conduct yourself with the utmost dignity and don't embarrass me! First, though - the Council requires a banner of the Drakkin, and Tailor Meikolu on Artisans' Row can guide you. She is on the second level of the city.");
      quest::taskselector(600241); # Prove Your Worth
    }
    else {
      quest::say("Sorry $name, I don't have anything for someone with your abilities.");
    }
  }
}

sub EVENT_ITEM {
  if (plugin::check_handin(\%itemcount, 85088 => 1)) { # Crescent Citizen's Declaration
    quest::say("Ah, so you are interested in gaining favor with the Scions of the Six, the council that stands before the great moontable? Very good. Let us begin!");
    if (quest::istaskactivityactive(6802, 0)) {
      quest::updatetaskactivity(6802, 0, 1);
    }
  }
  if (plugin::check_handin(\%itemcount, 57974 => 1)) { # Crescent Reach City Charter
    quest::say("The charter, safe and sound. Study it well, $name - a citizen who knows the charter is a citizen worth having.");
    if (quest::istaskactivityactive(505746, 2)) {
      quest::updatetaskactivity(505746, 2, 1);
    }
    quest::summonitem(57974); # the charter is the keepsake reward
  }
  plugin::return_items(\%itemcount);
}

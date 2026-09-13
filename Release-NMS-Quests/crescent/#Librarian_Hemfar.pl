# Librarian Hemfar - Crescent Reach
# The Serpent's Spine :: Charm of Lore (artifact turn-ins) + library dialogue
# Charm: Serpent Seeker's Charm of Lore (52354)
# Artifacts: 58715-58750 (37 items from across the expansion)

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (quest::istaskactivityactive(505746, 0)) { #Getting to Know You: The City Charter
      quest::say("Ah, yes. Mystrana told me you would be stopping by. Head upstairs and grab a copy of the Charter. My staff just finished scribing a new set. We can hardly keep up with the number of new faces who need to learn about our fine city!");
    }
    else {
      quest::say("Vasha, friend. I am the second-born of Keikolin the Enlightened, the most knowledgeable dragon of the Six. I am to aid in the education of drakkin and all who choose to enlighten their minds. I am a collector of artifacts and one of the founders of the Written Word and the Wanderlust Guild so we may learn from books and life. I have a unique gift that you may partake in if you [" . quest::saylink("aid") . "] in my work. Or you may simply ask me what [" . quest::saylink("lore") . "] I have gathered from artifacts in these lands.");
    }
  }
  if ($text=~/aid/i) {
    quest::say("Yes, indeed. I have been given a sight-gift from Lady Keikolin. In many artifacts I can see within them and through the eyes of those they belonged to. It allows me to create a history that will become part of this library. Should you find any artifacts in the surrounding lands, bring them to me and I shall reward you and be able to add to the [" . quest::saylink("volumes") . "] of our great library.");
    if (!defined($qglobals{charm_of_lore})) {
      quest::say("Take this charm, $name. As you bring me artifacts from across the Serpent's Spine, it will grow in power.");
      quest::emote("carefully presses a warm, humming charm into your hand.");
      quest::summonitem(53505); # Serpent Seeker's Charm of Lore
      quest::setglobal("charm_of_lore", 1, 5, "F");
      quest::setglobal("charm_of_lore_count", 0, 5, "F");
    }
    if (!quest::istaskactive(3666) && !quest::istaskcompleted(3666)) {
      quest::assigntask(3666);
    }
  }
  if ($text=~/lore/i) {
    quest::say("I've received artifacts from these lands and have information about them available. If you have an artifact that you would like information about, please give it to me. Otherwise, I can share from the library I've begun.");
  }
  if ($text=~/volumes/i) {
    quest::say("There are many creatures present and past that lived in these mountains, including the ogres that once lived in this very city. What exactly happened to them and their kind is somewhat of a mystery, but given time and the right artifacts, we shall learn more. I can reward you if you bring artifacts to me. Then, you may ask what [" . quest::saylink("lore") . "] and legend is available as people bring me artifacts and I can share the history with you when it is scribed.");
  }
  if ($text=~/charm/i) {
    if (defined($qglobals{charm_of_lore})) {
      my $count = defined($qglobals{charm_of_lore_count}) ? $qglobals{charm_of_lore_count} : 0;
      quest::say("Your Charm of Lore has absorbed $count artifact" . ($count == 1 ? "" : "s") . " so far. Bring me more and it will grow stronger.");
    }
    else {
      quest::say("Ask me about how you may [" . quest::saylink("aid") . "] me, and I will entrust you with a Charm of Lore.");
    }
  }
}

sub EVENT_SIGNAL {
  quest::settimer("enot", 4);
}

sub EVENT_TIMER {
  quest::stoptimer("enot");
  my $random = int(rand(100));
  if ($random > 60) {
    quest::say("Hello to you, Enot! I actually just got it in today. Here you go. I hope you find the information you're looking for.");
    quest::signalwith(394209, 1);
  }
  else {
    quest::say("Hello, Enot! I'm sorry but I haven't been able to find that tome yet. My assistants and I are still searching! I will let you know as soon as I find it.");
    quest::signalwith(394209, 2);
  }
}

sub EVENT_ITEM {
  my @artifacts = (58715, 58716, 58717, 58718, 58719, 58720, 58721, 58722, 58723, 58724,
                   58725, 58726, 58727, 58728, 58729, 58730, 58731, 58732, 58733, 58734,
                   58735, 58736, 58737, 58738, 58739, 58740, 58741, 58742, 58743, 58744,
                   58745, 58746, 58747, 58748, 58749, 58750, 58767);
  for my $a (@artifacts) {
    if (plugin::check_handin(\%itemcount, $a => 1)) {
      quest::say("Well done, $name! This is a treasure. Your keen eye will put another volume on the shelf of our library!");
      quest::emote("holds the item tightly as his eyelids flutter and close. He runs a hand over the artifact and then slowly opens his eyes. 'This has quite a story to tell. I shall scribe it.'");
      if (defined($qglobals{charm_of_lore})) {
        my $count = (defined($qglobals{charm_of_lore_count}) ? $qglobals{charm_of_lore_count} : 0) + 1;
        quest::setglobal("charm_of_lore_count", $count, 5, "F");
        $client->AddLevelBasedExp(5, 0);
        if ($count % 5 == 0) {
          quest::say("Your Charm of Lore pulses warmly as the history it holds deepens.");
        }
        if ($count >= 37 && !quest::checktitle(4102)) {
          quest::enabletitle(4102);
          quest::say("Incredible, $name! Every relic of the Serpent's Spine now has its volume on our shelves. The Guild would name you a Cartographer for this.");
          quest::emote("presses a freshly inked map into your hands and bows deeply.");
        }
      }
      last;
    }
  }
  plugin::return_items(\%itemcount);
}

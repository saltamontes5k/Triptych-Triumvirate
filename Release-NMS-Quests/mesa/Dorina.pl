# Dorina - Goru`kar Mesa
# The Serpent's Spine :: Dorina romance series (tasks 600630-600635).
# A dryad smitten with Simu; #2 summons the Letter to Simu (88110) for the
# courier step, matching the script-summon pattern used elsewhere.

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (quest::istaskactive(600630)) {
      quest::say("Have you [found] out what Simu does with his days?");
    }
    elsif (quest::istaskactive(600631)) {
      quest::say("You still carry my [letter]? Deliver it to Simu - and do not read it!");
    }
    elsif (quest::istaskactive(600632)) {
      quest::say("The [gift] will not gather itself. Recluses and snakes, remember.");
    }
    elsif (quest::istaskactive(600633)) {
      quest::say("The [widows] still crawl. Eight of them, for my pattern.");
    }
    elsif (quest::istaskactive(600634)) {
      quest::say("The [heart] of a bear, still warm if you can manage it.");
    }
    elsif (quest::istaskactive(600635)) {
      quest::say("The [pollen] and a honeycomb - and mind the Tuffein on the road.");
    }
    elsif (!quest::istaskcompleted(600630)) {
      quest::say("Oh! A traveler. Tell me - do you know [Simu]? The drakkin who camps near the minohten?");
    }
    elsif (!quest::istaskcompleted(600631)) {
      quest::say("I have written him a [letter] a dozen times and burned it each time. Perhaps. . . perhaps you could carry one?");
    }
    elsif (!quest::istaskcompleted(600632)) {
      quest::say("He answered! He answered! I must make him a [gift] worthy of the answer.");
    }
    elsif (!quest::istaskcompleted(600633)) {
      quest::say("Silk and fangs are a fine start, but a [pattern] needs widows' thread.");
    }
    elsif (!quest::istaskcompleted(600634)) {
      quest::say("My gift is nearly done - but the potion needs a [heart]. A bear's, if you please.");
    }
    elsif (!quest::istaskcompleted(600635)) {
      quest::say("One last [ingredient], and the charm is complete.");
    }
    else {
      quest::say("He wears the charm, you know. Every day. I have seen it.");
    }
  }
  if ($text=~/Simu/i && !quest::istaskactive(600630) && !quest::istaskcompleted(600630)) {
    quest::say("Find out what he does with his days - walk the minohten camp where he wanders, then speak with him, and come tell me everything!");
    quest::assigntask(600630);
  }
  if ($text=~/found/i && quest::istaskactive(600630)) {
    quest::say("Every small thing matters, when it is him. Now you see.");
  }
  if ($text=~/letter/i && quest::istaskcompleted(600630) && !quest::istaskactive(600631) && !quest::istaskcompleted(600631)) {
    quest::say("Here - take it before I lose my nerve. Deliver it to Simu, wait while he reads, and come straight back!");
    quest::summonitem(88110);
    quest::assigntask(600631);
  }
  if ($text=~/gift/i && quest::istaskcompleted(600631) && !quest::istaskactive(600632) && !quest::istaskcompleted(600632)) {
    quest::say("He really does not know her! Then I shall introduce myself properly - with a gift. Bring me silk and fangs: six mesa recluses and four mesa snakes should do.");
    quest::assigntask(600632);
  }
  if ($text=~/widows/i && quest::istaskcompleted(600632) && !quest::istaskactive(600633) && !quest::istaskcompleted(600633)) {
    quest::say("Eight mesa widows. Their thread shimmers so. Do be careful, won't you?");
    quest::assigntask(600633);
  }
  if ($text=~/heart/i && quest::istaskcompleted(600633) && !quest::istaskactive(600634) && !quest::istaskcompleted(600634)) {
    quest::say("The potion of Anamorata calls for a bear heart. The mesa bears are grumpy and numerous - one heart will do.");
    quest::assigntask(600634);
  }
  if ($text=~/pollen/i && quest::istaskcompleted(600634) && !quest::istaskactive(600635) && !quest::istaskcompleted(600635)) {
    quest::say("Cultivated jumjum pollen and a honeycomb, sweet as he is - and slay any Tuffein guards who try to spoil the finishing touch.");
    quest::assigntask(600635);
  }
}

sub EVENT_ITEM {
  # Consume the bear heart only while Dorina #5 is active (task system
  # handles completion); anything else is returned by the handin system.
  if (quest::istaskactive(600634)) {
    plugin::check_handin(\%itemcount, 88119 => 1);
  }
  plugin::return_items(\%itemcount);
}

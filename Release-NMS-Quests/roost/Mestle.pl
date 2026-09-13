# Mestle - Blackfeather Roost
# The Serpent's Spine :: griffon taming (task 600043 Blackfeather Roost, The Mesa)

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (!quest::istaskcompleted(600043)) {
      quest::say("You have come far, stranger. But the Mesa lies beyond Lady Inthra's reach. Kill her, and I will permit you to travel deeper into the roost. Do you [" . quest::saylink("accept") . "]?");
    }
    else {
      quest::say("Well done. Frail as you seem, you may be up to the task ahead. Speak with my sister Ashrana, and quickly.");
    }
  }
  if ($text=~/accept/i) {
    if (!quest::istaskactive(600043) && !quest::istaskcompleted(600043)) {
      quest::say("Kill her, and return to me when you have done so. Only then will you be permitted to travel deeper into the roost.");
      quest::assigntask(600043);
    }
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}

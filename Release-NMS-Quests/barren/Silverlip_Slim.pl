#-----------------------------------------------------------------------------
# TBS Barren Coast - Silverlip Slim
# npc_types id 422074 (Silverlip_Slim)
# The fence on the receiving end of Murderous Mal's "Deliver the Goods"
# (task 625014, buriedsea). Mal hands the player the Package of Goods
# (88232); turning it in here credits deliver activity 0 of the task, and
# once that leg is done Silverlip hands back the Bill of Sale (88233) to
# carry back to Mal (deliver activity 1, credited in buriedsea).
#-----------------------------------------------------------------------------

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (quest::istaskactive(625014)
        && !quest::istaskactivityactive(625014, 0)
        && quest::istaskactivityactive(625014, 1)) {
      quest::say("So Mal finally found somebody dumb enough to run his errands, eh? Package checked out fine. Here's the " . quest::itemlink(88233) . " -- now get it back to him before I think of a use for it.");
      quest::summonitem(88233);
    } elsif (quest::istaskactive(625014)) {
      quest::say("I don't know what you're hauling, $name, but I only take packages Mal is expecting. Go see him first.");
    } else {
      quest::say("Keep movin', $name. I don't do business with strangers, and I especially don't do business with people Mal talks to.");
    }
  }
}

sub EVENT_ITEM {
  # The Package of Goods (88232) is consumed by the task system when the
  # deliver activity credits; anything else handed here comes back.
  plugin::return_items(\%itemcount);
}

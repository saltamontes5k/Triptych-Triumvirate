# Verkorn - Icefall Glacier
# The Serpent's Spine :: Charming My Dear (600702), Prized Leopard (600707)

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (!quest::istaskcompleted(600702) && !quest::istaskactive(600702)) {
      quest::say("The wolves of the ice test my [" . quest::saylink("charms") . "], but I lack the hearts to make more.");
    }
    elsif (!quest::istaskcompleted(600707) && !quest::istaskactive(600707)) {
      quest::say("There is a [" . quest::saylink("leopard") . "] the Coldeye keep as a pet. Its heart would make my finest totem.");
    }
    else {
      quest::say("The totems sing with your work, $name.");
    }
  }
  if ($text=~/charms/i && !quest::istaskactive(600702) && !quest::istaskcompleted(600702)) {
    quest::say("Bring me hearts of the cave bears and charms from the Coldeye orcs. I will fashion you a totem worthy of the hunt.");
    quest::assigntask(600702);
  }
  if ($text=~/leopard/i && !quest::istaskactive(600707) && !quest::istaskcompleted(600707)) {
    quest::say("Ironfist's pet lives in the orc fort. Beat it near death, press my totem to its heart, and bring the prize back to me.");
    quest::assigntask(600707);
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}

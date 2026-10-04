sub EVENT_SAY {
  if ($text=~/hail/i) {
    my @chain = (600443,600444,600445,600468,600469,600470,600471,600472,600484);
    my $talked = 0;
    foreach my $tsk (@chain) {
      if ($tsk == 600443 && quest::istaskactive(600443)) { quest::say("Twelve drones, ten cocoons. The hatchery still hums."); $talked = 1; last; }
      if ($tsk == 600444 && quest::istaskactive(600444)) { quest::say("Twelve gardeners and five globs of honey."); $talked = 1; last; }
      if ($tsk == 600445 && quest::istaskactive(600445)) { quest::say("Ten slavers, ten drones. The silo still watches."); $talked = 1; last; }
      if ($tsk == 600468 && quest::istaskactive(600468)) { quest::say("Eight rats, eight vipers. The moors are still hungry."); $talked = 1; last; }
      if ($tsk == 600469 && quest::istaskactive(600469)) { quest::say("Six slashclaws, six crocs. Both grounds still crawl."); $talked = 1; last; }
      if ($tsk == 600470 && quest::istaskactive(600470)) { quest::say("Ten Mucktails on the road. The wagons wait."); $talked = 1; last; }
      if ($tsk == 600471 && quest::istaskactive(600471)) { quest::say("Three of each pack. The moors still walk."); $talked = 1; last; }
      if ($tsk == 600472 && quest::istaskactive(600472)) { quest::say("The fens still dream. Wanderers, never-resting, and Duskfall."); $talked = 1; last; }
      if ($tsk == 600484 && quest::istaskactive(600484)) { quest::say("Eight rats, eight vipers. The road remembers."); $talked = 1; last; }
    }
    if (!$talked) {
      foreach my $tsk (@chain) {
        if ($tsk == 600443 && !quest::istaskcompleted(600443) && !quest::istaskactive(600443)) { quest::say("The [hatchery] first - eggtenders and cocoons, before the next swarm hatches."); $talked = 1; last; }
        if ($tsk == 600444 && !quest::istaskcompleted(600444) && !quest::istaskactive(600444)) { quest::say("The [fields] next - gardeners in the jumjum, and their raw honey. Take the honey too; the cooks pay for it."); $talked = 1; last; }
        if ($tsk == 600445 && !quest::istaskcompleted(600445) && !quest::istaskactive(600445)) { quest::say("And the [silo] - slavers and worker drones guarding the grain."); $talked = 1; last; }
        if ($tsk == 600468 && !quest::istaskcompleted(600468) && !quest::istaskactive(600468)) { quest::say("Now - the board wants [hunters]. Prove you can survive the moors: bog rats and vipers."); $talked = 1; last; }
        if ($tsk == 600469 && !quest::istaskcompleted(600469) && !quest::istaskactive(600469)) { quest::say("An [explorer] posting - the slashclaw cliffs and the darkwater pools both need proving."); $talked = 1; last; }
        if ($tsk == 600470 && !quest::istaskcompleted(600470) && !quest::istaskactive(600470)) { quest::say("A [runner] posting - the supply road runs through Mucktail ground."); $talked = 1; last; }
        if ($tsk == 600471 && !quest::istaskcompleted(600471) && !quest::istaskactive(600471)) { quest::say("And the [moorwalkers] return from all four quarters of the moors. Western, Southern, Northern, Eastern."); $talked = 1; last; }
        if ($tsk == 600472 && !quest::istaskcompleted(600472) && !quest::istaskactive(600472)) { quest::say("She [haunts] my dreams, the seer says - the restless dead of the fens, and Duskfall above them."); $talked = 1; last; }
        if ($tsk == 600484 && !quest::istaskcompleted(600484) && !quest::istaskactive(600484)) { quest::say("One more - a [memento] lost on the road, before the rats and vipers found it. Clear them out."); $talked = 1; last; }
      }
    }
    if (!$talked) { quest::say("You have earned your keep a dozen times over, scout. The outpost thanks you."); }
  }
  if ($text=~/hatchery/i) {
    if (!quest::istaskactive(600443) && !quest::istaskcompleted(600443)) {
      quest::say("Twelve eggtender drones and ten waspling cocoons. Burn the brood.");
      quest::assigntask(600443);
    }
    elsif (quest::istaskactive(600443)) { quest::say("Twelve drones, ten cocoons. The hatchery still hums."); }
    else { quest::say("You have earned your keep a dozen times over, scout. The outpost thanks you."); }
  }
  if ($text=~/fields/i) {
    if (!quest::istaskactive(600444) && !quest::istaskcompleted(600444)) {
      quest::say("Twelve gardeners, and five Globs of Raw Honey for the pot.");
      quest::assigntask(600444);
    }
    elsif (quest::istaskactive(600444)) { quest::say("Twelve gardeners and five globs of honey."); }
    else { quest::say("You have earned your keep a dozen times over, scout. The outpost thanks you."); }
  }
  if ($text=~/silo/i) {
    if (!quest::istaskactive(600445) && !quest::istaskcompleted(600445)) {
      quest::say("Ten slavers and ten worker drones. Empty the silo guard.");
      quest::assigntask(600445);
    }
    elsif (quest::istaskactive(600445)) { quest::say("Ten slavers, ten drones. The silo still watches."); }
    else { quest::say("You have earned your keep a dozen times over, scout. The outpost thanks you."); }
  }
  if ($text=~/hunters/i) {
    if (!quest::istaskactive(600468) && !quest::istaskcompleted(600468)) {
      quest::say("Eight giant bog rats and eight moss vipers. Then we talk about real work.");
      quest::assigntask(600468);
    }
    elsif (quest::istaskactive(600468)) { quest::say("Eight rats, eight vipers. The moors are still hungry."); }
    else { quest::say("You have earned your keep a dozen times over, scout. The outpost thanks you."); }
  }
  if ($text=~/explorer/i) {
    if (!quest::istaskactive(600469) && !quest::istaskcompleted(600469)) {
      quest::say("Six slashclaws and six darkwater crocodilians. Walk both grounds and live.");
      quest::assigntask(600469);
    }
    elsif (quest::istaskactive(600469)) { quest::say("Six slashclaws, six crocs. Both grounds still crawl."); }
    else { quest::say("You have earned your keep a dozen times over, scout. The outpost thanks you."); }
  }
  if ($text=~/runner/i) {
    if (!quest::istaskactive(600470) && !quest::istaskcompleted(600470)) {
      quest::say("Ten Mucktail gnolls off the road. The wagons will follow.");
      quest::assigntask(600470);
    }
    elsif (quest::istaskactive(600470)) { quest::say("Ten Mucktails on the road. The wagons wait."); }
    else { quest::say("You have earned your keep a dozen times over, scout. The outpost thanks you."); }
  }
  if ($text=~/moorwalkers/i) {
    if (!quest::istaskactive(600471) && !quest::istaskcompleted(600471)) {
      quest::say("Three of each - Western, Southern, Northern, and Eastern. Then the roads breathe again.");
      quest::assigntask(600471);
    }
    elsif (quest::istaskactive(600471)) { quest::say("Three of each pack. The moors still walk."); }
    else { quest::say("You have earned your keep a dozen times over, scout. The outpost thanks you."); }
  }
  if ($text=~/dreams/i) {
    if (!quest::istaskactive(600472) && !quest::istaskcompleted(600472)) {
      quest::say("Eight wanderers, six of the never-resting, and Duskfall himself.");
      quest::assigntask(600472);
    }
    elsif (quest::istaskactive(600472)) { quest::say("The fens still dream. Wanderers, never-resting, and Duskfall."); }
    else { quest::say("You have earned your keep a dozen times over, scout. The outpost thanks you."); }
  }
  if ($text=~/memento/i) {
    if (!quest::istaskactive(600484) && !quest::istaskcompleted(600484)) {
      quest::say("Eight bog rats and eight vipers. Then the road is ours again.");
      quest::assigntask(600484);
    }
    elsif (quest::istaskactive(600484)) { quest::say("Eight rats, eight vipers. The road remembers."); }
    else { quest::say("You have earned your keep a dozen times over, scout. The outpost thanks you."); }
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}

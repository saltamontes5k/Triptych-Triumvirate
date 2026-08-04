
 sub EVENT_SPAWN {
$randomitem = quest::ChooseRandom(714759, 814759, 81254, 1135, 69303);

$npc->AddItem($randomitem);
}

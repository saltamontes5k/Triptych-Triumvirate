
 sub EVENT_SPAWN {
$randomitem = quest::ChooseRandom(5026,5027,5028,5029,5030,5031,5032,5033,5034,5035,5036,12261,12262,12263,12264,12265,12266);

$npc->AddItem($randomitem);
}

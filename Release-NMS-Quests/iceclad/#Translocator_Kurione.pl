# items: 60333
$instanceid = quest::GetInstanceID();

sub EVENT_SAY {
  if ($text=~/hail/i) {
    quest::say("Hello there. There seems to be some strange problems with the boats in this area. The Academy of Arcane Sciences has sent a small team of us to investigate them. If you need to [" . quest::saylink("travel to North Ro") . "] in the meantime, I can transport you to my companion there. We also just recently discovered that Joshel has been stranded over in the middle of the ocean since the problems with the boats started. If you'd be willing to go see if he's ok, I may be able to [" . quest::saylink("teleport you near there") . "]. Keep in mind though that it will be a one way trip. There is no one on the island able to send you back.");
  }
  if ($text=~/teleport near there/i) {
    quest::MovePCInstance(110, $instanceid, -20288, 3886, -7); # Instance aware to Joshel
  }
  if ($text=~/travel to north ro/i) {
    $client->MovePC(34, 304, 2664, -25, 241); # Old Nro
  }
}

sub EVENT_ITEM {
  # 60333 Joshel's Bandana
  if (plugin::check_handin(\%itemcount,60333=>1)) {
    quest::say("Whew, it's good that you were able to find him, and doing so well. Thanks very much for checking on him for me. I would have done so myself, but with the problems with the boats, I just haven't had the time. Thanks again.");
    quest::exp(1);
    quest::ding();
  }

  plugin::return_items(\%itemcount); # return unused items
}

#End of File, Zone:iceclad  NPC:110073 -- #Translocator_Kurione


$instanceid = quest::GetInstanceID();


sub EVENT_SPAWN {
	quest::say("All to me!");
	if ($zone->GetInstanceVersion() ne quest::get_rule("Custom:StaticInstanceVersion")+0){
		quest::settimer(1,1800);
	}
}

sub EVENT_TIMER  {
if($timer == 1) {
quest::depop();
}
}

sub EVENT_SAY {
if($text=~/hail/i) {
$client->Message(9,"Kill the stormlord!");
quest::MovePCInstance(209, $instanceid, -727,-1662,1728); # Zone: bothunder
}
}

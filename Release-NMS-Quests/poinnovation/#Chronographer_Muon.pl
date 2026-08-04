sub EVENT_SAY {
	if (plugin::check_hasitem($client, 29165) || plugin::check_hasitem($client, 1029165) || plugin::check_hasitem($client, 2029165) || plugin::check_hasitem($client, 18637) || plugin::check_hasitem($client, 1018637) || plugin::check_hasitem($client, 2018637)) {
		if ($text=~/Hail/i) {
			quest::say("Acquisition of power completed. Would you like to be transported to the time-projection chamber?");
		}
		if ($text=~/yes/i) {
			quest::say("Compliance.");
			quest::movepc(206,266,-857,-1853,62); # Zone: poinnovation
                }
	}
}
sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Hail there, $name! If you are not a [member of the White Rose], then it be best that you stay on the lower level. This here floor is for honest ...ermm respectable rogues only.");
	}
	elsif ($text=~/member of the white rose/i) {
		#:: Match if faction is better than indifferent
		if ($faction < 5) {
			quest::say("I hope that you are indeed respectable and loyal to Halas and the Rogues of the White Rose. To do otherwise would bring the wrath of the Six Hammers down on you. But enough with talk! Our caravan to the frigid north leaves in less than two days, and we are short on mammoth calf hides.");
			#:: Send a signal to Halas >> Ysanna_MacGibbon (29070)
			quest::signalwith(29070,1,1);
		}
		else {
			quest::say("The Order of the White Rose does not trust you.");
		}
	}
}


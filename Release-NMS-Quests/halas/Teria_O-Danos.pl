sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Good day to ye! Ye look a wee bit hungrry. I sell many fine foods. Please have a look. Might I suggest the [lion roast]? It is a wee bit expensive, but well worth it.");
	}
	elsif ($text=~/lion roast/i) {
		quest::say("The lion roast is quite good. Tis me specialty. Ah marinate the lion meat in mammoth fat fer two days before roasting it. Lion meat isn't common around here. I'll purchase what I can from strangers but I rely mostly on shipments from the Plains o' Karana. I'm presently searching fer someone to pick up me [lion meat shipment].");
	}
	elsif ($text=~/lion meat shipment/i) {
		quest::say("It'd be grand o' ye to pick up me lion meat shipment. Ye must travel to the Plains o' Karana. Search fer a Northman fishing village. It should be Clan McMannus. Speak with the chieftain, Einhorst. Tell him ye're there to [pick up the lion meat shipment for Halas]. When ye return, I'll pay ye at least three gold. I look forward to yer return.");
	}
	elsif ($text=~/lion delight/i) {
		quest::say("Lion Delight is a trade secrret and brings me much praise. I'll allow only one per customer. I'll also honor all as will pick up the [lion meat shipment] with a fine portion.");
	}
}

sub EVENT_ITEM {
	#:: Match a 13961 - Lion Meat Shipment
	if (plugin::check_handin(\%itemcount, 13961 => 1)) {
		quest::say("Ye've returned!! How wonderful! The people o' Halas thank ye! It isn't often we get to indulge ourselves in the delicacies o' warmer climates. Here ye go, me friend. Ye've completed the delivery in good time. I hope ye deliver more often. Here, try some of me new creation.. Lion Delight.");
		#:: Give a 12221 - Lion Delight
		quest::summonitem(12221);
		#:: Ding!
		quest::ding();
		#:: Set factions
		quest::faction(328, 10);	#:: + Merchants of Halas
		quest::faction(320, 7);		#:: + Wolves of the North
		quest::faction(327, 7);		#:: + Shamen of Justice
		#:: Grant a moderate amount of experience
		quest::exp(1000);
		#:: Create a hash for storing cash - 300 to 350cp
		my %cash = plugin::RandomCash(300,350);
		#:: Grant a random cash reward
		quest::givecash($cash{copper},$cash{silver},$cash{gold},$cash{platinum});
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}

sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Rrrribit.. Please, let me go!! I don't want to be eaten!!");
	}
	elsif ($text=~/glib sent me/i) {
		quest::say("Liessss. ...Groakk.. I do not believe you!! Bring me proof. Bring me the necklace of a basher!! ..Groakk..");
	}
}

sub EVENT_ITEM {
	#:: Match a 13311 - Intestine Necklace
	if (plugin::check_handin(\%itemcount, 13311 => 1)) {
		quest::say("Groak.. So you are a friend to the froglok. ..Grooakk.. I am soon to die. My precious legs are a delicacy here. Before I go I must contact my brother Grikk. He is a froglok forager in Innothule. Give him this vial. He will know what it means");
		#:: Give a 13375 - Empty Vial
		quest::summonitem(13375);
		#:: Ding!
		quest::ding();
		#:: Grant a small amount of experience based on level
		$client->AddLevelBasedExp(10,1);
	}
	#:: Match a 13376 - Ochre Liquid
	elsif (plugin::check_handin(\%itemcount, 13376 => 1)) {
		quest::say("Grooak.. You have done much to help me. This will come in handy soon. Thank you. Here is Marda's information. Take it to her. They must know. Farewell.");
		#:: Give a random reward: 18884 - Tattered Note or 18885 - Tattered Cloth Note
		quest::summonitem(quest::ChooseRandom(18884,18885));
		#:: Ding!
		quest::ding();
		#:: Grant a small amount of experience based on level
		$client->AddLevelBasedExp(14,1);
	}
	#:: Return unused items
	plugin::return_items(\%itemcount);
}

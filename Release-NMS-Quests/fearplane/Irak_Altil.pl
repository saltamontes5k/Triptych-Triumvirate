sub EVENT_SAY {
	if ($text=~/hail/i) {
	 	quest::emote("turns its head upon its dried, cracked spine to look at you with a rictus grin. After staring through you it continues to walk on.");
	}
	elsif ($text=~/what are you mumbling about/i) {
		quest::emote("turns its rotted eyesockets towards you. 'Fallen light, upon this ground I fell. Left to rot, cast out. My holy arms stripped and my soul cast out of the halls. Twisted, failed, disgraced.'");
	}
	elsif ($text=~/disgraced/i) {
		quest::say("Disgrace upon my soul for failing in my duties. Disgrace of my brethren.");
	}
	elsif ($text=~/duties/i) {
		quest::emote("breathes his words from his skeletal mouth as if wind through a valley. 'Sword, shield, breastplate. Twisted to Innoruuks foul will. Must be retrieved and cleansed else my soul is to wander for all time.'");
	}
	elsif ($text=~/sword/i) {
		quest::say("Hands of a twisted brother no longer living.");
	}
	elsif ($text=~/shield/i) {
		quest::say("Earthly children of the god of hate. Keeping stand over his dark brothers and sisters.");
	}
	elsif ($text=~/breastplate/i) {
		quest::emote("lets loose an unearthly howl as it gleams with sickly light. 'Upon she who lured me from my post. In that place where hatred festers. Painful corruption.'");
	}
	elsif ($text=~/cleansed/i) {
		quest::say("The sword must be dipped in water pure. Light of clean spirit to cleanse the shield. A gem of clarity unlike any other for the breastplate. All must be cleansed and returned to the temple for my soul to be freed. Only the temple can cleanse, only they can touch the artifacts. Take the sets of two to the temple. When they are all three cleansed separately take them to him who will grant me atonement.");
	}
}

sub EVENT_ITEM {
	#:: Match a 29010 - Mark of Atonement and a 11050 - Fiery Avenger	
	if (plugin::check_handin(\%itemcount, 29010 => 1, 11050 => 1)) {
		if (plugin::is_stage_complete($client, 'RoK')) {
			quest::emote("screams so loudly it echoes across the valley as the mark and flames of your holy sword touch his rotted bones. As his body twists he quiets and then speaks. 'Your selflessness has made it possible to redeem my honor. With the cleansing of my corruption your own soul has been strengthened. Your power comes from your devotion to your god and with this you have been rewarded. Remember always your purity, devotion, and why you have sacrificed. I must go now to sacrifice myself upon the spear of pain.'");
			#:: Give a 10099 - Fiery Defender
			$client->SummonFixedItem(2010099);
		} else {
			quest::emote(" is not yet ready to deal with these memories, come back when adventurers have breached the Ruins of Kunark.");
		}
	}

	plugin::return_items(\%itemcount);
}
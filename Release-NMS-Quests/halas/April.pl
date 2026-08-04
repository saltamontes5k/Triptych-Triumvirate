sub EVENT_SAY {
	if ($text=~/hail/i) {
		#:: 29 - Wave
		quest::doanim(29);
		quest::say("Hello, $name. I'm a maker of weapon molds. Care to view my wares?");
	}
	elsif ($text=~/wares|molds|weapons/i) {
		quest::say("The various molds that I have for sale are used in the smithing of weapons.  Simply use the necessary molds with a sheet of metal, a forge, and a water flask.  Weapons with hilts and pommels will also need molds for those pieces and weapons such as pole-arms and axes require an oak shaft.");
	}
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}

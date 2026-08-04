sub EVENT_SAY { 
		my $bindme = quest::saylink("bind your soul", 1);
		if($text=~/hail/i){
		plugin::Whisper("Greetings ${name} . When a hero of our world is slain their soul returns to the place it was last bound and the body is reincarnated. As a member of the Order of Eternity  it is my duty to [$bindme] to this location if that is your wish.");
	} elsif($text=~/bind your soul/i) {
	    plugin::Whisper("Binding your soul. You will return here when you die.");
	    quest::selfcast(2049);
	}
}

sub EVENT_SPAWN
{
	$x = $npc->GetX();
	$y = $npc->GetY();
	quest::set_proximity($x - 90, $x + 90, $y - 90, $y + 90);
}

sub EVENT_ENTER
{
	quest::signal(202273,5); #Qadar
}

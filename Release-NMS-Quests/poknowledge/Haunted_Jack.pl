# Haunted Jack - Plane of Knowledge Nights of the Dead candy vendor.
# Free candy is delivered through his merchant list (merchant id 202387).
# Seasonal: his spawn2 is gated by content_flags='peq_halloween'.
sub EVENT_SAY {
	if($text=~/hail/i) {
		quest::say("Happy Nights of the Dead, $name! Care for a [treat]? I've got candy and costumes for everyone!");
	}
	elsif($text=~/treat/i) {
		quest::say("Take your pick! Everything I carry is free... it's the spirit of the season!");
	}
	elsif($text=~/costume/i) {
		quest::say("Spooky Sally, right over there, has all the finest costumes. Go see her!");
	}
}

sub EVENT_SIGNAL {
	quest::say("I can throw pies too!");
}

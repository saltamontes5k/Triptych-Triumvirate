# Spooky Sally - Plane of Knowledge Nights of the Dead costume vendor.
# Free costume kits are delivered through her merchant list (merchant id 202386).
# Seasonal: her spawn2 is gated by content_flags='peq_halloween'.
sub EVENT_SAY {
	if($text=~/hail/i) {
		quest::say("Boo! ...Did I scare you? I'm Spooky Sally, and I've got [costumes] and goodies for the whole family!");
	}
	elsif($text=~/costume/i) {
		quest::say("Browse my wares! Every costume kit is free during Nights of the Dead. Haunted Jack has the candy!");
	}
	elsif($text=~/candy|treat/i) {
		quest::say("Candy? Haunted Jack is your ghoul for that!");
	}
}

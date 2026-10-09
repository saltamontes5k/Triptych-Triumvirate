# a_void_bloodmage - wave mob for "Out With the Old" (kithicor).
sub EVENT_DEATH {
	quest::signal(1500200084, 2);
}

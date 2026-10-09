# Rhaeda Evel - Plane of Knowledge, werewolf by the tree near the main bank.
# 2010 mission "Under Your Skin" (task 620016): root out the true Skinwalker
# hiding at the far east edge of Greater Faydark.  (Live ran this in the
# Snarlstone Dens; eastkorlacha is dz-instanced only on this server, so the
# encounter lives in a remote gfaydark pocket instead.)
# Seasonal (peq_halloween); spawn is flag-gated.
sub EVENT_SAY {
	if (!quest::is_content_flag_enabled('peq_halloween')) {
		quest::say("*A low growl* ... return during the Nights of the Dead.");
		return;
	}
	if ($text=~/hail/i) {
		if (!quest::istaskactive(620016)) {
			quest::say("It wears skin that is not its own and hides among three of itself. [Willing] to pull it out by the root?");
		} else {
			quest::say("[Where] did I say it was hiding?");
		}
	}
	elsif ($text=~/willing/i && !quest::istaskactive(620016)) {
		quest::say("Then listen. Far east of Greater Faydark, past where the trees thin and the world goes quiet, the Skinwalker waits with two of its fakes. Hail it, and watch which one bleeds true. Kill a fake and two more spring up - so find the real one.");
		quest::assigntask(620016);
	}
	elsif ($text=~/where/i && quest::istaskactive(620016)) {
		quest::say("Greater Faydark, the far east edge - beyond the last paths, near the world's rim. It hides in the open there, thinking itself clever.");
	}
}

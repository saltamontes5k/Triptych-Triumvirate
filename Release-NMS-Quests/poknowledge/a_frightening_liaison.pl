# a frightening liaison - Plane of Knowledge, Nights of the Dead mercenary liaison.
# Live-seasonal she fronts the Hunt for Tattooed Flesh; on this server that ledger
# is kept by Edmund Strangeways (master quest 620014). Seasonal: spawn is flag-gated.
sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Boo. Forgive me - occupational habit. I muster mercenary blades for the season's work, though the grave ledger itself belongs to [" . quest::saylink("Edmund Strangeways") . "]. He decides who joins the [" . quest::saylink("hunt") . "].");
	}
	elsif ($text=~/edmund/i) {
		quest::say("The pale fellow in the shadowed quarter, always scribbling. Prove yourself on his burial duties and he may put your name forward.");
	}
	elsif ($text=~/hunt/i) {
		quest::say("Tattooed flesh, from the things that claw out of the disturbed earth. Grim work, honest pay. See Edmund - I only muster, I do not sign.");
	}
}

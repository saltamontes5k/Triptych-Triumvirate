#::: illusion_tools.pl -- DUMMY (2026-11-22)
#:::
#::: The Trevius implementation is retired here. Its RandomFeatures() body does
#::: `use Switch;`, and the bundled Perl (perl/x64/perl, 5.24.4) ships no Switch.pm,
#::: so the file died at compile time and every zone boot logged the pair:
#:::     Can't locate Switch.pm in @INC ... at ./quests\plugins/illusion_tools.pl line 36.
#:::     BEGIN failed--compilation aborted at ./quests\plugins/illusion_tools.pl line 36.
#:::     Compilation failed in require at (eval 37) line 1.
#:::
#::: Nothing calls these subs: no quest script references plugin::RandomFeatures or
#::: plugin::CloneAppearance. The CloneAppearance used elsewhere (shards_partisan.lua,
#::: ascendant_april_fools.pl) is the native C++ Mob::CloneAppearance, not this plugin.
#::: They stay defined as no-ops so a script that still calls them cannot die with
#::: "Undefined subroutine".
#:::
#::: Original implementation: `git log -- Release-NMS-Plugins/illusion_tools.pl`
#::: (the revision immediately before this stub has the full Trevius body).

sub RandomFeatures {
	return;
}

sub CloneAppearance {
	return;
}

return 1; # Plugins may or may not require this return line.

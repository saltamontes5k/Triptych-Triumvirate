sub EVENT_SAY {
	if ($text=~/hail/i) {
		quest::say("Howdy, $name. Welcome to Miller's Farmstead. I am Cleet Miller. [Henina] and I own this here field o' crops. Look out if you go a-wandering in the field because there are a bunch of nasty scarecrows who call this farm home and don't like strangers.");
	}
	elsif ($text=~/henina/i) {
		quest::say("Henina is my loving wife of twenty-five years. She is a beautiful woman and the proud mother of five great kids; [Cleet Junior], [Baobob], [Tiny], [Chanda], and [Furball]. Henina loves them all very much, even though most of them ain't our natural-born children.");
 	} 
	elsif ($text=~/furball/i) {
		quest::say("Furball was just a pup when we saw him tussling with a scarecrow in the fields one day. He was all torn up by the time Tiny chased the 'crow off him. He was hurt bad and couldn't git back to [Blackburrow] 'cause his pa would've killed him for returning a failure. Those [Sabertooths] have some weird and dangerous customs. Henina tended to his wounds and taught him how to behave proper. He gets feisty sometimes, but we love him just the same and he helps out quite a bit on the farm.");
	} 
	elsif ($text=~/blackburrow/i) {
		quest::say("Blackburrow is northwest of here. It is home to a tribe of gnolls known as the Sabertooths. Our own son Furball came from there");
	}
	elsif($text=~/sabertooth/i) {
		quest::say("The Sabertooths of Blackburrow are a bloodthirsty clan of gnolls who claim the Hills of Qeynos as their homeland. The people of [Qeynos] don't exactly respect that claim, o' course.");
	}
	elsif($text=~/qeynos/i) {
		quest::say("Qeynos is due west of here. It is a fine city, one of the finest humanity has. Although I believe it may be built on ancestral gnoll land as the Sabertooths claim. The Qeynos Hills run along the west coast of Antonica and stretch from North Qeynos in the south to Surefall Glade in the north to the Plains of Karana in the east.");
	}
	elsif ($text=~/chanda/i) {
		quest::say("Chanda and Baobob don't live with us here on the farm anymore.  They are hunters and tanners and moved west several seasons ago.  I am quite proud of them.  When we found them, they were just toddlers.  The caravan they and their momma were traveling with was attacked by bandits.  Baobob managed to spirit his sister away to safety but their momma died that day.  Tiny found them sleeping in our field and we took them in and raised them as our own.");
	}
	elsif ($text=~/baobob/i) {
		quest::say("Chanda and Baobob don't live with us here on the farm anymore.  They are hunters and tanners and moved west several seasons ago.  I am quite proud of them.  When we found them, they were just toddlers.  The caravan they and their momma were traveling with was attacked by bandits.  Baobob managed to spirit his sister away to safety but their momma died that day.  Tiny found them sleeping in our field and we took them in and raised them as our own.");
	}
	elsif ($text=~/tiny/i) {
		quest::say("Tiny?  Oh... Tiny is my adoped son.  Me and Henina have taken in all sorts of orphans and given them a home.  Henina rescued Tiny from a mob that had killed his momma.  He is a good boy and strong as can be.  He helps us out a great deal even though some of our neighbors out here can't look past the fact that he's an ogre.  Heck, he don't even eat meat, let alone people!");
	}
	elsif ($text=~/cleet junior/i) {
		quest::say("Cleet Jr. is the youngest and the only natural-born child Henina and I have.  He is a bit of a troubled lad and resents the hard work of a farmer's life.  I hope he comes around and takes over the farm when I am dead and gone.");
	}
	elsif ($text=~/scarecrows/i) {
		quest::say("The scarecrows?  We don't know where they came from - just showed up here one night.  We let them be and they don't seem to mind us none.  They keep strangers out of our fields, that's for sure.");
	}
	elsif ($text=~/lempeck/i) {
		quest::say("Lempeck is our farmhand. He has been feeling ill ever since that mangy wolf bit him the other day.");
	}
}

sub EVENT_ITEM {
	#:: Return unused items
	plugin::return_items(\%itemcount);
}

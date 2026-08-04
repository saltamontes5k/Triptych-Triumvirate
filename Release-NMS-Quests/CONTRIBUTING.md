Coding conventions

Start reading our code and you'll get the hang of it. 

Readability is key--we want anyone who can install an EQEmu Server from the installation script that Akkadius created to be able to understand our code, even if they haven't been exposed to the EQEmu Quest API.

Please feel free to contribute at any time, but do include sources (non-Emu sources).

* We indent using tabs set to 8 spaces.
* We ALWAYS put spaces after list items and method parameters ([1, 2, 3], not [1,2,3]), around operators (x += 1, not x+=1), and around hash arrows.
* We ALWAYS comment database IDs (factions, items, npc_types, etc.).
* Please try to use Data Buckets instead of Quest Globals wherever you can--they're far more performant.

These are open source quest scripts. Consider the people who will read your code, and make it look nice for them. It's sort of like flying a plane: save the loop de loops for when you're alone, and make the ride as smooth as possible for everyone else.

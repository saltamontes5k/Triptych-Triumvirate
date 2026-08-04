
sub EVENT_SAY {

if ($text =~/Hail/i){
  quest::say("Hail $name! What would you like to know? [What inspired you initially?], [Did you have some ideas as to how an online RPG might work?], [Did Ultima Online influence EverQuest?], [Did you ever think EverQuest might not work?], [Was it easier to be creative and ambitious back in the day?], [Did you always take the philosophy that bigger is better?], [EverQuest is famed for its difficulty was this deliberate?], [Corpse runs, who was responsible?], [What were your grand ambitions for EverQuest]");
}


if ($text =~/What inspired you initially?/i){

quest::say("Making a 3D online RPG was John Smedley's idea. Steve Clover and I were working on a 2D single player RPG called WarWizard 2 at the time. Our inspiration came from the desire to create a 3D fantasy world as well as from playing text MUDs (especially Sojourn/TorilMUD).");
}


if ($text =~/Did you have some ideas as to how an online RPG might work?/i){


quest::say("Very much so. When I play games, especially those I enjoy, I always think about the mechanics: what makes a game fun, what makes it tick? In the early 90s I played a lot of MUDs. Some were fun, some were not. I was always trying to figure out how to make them better. In fact I used to post on Usenet about MUDs, ranting about what I thought were bad changes and nerfs. Later, when people would rant about EQ, I would always try to look at the issue from both a developer's and a player's standpoint.");
}



if ($text =~/Did Ultima Online influence EverQuest?/i){

quest::say("Absolutely. First, it gave us confidence that an MMORPG could be commercially viable. It also reinforced our belief that unrestricted PvP was a bad thing. We'd played PvP MUDs in the past and were not fans of them. The wanton PvP in UO confirmed for us that we wanted to make a primarily PvE game. On the other hand, UO taught us that crafting was destined to be a big part of MMORPGs. Our initial design had zero crafting and it was UO that convinced us that we needed to put a crafting system into EQ.");

}

if ($text =~/Did you ever think EverQuest might not work?/i){
quest::say("I think technically there were a few problems that really scared us. One was 3D performance. In a single player game you can control how many characters are in any given scene. But with an online game any number of players might choose to congregate in a single area. EQ started using a software-rendered engine but we went to hardware-only later in development because of performance (and visual) issues. John Buckley, who was one of the engineers of the original EQ engine came on board and he and others really saved us by optimizing character models and addressing other performance issues. Another was the network code. MMOs send and receive tons of little packets, which is very different from typical web network traffic. We knew we couldn't use TCP/IP like UO - it was just too slow. Vince Harron came in a created a reliable UDP framework and it really saved us. We also found out in beta that there just wasn't enough bandwidth coming into San Diego to accommodate EQ. Also, the millions of tiny packets were too much for routers to handle at that time. Thankfully we were able to get more bandwidth and newer, more powerful routers in the nick of time. While these issues frustrated many players, they didn't last long enough for people to actually give up on the game.");
}
if ($text =~/Was it easier to be creative and ambitious back in the day?/i){
  quest::say ("I think so, yes. Not only was the MMORPG genre relatively new, but so were we. Probably half of the team or more had never worked in the professional game industry. So we had no idea what would or wouldn't work. We were fearless and persevered through trial and error. Other people in the online industry were skeptical as to whether we could pull it off, but we didn't let that affect us. The newness of the genre also let us get away with issues that players now probably would not tolerate, like performance, UI issues, difficulty, lack of polish, etc.");
}
if ($text =~/Did you always take the philosophy that bigger is better?/i){
  quest::say("We believed from the very beginning that Content is King. While some other games would leave the end-game to PvP, we wanted there to be compelling content all the way from level 1 to 50. Having lots of races, classes, items, zones, etc. was always the plan.");
}
if ($text =~/EverQuest is famed for its difficulty was this deliberate?/i){
  quest::say("We made the game we ourselves wanted to play. We wanted a challenging game where players could get a real sense of accomplishment, where risk vs. reward really meant something. The more difficult games we'd played, both online and offline, were the ones we both enjoyed and fondly remembered. Was this the right approach from a commercial standpoint? Perhaps not. If I had a time machine I'd probably go back and do some of the things WoW later proved to be more mass market (though that would probably make me feel like a sell-out). In the end, though, EQ has grossed over a half a billion dollars. So while the game could have been easier, more polished, etc., it's not like we made something totally niche or esoteric. We were just lucky that the game we wanted to play was also a game that millions of others would enjoy as well.");
}
if ($text =~/Corpse runs, who was responsible?/i){
  quest::say("I'm probably the must culpable. Some of my favorite memories playing MUDs and then later EQ are the corpse runs. Having friends and guild mates log on late into the evening and risk everything to save us - it was challenging, even frustrating, but in the end the comradery and team-work employed made for the most fun I've had playing online games.");
}
if ($text =~/What were your grand ambitions for EverQuest/i){
  quest::say("I think the big ambition was to make a game we could be proud of, that we would enjoy playing, and where hopefully there were enough other people out there that would feel the same way. We knew that a good text MUD was very compelling - players would play all day and all night. But those were primarily kids in college. If we took similar mechanics and combined them with a 3D virtual world, would it be commercially viable? Were there only relatively few people (us and the college kids) who wanted a game like EQ? Or was that 'addictive' quality something that millions would enjoy? That was the big risk and our ambition was to be correct in our assumption: that a 3D graphical MUD could be a commercial success as well.");
}
}

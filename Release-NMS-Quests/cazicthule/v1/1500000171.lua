local STOP_TEXT = {
	"Now this looks like a mask!  Give me a moment to draw this thing in my journal.  It will only take a second. I'm a genius you know, though my job is very difficult.",
	"My map is paying off.  This mask is just where they said it would be.  Just give me a minute to scribble this down and we'll continue.  Please continue to scan the room.  I'll feel much better if you're eaten first... err... if you watch my back.",
	"Oh joy, there's nothing down this hallway.  That will teach me to follow you again.  Let me look at my map and see if I can undo your handy work.  One moment please. Shheeesh!",
	"Well, that was a nice little trek.  Take a breather while I note this area in my journal.  I know that you must be tired.  I haven't seen a head as large as yours in quite some time.  Lean it against the wall or something.  We'll need to leave in a moment.",
	"You're doing a great job!  I'll just need a moment to make a few notes.  Feel free to stand there and defend me with your life.  Really, I don't mind the attention.  If you see a monster, just yell.  I'll be right behind you.",
	"Well look at this thing!  A splendid example of a Tae Ew sacrificial death mask or something.  At first glance, this thing looked like beautifully carved wood, but alas it is just skin.",
	"Well, here we are.  See, you didn't even have to break a sweat.  I'm all ready to... hmm... wait, I seem to have dropped my favorite quill.  Did you pick it up by chance?  I'll add a little something to your payment if you did.",
};

local ROUTES = {
	{ 1, 2, 5, 8, 7, 10, 13 },
	{ 1, 3, 12, 4, 6, 9, 11 },
	{ 1, 3, 12, 5, 8, 7, 11 },
};
local GRIDS = {
	[1] = { g = 100081, endWp = 17, stopText = 1, ambush = 1 },  -- pyramid to H1
	[2] = { g = 100082, endWp = 24, stopText = 2, ambush = 2 },  -- H1 to H2
	[3] = { g = 100083, endWp = 15, stopText = 6, ambush = 6 },  -- H1 to C
	[4] = { g = 100084, endWp = 22, stopText = 3, ambush = 3 },  -- H2 to H3
	[5] = { g = 100085, endWp = 34, stopText = 4, ambush = 4 },  -- H2 to H4
	[6] = { g = 100086, endWp = 30, stopText = 4, ambush = 4 },  -- H3 to H4
	[7] = { g = 100087, endWp = 30, stopText = 5, ambush = 5 },  -- H3 to H5
	[8] = { g = 100088, endWp = 23, stopText = 3, ambush = 3 },  -- H4 to H3
	[9] = { g = 100089, endWp = 11, stopText = 5, ambush = 5 },  -- H4 to H5
	[10] = { g = 100090, endWp = 29, stopText = 6, ambush = 6 }, -- H5 to C
	[11] = { g = 100091, endWp = 18, stopText = 7 },             -- H5 to pyramid
	[12] = { g = 100092, endWp = 6,  stopText = 2, ambush = 2 }, -- C to H2
	[13] = { g = 100093, endWp = 13, stopText = 7 },             -- C to pyramid
};
local AMBUSHES = {
	{ x = -440, y = 27,  z = 3,   g = 100094 },
	{ x = -374, y = -5,  z = 3,   g = 100095 },
	{ x = -237, y = -37, z = 3,   g = 100096 },
	{ x = -91,  y = 329, z = 3.7, g = 100097 },
	{ x = -251, y = 536, z = 3,   g = 100098 },
	{ x = -400, y = 62,  z = 4.3, g = 0 },
};
local BROWN1_TYPE = 1500000151;
local BROWN2_TYPE = 1500000170;
local GREEN1_TYPE = 1500000148;
local GREEN2_TYPE = 1500000169;
local TRACKER_TYPE = 1500000152;
local PAUSE_TIMER = 118000;

local route, segment, spawnedTracker, eventComplete;
local started = false;

function event_spawn(e)
	started = false;
	spawnedTracker = false;
	eventComplete = false;
	eq.set_timer("idle", 1200000);
end

function event_say(e)
	if ( not started and e.message:findi("hail") ) then
		e.self:Say("Well look at you! You see, you're off to a great start!  Now, just follow me and yell out if something stabs you or maims you in anyway.  Never fear, I've memorized gate and have complete confidence in your ability to fend off danger for at least five seconds.  Follow me... follow me.");
		e.self:Say("When you are ready to begin this little stroll, just tell me that you are [ready].");
	elseif ( not started and e.message:findi("ready") ) then
		started = true;
		eq.stop_timer("idle");
		route = math.random(1, #ROUTES);
		segment = 1;
		e.self:AssignWaypoints(GRIDS[ROUTES[route][segment]].g);
	end
end

function event_waypoint_arrive(e)
	if ( not started or eventComplete ) then
		return;
	end
	if ( e.wp == GRIDS[ROUTES[route][segment]].endWp ) then
		e.self:Say(STOP_TEXT[GRIDS[ROUTES[route][segment]].stopText]);
		if ( segment == 7 ) then
			eventComplete = true;
			eq.set_timer("depop", 1800000);
		else
			eq.set_timer("pause", PAUSE_TIMER);
			local ambushType = math.random(1, 4);
			local ambush = AMBUSHES[GRIDS[ROUTES[route][segment]].ambush];
			if ( ambushType == 1 ) then
				eq.spawn2(BROWN1_TYPE, ambush.g, 0, ambush.x, ambush.y, ambush.z, 0);
				if ( math.random(100) > 50 ) then
					eq.spawn2(BROWN1_TYPE, ambush.g, 0, ambush.x, ambush.y, ambush.z, 0);
				end
			elseif ( ambushType == 2 ) then
				eq.spawn2(BROWN2_TYPE, ambush.g, 0, ambush.x, ambush.y, ambush.z, 0);
				if ( math.random(100) > 50 ) then
					eq.spawn2(BROWN2_TYPE, ambush.g, 0, ambush.x, ambush.y, ambush.z, 0);
				end
			elseif ( ambushType == 3 ) then
				local num = math.random(5, 6);
				for i = 1, num do
					eq.spawn2(GREEN1_TYPE, ambush.g, 0, ambush.x + math.random(-2, 2), ambush.y + math.random(-2, 2), ambush.z + math.random(-2, 2), 0);
				end
			else
				local num = math.random(3, 4);
				for i = 1, num do
					eq.spawn2(GREEN2_TYPE, ambush.g, 0, ambush.x + math.random(-2, 2), ambush.y + math.random(-2, 2), ambush.z + math.random(-2, 2), 0);
				end
			end
		end
	end
end

function event_timer(e)
	if ( e.timer == "idle" ) then
		eq.depop();
	elseif ( e.timer == "pause" ) then
		e.self:Say("Alrighty, off we go!");
		if ( segment == 6 and not spawnedTracker ) then
			e.self:Say("Ack ack ack! Eat them not me!");
			eq.spawn2(TRACKER_TYPE, 0, 0, e.self:GetX(), e.self:GetY(), e.self:GetZ(), 0);
			spawnedTracker = true;
			eq.set_timer("pause", PAUSE_TIMER);
			return;
		end
		segment = segment + 1;
		e.self:AssignWaypoints(GRIDS[ROUTES[route][segment]].g);
		eq.stop_timer("pause");
	elseif ( e.timer == "depop" ) then
		eq.depop();
	end
end

function event_trade(e)
	local item_lib = require("items");
	if ( eventComplete and item_lib.check_turn_in(e.trade, {item1 = 8723}) ) then -- A Tiny Metal Quill
		e.self:Emote("begins to cast a spell.  Gimlik says, 'Well, you've got a good eye on you for being so daft.  Thank you for returning my quill. Take care!'  Gimlik gates.");
		-- Tiny Gear Shaped Earring, Rough Steel Cog Earring, Iron Cog Earring, Shiny Cog Earring, Cogboggle's Clockwork Contraption
		e.other:QuestReward(e.self, 0, 0, 0, 0, eq.ChooseRandom(8726, 8727, 8728, 8729, 8730));
		eq.depop();
	end
	item_lib.return_items(e.self, e.other, e.trade);
end

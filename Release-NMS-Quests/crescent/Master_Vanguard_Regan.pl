# Master Vanguard Regan - Crescent Reach
# The Serpent's Spine :: Wanderlust Guild chain
# #1 600050 On Guard, #2 600207 The Crossroads, #3 600208 Far Afield (Gimlek),
# #4 600209 Into the Reeds, #5 600212 All Abuzz (Fiskar), #6 600224 Northbound Trails,
# #7 600225 Pie-Eyed Pipers (Vulu), #8 600226 West of the Mesa, #9 600227 Spring in Your Step,
# #10 600228 Into the Mines, #11 600200 Into the Spine, #12 600201 Meet Your Map Maker,
# #16 600205 The Journey Beyond, #18 600229 Into the Reliquary.
# #13/#14/#15/#17 are assigned by Cartographer Wyl`ard in The Steppes.
# Located on the second floor west of the elevator, at -1360, -1340.

sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (!quest::istaskcompleted(600050) && !quest::istaskactive(600050)) {
      quest::say("Welcome to the Wanderlust Guild, $name. We seek those who would investigate and explore. I almost always have places in the world I would like you to see. For now, would you explore some areas of Blightfire Moors? Will you [" . quest::saylink("do this") . "] for me?");
    }
    elsif (quest::istaskactive(600050)) {
      quest::say("You still have landmarks to find in Blightfire Moors, $name.");
    }
    elsif (!quest::istaskcompleted(600207)) {
      quest::say("Well travelled! There is a wanderer in Blightfire Moors I would like you to meet. Will you [" . quest::saylink("seek out the crossroads") . "] for me?");
    }
    elsif (!quest::istaskcompleted(600208)) {
      quest::say("Wanderer Gimlek has more landmarks for you to find out in the moors, $name.");
    }
    elsif (!quest::istaskcompleted(600209)) {
      quest::say("There is a pilgrim studying the reeds of Blightfire Moors. Will you [" . quest::saylink("into the reeds") . "] and find him?");
    }
    elsif (!quest::istaskcompleted(600212)) {
      quest::say("Pilgrim Fiskar could use your help scouting the lands around Stone Hive, $name.");
    }
    elsif (!quest::istaskcompleted(600224)) {
      quest::say("The trails of Goru`kar Mesa call. Will you [" . quest::saylink("northbound trails") . "] and find Pioneer Vulu?");
    }
    elsif (!quest::istaskcompleted(600225)) {
      quest::say("Pioneer Vulu has more of Goru`kar Mesa for you to map, $name.");
    }
    elsif (!quest::istaskcompleted(600226)) {
      quest::say("The western reaches of the mesa remain uncharted. Will you [" . quest::saylink("west of the mesa") . "] for me?");
    }
    elsif (!quest::istaskcompleted(600227)) {
      quest::say("The springs of Sunderock are a wonder to behold. Will you go and [" . quest::saylink("spring in your step") . "] for me?");
    }
    elsif (!quest::istaskcompleted(600228)) {
      quest::say("The Vergalid Mines are deep and dark. Will you venture [" . quest::saylink("into the mines") . "] for me?");
    }
    elsif (!quest::istaskcompleted(600200)) {
      quest::say("There is always more of the world to see. Will you venture [" . quest::saylink("into the Spine") . "] for me?");
    }
    elsif (!quest::istaskcompleted(600201)) {
      quest::say("Our Cartographer Wyl`ard is mapping the far lands. Will you [" . quest::saylink("meet your map maker") . "] in The Steppes and assist him?");
    }
    elsif (!quest::istaskcompleted(600204)) {
      quest::say("Cartographer Wyl`ard continues his work in The Steppes. Please assist him, $name.");
    }
    elsif (!quest::istaskcompleted(600205)) {
      quest::say("Hello, $name. You have traveled far and helped Wyl`ard greatly. Shall we test your knowledge? I would like you to prove you can find your way out [" . quest::saylink("abroad again") . "].");
    }
    elsif (!quest::istaskcompleted(600206)) {
      quest::say("Wyl`ard needs a rough map of Frostcrypt. Please assist him, $name.");
    }
    elsif (!quest::istaskcompleted(600229)) {
      quest::say("One last place remains. Will you venture [" . quest::saylink("into the reliquary") . "] for me?");
    }
    else {
      quest::say("You have done the Guild proud, $name. Wyl`ard's maps grow richer by the day.");
    }
  }
  if ($text=~/do this/i && !quest::istaskactive(600050) && !quest::istaskcompleted(600050)) {
    quest::say("Locate the Guard Outpost, search for a dark tower in the northern region, and find the Slashclaw Cliffs to the southern end of the territory. Good luck.");
    quest::assigntask(600050);
  }
  if ($text=~/seek out the crossroads/i && quest::istaskcompleted(600050) && !quest::istaskactive(600207) && !quest::istaskcompleted(600207)) {
    quest::say("Find Wanderer Gimlek at the crossroads in Blightfire Moors. He knows the moors better than any of us.");
    quest::assigntask(600207);
  }
  if ($text=~/into the reeds/i && quest::istaskcompleted(600208) && !quest::istaskactive(600209) && !quest::istaskcompleted(600209)) {
    quest::say("Pilgrim Fiskar has been studying the reeds and the strange buzzing of the moors. Find him and see what he needs.");
    quest::assigntask(600209);
  }
  if ($text=~/northbound trails/i && quest::istaskcompleted(600212) && !quest::istaskactive(600224) && !quest::istaskcompleted(600224)) {
    quest::say("Pioneer Vulu has been blazing trails through Goru`kar Mesa. Find him and assist him.");
    quest::assigntask(600224);
  }
  if ($text=~/west of the mesa/i && quest::istaskcompleted(600225) && !quest::istaskactive(600226) && !quest::istaskcompleted(600226)) {
    quest::say("Explore the old home of the giants, Dromrek Jaunt, the path to Blackfeather Roost, the graveyard within, and the lost Nymph soul. Report back to me.");
    quest::assigntask(600226);
  }
  if ($text=~/spring in your step/i && quest::istaskcompleted(600226) && !quest::istaskactive(600227) && !quest::istaskcompleted(600227)) {
    quest::say("Travel to Sunderock Springs. Explore the Crusader camp and find the North, South, East, and West Spires. Then report back to me.");
    quest::assigntask(600227);
  }
  if ($text=~/into the mines/i && quest::istaskcompleted(600227) && !quest::istaskactive(600228) && !quest::istaskcompleted(600228)) {
    quest::say("Inquirer Galstat is studying the Vergalid Mines. Find him, explore the Flooded Caves, the Burial Chamber, and the Shrine of Zek, then report to him and to me.");
    quest::assigntask(600228);
  }
  if ($text=~/into the Spine/i && quest::istaskcompleted(600228) && !quest::istaskactive(600200) && !quest::istaskcompleted(600200)) {
    quest::say("Travel the Direwind Cliffs and see what the Spine holds. Report back when you have scouted the area.");
    quest::assigntask(600200);
  }
  if ($text=~/meet your map maker/i && quest::istaskcompleted(600200) && !quest::istaskactive(600201) && !quest::istaskcompleted(600201)) {
    quest::say("Cartographer Wyl`ard has been exploring and mapping the far lands for the people of Crescent Reach. His last report came from The Steppes. Report to him and assist him in any way possible.");
    quest::assigntask(600201);
  }
  if ($text=~/abroad again/i && quest::istaskcompleted(600204) && !quest::istaskactive(600205) && !quest::istaskcompleted(600205)) {
    quest::say("Visit Blightfire Moors, Goru`kar Mesa, and The Steppes, and report back to me. Prove you can find your way out abroad again.");
    quest::assigntask(600205);
  }
  if ($text=~/into the reliquary/i && quest::istaskcompleted(600206) && !quest::istaskactive(600229) && !quest::istaskcompleted(600229)) {
    quest::say("Ashengate, Reliquary of the Scale, holds the last of the landmarks. Find the Artifact, the top of the Shattered Halls, the Stone Span, the Nesting Grounds, and the lava pools. Report back to me.");
    quest::assigntask(600229);
  }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}

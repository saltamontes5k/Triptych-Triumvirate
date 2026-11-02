-- Freeport Porter: carries adventurers to West Freeport (the Prophecy of Ro city).
-- Ungated on purpose: freeportwest is already walk-in via the ungated East
-- Commonlands zone line; this porter is the convenience route from the classic city.
function event_say(e)
  if e.message:findi("hail") then
    eq.get_entity_list():MessageClose(e.self, true, 100, MT.SayEcho, "The Freeport Porter says, 'Past the harbor fog waits another Freeport, the city as the Prophecy of Ro remade it, with gates to the North Ro desert and passages to Arcstone. I can carry you there, if you are [" .. eq.say_link("ready") .. "]. The way back lies open through the city gates.'")

  elseif e.message:findi("ready") then
    e.other:MovePC(383, 339, 12, -23, 384) -- Zone: freeportwest (West Freeport)
  end
end

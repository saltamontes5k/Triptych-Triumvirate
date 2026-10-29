-- Original concise dialogue. Native task engine handles exploration/hails/completion and rewards.
local offers = {
  { id=3039401, previous=0, level=15 },
  { id=3039402, previous=3039401, level=15 },
  { id=3039404, previous=3039403, level=15 },
  { id=3039406, previous=3039405, level=25 },
  { id=3039408, previous=3039407, level=45 },
  { id=3039409, previous=3039408, level=55 },
  { id=3039410, previous=3039409, level=55 },
  { id=3039411, previous=3039410, level=60 },
  { id=3039412, previous=3039411, level=60 },
  { id=3039416, previous=3039415, level=65 },
  { id=3039418, previous=3039417, level=75 },
}
local function completed(id)
  local v = eq.is_task_completed(id)
  return v == 1 or v == true
end
function event_say(e)
  if e.message:lower():find("hail", 1, true) then
    e.self:Say("Welcome, traveler. Ask to [explore] when you are ready for another journey.")
    return
  end
  if not e.message:lower():find("explore", 1, true) then return end
  local choices = {}
  for _, offer in ipairs(offers) do
    local active = eq.is_task_active(offer.id)
    if not completed(offer.id) and active ~= 1 and active ~= true and
       (offer.previous == 0 or completed(offer.previous)) and e.other:GetLevel() >= offer.level then
      choices[#choices + 1] = offer.id
    end
  end
  if #choices > 0 then eq.task_selector(choices)
  else e.self:Say("Finish your current exploration, or gain more experience before continuing.") end
end

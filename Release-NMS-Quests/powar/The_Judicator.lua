-- powar: The Judicator — the Field of Strife's winged verdict.
-- Loot: The Warlord's Blessing (PoWar_Judicator). Pets draw his eye first,
-- per Bonzz - reflected in the emote only.
local P = require("powar_shared")

function event_spawn(e)
  eq.zone_emote(15, "The sound of wings grows louder. Something with a mace and a verdict descends toward the Field of Strife...")
end

function event_combat(e)
  if e.joined then
    e.self:Shout("THE FIELD HAS JUDGED. THE SENTENCE IS WEIGHT.")
  end
end

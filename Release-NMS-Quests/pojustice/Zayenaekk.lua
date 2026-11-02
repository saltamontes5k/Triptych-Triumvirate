----------------------------------------------------------------------
-- Zone: PoJustice
-- NPC: Zayenaekk (201281)
-- PoP-ized powar tithe chain, first leg (Bonzz pow.htm). The original PEQ
-- flavor hail is kept for players who have not started the tithe.
----------------------------------------------------------------------
local P = require("powar_shared")
local item_lib = require("items")

function event_say(e)
    local c = e.other
    if (e.message:findi("hail")) then
        if (P.flagged(c, "tithe_jus")) then
            e.self:Say("flaps her wings and raises her chin high and proud as she gazes down upon " .. e.other:GetName() .. ", 'The tithe has been spoken. My sister Zayenaek waits in the Plane of Valor — carry it to her.'");
        elseif (P.get(c, "tithe_started")) then
            P.set(c, "tithe_jus", "1")
            e.self:Say("flaps her wings and raises her chin high and proud as she gazes down upon " .. e.other:GetName() .. ", 'Za`ye`na`ekk... long has it been since that name was spoken aloud. Ets`in`thini`konar`ifet still guards the wall, then? Very well — the tithe continues. Seek my sister Zayenaek in the Plane of Valor. Tell her: I seek the blessing of your sister.'");
        else
            e.self:Say("flaps her wings and raises her chin high and proud as she gazes down upon " .. e.other:GetName() .. ", 'You stand before Zayenaekk -- servant of Murdunk and prisoner now of the Tribunal. It has been many years since our paths last crossed, " .. e.other:Race() .. ", but there is nothing more to this being than the formerly stated. Move along, " .. e.other:GetName() .. ". This is not a realm for the free to wander.'");
        end
    end
end

function event_trade(e)
    item_lib.return_items(e.self, e.other, e.trade)
end

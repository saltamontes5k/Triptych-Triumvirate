-- [[
-- the_M_E_G (460533) -- MMM Brinda event, password receptacle (non-hostile).
-- On live, players say the three recovered passwords to it in order. EQS
-- simplifies the ritual: M.E.G. is flavour, and the three password enforcers
-- (460534) drive completion. Rasper: raidMMM.html stage 3.
-- ]]

function event_say(e)
    if e.message:findi("hail") then
        e.self:Say("M.E.G. READY. FEED ME THE PASSWORDS, LITTLE GEARS.")
    elseif e.message:findi("password") or e.message:findi("fragment") then
        e.self:Say("FRAGMENTS DETECTED IN THE ENFORCERS. TEAR THEM FROM XLI, LXXII AND CXIII.")
    end
end

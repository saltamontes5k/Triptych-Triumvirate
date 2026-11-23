-- Gates of Discord progression guide, shared by the Abysmal Sea dialogue
-- (Saney Jakis) and the clicky guide item (global/items/9015301.lua).

local M = {}

M.CLICKY_ID = 9015301

M.sections = {
    "GoD GUIDE 1/6 - OVERVIEW / BREAKDOWN IN COMMUNICATION: " ..
    "Begin in the Abysmal Sea with Fezbin Fizzles. Speak to Taminoa Bialu, Vaifan Cogswin and " ..
    "L`diava Rexxen, complete their scouting reports, then return to Fezbin. Beanalle Banoam " ..
    "then sends you for the four Shards of Dark Matter from Qvic, Inktu'ta, Txevu and Tacvi. " ..
    "Fezbin Fizzles can swap your augment if you want a different one.",

    "GoD GUIDE 2/6 - GROUP INSTANCES: " ..
    "In Barindu, Apprentice Udranda opens the way. The Sewers of Nihilia: Purifying Plant is " ..
    "first (destroy the aged stonemites, then the Ancient Kayserops). Then Vxed - speak to " ..
    "Stonespiritist Ekikoa - and Tipt - solve Rikabi the Riddler's riddle. Finish with the " ..
    "Outer Regions scouting report and return to Vaifan Cogswin with the charged power pack.",

    "GoD GUIDE 3/6 - KOD'TAZ: " ..
    "Speak to Kevren Nalavat, then Tublik Narwethar. Complete the three group Ikkinz trials " ..
    "(Gazak Klelkek, Maroley Nazuey, Kenra Kalekkio). Static events: Temple of the Damned " ..
    "(/open the bones), Pit of the Lost (collect four Minor Relics of Energy from the Forlorn " ..
    "Relic Devotee, combine in Tublik's Bag, then kill the Ageless Relic Protector), and the " ..
    "Summoner Ring (nine Pixtt Priest Summoners, then the Grand Summoner).",

    "GoD GUIDE 4/6 - IKKINZ RAIDS: " ..
    "Tublik Narwethar assigns the four raid instances: Trial of Righteousness, Trial of " ..
    "Glorification (root the Guardian, kill the Glorified Bolsterers), Trial of Transcendence, " ..
    "and Chambers of Destruction. The Stalwart Caretaker handles the research step even when " ..
    "your trio has no intelligence caster.",

    "GoD GUIDE 5/6 - UQUA / QVIC / INKTU'TA: " ..
    "Jerimo Jiao in Yxtta opens Uqua, the Ocean God Chantry. Carry an item of Destructive " ..
    "Protection to survive the Aura of Destruction. Madronoa in Natimbi sends you to Qvic. " ..
    "In Inktu'ta, defeat Kelekdrix, then Jomica the Unforgiven, then Noqufiel.",

    "GoD GUIDE 6/6 - TXEVU / TACVI: " ..
    "Txevu: free the Ukun Bloodfeaster, kill the Ancient Cragbeast Matriarch after the Bearer " ..
    "of Nascency, then Zun`Muram Tkarish Zyk - keep the Ikaav Ritualists alive to control his " ..
    "adds. Tacvi: six bosses ending with Zun`muram Kvxe Pirik (balance the scales, hail to " ..
    "force a balance check) and Pixtt Riel Tavas. The whole zone shares one 14 hour lockout.",
}

function M.show(client)
    if client == nil then return end
    for _, text in ipairs(M.sections) do
        client:Message(MT.Yellow, text)
    end
end

return M

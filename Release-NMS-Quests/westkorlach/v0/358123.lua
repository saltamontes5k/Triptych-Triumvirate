function event_say(e)
    if not e.self.valid or not e.other.valid or e.self:GetSpawnPointID() ~= 102235 then
        return
    end
    local text = e.message:lower():match("^%s*(.-)%s*$")
    if text == "hail" or text == "i will aid you" or text == "what visions?" or text == "what visions"
        or text == "what move?" or text == "what move" or text == "freeing an elder"
        or text == "the orb of subversion" or text == "a plea for help"
        or text == "trailing longshadow" or text == "confronting a traitor" then
        eq.task_selector({920251, 920252, 920253, 920254, 920255})
    end
end

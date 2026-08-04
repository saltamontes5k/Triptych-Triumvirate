local epic_disabled = true; -- Disabling for omens (epics) cannot reference perl expansion vars from lua.

if not epic_disabled then
    eq.load_encounter('berserkerepic_1_5');
end
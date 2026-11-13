-- potimea encounter bootstraps. The parser runs this file once at zone boot
-- (all versions); each eq.load_encounter creates the Encounter entity and
-- dispatches event_encounter_load in the encounter file -- without it the
-- encounter never binds and its NPC stands inert (the anguish / acrylia /
-- barindu script_init.lua pattern).
eq.load_encounter("xebuxoruk_clone");

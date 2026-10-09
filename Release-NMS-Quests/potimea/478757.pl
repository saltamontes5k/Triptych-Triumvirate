# a_void_rift (478757) -- Plane of Time entry to the SoD sphere.
# Routes to the player's earned Void version (plugin::SodPortalUse).
sub EVENT_SAY {
    plugin::SodPortalUse($client, 478757);
}

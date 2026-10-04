# Spell 121860 - RETIRED (was "Manifest Experience" -> Lucky Coin)
#
# The "Manifest Experience" AA (aa_ability 31082 / rank 41000) was replaced by
# the Origin AA. Origin uses its own spell, 121861, whose first effect is the
# native SE_GateToHomeCity (322); the server handles that SPA directly in
# zone/spell_effects.cpp with Client::GoToBind(4) -- bind slot 4, the
# character's home city.
#
# See: Release-NMS-Server/utils/sql/20261005_ascendant_origin_aa.sql
#
# Nothing casts spell 121860 any more (the old AA rank 41000 was the only
# caller), so this handler is intentionally inert. It used to deduct 3 unspent
# AA points and summon a Lucky Coin (121857). Keeping it as an explicit no-op
# means a stray cast of spell 121860 can never charge a player AA points again.
#
# This file can simply be deleted instead -- either way Origin is unaffected:
#     git rm Release-NMS-Quests/global/spells/121860.pl
#
# Note: rolling back 20261005_ascendant_origin_aa.sql also requires restoring
# this file (git checkout), because a SQL migration cannot restore a file.

sub EVENT_SPELL_EFFECT_CLIENT {
    # Intentionally does nothing. Do not return a non-zero value: that would
    # make SpellEffect() abort the remaining effects of the spell.
    return;
}

1;

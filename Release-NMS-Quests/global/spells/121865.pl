# Spell 121865 - Invitation of Blood (aa_ability 31089 / rank 41011)
#
# The Invitation sacrifices a fifth of the caster's CURRENT health (clamped so
# the curse can never land the killing blow) and the spell's native slot 2
# (SE_DamageModifier +25%, 30 seconds) lands as the power granted in exchange.
# Slot 1 is intentionally blank: the health cost is handled here so it can be a
# percentage instead of a flat number.
#
# See: Release-NMS-Server/utils/sql/20261004_glyphs_blood_gambler.sql

sub EVENT_SPELL_EFFECT_CLIENT {
    my $hp = $client->GetHP();
    my $cut = int($hp * 0.2);
    if ($cut > 0 && $hp - $cut > 0) {
        $client->SetHP($hp - $cut);
        $client->Message(15, "The curse accepts your offering of " . $cut . " blood.");
    }
    # Return nothing: the spell's damage-modifier effect must still land.
}

1;

# deity_blessings.pl
# Shared helpers + proc engine for the deity blessing system (NMS / Triptych).
#
# Ranks: 10 per tree. Tier 1 = ranks 1-3, tier 2 = 4-6, tier 3 = 7-10.
# Rank 1 -- "Devotion": forge a fired idol of your deity and deliver it to a
# Keeper of Devotion (The Bazaar / Plane of Tranquility).
#
# Triggers:
#   melee  -> landed melee OR ranged hit     (EVENT_DAMAGE_GIVEN, spell_id SPELL_UNKNOWN)
#   cast   -> completed hostile damage cast  (EVENT_CAST)
#   taken  -> incoming melee damage (reflect)(EVENT_DAMAGE_TAKEN)
#   passive-> applied on zone-in
#
# Rules:
#   * One shared internal cooldown -> at most one blessing proc per 2s.
#   * Hostile triggers require combat (IsEngaged/GetAggroCount).
#   * Beneficial casts (buffs/heals) roll HEAL effects only (never hostile).
#   * Hostile damage casts roll the deity's offensive + heal bundle.
#   * Heal procs are allowed out of combat.
#   * Heal procs also fire on non-CC utility casts (slow/tash/cures/etc.).
#   * CC casts (root/calm/charm/fear/mez/memblur/FD) never proc anything.

# ---------------------------------------------------------------------------
# Identity + rank-1 quest maps
# ---------------------------------------------------------------------------
my %BLESS_NAME = (
    140 => 'Agnostic', 396 => 'Agnostic',
    201 => 'Bertoxxulous', 202 => 'Brell Serilis', 203 => 'Cazic-Thule',
    204 => 'Erollisi Marr', 205 => 'Bristlebane', 206 => 'Innoruuk',
    207 => 'Karana', 208 => 'Mithaniel Marr', 209 => 'Prexus',
    210 => 'Quellious', 211 => 'Rallos Zek', 212 => 'Rodcet Nife',
    213 => 'Solusek Ro', 214 => 'the Tribunal', 215 => 'Tunare', 216 => 'Veeshan',
);

my %BLESS_R1_TASK = (
    140 => 700017, 396 => 700017,
    201 => 700001, 202 => 700002, 203 => 700003, 204 => 700004, 205 => 700005,
    206 => 700006, 207 => 700007, 208 => 700008, 209 => 700009, 210 => 700010,
    211 => 700011, 212 => 700012, 213 => 700013, 214 => 700014, 215 => 700015,
    216 => 700016,
);

my %BLESS_R1_IDOL = (
    140 => 976205, 396 => 976205,   # Fired Idol (Agnostic)
    201 => 9706, 202 => 9707, 203 => 9708, 204 => 9709, 205 => 9710,
    206 => 9711, 207 => 9712, 208 => 9713, 209 => 9714, 210 => 9715,
    211 => 9716, 212 => 9717, 213 => 9718, 214 => 9719, 215 => 9720,
    216 => 976203,                  # Golden Idol of Veeshan
);

# ---------------------------------------------------------------------------
# Spell palette.
#   Buff-type effects use custom collision-free spell ids (50018-50022),
#   registered in Spells:AlwaysStackSpells so they never clash with player
#   spell lines. Instant effects have no buff slot, so base ids are fine.
# ---------------------------------------------------------------------------
my $SP_FEAR     = 44017;  # Blessing: Fear
my $SP_ROOT     = 44015;  # Blessing: Root
my $SP_POISON   = 204;    # Shock of Poison (instant)
my $SP_DISEASE  = 44014;  # Blessing: Disease
my $SP_LIFETAP  = 446;    # Siphon Life (instant)
my $SP_HEAL     = 12;     # Healing (instant)
my $SP_GROUPHEAL= 18006;  # Cantata of Rodcet (instant)
my $SP_STUN     = 216;    # Stun (instant)
my $SP_WHIRL    = 461;    # Cast Force (instant PB AE)
my $SP_FIRE     = 657;    # Flame Shock (instant)
my $SP_FIRE2    = 6862;   # Flame Shock alt (instant)
my $SP_MAGIC    = 383;    # Shock of Lightning (instant)
my $SP_COLD     = 658;    # Ice Shock (instant)
my $SP_MANATAP  = 1686;   # Theft of Thought (instant)
my $SP_SNARE    = 44018;  # Blessing: Snare
my $SP_DS       = 44020;  # Blessing: Damage Shield
my $SPELL_UNKNOWN = 0xFFFF;  # melee/ranged/basic-skill damage (EVENT_DAMAGE_GIVEN)

# ---------------------------------------------------------------------------
# Per-deity signature effects.
#   melee      -> hostile bundle on landed melee/ranged hit
#   cast       -> offensive bundle on a hostile damage cast
#   cast_heal  -> heal bundle (beneficial/util casts, and hostile casts for heals)
#   taken      -> reflect bundle on incoming melee
#   passive    -> zone-in
#   mimic      -> this tree copies a random other tree's effect per proc
# Actions: {cast=>id,to=>'self'|'opp'}, {rand=>[ids]}, {heal=>pct},
#          {heal_if_hurt=>pct}, {hate=>amt}, {pickpocket=>1}, {illusion=>1},
#          {twinproc=>1}, {flurry=>1}, {tribunal=>1}, {twincast_fire=>1},
#          {mimicry=>1}, {mischief=>1}, {ds_buff=>id}
#   {mischief}: mimic-tree caprice -- 40% pickpocket+illusion, else mimicry.
# ---------------------------------------------------------------------------
my %BLESS_PROC = (
    201 => {  # Bertoxxulous
        melee => [ {rand=>[$SP_DISEASE,$SP_POISON], to=>'opp'} ],
        cast  => [ {rand=>[$SP_DISEASE,$SP_POISON], to=>'opp'} ],
        taken => [ {cast=>$SP_DISEASE, to=>'opp'} ],
    },
    202 => {  # Brell Serilis
        melee     => [ {cast=>$SP_STUN, to=>'opp'} ],
        cast      => [ {cast=>$SP_STUN, to=>'opp'} ],
        cast_heal => [ {cast=>$SP_GROUPHEAL, to=>'self'}, {heal_if_hurt=>0.10} ],
    },
    203 => {  # Cazic-Thule
        melee => [ {rand=>[$SP_FEAR,$SP_ROOT,$SP_POISON], to=>'opp'} ],
        cast  => [ {rand=>[$SP_FEAR,$SP_ROOT,$SP_POISON], to=>'opp'} ],
        taken => [ {cast=>$SP_FEAR,to=>'opp'}, {cast=>$SP_ROOT,to=>'opp'}, {cast=>$SP_POISON,to=>'opp'} ],
    },
    204 => {  # Erollisi Marr
        melee     => [ {cast=>$SP_LIFETAP, to=>'opp'} ],
        cast      => [ {cast=>$SP_MANATAP, to=>'opp'} ],
        cast_heal => [ {heal_if_hurt=>0.10} ],
    },
    205 => {  # Bristlebane -- capricious: mischief or borrow ({mischief})
        mimic     => 1,
        melee     => [ {mischief=>1} ],
        cast      => [ {mischief=>1} ],
        cast_heal => [ {mischief=>1} ],
    },
    206 => {  # Innoruuk
        melee => [ {cast=>$SP_LIFETAP, to=>'opp'} ],
        cast  => [ {cast=>$SP_LIFETAP, to=>'opp'}, {cast=>$SP_MANATAP, to=>'opp'}, {hate=>200} ],
    },
    207 => {  # Karana
        melee     => [ {twinproc=>1} ],
        cast      => [ {twinproc=>1} ],
        cast_heal => [ {heal_if_hurt=>0.10} ],
    },
    208 => {  # Mithaniel Marr
        melee     => [ {cast=>$SP_STUN, to=>'opp'} ],
        cast      => [ {cast=>$SP_STUN, to=>'opp'} ],
        cast_heal => [ {cast=>$SP_GROUPHEAL, to=>'self'}, {heal_if_hurt=>0.10} ],
    },
    209 => {  # Prexus
        melee     => [ {cast=>$SP_COLD, to=>'opp'} ],
        cast      => [ {cast=>$SP_COLD, to=>'opp'} ],
        cast_heal => [ {heal_if_hurt=>0.10} ],
    },
    210 => {  # Quellious
        melee => [ {hate=>-200}, {cast=>$SP_MANATAP, to=>'opp'} ],
        cast  => [ {hate=>-200}, {cast=>$SP_MANATAP, to=>'opp'} ],
    },
    211 => {  # Rallos Zek
        melee => [ {cast=>$SP_LIFETAP,to=>'opp'}, {hate=>150}, {flurry=>1} ],
        cast  => [ {cast=>$SP_LIFETAP,to=>'opp'}, {twinproc=>1}, {hate=>150} ],
    },
    212 => {  # Rodcet Nife
        melee     => [ {heal=>0.05} ],
        cast_heal => [ {cast=>$SP_GROUPHEAL, to=>'self'} ],
    },
    213 => {  # Solusek Ro
        melee => [ {cast=>$SP_FIRE, to=>'opp'} ],
        cast  => [ {twincast_fire=>1}, {cast=>$SP_FIRE2, to=>'opp'} ],
    },
    214 => {  # The Tribunal
        melee => [ {tribunal=>1, to=>'opp'} ],
        cast  => [ {tribunal=>1, to=>'opp'} ],
    },
    215 => {  # Tunare
        melee     => [ {cast=>$SP_SNARE,to=>'opp'}, {heal=>0.04} ],
        cast_heal => [ {heal=>0.08} ],
        passive   => [ {ds_buff=>$SP_DS} ],
    },
    216 => {  # Veeshan
        melee     => [ {rand=>[$SP_FIRE,$SP_COLD,$SP_MAGIC], to=>'opp'} ],
        cast      => [ {rand=>[$SP_FIRE,$SP_COLD,$SP_MAGIC], to=>'opp'} ],
        cast_heal => [ {heal_if_hurt=>0.10} ],
    },
    140 => {  # Agnostic -- Bristlebane's line, capricious ({mischief})
        mimic     => 1,
        melee     => [ {mischief=>1} ],
        cast      => [ {mischief=>1} ],
        cast_heal => [ {mischief=>1} ],
    },
    396 => {
        mimic     => 1,
        melee     => [ {mischief=>1} ],
        cast      => [ {mischief=>1} ],
        cast_heal => [ {mischief=>1} ],
    },
);

my @BLESS_CHANCE  = (0, 1, 3, 5, 8, 11, 15, 17, 20, 22, 25);
my @BLESS_MIMIC_EXCLUDE = (205, 140, 396);

# Highest rank currently obtainable. Ranks 2-10 are authored later; until then
# only Rank I is reachable, so the status text is capped to match.
my $BLESS_RANK_CAP = 1;

# --- TEMP TEST DEBUG (disabled 2026-09-24; re-enable to test) --------------
# Self-service 100% proc override. Say the password to a Keeper of Devotion to
# toggle it on/off for your character (no GM rights needed). Value 2 = always
# proc, ignoring the shared cooldown and the in-combat requirement.
# To re-enable: uncomment this block and the commented _BlessingDebug /
# _BlessingDebugMsg calls in the proc gates, then uncomment the password
# branch in quests/{bazaar,potranquility}/Blessing_of_the_Gods.pl.
# my $BLESS_DEBUG_FORCE = 0;                 # >0 forces the debug for everyone (0 = off)
# my $BLESS_DEBUG_ON    = 2;                 # bucket value applied when enabled
# my $BLESS_DEBUG_PASS  = 'blessdebug';      # say this to a Keeper to toggle on/off
#
# sub BlessingDebugPassword { return $BLESS_DEBUG_PASS; }
#
# sub _BlessingDebug {
#     my $c = shift;
#     return 0 unless $c;
#     my $v = $BLESS_DEBUG_FORCE || $c->GetBucket('bless-debug');
#     return int($v || 0);
# }
#
# sub _BlessingDebugMsg {
#     my ($c, $d, $note) = @_;
#     return unless $c && $d;
#     $c->Message(15, "[bless-debug] " . $note);
# }
#
# sub BlessingDebugToggle {
#     my $c = shift;
#     return 0 unless $c;
#     if (int($c->GetBucket('bless-debug') || 0) > 0) {
#         $c->DeleteBucket('bless-debug');
#         return 0;
#     }
#     $c->SetBucket('bless-debug', $BLESS_DEBUG_ON);
#     return 1;
# }

# ---------------------------------------------------------------------------
# Accessors
# ---------------------------------------------------------------------------
sub BlessingDeityName { my $d = shift; return $BLESS_NAME{$d} || 'your god'; }
sub BlessingRank1Task { my $d = shift; return $BLESS_R1_TASK{$d} || 0; }
sub BlessingRank1Idol { my $d = shift; return $BLESS_R1_IDOL{$d} || 0; }

sub BlessingRank   { my $c = shift; return int($c->GetBucket('bless-rank') || 0); }
sub BlessingPoints { my $c = shift; return int($c->GetBucket('bless-pts')  || 0); }

sub BlessingProcChance {
    my $r = shift;
    return ($r >= 0 && $r <= 10) ? $BLESS_CHANCE[$r] : 0;
}

sub BlessingTier {
    my $r = shift;
    return 0 if $r < 1;
    return 1 if $r <= 3;
    return 2 if $r <= 6;
    return 3;
}

sub BlessingCheckDeity {
    my $c      = shift;
    my $deity  = $c->GetDeity();
    my $stored = $c->GetBucket('bless-deity');
    if ($stored && int($stored) != int($deity)) {
        $c->DeleteBucket('bless-rank');
        $c->DeleteBucket('bless-pts');
        $c->DeleteBucket('bless-deity');
        $c->DeleteBucket('bless-r1-claimed');
        $c->Message(15, "Your change of faith has severed your divine blessings. Your devotion must be earned anew.");
    }
    return $deity;
}

# ---------------------------------------------------------------------------
# Rank-1 quest wiring
# ---------------------------------------------------------------------------
sub BlessingAssignRank1 {
    my $c     = shift;
    my $deity = BlessingCheckDeity($c);
    my $task  = BlessingRank1Task($deity);
    return 0 unless $task;
    return 0 if BlessingRank($c) >= 1;
    # Rank tasks are repeatable: a change of faith resets the buckets and the
    # player re-earns every rank from scratch, even if the task completed before.
    return 0 if $c->IsTaskActive($task);
    $c->AssignTask($task);
    return 1;
}

sub BlessingGrantRank1 {
    my ($c, $task_id) = @_;
    my $deity = BlessingCheckDeity($c);
    return 0 unless BlessingRank1Task($deity) == $task_id;
    return 0 if BlessingRank($c) >= 1;
    $c->SetBucket('bless-deity', $deity);
    $c->SetBucket('bless-rank', 1);
    $c->SetBucket('bless-pts', BlessingPoints($c) + 1);
    $c->Message(15, "You have awakened Rank I of the blessing of " . BlessingDeityName($deity) . ". (1 blessing point)");
    return 1;
}

# Rank grid for ranks 2-10 (task = 700100 + treeIndex*9 + (rank-2)).
my @BLESS_TREES = (201,202,203,204,205,206,207,208,209,210,211,212,213,214,215,216,140);

sub BlessingTreeIndex {
    my $d = shift;
    $d = 140 if $d == 396;
    for my $i (0..$#BLESS_TREES) { return $i if $BLESS_TREES[$i] == $d; }
    return -1;
}
sub BlessingRankTask {
    my ($d, $r) = @_;
    return 0 if $r < 2 || $r > 10;
    my $i = BlessingTreeIndex($d);
    return 0 if $i < 0;
    return 700100 + $i * 9 + ($r - 2);
}
sub BlessingTaskRank {
    my ($d, $t) = @_;
    my $r1 = BlessingRank1Task($d);
    return 1 if $r1 && $r1 == $t;
    return 0 if $t < 700100 || $t > 700252;
    for my $r (2..10) { return $r if BlessingRankTask($d, $r) == $t; }
    return 0;
}
sub BlessingGrantRank {
    my ($c, $task_id) = @_;
    my $deity = BlessingCheckDeity($c);
    my $r = BlessingTaskRank($deity, $task_id);
    return 0 unless $r;
    # Strictly sequential: only the next rank can be earned.
    return 0 if BlessingRank($c) != $r - 1;
    $c->SetBucket('bless-deity', $deity);
    $c->SetBucket('bless-rank', $r);
    $c->SetBucket('bless-pts', BlessingPoints($c) + 1);
    $c->Message(15, "You have awakened Rank $r of the blessing of " . BlessingDeityName($deity) . ". (1 blessing point)");
    return 1;
}

# ---------------------------------------------------------------------------
# Detection helpers
# ---------------------------------------------------------------------------
sub _BlessingInCombat {
    my $c = shift;
    return 0 unless $c;
    return 1 if $c->IsEngaged();
    return 1 if $c->GetAggroCount() > 0;
    return 0;
}

sub _BlessingSpellHasSpa {
    my ($spell, $spa, $sign) = @_;
    return 0 unless $spell;
    for my $slot (0..11) {
        next unless $spell->GetEffectID($slot) == $spa;
        my $v = $spell->GetBaseValue($slot);
        next unless defined $v;
        return 1 if $sign eq 'any';
        return 1 if $sign eq 'neg' && $v < 0;
        return 1 if $sign eq 'pos' && $v > 0;
    }
    return 0;
}

sub _BlessingIsDamageSpell { return _BlessingSpellHasSpa($_[0], 0, 'neg'); }
sub _BlessingIsHealSpell   { return _BlessingSpellHasSpa($_[0], 0, 'pos'); }

# root(10) calm(30) charm(22) fear(23) mez(31) memblur(63) feign death(74)
my %BLESS_CC_SPA = (10=>1, 22=>1, 23=>1, 30=>1, 31=>1, 63=>1, 74=>1);
sub _BlessingIsCCUtility {
    my $spell = shift;
    return 0 unless $spell;
    for my $slot (0..11) {
        return 1 if $BLESS_CC_SPA{ $spell->GetEffectID($slot) };
    }
    return 0;
}

# Every tree heals. Deities with no explicit heal bundle fall back to the
# generic "Healing" line so a heal can still trip on casts.
sub _BlessingHealBundle {
    my $eff = shift;
    if ($eff && $eff->{cast_heal} && @{ $eff->{cast_heal} }) {
        return $eff->{cast_heal};
    }
    return [ { cast=>$SP_HEAL, to=>'self' } ];
}

# ---------------------------------------------------------------------------
# Internal cooldown (shared, one proc at a time)
# ---------------------------------------------------------------------------
sub _BlessingProcOffCooldown {
    my $c    = shift;
    my $now  = time();
    my $last = int($c->GetEntityVariable('bless-proc-ts') || 0);
    return ($now - $last) >= 2;
}
sub _BlessingMarkProc {
    my $c = shift;
    $c->SetEntityVariable('bless-proc-ts', time());
}

# ---------------------------------------------------------------------------
# Action engine
# ---------------------------------------------------------------------------
sub _BlessingCastOn {
    my ($c, $spell, $mob) = @_;
    return unless $spell && $mob;
    # SpellFinished applies instantly (like a proc) and does NOT emit EVENT_CAST,
    # so a blessing can never re-enter the cast engine or show a cast bar.
    $c->SpellFinished($spell, $mob);
}

sub _BlessingPickpocket {
    my ($c, $opp) = @_;
    return unless $opp && $opp->IsNPC() && !$opp->GetOwnerID();
    # PickPocket is an NPC method (NPC::PickPocket(Client*)); cast the Mob first.
    my $npc = $opp->CastToNPC();
    $npc->PickPocket($c) if $npc;
}

sub _BlessingIllusion {
    my ($c, $opp) = @_;
    return unless $opp;
    # Take on the victim's form (race, gender, texture, face, hair, ...).
    $c->CopyAppearance($opp);
}

my %FIRE_SPELLS;
my $FIRE_LOADED = 0;
sub _BlessingIsFireSpell {
    my $sid = shift;
    return 0 unless $sid;
    unless ($FIRE_LOADED) {
        $FIRE_LOADED = 1;
        my $dbh = plugin::LoadMysql();
        if ($dbh) {
            my $sth = $dbh->prepare(
                "SELECT id FROM spells_new WHERE resisttype=2 AND effectid1=0 AND effect_base_value1 < 0"
            );
            if ($sth && $sth->execute()) {
                while (my ($id) = $sth->fetchrow_array()) { $FIRE_SPELLS{$id} = 1; }
            }
            $sth->finish() if $sth;
            $dbh->disconnect();
        }
    }
    return $FIRE_SPELLS{$sid} ? 1 : 0;
}

sub _BlessingMimicry {
    my ($c, $opp, $trigger, $spell_id) = @_;
    $trigger = 'melee' unless $trigger;
    my $mimic_ok = sub {
        my $d = shift;
        return 0 if $d == $c->GetDeity();
        for my $x (@BLESS_MIMIC_EXCLUDE) { return 0 if $d == $x; }
        my $e = $BLESS_PROC{$d};
        return ($e && $e->{$trigger}) ? 1 : 0;
    };
    my @keys = grep { $mimic_ok->($_) } keys %BLESS_PROC;
    return unless @keys;
    my $d = $keys[int(rand(@keys))];
    my $e = $BLESS_PROC{$d};
    # DEBUG (re-enable): _BlessingDebugMsg($c, _BlessingDebug($c),
    #     "borrow -> " . BlessingDeityName($d) . " | trigger=" . $trigger);
    _BlessingRunActions($c, $opp, $e->{$trigger}, $spell_id, $trigger);
    if ($trigger eq 'cast' && $e->{cast_heal}) {
        _BlessingRunActions($c, $opp, $e->{cast_heal}, $spell_id, 'cast_heal');
    }
}

sub _BlessingRunActions {
    my ($c, $opp, $actions, $cast_spell_id, $trigger) = @_;
    return unless $actions;
    for my $a (@$actions) {
        my $self = ($a->{to} && $a->{to} eq 'self');
        my $mob  = $self ? $c : $opp;

        if ($a->{cast}) {
            _BlessingCastOn($c, $a->{cast}, $mob);
        }
        elsif ($a->{rand}) {
            my @s = @{ $a->{rand} };
            _BlessingCastOn($c, $s[int(rand(@s))], $mob);
        }
        elsif ($a->{heal}) {
            $c->HealDamage(int($c->GetMaxHP() * $a->{heal}), $c);
        }
        elsif ($a->{heal_if_hurt}) {
            if ($c->GetHP() < ($c->GetMaxHP() * 0.5)) {
                $c->HealDamage(int($c->GetMaxHP() * $a->{heal_if_hurt}), $c);
            }
        }
        elsif ($a->{hate}) {
            $opp->AddToHateList($c, $a->{hate}) if $opp;
        }
        elsif ($a->{pickpocket}) {
            _BlessingPickpocket($c, $opp);
        }
        elsif ($a->{illusion}) {
            _BlessingIllusion($c, $opp);
        }
        elsif ($a->{twinproc}) {
            # Re-fire the wielder's main-hand weapon proc (mirrors the Twinproc AA).
            $c->DoWeaponProc($opp) if $opp;
        }
        elsif ($a->{flurry}) {
            _BlessingCastOn($c, $SP_MAGIC, $opp) if $opp;
        }
        elsif ($a->{tribunal}) {
            if ($opp) {
                if ($c->GetHP() < $c->GetMaxHP()) {
                    _BlessingCastOn($c, $SP_LIFETAP, $opp);
                } else {
                    _BlessingCastOn($c, $SP_MAGIC, $opp);
                }
            }
        }
        elsif ($a->{twincast_fire}) {
            if ($cast_spell_id && _BlessingIsFireSpell($cast_spell_id) && $opp) {
                _BlessingCastOn($c, $cast_spell_id, $opp);
            }
        }
        elsif ($a->{mimicry}) {
            _BlessingMimicry($c, $opp, $trigger, $cast_spell_id);
        }
        elsif ($a->{mischief}) {
            # Mimic-tree caprice: 40% pickpocket+illusion, else borrow another god.
            # DEBUG (re-enable): my $dbg = _BlessingDebug($c);
            if (int(rand(100)) < 40) {
                # DEBUG (re-enable): _BlessingDebugMsg($c, $dbg, "mischief -> pickpocket + illusion | trigger=" . $trigger);
                _BlessingPickpocket($c, $opp);
                _BlessingIllusion($c, $opp);
            } else {
                _BlessingMimicry($c, $opp, $trigger, $cast_spell_id);
            }
        }
        elsif ($a->{ds_buff}) {
            $c->SpellFinished($a->{ds_buff}, $c);
        }
    }
}

# Single roll -> single blessing. Shared cooldown.
sub _BlessingTryList {
    my ($c, $opp, $actions, $need_combat, $spell_id, $trigger) = @_;
    return unless $actions && @$actions;
    return unless BlessingRank($c) >= 1;
    # DEBUG (re-enable): my $debug = _BlessingDebug($c); and use $debug in the gates below.
    # return if $need_combat && $debug < 2 && !_BlessingInCombat($c);
    # return unless $debug >= 2 || _BlessingProcOffCooldown($c);
    # return unless $debug >= 1 || int(rand(100)) < BlessingProcChance(BlessingRank($c));
    return if $need_combat && !_BlessingInCombat($c);
    return unless _BlessingProcOffCooldown($c);
    return unless int(rand(100)) < BlessingProcChance(BlessingRank($c));
    _BlessingMarkProc($c);
    # _BlessingDebugMsg($c, $debug,
    #     "FIRED | deity=" . BlessingDeityName($c->GetDeity()) .
    #     " | trigger=" . (defined $trigger ? $trigger : '?') .
    #     " | target=" . ($opp ? $opp->GetCleanName() : 'self'));
    _BlessingRunActions($c, $opp, $actions, $spell_id, $trigger);
}

# ---------------------------------------------------------------------------
# Event entry points (called from global_player.pl)
# ---------------------------------------------------------------------------
sub BlessingOnDamageGiven {
    my ($c, $entity_id, $damage, $spell_id, $is_ds, $is_tic, $special_attack) = @_;
    return unless $c && $damage && $damage > 0;
    BlessingCheckDeity($c);
    return if $spell_id && $spell_id != $SPELL_UNKNOWN;   # 0/65535 = melee/ranged; skip real spells
    return if $is_ds || $is_tic;
    # DEBUG (re-enable): my $dbg = _BlessingDebug($c); and the _BlessingDebugMsg lines.
    return unless _BlessingInCombat($c);
    my $el  = plugin::val('$entity_list');
    my $tgt = $el ? $el->GetMobByID($entity_id) : undef;
    return unless $tgt && $tgt->IsNPC() && !$tgt->GetOwnerID();
    my $eff = $BLESS_PROC{ $c->GetDeity() };
    return unless $eff && $eff->{melee};
    _BlessingTryList($c, $tgt, $eff->{melee}, 1, undef, 'melee');
}

sub BlessingOnDamageTaken {
    my ($c, $entity_id, $damage, $spell_id, $is_ds, $is_tic) = @_;
    return 0 unless $c && $damage && $damage > 0;
    BlessingCheckDeity($c);
    return 0 if $spell_id && $spell_id != $SPELL_UNKNOWN;   # 0/65535 = melee/ranged; skip real spells
    return 0 if $is_ds || $is_tic;
    # DEBUG (re-enable): my $dbg = _BlessingDebug($c);
    return 0 unless _BlessingInCombat($c);
    my $eff = $BLESS_PROC{ $c->GetDeity() };
    return 0 unless $eff && $eff->{taken};
    my $el  = plugin::val('$entity_list');
    my $atk = $el ? $el->GetMobByID($entity_id) : undef;
    return 0 unless $atk && $atk->IsNPC() && !$atk->GetOwnerID();
    _BlessingTryList($c, $atk, $eff->{taken}, 1, undef, 'taken');
    return 0;
}

sub BlessingOnCast {
    my ($c, $spell_id, $target_id, $target, $spell) = @_;
    return unless $c && $spell;
    BlessingCheckDeity($c);
    my $eff = $BLESS_PROC{ $c->GetDeity() };
    return unless $eff;

    # Beneficial casts (buffs/heals): heal procs only, no combat requirement.
    # Pass the cast target so the mimic-tree mischief illusion can copy it.
    if ($spell->GetGoodEffect() || _BlessingIsHealSpell($spell)) {
        _BlessingTryList($c, $target, _BlessingHealBundle($eff), 0, $spell_id, 'cast_heal');
        return;
    }

    # CC spells (root/calm/charm/fear/mez/memblur/FD) never proc.
    return if _BlessingIsCCUtility($spell);

    if (_BlessingIsDamageSpell($spell)) {
        my $hostile = ($target && $target->IsNPC() && !$target->GetOwnerID());
        if (_BlessingInCombat($c)) {   # DEBUG: was  || _BlessingDebug($c) >= 2
            # one roll: offensive bundle + heal bundle (heals still fire off damage)
            my @union;
            push @union, @{ $eff->{cast} } if $eff->{cast};
            push @union, @{ _BlessingHealBundle($eff) } if !$eff->{mimic};
            _BlessingTryList($c, ($hostile ? $target : undef), \@union, 1, $spell_id, 'cast') if @union;
        } else {
            # out of combat: heals still allowed
            _BlessingTryList($c, undef, _BlessingHealBundle($eff), 0, $spell_id, 'cast_heal');
        }
        return;
    }

    # Non-damaging utility (slow/tash/cures/etc.): a heal may still trip.
    _BlessingTryList($c, undef, _BlessingHealBundle($eff), 0, $spell_id, 'cast_heal');
}

sub BlessingOnEnterZone {
    my $c = shift;
    return unless $c;
    BlessingCheckDeity($c);
    my $eff = $BLESS_PROC{ $c->GetDeity() };
    return unless $eff && $eff->{passive} && BlessingRank($c) >= 1;
    _BlessingRunActions($c, undef, $eff->{passive}, undef, 'passive');
}

# ---------------------------------------------------------------------------
# Menu / status text
# ---------------------------------------------------------------------------
sub BlessingStatusHtml {
    my $c      = shift;
    my $deity  = BlessingCheckDeity($c);
    my $name   = BlessingDeityName($deity);
    my $rank   = BlessingRank($c);
    my $pts    = BlessingPoints($c);
    my $tier   = BlessingTier($rank);
    my $chance = BlessingProcChance($rank);

    my $html = "<c \"#FFD700\">Devotion to $name</c><br><br>";
    $html .= "<c \"#FFFFFF\">Rank:</c> <c \"#00FF00\">$rank</c> / $BLESS_RANK_CAP";
    $html .= "   <c \"#FFFFFF\">Tier:</c> <c \"#00CCFF\">" . ($tier ? $tier : '-') . "</c><br>";
    $html .= "<c \"#FFFFFF\">Blessing points:</c> <c \"#FFD700\">$pts</c><br>";
    $html .= "<c \"#FFFFFF\">Proc chance:</c> <c \"#00FF00\">$chance%</c> per trigger<br><br>";

    if ($rank < 1) {
        $html .= "<c \"#AAAAAA\">Forge a fired idol of your faith and deliver it to the Keeper of Devotion in The Bazaar to awaken Rank I.</c>";
    } elsif ($rank < $BLESS_RANK_CAP) {
        $html .= "<c \"#AAAAAA\">Further ranks are earned through devotion.</c>";
    } else {
        $html .= "<c \"#AAAAAA\">Further ranks are not yet available.</c>";
    }
    return $html;
}

return 1;

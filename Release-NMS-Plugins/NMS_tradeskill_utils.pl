# NMS_tradeskill_utils.pl
# Permanent tradeskill skill-ups for killing raid NPCs (an enticement to keep
# hunting them). Same mechanism as the Fool's Gold Cake Defense reward
# (rivervale/#Cake_Defense_Baker.lua): Client::SetSkill writes character_skills
# and sends OP_SkillUpdate, so the gain is permanent. The old IncreaseSkill
# inline did neither and the reward vanished on zone.
#
# Hook: global_npc.pl EVENT_KILLED_MERIT -> plugin::AwardTradeskillKillCredit.
# EVENT_KILLED_MERIT is dispatched once per credited player
# (zone/attack.cpp Death() -> give_exp_client->GetRaidOrGroupOrSelf(true)), so
# every raid/group member in the zone is awarded exactly once per kill.
#
# Names are matched on the *normalized* npc name, not on npc_types.id, so every
# copy of a target counts: 'Lady_Vox', '#Lady_Vox' (raid version), the Fabled
# version and '##Vallon_Zek_' variants all collapse to one key. Normalization
# (plugin::NormalizeNPCName): lowercase, non-alphanumerics -> '_', trim '_',
# drop a leading '#' / 'the_fabled_' / 'the_' / 'an_' / 'a_', drop a trailing
# three-digit uniqueness suffix.
#
# IMPORTANT: match Mob::GetOrigName(), never Mob::GetName(). NPC::NPC() runs
# EntityList::RemoveNumbers() + EntityList::MakeNameUnique(), and
# MakeNameUnique() appends "%03d" to *every* spawned NPC -- '#Lord_Inquisitor_Seru_'
# is '#Lord_Inquisitor_Seru_000' at runtime, 'Lady_Vox' is 'Lady_Vox000'.
# GetOrigName() is the untouched npc_types.name; zone/npc.cpp calls it out as
# the name keyed kill logic should use. GetName() is only a fallback, with the
# suffix stripped.
#
# Adding a target later: put its normalized name in the right list below. The
# name must match npc_types.name with '_' for spaces, and an apostrophe
# written as a backtick (e.g. "Rydda`Dar" -> 'rydda_dar', "Kelorek`Dar" ->
# 'kelorek_dar', "Zun`Muram_Votal" -> 'zun_muram_votal'). A name may appear in
# more than one list; the rewards add (Vallon Zek = baking/alchemy/poisoning
# +5 AND +1 to everything else).
#
# Points are capped by the character's own skill cap for the skill
# (Client::MaxSkill, the same rule the #train trainer in global/Zapf.pl uses):
# tradeskills cap at 300, Fishing at 200, Alcohol Tolerance at 375, and a
# low-level character cannot be pushed past their level's cap.

# Skill ids (common/skills.h).
my @ALL_TRADESKILLS = (
    55, # Fishing
    56, # Make Poison
    57, # Tinkering
    58, # Research
    59, # Alchemy
    60, # Baking
    61, # Tailoring
    63, # Blacksmithing
    64, # Fletching
    65, # Brewing
    66, # Alcohol Tolerance
    68, # Jewelry Making
    69, # Pottery
);

my %TRADESKILL_SKILL_NAMES = (
    55 => 'Fishing',
    56 => 'Make Poison',
    57 => 'Tinkering',
    58 => 'Research',
    59 => 'Alchemy',
    60 => 'Baking',
    61 => 'Tailoring',
    63 => 'Blacksmithing',
    64 => 'Fletching',
    65 => 'Brewing',
    66 => 'Alcohol Tolerance',
    68 => 'Jewelry Making',
    69 => 'Pottery',
);

# category -> skills it raises
my %TRADESKILL_CATEGORY_SKILLS = (
    tailoring  => [ 61 ],
    smithing   => [ 63 ],
    brewing    => [ 65, 66 ],           # Brewing + Alcohol Tolerance
    research   => [ 58 ],
    jewelcraft => [ 68 ],
    fletching  => [ 64 ],
    baking     => [ 56, 59, 60 ],       # Baking + Alchemy + Make Poison
    pottery    => [ 69 ],
    fishing    => [ 55 ],
    tinkering  => [ 57 ],
    all        => [ @ALL_TRADESKILLS ],
);

# The kill lists. points = skill points added per kill, per skill in category.
my @TRADESKILL_KILL_LISTS = (
    {
        category => 'tailoring',
        points   => 5,
        targets  => [qw(
            lady_vox gorenaire dracoliche bazzt_zzzt lord_yelinak king_tormax
            shei_vinitras gozzrem rydda_dar jiva thall_va_kelun
            tantisala_jaggedtooth pyrique_redwing primal_arachnid
            primal_reptile phara_dar
        )],
    },
    {
        category => 'smithing',
        points   => 5,
        targets  => [qw(
            lord_nagafen talendor terror eye_of_veeshan avatar_of_war
            itraer_vius lord_inquisitor_seru zeixshi_kar
            zeixshi_kar_the_ancient nanzata_the_warder
            khati_sha_the_twisted cekenar rizlona thall_xundraux_diabo
            smith_rondo weapon_master_vtiink_vzaan zun_muram_votal
            derugoak_bloodwalker primal_insect druushk
        )],
    },
    {
        category => 'brewing',
        points   => 5,
        targets  => [qw(
            dain_frostreaver_iv prince_selrach_di_zok fright noble_dojorn
            derakor_the_vindicator bristlebane
            bristlebane_the_king_of_thieves tjudawos_the_ancient
            ventani_the_warder dagarn_the_destroyer lord_kreizenn arlyxir
            thall_va_xakra nexona
        )],
    },
    {
        category => 'research',
        points   => 5,
        targets  => [qw(
            overking_bathezid venril_sathir sister_of_the_spire
            velketor_the_sorcerer grieg_veneficus arch_lich_rhag_zadune
            kildrukaun_the_ancient aaryonar dozekar_the_cursed xuzl
            diabo_xi_va_temariel vrex_xalkak_nixki pixtt_grand_summoner
            lendiniara_the_keeper dartain_the_lost
        )],
    },
    {
        category => 'jewelcraft',
        points   => 5,
        targets  => [qw(
            queen_velazul_di_zok spiroc_lord rumblecrush aerin_dar
            vyskudra_the_ancient hraashna_the_warder lady_nevederia
            protector_of_dresolik diabo_xi_xin_thall spirit_of_tunik_tamuik
            pixtt_suir_mindrider silverwing ixiblat_fer
        )],
    },
    {
        category => 'fletching',
        points   => 5,
        targets  => [qw(
            klandicar doomshade jorlleag lord_feshlak diabo_xi_va
            perfected_warder_of_earth packmaster_skoiat_pizak
        )],
    },
    {
        category => 'baking',
        points   => 5,
        targets  => [qw(
            severilous trakanon zlandicar maestro_of_rancor dread gorgalosk
            wuoshi vallon_zek tukaarak_the_warder lady_mirenilla sevalak
            grummus diabo_xi_xin filth_gorger tainted_rock_beast
            hexxt_chaos_provoker hoshkar
        )],
    },
    {
        category => 'pottery',
        points   => 5,
        targets  => [qw(
            cazic_thule keeper_of_souls sontalak xerkizh_the_creator
            final_arbiter lord_vyemm telkorenar va_xi_aten_ha_ra
            monsterous_mudwalker mystical_arbitor_of_earth hulcror
            vrex_barxt_qurat nexona master_of_the_guard xygoz
        )],
    },
    {
        category => 'fishing',
        points   => 5,
        targets  => [qw(
            phinigel_autropos kelorek_dar faydedar protector_of_sky
            insanity_crawler lord_koi_doken zlexak kaas_thox_xi_ans_dyek
            hydrotha krziik_the_mighty
        )],
    },
    {
        category => 'tinkering',
        points   => 5,
        targets  => [qw(
            xanamech_nezmirthafen manaetic_behemoth
        )],
    },
    {
        category => 'all',
        points   => 1,
        targets  => [qw(
            kerafyrm kerafyrm_the_awakened cazic_thule tunare
            tunare_mother_of_all innoruuk bristlebane
            bristlebane_the_king_of_thieves solusek_ro emperor_ssraeshza
            rallos_zek rallos_zek_the_warlord terris_thule tallon_zek
            vallon_zek vulak_aerr bertoxxulous xegony_the_queen_of_air
            saryrn seventh_hammer agnarr_the_storm_lord
            lord_mithaniel_marr quarm triumvirate_of_soil
            coirnav_the_avatar_of_water fennin_ro_the_tyrant_of_fire
        )],
    },
);

# Trigger/placeholder copies of these names exist at level 1 (e.g. "Innoruuk"
# and "Cazic_Thule" in some zones); none of the real targets is below 50.
my $TRADESKILL_MIN_NPC_LEVEL = 45;

# name -> { category => points }, built from the lists above.
my %TRADESKILL_KILL_REWARDS;
for my $list (@TRADESKILL_KILL_LISTS) {
    for my $name (@{ $list->{targets} }) {
        next unless ($TRADESKILL_CATEGORY_SKILLS{ $list->{category} });
        $TRADESKILL_KILL_REWARDS{$name}{ $list->{category} } = $list->{points};
    }
}

# "##Vallon_Zek_", "#The_Fabled_Lady_Vox", "A_Tainted_Rock_Beast" and
# "Rydda`Dar" all become lower-case, underscore-separated container names.
sub NormalizeNPCName {
    my $name = lc(shift // '');
    $name =~ s/[^a-z0-9]+/_/g;
    $name =~ s/^_+//;
    $name =~ s/_+$//;
    # EntityList::MakeNameUnique() appends %03d to every spawned NPC.
    $name =~ s/_?\d{3}$//;
    $name =~ s/^_+//;
    $name =~ s/_+$//;
    $name =~ s/^the_fabled_//;
    $name =~ s/^(?:the|an|a)_//;
    $name =~ s/^_+//;
    $name =~ s/_+$//;
    return $name;
}

# Skill id -> the character's cap for it. Multiclass characters take the best
# of their classes, exactly like the #train trainer in global/Zapf.pl.
sub GetTradeskillMaxForClient {
    my ($client, $skill) = @_;
    return 0 unless ($client && $client->CanHaveSkill($skill));

    my $class_bits = $client->GetClassesBitmask() || $client->GetClassBitmask();
    my $level      = $client->GetLevel();
    my $best       = 0;

    for my $class_id (1 .. 16) {
        next unless ($class_bits & (1 << ($class_id - 1)));
        my $class_max = $client->MaxSkill($skill, $class_id, $level);
        $best = $class_max if ($class_max > $best);
    }

    return $best;
}

# The names to key the reward lookup on. GetOrigName() is the untouched
# npc_types.name; GetName() is the runtime name (with the MakeNameUnique %03d
# suffix), kept as a fallback in case orig_name is empty.
sub GetNPCNameCandidates {
    my ($npc) = @_;
    my @candidates;
    my $orig = $npc->GetOrigName();
    push @candidates, $orig if (defined($orig) && length($orig));
    my $runtime = $npc->GetName();
    push @candidates, $runtime if (defined($runtime) && length($runtime));
    return @candidates;
}

# A printable name: no leading '#', no '_', no uniqueness suffix.
sub GetNPCPrintName {
    my ($npc) = @_;
    my $name = $npc->GetOrigName();
    $name = $npc->GetName() if (!defined($name) || !length($name));
    $name = '' unless (defined($name));
    $name =~ s/_/ /g;
    $name =~ s/^\s*#+\s*//;
    $name =~ s/\s*\d{3}$//;
    $name =~ s/\s+/ /g;
    $name =~ s/^\s+|\s+$//g;
    return length($name) ? $name : 'your foe';
}

# NPC -> { skill_id => points } after expanding categories, or undef.
sub GetTradeskillKillReward {
    my ($npc) = @_;
    return undef unless ($npc);

    my $categories;
    for my $candidate (GetNPCNameCandidates($npc)) {
        my $key = NormalizeNPCName($candidate);
        next unless (length($key));
        my $found = $TRADESKILL_KILL_REWARDS{$key};
        if ($found) {
            $categories = $found;
            last;
        }
    }
    return undef unless ($categories);

    my %points;
    for my $category (keys %$categories) {
        my $skills = $TRADESKILL_CATEGORY_SKILLS{$category};
        next unless ($skills);
        for my $skill (@$skills) {
            $points{$skill} += $categories->{$category};
        }
    }

    return %points ? \%points : undef;
}

# Called from global_npc.pl EVENT_KILLED_MERIT, once per credited client.
# Returns 1 if at least one skill was raised.
sub AwardTradeskillKillCredit {
    my ($client, $npc) = @_;
    return 0 unless ($client && $npc);
    return 0 unless ($client->IsClient() && $npc->IsNPC());
    return 0 if ($npc->GetLevel() < $TRADESKILL_MIN_NPC_LEVEL);

    my $points = GetTradeskillKillReward($npc);
    return 0 unless ($points);

    my (@learned, @short);
    for my $skill (sort { $a <=> $b } keys %$points) {
        my $cap = GetTradeskillMaxForClient($client, $skill);
        next unless ($cap > 0);

        my $current = $client->GetSkill($skill);
        next if ($current >= $cap);

        my $gain = $points->{$skill};
        $gain = $cap - $current if (($current + $gain) > $cap);
        next unless ($gain > 0);

        my $new_value = $current + $gain;
        # SetSkill saves character_skills and sends OP_SkillUpdate; the client
        # also prints its own "You have become better at ..." line.
        $client->SetSkill($skill, $new_value);

        my $skill_name = $TRADESKILL_SKILL_NAMES{$skill} // "Skill $skill";
        push @learned, sprintf('%s +%d (%d/%d)', $skill_name, $gain, $new_value, $cap);
        push @short,   sprintf('%s +%d', $skill_name, $gain);
    }

    my $killed = GetNPCPrintName($npc);

    # Target matched but nothing could be raised: say so once, instead of
    # leaving the player wondering why a raid kill paid nothing.
    if (!@learned) {
        $client->Message(6, sprintf(
            'The death of %s teaches you nothing new -- your tradeskills are already at their limit.',
            $killed
        ));
        return 0;
    }

    # The reward has to be unmissable: a gold marquee across the screen, then a
    # lime chat line with the breakdown (the client's own skill-up lines are
    # yellow, so the summary reads differently).
    my $marquee = (@learned == 1)
        ? sprintf('TRADESKILL: %s', $learned[0])
        : (@learned <= 3)
            ? sprintf('TRADESKILL: %s', join(', ', @short))
            : sprintf('TRADESKILL: %d skills raised', scalar(@learned));

    $client->SendMarqueeMessage(15, 510, 0, 1000, 5000, $marquee);
    $client->Message(14, sprintf(
        'The death of %s teaches you a trade: %s.',
        $killed, join(', ', @learned)
    ));

    return 1;
}

1;

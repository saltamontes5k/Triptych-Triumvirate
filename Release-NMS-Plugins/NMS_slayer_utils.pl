sub ProcessSlayerCredit {
    my ($client, $npc, $entity_list) = @_;

    my %creature_data = (
        'human' => {
            race_ids    => [1,44,55,67,71,236,237,341,566],
            title_flags => 1000,
        },
        'barbarian' => {
            race_ids    => [2,90],
            title_flags => 1002,
        },
        'erudite' => {
            race_ids    => [3,78,342,678],
            title_flags => 1003,
        },
        'wood_elf' => {
            race_ids    => [4,112],
            title_flags => 1004,
        },
        'high_elf' => {
            race_ids    => [5,106],
            title_flags => 1005,
        },
        'dark_elf' => {
            race_ids    => [6,77,339,351,352],
            title_flags => 1006,
        },
        'half_elf' => {
            race_ids    => [7],
            title_flags => 1007,
        },
        'dwarf' => {
            race_ids    => [8,94,183,640,645],
            title_flags => 1008,
        },
        'troll' => {
            race_ids    => [9,92,331,332,333,335,336,337],
            title_flags => 1009,
        },
        'ogre' => {
            race_ids    => [10,93,325,340,624],
            title_flags => 1010,
        },
        'halfling' => {
            race_ids    => [11,81],
            title_flags => 1011,
        },
        'gnome' => {
            race_ids    => [12,338],
            title_flags => 1012,
        },
        'aviak' => {
            race_ids    => [13,558],
            title_flags => 1013,
        },
        'werewolf' => {
            race_ids    => [14,133,241,454],
            title_flags => 1014,
        },
        'fey' => {
            race_ids    => [15,25,56,64,69,79,86,110,113,124,154,173,178,185,187,242,243,564,244,434,473,493,520,568],
            title_flags => 1015,
        },
        'brownie' => {
            race_ids    => [15,568],
            title_flags => 1016,
        },
        'centaur' => {
            race_ids    => [16,521],
            title_flags => 1017,
        },
        'golem' => {
            race_ids    => [17,29,66,80,82,100,160,164,166,17,175,220,280,322,323,362,374,387,405,442,491,575,608],
            title_flags => 1018,
        },
        'giant' => {
            race_ids    => [18,140,188,189,453,490,523,626],
            title_flags => 1019,
        },
        'dragon' => {
            race_ids    => [19,49,122,165,184,192,195,196,198,435,437,438,452,530],
            title_flags => 1020,
        },
        'iksar' => {
            race_ids    => [20,128,139],
            title_flags => 1021,
        },
        'evil_eye' => {
            race_ids    => [21,30,375,469],
            title_flags => 1022,
        },
        'insect' => {
            race_ids    => [22,38,109,129,134,199,201,207,223,245,265,370,559,611],
            title_flags => 1023,
        },
        'cat_girls' => {
            race_ids    => [23,562],
            title_flags => 1024,
        },
        'fairy' => {
            race_ids    => [25,473],
            title_flags => 1025,
        },
        'froglok' => {
            race_ids    => [26,27,102,330],
            title_flags => 1026,
        },
        'undead' => {
            race_ids    => [27,33,45,60,70,85,117,118,122,146,147,155,174,224,234,250,286,297,324,334,349,350,353,354,355,357,359,360,365,367,368,371,373,471,485,487,488,571,587,588,605,606,604],
            title_flags => 1027,
        },
        'sporali' => {
            race_ids    => [28,456],
            title_flags => 1028,
        },
        'gargoyle' => {
            race_ids    => [29,280,464],
            title_flags => 1029,
        },
        'fish' => {
            race_ids    => [24,61,74,105,116,148,213,315],
            title_flags => 1030,
        },
        'shark' => {
            race_ids    => [61],
            title_flags => 1031,
        },
        'gelatinous_cube' => {
            race_ids    => [31],
            title_flags => 1032,
        },
        'ghoul' => {
            race_ids    => [33,571],
            title_flags => 1033,
        },
        'beast' => {
            race_ids    => [34,36,37,41,42,43,63,76,83,87,91,135,148,169,176,177,194,200,206,221,222,232,259,260,279,314,315,316,317,319,321,348,356,388,389,390,391,392,409,410,414,415,436,439,468,560,580,668],
            title_flags => 1034,
        },
        'bat' => {
            race_ids    => [34,260,416],
            title_flags => 1035,
        },
        'rat' => {
            race_ids    => [36,415],
            title_flags => 1036,
        },
        'snake' => {
            race_ids    => [37,468],
            title_flags => 1037,
        },
        'spider' => {
            race_ids    => [38,326,327,440,441,450,451],
            title_flags => 1038,
        },
        'gnoll' => {
            race_ids    => [39,524,617],
            title_flags => 1039,
        },
        'goblin' => {
            race_ids    => [40,59,137,277,369,433],
            title_flags => 1040,
        },
        'gorilla' => {
            race_ids    => [41],
            title_flags => 1041,
        },
        'wolf' => {
            race_ids    => [42,232],
            title_flags => 1042,
        },
        'bear' => {
            race_ids    => [43,206,305],
            title_flags => 1043,
        },
        'skeleton' => {
            race_ids    => [45,60,122,155,161,234,324,349,362,367,491,604,606],
            title_flags => 1044,
        },
        'demon' => {
            race_ids    => [46,300,408,614],
            title_flags => 1045,
        },
        'griffin' => {
            race_ids    => [47,525],
            title_flags => 1046,
        },
        'kobold' => {
            race_ids    => [48,455],
            title_flags => 1047,
        },
        'cat' => {
            race_ids    => [50,63,76,119,221,314,439],
            title_flags => 1048,
        },
        'lizard' => {
            race_ids    => [51],
            title_flags => 1049,
        },
        'minotaur' => {
            race_ids    => [53,420,470,474],
            title_flags => 1050,
        },
        'orc' => {
            race_ids    => [54,361,366,458,579],
            title_flags => 1051,
        },
        'pixie' => {
            race_ids    => [56],
            title_flags => 1052,
        },
        'drachnid' => {
            race_ids    => [57,149,461],
            title_flags => 1053,
        },
        'god' => {
            race_ids    => [58,62,95,123,150,151,153,246,247,255,256,257,278,283,284,288,289,290,205,296,298,299,304,498,670],
            title_flags => 1054,
        },
        'treant' => {
            race_ids    => [64,244,496],
            title_flags => 1055,
        },
        'vampire' => {
            race_ids    => [65,98,193,208,219,359,360,365,466,497],
            title_flags => 1056,
        },
        'abomination' => {
            race_ids    => [68,80,96,104,110,138,57,149,159,172,214,258,281,362,412,494,620],
            title_flags => 1057,
        },
        'zombie' => {
            race_ids    => [70,471],
            title_flags => 1058,
        },
        'elemental' => {
            race_ids    => [75,209,210,211,212,475,376,377,478],
            title_flags => 1059,
        },
        'scarecrow' => {
            race_ids    => [8,575],
            title_flags => 1060,
        },
        'spectre' => {
            race_ids    => [85,174,485],
            title_flags => 1061,
        },
        'sphinx' => {
            race_ids    => [86,565],
            title_flags => 1062,
        },
        'clockwork' => {
            race_ids    => [88,192,248,249,263,273,274,275,276,457,472,570,572,577],
            title_flags => 1063,
        },
        'drake' => {
            race_ids    => [89,154,430,432],
            title_flags => 1064,
        },
        'cockatrice' => {
            race_ids    => [96],
            title_flags => 1065,
        },
        'amygdalan' => {
            race_ids    => [24,663],
            title_flags => 1066,
        },
        'efreeti' => {
            race_ids    => [101,126,320],
            title_flags => 1067,
        },
        'kedge' => {
            race_ids    => [103,561],
            title_flags => 1068,
        },
        'mammoth' => {
            race_ids    => [107,528],
            title_flags => 1069,
        },
        'merfolk' => {
            race_ids    => [110,187,242,564,261],
            title_flags => 1070,
        },
        'harpy' => {
            race_ids    => [111,121,527],
            title_flags => 1071,
        },
        'ghost' => {
            race_ids    => [117,118,120,146,147,196,224,250,334,371,487,488,526,587,588,605,606,604],
            title_flags => 1072,
        },
        'unicorn' => {
            race_ids    => [124,519],
            title_flags => 1073,
        },
        'pegasus' => {
            race_ids    => [125,493],
            title_flags => 1074,
        },
        'vah_shir' => {
            race_ids    => [130,238,239],
            title_flags => 1075,
        },
        'sarnak' => {
            race_ids    => [131,136,610],
            title_flags => 1076,
        },
        'burynai' => {
            race_ids    => [144,602],
            title_flags => 1077,
        },
        'slime' => {
            race_ids    => [145],
            title_flags => 1078,
        },
        'ratman' => {
            race_ids    => [156,718],
            title_flags => 1079,
        },
        'wyvern' => {
            race_ids    => [157,581],
            title_flags => 1080,
        },
        'wurm' => {
            race_ids    => [158,613],
            title_flags => 1081,
        },
        'plant' => {
            race_ids    => [162,167,225,227,218,258,494,573],
            title_flags => 1082,
        },
        'raptor' => {
            race_ids    => [163,609],
            title_flags => 1083,
        },
        'holgresh' => {
            race_ids    => [168],
            title_flags => 1084,
        },
        'yak_man' => {
            race_ids    => [181],
            title_flags => 1085,
        },
        'coldain' => {
            race_ids    => [183,640,645],
            title_flags => 1086,
        },
        'otter_man' => {
            race_ids    => [190],
            title_flags => 1087,
        },
        'walrus_man' => {
            race_ids    => [191],
            title_flags => 1088,
        },
        'turtle' => {
            race_ids    => [194],
            title_flags => 1089,
        },
        'grimling' => {
            race_ids    => [202],
            title_flags => 1090,
        },
        'worm' => {
            race_ids    => [104,203],
            title_flags => 1091,
        },
        'thought_horror' => {
            race_ids    => [214],
            title_flags => 1092,
        },
        'shissar' => {
            race_ids    => [217,563],
            title_flags => 1093,
        },
        'akhevan' => {
            race_ids    => [230],
            title_flags => 1094,
        },
        'mutant' => {
            race_ids    => [235,229,228,215],
            title_flags => 1095,
        },
        'slarghilug' => {
            race_ids    => [261],
            title_flags => 1096,
        },
        'mephit' => {
            race_ids    => [271,272,291,292,293,294,607],
            title_flags => 1097,
        },
        'extraplanar' => {
            race_ids    => [98,99,121,173,251,253,254,266,267,268,269,270,271,272,264,277,281,291,292,293,294,285,286,287,297,300,302,303,306,307,308,309,310,311,312,313,314,319,363,407,408,431,607,663],
            title_flags => 1098,
        },
        'phoenix' => {
            race_ids    => [303],
            title_flags => 1099,
        },
        'wrulon' => {
            race_ids    => [314],
            title_flags => 1100,
        },
        'pirate' => {
            race_ids    => [334,342,341,340,339,338,337,336,335,334,333,332,331],
            title_flags => 1101,
        },
        'luggald' => {
            race_ids    => [345,346,347],
            title_flags => 1102,
        },
        'taelosian' => {
            race_ids    => [385,386,403],
            title_flags => 1103,
        },
        'muramite' => {
            race_ids    => [392,393,394,395,396,397,398,399,400,402,406,418,419,420],
            title_flags => 1104,
        },
        'pyrilen' => {
            race_ids    => [411],
            title_flags => 1105,
        },
        'dragorn' => {
            race_ids    => [413],
            title_flags => 1106,
        },
        'gelidran' => {
            race_ids    => [417],
            title_flags => 1107,
        },
        'kirin' => {
            race_ids    => [434],
            title_flags => 1108,
        },
        'drakkin' => {
            race_ids    => [522],
            title_flags => 1109,
        },
    );

    my @tiers = (100, 1000, 10000, 100000, 1000000);
    my $this_race = $npc->GetBaseRace(); # Get the race ID of the current NPC

    foreach my $category (keys %creature_data) {
        my $data = $creature_data{$category};

        # Check if $this_race is in the race_ids for this category
        if (grep { $_ == $this_race } @{$data->{race_ids}}) {
            # Sum all the kill counts for the races in this category
            my $sum = 0;
            foreach my $race_id (@{$data->{race_ids}}) {
                $sum += $client->GetKillCount($race_id);
            }

            # Perform actions for each tier that $sum is greater than or equal to
            for my $tier_index (0 .. $#tiers) {
                my $tier = $tiers[$tier_index];

                if ($sum >= $tier) {
                    my $title_set = (($data->{title_flags} * 10) + ($tier_index + 1));

                    # Replace this with the actual action you want to perform

                    if (!$client->CheckTitle($title_set)) {
                        plugin::AddTitleFlag($title_set, $client);
                    }
                }
            }
        }
    }
}

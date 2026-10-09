# a_crystalline_avatar.pl -- Rank II favor of Veeshan: "Memory in Crystal".
# A 5-question /say trivia quiz (simplified from the live 3-minute timer).
# Answer activities are quest-driven: this script calls UpdateTaskActivity on
# each correct answer; the rank is granted by EVENT_TASK_COMPLETE ->
# plugin::BlessingGrantRank (single-authority design).

my $TREE = 216;
my $TASK = 700235;

# [question, [accepted answers]] -- classic-era lore, lowercase compare.
my @QUIZ = (
    ["Tassel's Tavern pours ale in which seaside city?", ['freeport']],
    ["McQuaids Dark Stout flows in which frozen city?", ['halas']],
    ["Deathsteel Ore is drawn from the earth of which continent?", ['kunark']],
    ["The heretic Erudites raised which city of night?", ['paineel']],
    ["The Fool's Gold tavern pours ale in which small town?", ['rivervale']],
    ["In which treetop city is the Sparkling Glass shop found?", ['kelethin']],
    ["How many portal stones ring the Plane of Knowledge?", ['24', 'twenty four', 'twenty-four']],
    ["Who rules the cat-city of Shar Vahl as king?", ['raja kerrath', 'raja']],
    ["What is the name of the great ship moored in the Abysmal Sea?", ['queen of thorns', 'the queen of thorns']],
    ["What number marks the miners guild of Kaladim?", ['628', 'six hundred twenty eight', 'six hundred and twenty eight']],
    ["Saryrn's raven is called what name?", ['sorrowsong']],
    ["Which dragon guards the lava pits of Veeshan's Peak?", ['hoshkar']],
);

sub _bless_lc {
    my $s = lc(shift // '');
    $s =~ s/[^a-z0-9 ]//g;
    $s =~ s/^\s+|\s+$//g;
    return $s;
}

sub _bless_ask {
    my ($client, $idx) = @_;
    my @picks = split /,/, $client->GetEntityVariable('blessquiz-q') || '';
    my $q = $QUIZ[$picks[$idx - 1]];
    plugin::Whisper("Question $idx of 5: " . $q->[0]);
}

sub _bless_start {
    my ($client) = @_;
    my @order = (0 .. $#QUIZ);
    for my $i (reverse 1 .. $#order) {
        my $j = int(rand($i + 1));
        @order[$i, $j] = @order[$j, $i];
    }
    $client->SetEntityVariable('blessquiz-q', join(',', @order));
    $client->SetEntityVariable('blessquiz-idx', 1);
    _bless_ask($client, 1);
}

sub EVENT_SAY {
    my $deity  = plugin::BlessingCheckDeity($client);
    my $rank   = plugin::BlessingRank($client);
    my $answer = _bless_lc($text);

    # mid-quiz: an answer is expected
    my $idx = int($client->GetEntityVariable('blessquiz-idx') || 0);
    if ($idx >= 1 && $idx <= 5 && $answer ne 'hail') {
        my @picks = split /,/, $client->GetEntityVariable('blessquiz-q') || '';
        my $ok = 0;
        for my $a (@{ $QUIZ[$picks[$idx - 1]][1] }) {
            $ok = 1 if $answer eq _bless_lc($a);
        }
        if ($ok) {
            $client->UpdateTaskActivity($TASK, $idx, 1);
            if ($idx >= 5) {
                $client->SetEntityVariable('blessquiz-idx', 0);
                plugin::Whisper("The crystals chime as one. You did well to answer my questions, $name.");
            } else {
                $idx += 1;
                $client->SetEntityVariable('blessquiz-idx', $idx);
                plugin::Whisper("The crystal glows brighter.");
                _bless_ask($client, $idx);
            }
        } else {
            plugin::Whisper("The crystals dim. Think again, $name.");
        }
        return;
    }

    return unless $text =~ /hail/i;
    if ($rank < 1) {
        plugin::Whisper("First kindle your devotion at the Keeper of Devotion in The Bazaar, $name.");
    } elsif ($rank >= 2) {
        plugin::Whisper("You have already proven your memory, $name. The Wyrmqueen is content.");
    } elsif (!(plugin::BlessingIsAgnostic($deity) || $deity == $TREE)) {
        plugin::Whisper("The god I serve is not the god that binds you, $name.");
    } elsif (plugin::BlessingAssignRank2($client, $TREE)) {
        plugin::Whisper("So be it. Answer five questions of memory within the crystal -- say your answers aloud.");
        _bless_start($client);
    } else {
        plugin::Whisper("Your task is already upon you, $name. Answer the question posed to you.");
    }
}

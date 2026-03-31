unit module Math::GameTheory::Creators;

use Statistics::Distributions;

our proto sub matrix-game(Str:D $name, |) is export {*}

#| ArmsRaces matrix game
our multi sub matrix-game("ArmsRaces") {
    my $n = 1;
    my @coeff = sub ($x) { -0.5 * $x }, sub ($x, $y) { $x - $y };

    my @payoff-array;
    for 0..$n -> $i {
        for 0..$n -> $j {
            my $val1 = @coeff[1]($i, $j) - @coeff[0]($i);
            my $val2 = @coeff[1]($j, $i) - @coeff[0]($j);
            @payoff-array[$i][$j] = [$val1, $val2];
        }
    }

    return Math::GameTheory::MatrixGame.new(
        :@payoff-array,
        game-action-labels => [0..$n, 0..$n]
    )
}

#| BachOrStravinsky game
our multi sub matrix-game("BachOrStravinsky") {
    my ($win, $lose, $unc) = (3, 2, 0);
    Math::GameTheory::MatrixGame.new(
            payoff-array => [
                [[$win, $lose], [$unc, $unc]],
                [[$unc, $unc], [$lose, $win]]
            ],
            game-action-labels => [["Stravinsky", "Bach"], ["Stravinsky", "Bach"]]
            )
}

#| BattleOfTheBismarck matrix game
our multi sub matrix-game("BattleOfTheBismarck") {
    my ($a, $b, $c) = (1, 2, 3);
    return Math::GameTheory::MatrixGame.new(
            payoff-array => [
                [[$b, $b], [$a, $c]],
            ],
            game-player-labels => ["Kennedy", "Kimura"],
            game-action-labels => [["North", "South"], ["North", "South"]]
            )
}

#| BertrandOligopoly matrix game
our multi sub matrix-game("BertrandOligopoly") {
    my @prices = ([1, 2], [1, 2], [1, 3]);
    my @costs = (0.3, 0.5, 0.7);
    my &demand = -> $p { 100 * $p };

    my @payoff-array;
    for ^@prices -> $i {
        my @row;
        for ^@prices[$i] -> $j {
            my @p-list;
            for ^@prices -> $k {
                @p-list.push: @prices[$k][$i];
            }
            my $m = @p-list.min;
            my @m-indices = grep { @p-list[$_] == $m }, ^@p-list;
            my @revenue;
            for ^@prices -> $k {
                if @m-indices.contains($k) {
                    my $quantity = demand($m) / @m-indices.elems;
                    @revenue.push: $m * ($quantity - @costs[$k] * $quantity);
                } else {
                    @revenue.push: 0;
                }
            }
            @row.push: @revenue;
        }
        @payoff-array.push: @row;
    }

    return Math::GameTheory::MatrixGame.new(
            :@payoff-array,
            game-action-labels => @prices
            )
}

#| BuyingStock matrix game
our multi sub matrix-game("BuyingStock") {
    return Math::GameTheory::MatrixGame.new(
            payoff-array => [
                [
                    [[0, 12, 11], [6, 7, 11]],
                    [[11, 6, 3], [1, 8, 3]]
                ],
                [
                    [[6, 10, 0], [4, 12, 14]],
                    [[6, 8, 2], [8, 1, 7]]
                ]
            ],
            game-action-labels => [
                ["Stock #1", "Stock #2"],
                ["Stock #1", "Stock #2"],
                ["Stock #1", "Stock #2"]
            ]
            )
}

#| Chicken matrix game
our multi sub matrix-game("Chicken") {
    my ($swerve, $win, $collision) = (0, 1, -5);
    return Math::GameTheory::MatrixGame.new(
            payoff-array => [
                [[$swerve, $swerve], [-$win, $win]],
                [[$win, -$win], [$collision, $collision]]
            ],
            game-action-labels => [["Swerve", "Straight"], ["Swerve", "Straight"]]
            )
}

#| Contribution matrix game
our multi sub matrix-game("Contribution") {
    my ($a, $b, $c, $d, $w, $x, $y, $z) = (1, 4, 2, 3, 1, 2, 3, 4);
    return Math::GameTheory::MatrixGame.new(
            payoff-array => [
                [[$a, $w], [$b, $x]],
                [[$c, $y], [$d, $z]]
            ]
            )
}

#| Convergence matrix game
our multi sub matrix-game("Convergence") {
    my ($a, $b, $c, $d) = (2, 4, 3, 1);
    return Math::GameTheory::MatrixGame.new(
            payoff-array => [
                [[$b, $b], [$a, $d]],
                [[$d, $a], [$c, $c]]
            ]
            )
}

#| DangerousCoordination matrix game
our multi sub matrix-game("DangerousCoordination") {
    return Math::GameTheory::MatrixGame.new(
            payoff-array => [
                [[1, 1], [-1, -1]],
                [[-1000, -1], [2, 2]]
            ],
            game-action-labels => [["Left", "Right"], ["Left", "Right"]]
            )
}

#| Discoordination matrix game
our multi sub matrix-game("Discoordination") {
    my ($a, $b, $c, $d, $w, $x, $y, $z) = (1, 2, 3, 4, 1, 2, 3, 4);
    return Math::GameTheory::MatrixGame.new(
            payoff-array => [
                [[$a, $w], [$b, $x]],
                [[$c, $y], [$d, $z]]
            ]
            )
}

#| Exponential matrix game
our multi sub matrix-game("Exponential") {
    return Math::GameTheory::MatrixGame.new(
            payoff-array => [
                [[-(2**3), (2**3) + 1], [0, 0]],
                [[0, 0], [2, -1]]
            ]
            )
}

#| Greedy matrix game
our multi sub matrix-game("Greedy") {
    my ($i1, $i2, $p, $n) = (0, 1, 2, 4);
    my @l = 0..^$n;
    my @r = @l.combinations(1..^$p.min($n));
    my @b = @l.combinations(1..$n);

    my @payoff-array;
    for @r.kv -> $i, $r-set {
        for @b.kv -> $j, $b-set {
            if $r-set.grep: * ∈ $b-set {
                @payoff-array[$i][$j] = [$i1, $i1];
            } else {
                @payoff-array[$i][$j] = [$i2, $i2];
            }
        }
    }

    return Math::GameTheory::MatrixGame.new(
            :@payoff-array,
            game-player-labels => ["Red", "Blue"],
            game-action-labels => [@r, @b]
            )
}

#| HawkDove matrix game
our multi sub matrix-game("HawkDove") {
    my ($win, $fight) = (2, 1);
    return Math::GameTheory::MatrixGame.new(
            payoff-array => [
                [[$win / 2 - $fight, $win / 2 - $fight], [$win, 0]],
                [[0, $win], [$win / 2, $win / 2]]
            ],
            game-action-labels => [["Dove", "Hawk"], ["Dove", "Hawk"]]
            )
}

#| Hero matrix game
our multi sub matrix-game("Hero") {
    my ($d, $c, $b, $a) = (1, 2, 3, 4);
    return Math::GameTheory::MatrixGame.new(
            payoff-array => [
                [[$c, $c], [$a, $b]],
                [[$b, $a], [$d, $d]]
            ]
            )
}

#| Inspection matrix game
our multi sub matrix-game("Inspection") {
    my ($h, $g, $w, $v) = (1, 2, 3, 6);
    return Math::GameTheory::MatrixGame.new(
            payoff-array => [
                [[0, -$h], [$w, -$w]],
                [
                    [$w - $g, ($v - $w) - $h],
                    [$w - $g, $v - $w]
                ]
            ],
            game-player-labels => ["Principal", "Agent"],
            game-action-labels => [["Shirk", "Work"], ["Inspect", "Not Inspect"]]
            )
}

#| MatchingPennies matrix game
our multi sub matrix-game("MatchingPennies") {
    return Math::GameTheory::MatrixGame.new(
            payoff-array => [
                [[1, -1], [-1, 1]],
                [[-1, 1], [1, -1]]
            ],
            game-player-labels => ["Even", "Odd"],
            game-action-labels => [["Heads", "Tails"], ["Heads", "Tails"]]
            )
}

#| NashPoker matrix game
our multi sub matrix-game("NashPoker") {
    return Math::GameTheory::MatrixGame.new(
            payoff-array => [
                [
                    [[-(4 ** -1), 1/4, 0], [-(4 ** -1), 1/4, 0]],
                    [[-(4 ** -1), -(4 ** -1), 1/2], [0, 0, 0]],
                    [[-(4 ** -1), 1/2, -(4 ** -1)], [0, -(4 ** -1), 1/4]],
                    [[-(4 ** -1), 0, 1/4], [1/4, -(2 ** -1), 1/4]]
                ],
                [
                    [[1/8, -(4 ** -1), 1/8], [1/8, -(4 ** -1), 1/8]],
                    [[0, -(4 ** -1), 1/4], [-(2 ** -1), 1/4, 1/4]],
                    [[1/4, 1/8, -3/8], [1/4, -7/8, 5/8]],
                    [[1/8, 1/8, -(4 ** -1)], [-3/8, -3/8, 3/4]]
                ]
            ],
            game-action-labels => [
                ["Open", "Close"],
                ["OpenHigh", "CloseHigh", "OpenLow", "CloseLow"],
                ["Open", "Close"]
            ]
            )
}

#| OddsAndEvens matrix game
our multi sub matrix-game("OddsAndEvens") {
    my ($win, $lose) = (1, 0);
    return Math::GameTheory::MatrixGame.new(
            payoff-array => [
                [[$lose, $win], [$win, $lose]],
                [[$win, $lose], [$lose, $win]]
            ],
            game-action-labels => [["One", "Two"], ["One", "Two"]],
            game-player-labels => ["Odds", "Evens"]
            )
}

#| OptionalPrisonersDilemma matrix game
our multi sub matrix-game("OptionalPrisonersDilemma") {
    my ($coop, $defect, $abstain, $betray, $betrayed) = (1, -1, 0, 2, -2);
    return Math::GameTheory::MatrixGame.new(
            payoff-array => [
                [[$coop, $coop], [$betrayed, $betray], [$abstain, $abstain]],
                [[$betray, $betrayed], [$defect, $defect], [$abstain, $abstain]],
                [[$abstain, $abstain], [$abstain, $abstain], [$abstain, $abstain]]
            ],
            game-action-labels => [["Cooperate", "Defect", "Abstain"], ["Cooperate", "Defect", "Abstain"]]
            )
}

#| PrisonersDilemma matrix game
our multi sub matrix-game("PrisonersDilemma") {
    my ($coop, $betray, $betrayed, $defect) = (-1, 0, -3, -2);
    return Math::GameTheory::MatrixGame.new(
            payoff-array => [
                [[$coop, $coop], [$betrayed, $betray]],
                [[$betray, $betrayed], [$defect, $defect]]
            ],
            game-action-labels => [["Cooperate", "Defect"], ["Cooperate", "Defect"]]
            )
}

#| RockPaperScissors matrix game
our multi sub matrix-game("RockPaperScissors") {
    my ($lose, $null, $win) = (-1, 0, 1);
    return Math::GameTheory::MatrixGame.new(
            payoff-array => [
                [[$null, $null], [$lose, $win], [$win, $lose]],
                [[$win, $lose], [$null, $null], [$lose, $win]],
                [[$lose, $win], [$win, $lose], [$null, $null]]
            ],
            game-action-labels => [["Rock", "Paper", "Scissors"], ["Rock", "Paper", "Scissors"]]
            )
}

#| Shapley matrix game
our multi sub matrix-game("Shapley") {
    my ($lose, $null, $win) = (-1, 0, 1);
    return Math::GameTheory::MatrixGame.new(
            payoff-array => [
                [[$null, $null], [$win, $lose], [$lose, $win]],
                [[$lose, $win], [$null, $null], [$win, $lose]],
                [[$win, $lose], [$lose, $win], [$null, $null]]
            ]
            )
}

#| SimpleInspection matrix game
our multi sub matrix-game("SimpleInspection") {
    my ($n, $p, $q) = (4, 2, 2);
    my @l = 1..$n;
    my @r = @l.combinations($p);
    my @b = @l.combinations($q);

    my @payoff-array;
    for 0..@r.end -> $i {
        for 0..@b.end -> $j {
            if @r[$i] ∩ @b[$j] -> $intersection {
                @payoff-array[$i][$j] = [0, 0];
            } else {
                @payoff-array[$i][$j] = [1, 1];
            }
        }
    }

    return Math::GameTheory::MatrixGame.new(
            :@payoff-array,
            game-player-labels => ["Red", "Blue"],
            game-action-labels => [@r, @b]
            )
}

#| SmallPig matrix game
our multi sub matrix-game("SmallPig") {
    my ($f, $e, $d, $c, $b, $a) = (0, 1, 2, 3, 4, 5);
    return Math::GameTheory::MatrixGame.new(
            payoff-array => [
                [[$b, $d], [$c, $c]],
                [[$a, $f], [$e, $e]]
            ]
            )
}

#| StagHunt matrix game
our multi sub matrix-game("StagHunt") {
    my ($a, $b, $c, $d) = (4, 3, 1, 2);
    return Math::GameTheory::MatrixGame.new(
            payoff-array => [
                [[$a, $a], [$c, $b]],
                [[$b, $c], [$d, $d]]
            ],
            game-action-labels => [["Stag", "Hare"], ["Stag", "Hare"]]
            )
}

#| TravelersDilemma matrix game
our multi sub matrix-game("TravelersDilemma") {
    my ($k, $min, $d) = (5, 2, 1);

    sub f($x, $y) {
        return $min($x, $y) + 2 * ($y - $x).sign;
    }

    my @payoff-array;
    for 2..$k + 1 -> $x {
        for 2..$k + 1 -> $y {
            @payoff-array[$x - 2][$y - 2] = [f($x, $y), f($y, $x)];
        }
    }

    return Math::GameTheory::MatrixGame.new(
            :@payoff-array
            )
}

#| Welfare matrix game
our multi sub matrix-game("Welfare") {
    my ($e, $d, $c, $b, $a) = (-1, 0, 1, 2, 3);
    return Math::GameTheory::MatrixGame.new(
            payoff-array => [
                [[$a, $b], [$e, $a]],
                [[$e, $c], [$d, $d]]
            ],
            game-player-labels => ["Government", "Pauper"],
            game-action-labels => [["Aid", "No Aid"], ["Work", "Loaf"]]
            )
}

#| Compound matrix game
our multi sub matrix-game("Compound", Int:D $n where * >= 1) {
    my ($r, $s, $t, $p) = (2, 1, 4, 3);

    my $payoff-function = sub ($option, $x) {
        return $option == 0 ?? ($r * $x) + $s * (($n - 1) - $x) !! ($t * $x) + $p * (($n - 1) - $x);
    };

    my @payoff-array;

    for ^2 ** $n -> $i {
        my @row;
        for ^2 -> $j {
            my @indices = $i.base(2).comb;
            @indices = (0 xx ($n - @indices.elems)) ++ @indices;
            my $x = [+] (^$n).grep({ @indices[$_] == 1 }).map({ 1 - (1 - 1) });
            my $option = @indices[$j];
            push @row, $payoff-function($option, $x);
        }
        push @payoff-array, [@row];
    }

    return Math::GameTheory::MatrixGame.new(
            :@payoff-array,
            game-action-labels => [(["Cooperate", "Defect"] xx $n).flat]
            );
}

#| DinersDilemma matrix game
our multi sub matrix-game("DinersDilemma", Int $n = 2) {
    my @utility-price-list = [[-1, -2], [-1, -3], [-1, -4]];
    my $m = @utility-price-list.elems;

    my $payoff-f = sub (@a-l) {
        my @first = @a-l.map({ @utility-price-list[$_ - 1][0] });
        my @second = @a-l.map({ @utility-price-list[$_ - 1][1] });
        return @first.sum - @second.sum / $n;
    };

    my @payoff-array;
    for (^$m) X (^$m) -> ($i, $j) {
        @payoff-array[$i][$j] = $payoff-f([$i + 1, $j + 1]);
    }

    return Math::GameTheory::MatrixGame.new(:@payoff-array);
}

#| Random matrix game
our multi sub matrix-game("Random", Int:D $n where * >= 1) {
    my @sizes = $n xx ($n + 1);
    my @payoff-array = random-variate(NormalDistribution.new, [*] @sizes);
    for @sizes.tail(*-1).reverse -> $s {
        @payoff-array .= rotor($s)
    }
    return Math::GameTheory::MatrixGame.new(:@payoff-array);
}
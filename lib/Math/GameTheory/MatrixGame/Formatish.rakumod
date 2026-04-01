use v6.d;

role Math::GameTheory::MatrixGame::Formatish {

    #| WL representation of the game
    method wl() {
        my $arr = self.payoff-array.raku.trans(['[' => '{', ']' => '}']);
        my $actLables = self.game-action-labels.raku.trans(['[' => '{', ']' => '}']);
        my $plLables = self.game-player-labels.raku.trans(['[' => '{', ']' => '}']);
        return "MatrixGame[$arr, GameActionLabels -> $actLables, GamePlayerLabels -> $plLables]";
    }

    #| HTML representation of the game
    method html(
            :$colors is copy = Whatever,
            :$font-color is copy = Whatever,
            :$theme is copy = 'default',
            Bool:D :$caption = True
    ) {

        if $theme.isa(Whatever) { $theme = 'default'}

        if $theme.lc ∈ <grayscale gray-scale greyscale grey-scale gray grey> {
            $colors = generate-colors(self.game-player-labels.elems);
            $font-color = 'gainsboro';
        } elsif $theme.lc ∈ <mono monochrome black-and-white bw blackandwhite> {
            $colors = ('black' xx self.game-player-labels) unless $colors ~~ Positional:D && $colors.all ~~ Str:D;
            $font-color = 'silver' unless $font-color ~~ Str:D;
        } elsif $theme.lc ∈ <default wl> {
            $colors = <#9ecce6 #f9cf92 #b7d7a8>,
            $font-color = '#666666';
        }

        my @player-labels = self.game-player-labels;
        my @row-actions = ((self.game-action-labels[0] // []).list).Array;
        my @col-actions = ((self.game-action-labels[1] // []).list).Array;

        my $name = self.name ~~ Whatever ?? '' !! esc(self.name);
        @player-labels .= map({ esc($_) });
        @row-actions .= map({ esc($_) });
        @col-actions .= map({ esc($_) });
        my $max-payoff-len = 1;

        for self.payoff-array -> @row {
            for @row -> @payoff {
                for @payoff -> $value {
                    my $len = $value.Str.chars;
                    $max-payoff-len = $len if $len > $max-payoff-len;
                }
            }
        }

        my %actionIndex = self.game-action-labels.head.Array Z=> ( 0 ... ^self.game-action-labels.head.elems).Array;

        sub game-payoff(@profile) {
            reduce({$^a[$^b]}, self.payoff-array, |%actionIndex{|@profile})
        }

        return payoff-table-html(
                @player-labels,
                @row-actions,
                &game-payoff,
                :$colors,
                :$font-color,
                caption => $caption ?? $name !! '');
    }

    sub generate-colors(Int $n, $start = 0x1f1f1f, $end = 0x4f4f4f) {
        my @colors;
        my $step = ($end - $start) div ($n - 1);

        for ^ $n -> $i {
            my $color-value = $start + $i * $step;
            my $color-hex = sprintf("#%06x", $color-value);
            @colors.push($color-hex);
        }
        return @colors;
    }

    sub esc($text) {
        $text.Str
                .subst('&', '&amp;', :g)
                .subst('<', '&lt;', :g)
                .subst('>', '&gt;', :g)
                .subst('"', '&quot;', :g)
                .subst("'", '&#39;', :g)
    }

    sub cartesian-tuples(@lists) {
        if @lists {
            my @rest = cartesian-tuples(@lists[1..*]);
            gather for @lists[0].list -> $x {
                for @rest -> @r {
                    take [$x, |@r];
                }
            }
        } else {
            [(),]
        }
    }

    sub payoff-table-html(
            @players,
            @strategies,
            &payoff-fn,
            :@colors = <#b9d8ea #f3cf95 #b7d7a8>,
            :$font-color = 'black',
            :$border = 1,
            :$caption = ''
                          ) {
        die "At least one player is required." unless @players.elems;
        die "At least one strategy is required." unless @strategies.elems;

        my $n = @players.elems;
        my $m = @strategies.elems;

        sub color-for($i) {
            @colors[$i % @colors.elems]
        }

        my @col-profiles =
                $n == 1
                ?? [(),]
                !! cartesian-tuples(([ @strategies ] xx ($n - 1)));

        my $html = '';

        $html ~= "<table border=\"$border\" cellspacing=\"0\" cellpadding=\"6\">\n";
        if $caption {
            $html ~= "  <caption align=bottom><i>{$caption}</i></caption>";
        }

        # Header rows for players 2..n
        for 1 ..^ $n -> $level {
            $html ~= "  <tr>\n";


            $html ~= "    <th bgcolor=\"" ~ color-for($n-1) ~ "\" style=\"color:{$font-color};\"></th>\n";

            my $repeat-block = $m ** ($n - $level - 1);
            my $span = $n * $repeat-block;

            for ^($m ** ($level - 1)) {
                for @strategies -> $s {
                    $html ~= "    <th bgcolor=\"{color-for($n-$level)}\" colspan=\"$span\" align=\"center\" style=\"color:{$font-color};\">{$s}</th>\n";
                }
            }

            $html ~= "  </tr>\n";
        }

        # Data rows
        for @strategies -> $row-strategy {

            $html ~= "  <tr>\n";
            $html ~= "    <th bgcolor=\"" ~ color-for(0) ~ "\" align=\"left\" style=\"color:{$font-color};\">{$row-strategy}</th>\n";

            for @col-profiles -> @rest-profile {
                my @profile = $row-strategy, |@rest-profile;
                my @payoff = |payoff-fn(@profile);

                die "Payoff vector must have $n elements for profile {@profile.raku}"
                unless @payoff.elems == $n;

                for ^$n -> $i {
                    my $bg = color-for($i);
                    $html ~= "    <td bgcolor=\"$bg\" align=\"right\" style=\"color:{$font-color};\">{@payoff[$i]}</td>\n";
                }
            }

            $html ~= "  </tr>\n";
        }

        $html ~= "</table>";
        return $html;
    }
}

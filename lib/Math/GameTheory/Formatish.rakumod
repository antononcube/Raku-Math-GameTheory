use v6.d;

role Math::GameTheory::Formatish {

    #| WL representation of a game
    method wl() {
        my $arr = self.payoff-array.raku.trans(['[' => '{', ']' => '}']);
        my $actLables = self.game-action-labels.raku.trans(['[' => '{', ']' => '}']);
        my $plLables = self.game-player-labels.raku.trans(['[' => '{', ']' => '}']);
        return "MatrixGame[$arr, GameActionLabels -> $actLables, GamePlayerLabels -> $plLables]";
    }

    #| HTML representation of the game
    method html() {
        my @player-labels = self.game-player-labels;
        my @row-actions = ((self.game-action-labels[0] // []).list).Array;
        my @col-actions = ((self.game-action-labels[1] // []).list).Array;

        die "HTML rendering currently supports 2-player matrix games."
        unless @player-labels.elems == 2;

        my sub esc($text) {
            $text.Str
                    .subst('&', '&amp;', :g)
                    .subst('<', '&lt;', :g)
                    .subst('>', '&gt;', :g)
                    .subst('"', '&quot;', :g)
                    .subst("'", '&#39;', :g)
        }

        my $name = self.name ~~ Whatever ?? '' !! esc(self.name);
        my $p1 = esc(@player-labels[0] // 'Player 1');
        my $p2 = esc(@player-labels[1] // 'Player 2');

        my $html = qq:to/END/;
<table style="margin:0 auto;text-align:center;">
<tbody><tr>
<td>
<table>
<caption align=bottom><i>{$name}</i>
</caption>
<tbody><tr>
<th><div style="margin-left:2em;text-align:right">{$p2}</div><div style="margin-right:2em;text-align:left"><br />{$p1}</div>
</th>
END

        for @col-actions -> $action {
            $html ~= qq:to/END/;
<th><i>{esc($action)}</i>
</th>
END
        }

        $html ~= "</tr>\n";

        for self.payoff-array.kv -> $row-index, @row {
            my $row-label = esc(@row-actions[$row-index] // "A{$row-index + 1}");
            $html ~= qq:to/END/;
<tr>
<th><i>{$row-label}</i>
</th>
END

            for @row -> @payoff {
                my $payoff = @payoff.map(*.Str).join(', ');
                $html ~= qq:to/END/;
<td>{$payoff}
</td>
END
            }

            $html ~= "</tr>\n";
        }

        $html ~= "</tbody></table>\n</td>\n</tr></tbody></table>";
        $html
    }
}

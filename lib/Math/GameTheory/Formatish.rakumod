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
    method html(
            Str:D :$player1-color is copy = 'none',
            Str:D :$player2-color is copy = 'none',
            Str:D :$player1-font-color is copy = 'silver',
            Str:D :$player2-font-color is copy = 'silver',
            :$theme is copy = Whatever
    ) {

        if $theme ~~ Str:D {
            if $theme.lc ∈ <mono monochrome black-and-white bw blackandwhite> {
                $player1-color = '#1f1f1f';
                $player2-color = '#1f1f1f';
                $player1-font-color = 'gainsboro';
                $player2-font-color = 'gainsboro';
            } elsif $theme.lc ∈ <default wl> {
                $player1-color = '#9ecce6';
                $player2-color = '#f9cf92';
                $player1-font-color = '#666666';
                $player2-font-color = '#666666';
            }
        }

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
        my $p1-bg = esc($player1-color);
        my $p2-bg = esc($player2-color);
        my $p1-fg = esc($player1-font-color);
        my $p2-fg = esc($player2-font-color);
        my $max-payoff-len = 1;

        for self.payoff-array -> @row {
            for @row -> @payoff {
                for @payoff -> $value {
                    my $len = $value.Str.chars;
                    $max-payoff-len = $len if $len > $max-payoff-len;
                }
            }
        }

        my $html = qq:to/END/;
<table style="margin:0 auto;text-align:center;">
<tbody><tr>
<td>
<table>
<caption align=bottom><i>{$name}</i>
</caption>
<tbody><tr>
<th style="background:linear-gradient(to bottom, {$p2-bg} 50%, {$p1-bg} 50%);"><div style="margin-left:2em;text-align:right;padding:0.1em 0.4em;border-radius:0.2em;display:inline-block;color:{$p2-fg};">{$p2}</div><div style="margin-right:2em;text-align:left"><br /><span style="padding:0.1em 0.4em;border-radius:0.2em;display:inline-block;color:{$p1-fg};">{$p1}</span></div>
</th>
END

        for @col-actions -> $action {
            $html ~= qq:to/END/;
<th style="background-color:{$p2-bg};color:{$p2-fg};"><i>{esc($action)}</i>
</th>
END
        }

        $html ~= "</tr>\n";

        for self.payoff-array.kv -> $row-index, @row {
            my $row-label = esc(@row-actions[$row-index] // "A{$row-index + 1}");
            $html ~= qq:to/END/;
<tr>
<th style="background-color:{$p1-bg};color:{$p1-fg};"><i>{$row-label}</i>
</th>
END

            for @row -> @payoff {
                my $v1 = esc(sprintf('%*s', $max-payoff-len, (@payoff[0] // '').Str));
                my $v2 = esc(sprintf('%*s', $max-payoff-len, (@payoff[1] // '').Str));
                my $payoff = '<table style="margin:0 auto;border-collapse:collapse;"><tbody><tr>'
                           ~ '<td style="background-color:' ~ $p1-bg ~ ';color:' ~ $p1-fg ~ ';padding:0.1em 0.4em;width:' ~ $max-payoff-len ~ 'ch;text-align:right;white-space:pre;font-family:monospace;">' ~ $v1 ~ '</td>'
                           ~ '<td style="background-color:' ~ $p2-bg ~ ';color:' ~ $p2-fg ~ ';padding:0.1em 0.4em;width:' ~ $max-payoff-len ~ 'ch;text-align:right;white-space:pre;font-family:monospace;">' ~ $v2 ~ '</td>'
                           ~ '</tr></tbody></table>';
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

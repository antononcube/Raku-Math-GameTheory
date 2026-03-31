use v6.d;

class Math::GameTheory::MatrixGame {

    has $.name is rw = Whatever;
    has Str:D $.description is rw = '';
    has Str:D $.source is rw = '';
    has @.classes = Empty;
    has @.payoff-array is required;
    has @.game-player-labels;
    has @.game-action-labels;

    submethod BUILD(
            :$!name = Whatever,
            :$!description = '',
            :$!source = '',
            :@!classes = [],
            :@!payoff-array!,
            :@!game-player-labels = [],
            :@!game-action-labels = []
                    ) {

        @!game-player-labels = self!default-player-labels unless @!game-player-labels.elems;
        @!game-action-labels = self!default-action-labels unless @!game-action-labels.elems;

    }

    #| Composite payoff array
    method composite-payoff-array() {
        @!payoff-array;
    }

    #| Payoff array per player
    multi method component-payoff-array() {
        @!game-player-labels.map(
                -> $player-label {
                    $player-label => self.component-payoff-array($player-label)
                }
                ).Hash
    }

    #| Payoff array for a given player index
    multi method component-payoff-array(Int:D $player-index) {
        self!extract-player-payoffs(@!payoff-array, $player-index);
    }

    #| Payoff array for a given player label
    multi method component-payoff-array(Str:D $player-label) {
        self.component-payoff-array(self!player-index($player-label));
    }

    #| Gives the list of possible payoffs for each player:
    method payoff-data() {

    }

    #| Min-max payoffs of the game
    method min-max-payoffs() {
        @!game-player-labels.kv.map(
                -> $index, $label {
                    my @values = self!terminal-payoffs(@!payoff-array).map({ .[$index] });
                    $label => {
                        min => @values.min,
                        max => @values.max,
                    }
                }
                ).Hash
    }

    #| Transform into a tree game object
    method tree-game() {
        ## Convert a matrix game to a tree game
    }

    #------------------------------------------------------
    # Private methods
    #------------------------------------------------------
    method !player-index(Str:D $player-label) {
        my $index = @!game-player-labels.first(* eq $player-label, :k);
        die "Unknown player label: {$player-label}." unless $index.defined;
        $index
    }

    method !default-player-labels() {
        my $player-count = self!player-count;
        (1 .. $player-count).map({ "Player $_" }).Array
    }

    method !default-action-labels() {
        self!action-dimensions.kv.map(
                -> $player-index, $action-count {
                    (1 .. $action-count).map({ "P{$player-index + 1}A$_" }).Array
                }
                ).Array
    }

    method !player-count() {
        my @first-payoff = self!first-terminal-payoff(@!payoff-array);
        @first-payoff.elems || 1
    }

    method !action-dimensions() {
        self!dimensions(@!payoff-array, self!player-count);
    }

    method !dimensions($node, Int:D $player-count) {
        return [] unless $node ~~ Positional;
        return [] if self!is-terminal-payoff($node, $player-count);
        [$node.elems, |self!dimensions($node[0], $player-count)]
    }

    method !first-terminal-payoff($node) {
        if self!is-terminal-payoff($node, $node.elems) {
            return $node.Array;
        }

        for $node.list -> $item {
            my @candidate = self!first-terminal-payoff($item);
            return @candidate if @candidate.elems;
        }

        []
    }

    method !extract-player-payoffs($node, Int:D $player-index) {
        if self!is-terminal-payoff($node, self!player-count) {
            die "Player index out of range: {$player-index}."
            if $player-index < 0 || $player-index >= $node.elems;
            return $node[$player-index];
        }

        $node.map({ self!extract-player-payoffs($_, $player-index) }).Array
    }

    method !terminal-payoffs($node) {
        if self!is-terminal-payoff($node, self!player-count) {
            return [$node.Array.item];
        }

        $node.map({ |self!terminal-payoffs($_) }).Array
    }

    method !is-terminal-payoff($node, Int:D $player-count) {
        $node ~~ Positional
                && $node.elems == $player-count
                && $node.list.none ~~ Positional
    }

    #------------------------------------------------------
    # Representation
    #------------------------------------------------------

    #| To Hash
    multi method Hash(::?CLASS:D:-->Hash) {
        {
            'name'                => $!name,
            'description'         => $!description,
            'payoff-array'        => self.composite-payoff-array,
            'game-player-labels'  => @!game-player-labels.Array,
            'game-action-labels'  => @!game-action-labels.Array,
            'component-payoff-array' => self.component-payoff-array,
            'min-max-payoffs'     => self.min-max-payoffs,
        }
    }

    #| To string
    multi method Str(::?CLASS:D:-->Str) {
        return self.gist;
    }

    #| To gist
    multi method gist(::?CLASS:D:-->Str) {
        return 'MatrixGame' ~ (name => self.name,
                               number-of-players => self.payoff-array.elems,
                               number-of-actions => self.component-payoff-array()>>.elems.List).List.raku;
    }

    #| HTML representation of the game
    method html() {
        my @player-labels = @!game-player-labels;
        my @row-actions = ((@!game-action-labels[0] // []).list).Array;
        my @col-actions = ((@!game-action-labels[1] // []).list).Array;

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

        my $name = $!name ~~ Whatever ?? '' !! esc($!name);
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

        for @!payoff-array.kv -> $row-index, @row {
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

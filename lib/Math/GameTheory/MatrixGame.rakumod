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

    method composite-payoff-array() {
        @!payoff-array;
    }

    multi method component-payoff-array() {
        @!game-player-labels.map(
                -> $player-label {
                    $player-label => self.component-payoff-array($player-label)
                }
                ).Hash
    }

    multi method component-payoff-array(Int:D $player-index) {
        self!extract-player-payoffs(@!payoff-array, $player-index);
    }

    multi method component-payoff-array(Str:D $player-label) {
        self.component-payoff-array(self!player-index($player-label));
    }

    method payoff-data() {
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

    method tree-game() {
        ## Convert a matrix game to a tree game
    }

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
}

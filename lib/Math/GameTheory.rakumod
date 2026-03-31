use v6.d;

unit module Math::GameTheory;

use JSON::Fast;
use Math::GameTheory::MatrixGame;
use Math::GameTheory::Creators;

#==========================================================
# Game data
#==========================================================

my %game-data;
our sub get-game-data() {
    return %game-data if %game-data;
    %game-data = from-json(%?RESOURCES<game-data.json>.IO.slurp)
}

our proto sub game-theory-data(|) is export {*}

our multi sub game-theory-data() {
    get-game-data().keys.sort;
}

our multi sub game-theory-data('Classes') {
    get-game-data().map({ $_.value<classes> }).flat.sort;
}

our multi sub game-theory-data('Properties') {
    ['Description', 'Classes', 'Source'];
}

our multi sub game-theory-data(Str:D $name, 'Description') {
    get-game-data(){$name}<description> // Whatever;
}

our multi sub game-theory-data(Str:D $name, 'Source') {
    get-game-data(){$name}<source> // Whatever;
}

our multi sub game-theory-data(Str:D $name, 'Classes') {
    get-game-data(){$name}<classes> // Whatever;
}

our multi sub game-theory-data(Str:D $name, *@args, *%args) {
    my $obj = Math::GameTheory::Creators::matrix-game($name, |@args, |%args);
    if $obj {
        $obj.description = game-theory-data($name, 'Description');
        $obj.source = game-theory-data($name, 'Source');
    }
    return $obj;
}

our multi sub game-theory-data(Str:D $name, Int:D $n) {
    if 'NPlayer' ∈ get-game-data(){$name}<classes> {
        # has to be developed;
        $name;
    } else {
        Whatever;
    }
}

our multi sub game-theory-data(Str:D $name, Str:D $class) {
    if get-game-data(){$name} {
        $class ∈ get-game-data(){$name}<classes>
    } else { Whatever }
}

#==========================================================
# Game data
#==========================================================
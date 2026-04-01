# Math::GameTheory

The package provides descriptions and data of different games amenable for Game Theory experiments and studies.

----

## Installation

From [Zef ecosystem](https://raku.land):

```
zef install Math::GameTheory
```

From GitHub:

```
zef install https://github.com/antononcube/Raku-Math-GameTheory
```

----

## Game Theory data

All games known by the package "Math::GameTheory":

```raku
use Math::GameTheory;

say "Total number of known games: {game-theory-data().elems}";
say game-theory-data();
```

Games and their classes:

```raku
my @dsGames = game-theory-data(Whatever, property => "Classes").map({ $_.key X $_.value.Array }).flat(1).map({ <name property> Z=> $_  })».Hash;
@dsGames.elems
```

Here is a summary:

```raku
use Data::Summarizers;

sink records-summary(@dsGames)
```

Here is a "taxonomy tree" like breakdown:

```raku
use ML::TriesWithFrequencies;

my %cat = <2Player 3Player NPlayer MatrixGame TreeGame Symmetric> Z=> (^7);

game-theory-data(Whatever, property => "Classes").values
==> { .map({ %cat.keys (&) $_ }) }()
==> { $_.map({ $_ ?? $_.keys !! 'Other' })».sort({ %cat{$_} })».List }()
==> trie-create()
==> trie-form()
```

----

## Two player games

Get the game "Chicken" (provided by the package):

```raku
my $obj = game-theory-data('Chicken')
```

Here is a description of the game:

```raku
$obj.description
```

Here is game's table:

```raku, results=asis
$obj.html
```

Here is a gray-scale version of the dataset can be obtained with `$obj.html(theme => 'gray-scale')`.


----

## Three player games

Get the game "3Coordination" (provided by the package):

```raku
my $obj = game-theory-data('3Coordination')
```

```raku
$obj.description
```

Here is game's table:

```raku, results=asis
$obj.html
```

---

## Zero sum games

Represent a Rock Paper Scissors game as a directed graph:

```raku
use Graph;
my $g = Graph.new(edges => [Rock => "Scissors", Scissors => "Paper", Paper => "Rock"]):d;
#$g.dot(engine => 'neato', :2size, vertex-font-size => 8):svg
```

![](./docs/img/Rock-Paper-Scissors-graph.svg)

Create a Rock Paper Scissors game:

```raku
use Data::Reshapers;

my @payoff-array = ($g.adjacency-matrix <<->> transpose($g.adjacency-matrix)).deepmap(-> Int:D $p { [$p, -$p] });
my $game = Math::GameTheory::MatrixGame.new(:@payoff-array, game-action-labels => ($g.vertex-list xx 2))
```

Here is game's table:

```raku, results=asis
$game.html(theme => 'default')
```

-----

## TODO

- [ ] TODO Implementation
  - [X] DONE Games data JSON file and corresponding retrieval (multi-)sub
  - [ ] TODO Matrix games
    - [X] DONE `MatrixGame` class
    - [X] DONE HTML format of matrix game dataset
    - [X] DONE Wolfram Language (WL) representation
    - [ ] TODO Payoff functions
    - [ ] TODO Simpler zero-sum games initialization
  - [ ] TODO Tree games
    - [ ] TODO `TreeGame` class
    - [ ] TODO Creation using WL's tree game input format
    - [ ] TODO Special tree-game plots
- [ ] TODO Documentation
  - [X] DONE Complete README
  - [ ] TODO Basic usage notebook
  - [ ] TODO Blog post
  - [ ] TODO Video demo


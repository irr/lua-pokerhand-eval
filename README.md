Poker Hand Evaluator
====================

In pure Lua

27 April 2015, Ivan Ribeiro Rocha

Introduction
------------

This is a pure Lua library to calculate the rank of the best [Texas Holdem]
hand out of 5, 6, or 7 cards. It does not run the board for you, or
calculate winning percentage, EV, or anything like that. But if you give
it two hands and the same board, you will be able to tell which hand
wins.

This is a Lua port from the python library: https://github.com/aliang/pokerhand-eval

Quick Start
-----------

```lua

    card = require "holdem.card"
    lookup = require "holdem.lookup"
    analysis = require "holdem.analysis"

    hole = { card.Card(2, 1), card.Card(2, 2) }
    board = {}
    rank, percentile = analysis.evaluate(hole, board)
    print(rank, percentile)
    -- Output: nil	0.52337858220211
    -- For 2 cards, score will be nil and you must use percentile

    board = { card.Card(10, 2), card.Card(14, 2), card.Card(13, 2), card.Card(7, 2) }
    rank, percentile = analysis.evaluate(hole, board)
    print(rank, percentile)
    -- Output: 420	0.6792270531401
    -- ps: less rank is better
```

Rank is 2-14 representing 2-A, while suit is 1-4 representing
spades, hearts, diamonds, clubs.

The Card constructor accepts two arguments, rank, and suit.

```lua

    card = require "holdem.card"

    aceOfSpades = card.Card(14, 1)
    twoOfDiamonds = card.Card(2, 3)

    -- or

    aceOfSpades = card.Card("AS")
    twoOfDiamonds = card.Card("2D")
```

Algorithm
---------

The algorithm for 5 cards is just a port of this algorithm:
http://www.suffecool.net/poker/evaluator.html

1. 6 and 7 card evaluators using a very similar card representation and 
applying some of the same ideas with prime numbers. The idea was to 
strike a balance between lookup table size and speed.

2. There is also a two-card ranking/percentile algorithm that is unrelated
to the rest and may get cleaned up later. We used it at one point for
some pre-flop evaluation. Credit to Zach Wissner-Gross for developing
this.

3. For Bitwise operators, I chose https://github.com/davidm/lua-bit-numberlua

4. For map/reduce operations I chose https://github.com/mirven/underscore.lua

[Texas Holdem]: http://en.wikipedia.org/wiki/Texas_hold_%27em


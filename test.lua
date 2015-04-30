__ = require "underscore" 

card = require "holdem.card"
lookup = require "holdem.lookup"
analysis = require "holdem.analysis"

hand = { card.Card(2, 1), card.Card(2, 2) }
board = { card.Card(14, 1), card.Card(14, 2), card.Card(13, 3) }

print(">>>>", 2, __.each(hand, function (c) print(c:tostring()) end)
print(analysis.evaluate(hand, {}))

print()

print(">>>>", 5)
print(analysis.evaluate(hand, board))

print()

print(">>>>", 6)
board = { card.Card(10, 2), card.Card(14, 2), card.Card(13, 2), card.Card(7, 2) }
print(analysis.evaluate(hand, board))

print()

print(">>>>", "7A")
board = { card.Card(3,3), card.Card(3,1), card.Card(8,4), card.Card(5,4), card.Card(4,4) }
print(analysis.evaluate(hand, board))

print()

print(">>>>", "7B")
board = { card.Card(3,3), card.Card(3,1), card.Card(10,4), card.Card(5,4), card.Card(4,4) }
print(analysis.evaluate(hand, board))

print()

print(">>>>", "7C")
board = { card.Card(2,3), card.Card(2,4), card.Card(10,4), card.Card(5,4), card.Card(4,4) }
print(analysis.evaluate(hand, board))

print()


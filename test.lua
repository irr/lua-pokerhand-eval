card = require "holdem.card"
lookup = require "holdem.lookup"
analysis = require "holdem.analysis"

hand = { card.Card(2, 1), card.Card(2, 2) }
board = { card.Card(14, 1), card.Card(14, 2), card.Card(13, 3) }

print(">>>>", 2)
analysis.d(hand)
print(analysis.evaluate(hand, {}))

print()

print(">>>>", 5)
analysis.d(hand)
analysis.d(board)
print(analysis.evaluate(hand, board))

print()

print(">>>>", 6)
analysis.d(hand)
board = { card.Card(10, 2), card.Card(14, 2), card.Card(13, 2), card.Card(7, 2) }
analysis.d(board)
print(analysis.evaluate(hand, board))

print()

print(">>>>", "7A")
analysis.d(hand)
board = { card.Card(3,3), card.Card(3,1), card.Card(8,4), card.Card(5,4), card.Card(4,4) }
analysis.d(board)
print(analysis.evaluate(hand, board))

print()

print(">>>>", "7B")
analysis.d(hand)
board = { card.Card(3,3), card.Card(3,1), card.Card(10,4), card.Card(5,4), card.Card(4,4) }
analysis.d(board)
print(analysis.evaluate(hand, board))

print()

print(">>>>", "7C")
analysis.d(hand)
board = { card.Card(2,3), card.Card(2,4), card.Card(10,4), card.Card(5,4), card.Card(4,4) }
analysis.d(board)
print(analysis.evaluate(hand, board))

print()


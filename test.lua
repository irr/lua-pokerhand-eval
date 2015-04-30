card = require "holdem.card"
lookup = require "holdem.lookup"
analysis = require "holdem.analysis"

hand = { card.Card(2, 1), card.Card(2, 2) }
board = { card.Card(14, 1), card.Card(14, 2), card.Card(13, 3) }

function d(h, b)
    local n = #h 
    if b then n = n + #b end
    print(string.format(">>>> %d cards", n))
    local p = function (s, t) 
        print("  "..s..":")
        for i, v in pairs(t) do
            print(string.format("     %d. %s", i, v:tostring()))
        end
    end
    p("hand", h)
    if b then p("board", b) end
end

d(hand)
print(analysis.evaluate(hand, {}))

board = { card.Card(10, 2), card.Card(14, 2), card.Card(13, 2)  }
d(hand, board)
print(analysis.evaluate(hand, board))

board = { card.Card(10, 2), card.Card(14, 2), card.Card(13, 2), card.Card(7, 2) }
d(hand, board)
print(analysis.evaluate(hand, board))

board = { card.Card(3,3), card.Card(3,1), card.Card(8,4), card.Card(5,4), card.Card(4,4) }
d(hand, board)
print(analysis.evaluate(hand, board))

board = { card.Card(3,3), card.Card(3,1), card.Card(10,4), card.Card(5,4), card.Card(4,4) }
d(hand, board)
print(analysis.evaluate(hand, board))

board = { card.Card(2,3), card.Card(2,4), card.Card(10,4), card.Card(5,4), card.Card(4,4) }
d(hand, board)
print(analysis.evaluate(hand, board))

print()

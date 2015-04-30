local card = require "holdem.card"
local lookup = require "holdem.lookup"
local prob = require "holdem.prob"

local __ = require "underscore"

local ok, bit = pcall(require, "bit")
if not ok then
    bit = require 'bit.numberlua'.bit
end

local error = error
local pairs = pairs
local table = table
local type = type

module('holdem.analysis')

local function card_to_binary5(card)
    local b_mask = bit.lshift(1, (14 + card.rank))
    local cdhs_mask = bit.lshift(1, (card.suit + 11))
    local r_mask = bit.lshift((card.rank - 2), 8)
    local p_mask = lookup.Tables.primes[card.rank - 1]
    return bit.bor(b_mask, bit.bor(r_mask, bit.bor(p_mask, cdhs_mask)))
end

local function card_to_binary6(card)
    local b_mask = bit.lshift(1, (14 + card.rank))
    local q_mask = bit.lshift(lookup.Tables.primes[card.suit], 12)
    local r_mask = bit.lshift((card.rank - 2), 8)
    local p_mask = lookup.Tables.primes[card.rank - 1]
    return bit.bor(b_mask, bit.bor(q_mask, bit.bor(r_mask, p_mask)))
end

local function card_to_binary7(card)
    return card_to_binary6(card)
end

local function card_to_binary_lookup5(card)
    return lookup.Tables.Five.card_to_binary[card.rank + 1][card.suit + 1]
end

local function card_to_binary_lookup6(card)
    return lookup.Tables.Six.card_to_binary[card.rank + 1][card.suit + 1]
end

local function card_to_binary_lookup7(card)
    return lookup.Tables.Seven.card_to_binary[card.rank + 1][card.suit + 1]
end

local function evaluate2(hand)
    if hand[1].suit == hand[2].suit then
        if hand[1].rank < hand[2].rank then
            return nil, lookup.Tables.Two.suited_ranks_to_percentile[hand[1].rank+1][hand[2].rank+1]
        else
            return nil, lookup.Tables.Two.suited_ranks_to_percentile[hand[2].rank+1][hand[1].rank+1]
        end
    else
        return nil, lookup.Tables.Two.unsuited_ranks_to_percentile[hand[1].rank+1][hand[2].rank+1]
    end
end

local function evaluate5(hand)
    local bh = __.map(hand, card_to_binary5) 
    local has_flush = __.reduce(bh, 0xF000, bit.band)
    local q = bit.rshift(__.reduce(bh, 0, bit.bor), 16) + 1
    if has_flush > 0 then
        return lookup.Tables.Five.flushes[q]
    else
        local possible_rank = lookup.Tables.Five.unique5[q]
        if possible_rank ~= 0 then
            return possible_rank
        else
            bh = __.map(bh, function (c) return bit.band(c, 0xFF) end)
            q = __.reduce(bh, 1, function (a, b) return (a * b) end)
            return lookup.Tables.Five.pairs[q]
        end
    end
end

local function evaluate6(hand)
    local bh = __.map(hand, card_to_binary6) 
    local bhfp = __.map(bh, function (c) return bit.band(bit.rshift(c, 12), 0xF) end)
    local flush_prime = __.reduce(bhfp, 1, function (a, b) return (a * b) end)
    local flush_suit = lookup.Tables.Six.prime_products_to_flush[flush_prime]
    local odd_xor = bit.rshift(__.reduce(bh, 0, bit.bxor), 16)
    local even_xor = bit.bxor(bit.rshift(__.reduce(bh, 0, bit.bor), 16), odd_xor)
    if flush_suit then
        if even_xor == 0 then
            local bhflt = __.select(bh, function (e) return bit.band(bit.rshift(e, 12), 0xF) == flush_suit end)
            local bhbits = __.map(bhflt, function (c) return bit.rshift(c, 16) end)
            local bits = __.reduce(bhbits, 0, bit.bor)
            return lookup.Tables.Six.flush_rank_bits_to_rank[bits]
        else
            return lookup.Tables.Six.flush_rank_bits_to_rank[bit.bor(odd_xor, even_xor)]
        end
    end

    if even_xor == 0 then
        local odd_popcount = lookup.PopCountTable16(odd_xor)
        if odd_popcount == 4 then
            local bhpp = __.map(bh, function (c) return bit.band(c, 0xFF) end)
            local prime_product = __.reduce(bhpp, 1, function (a, b) return (a * b) end)
            return lookup.Tables.Six.prime_products_to_rank[prime_product]
        else
            return lookup.Tables.Six.odd_xors_to_rank[odd_xor]
        end
    elseif odd_xor == 0 then
        local even_popcount = lookup.PopCountTable16(even_xor)
        if even_popcount == 2 then
            local bhpp = __.map(bh, function (c) return bit.band(c, 0xFF) end)
            local prime_product = __.reduce(bhpp, 1, function (a, b) return (a * b) end)
            return lookup.Tables.Six.prime_products_to_rank[prime_product]
        else
            return lookup.Tables.Six.even_xors_to_rank[even_xor]
        end
    else
        local odd_popcount = lookup.PopCountTable16(odd_xor)
        if odd_popcount == 4 then
            return lookup.Tables.Six.even_xors_to_odd_xors_to_rank[even_xor][odd_xor]
        else
            local even_popcount = lookup.PopCountTable16(even_xor)
            if even_popcount == 2 then
                return lookup.Tables.Six.even_xors_to_odd_xors_to_rank[even_xor][odd_xor]
            else
                local bhpp = __.map(bh, function (c) return bit.band(c, 0xFF) end)
                local prime_product = __.reduce(bhpp, 1, function (a, b) return (a * b) end)
                return lookup.Tables.Six.prime_products_to_rank[prime_product]
            end
        end
    end
end

local function evaluate7(hand)
    local bh = __.map(hand, card_to_binary7) 
    local bhfp = __.map(bh, function (c) return bit.band(bit.rshift(c, 12), 0xF) end)
    local flush_prime = __.reduce(bhfp, 1, function (a, b) return (a * b) end)
    local flush_suit = lookup.Tables.Seven.prime_products_to_flush[flush_prime]
    local odd_xor = bit.rshift(__.reduce(bh, 0, bit.bxor), 16)
    local even_xor = bit.bxor(bit.rshift(__.reduce(bh, 0, bit.bor), 16), odd_xor)
    if flush_suit then
        local even_popcount = lookup.PopCountTable16(even_xor)
        if even_xor == 0 then
            local bhflt = __.select(bh, function (e) return bit.band(bit.rshift(e, 12), 0xF) == flush_suit end)
            local bhbits = __.map(bhflt, function (c) return bit.rshift(c, 16) end)
            local bits = __.reduce(bhbits, 0, bit.bor)
            return lookup.Tables.Seven.flush_rank_bits_to_rank[bits]
        else
            if even_popcount == 2 then
                return lookup.Tables.Seven.flush_rank_bits_to_rank[bit.bor(odd_xor, even_xor)]
            else
                local bhflt = __.select(bh, function (e) return bit.band(bit.rshift(e, 12), 0xF) == flush_suit end)
                local bhbits = __.map(bhflt, function (c) return bit.rshift(c, 16) end)
                local bits = __.reduce(bhbits, 0, bit.bor)
                return lookup.Tables.Seven.flush_rank_bits_to_rank[bits]
            end
        end
    end
    if even_xor == 0 then
        local odd_popcount = lookup.PopCountTable16(odd_xor)
        if odd_popcount == 7 then
            return lookup.Tables.Seven.odd_xors_to_rank[odd_xor]
        else
            local bhpp = __.map(bh, function (c) return bit.band(c, 0xFF) end)
            local prime_product = __.reduce(bhpp, 1, function (a, b) return (a * b) end)
            return lookup.Tables.Seven.prime_products_to_rank[prime_product]
        end
    else
        local odd_popcount = lookup.PopCountTable16(odd_xor)
        if odd_popcount == 5 then
            return lookup.Tables.Seven.even_xors_to_odd_xors_to_rank[even_xor][odd_xor]
        elseif odd_popcount == 3 then
            local even_popcount = lookup.PopCountTable16(even_xor)
            if even_popcount == 2 then
                return lookup.Tables.Seven.even_xors_to_odd_xors_to_rank[even_xor][odd_xor]
            else
                local bhpp = __.map(bh, function (c) return bit.band(c, 0xFF) end)
                local prime_product = __.reduce(bhpp, 1, function (a, b) return (a * b) end)
                return lookup.Tables.Seven.prime_products_to_rank[prime_product]
            end
        else
            local even_popcount = lookup.PopCountTable16(even_xor)
            if even_popcount == 3 then
                return lookup.Tables.Seven.even_xors_to_odd_xors_to_rank[even_xor][odd_xor]
            elseif even_popcount == 2 then
                local bhpp = __.map(bh, function (c) return bit.band(c, 0xFF) end)
                local prime_product = __.reduce(bhpp, 1, function (a, b) return (a * b) end)
                return lookup.Tables.Seven.prime_products_to_rank[prime_product]
            else
                return lookup.Tables.Seven.even_xors_to_odd_xors_to_rank[even_xor][odd_xor]
            end
        end
    end 
end

local function to_cards(h, b)
    local c = {}
    __.each({h, b}, function (t) __.each(t, function (a) table.insert(c, a) end) end)
    return c
end

function evaluate(hand, board)
    local ev, cards = nil, to_cards(hand, board)

    local cardset = {}
    for _, c in pairs(cards) do
        local s = c:tostring()
        if cardset[s] then
            error("invalid cards (duplicate)!")
        else
            cardset[s] = true
        end
    end

    if #cards == 2 then
        return evaluate2(cards)
    elseif #cards == 5 then
        ev = evaluate5
    elseif #cards == 6 then
        ev = evaluate6
    elseif #cards == 7 then
        ev = evaluate7
    else
        error("invalid hand/board (must have 2, 5, 6 or seven cards)")
    end

    local percentile = 0.0
    local rank = ev(cards)

    local deck = prob.difference(lookup.Tables.deck, cards)
    local possible_opponent_hands = prob.comb(deck, #hand)
    
    local hands_beaten = 0
    for _, h in pairs(possible_opponent_hands) do
        local pcards = {}
        local possible_opponent_rank = ev(to_cards(h, board))
        if rank < possible_opponent_rank then
            hands_beaten = hands_beaten + 1
        elseif rank == possible_opponent_rank then
            hands_beaten = hands_beaten + 0.5
        end
    end

    return rank, (hands_beaten / #possible_opponent_hands)
end


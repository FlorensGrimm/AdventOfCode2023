abstract type AbstractHand end
abstract type AbstractNormalHand <: AbstractHand end
abstract type AbstractJokerHand <: AbstractHand end

struct Day07{P<:AbstractPart} <: AbstractDay
    part::P
end

"""
Defines the ordering of the different cards with each other.
"""
const CARDS = Dict(
    'A' => 13,
    'K' => 12,
    'Q' => 11,
    'J' => 10,
    'T' => 9,
    '9' => 8,
    '8' => 7,
    '7' => 6,
    '6' => 5,
    '5' => 4,
    '4' => 3,
    '3' => 2,
    '2' => 1,
)

struct FiveOfAKind <: AbstractNormalHand
    cards::Vector{Char}
    bid::T where T
end
struct FourOfAKind <: AbstractNormalHand
    cards::Vector{Char}
    bid::T where T
end
struct FullHouse <: AbstractNormalHand
    cards::Vector{Char}
    bid::T where T
end
struct ThreeOfAKind <: AbstractNormalHand
    cards::Vector{Char}
    bid::T where T
end
struct TwoPair <: AbstractNormalHand
    cards::Vector{Char}
    bid::T where T
end
struct OnePair <: AbstractNormalHand
    cards::Vector{Char}
    bid::T where T 
end
struct HighCard <: AbstractNormalHand
    cards::Vector{Char}
    bid::T where T
end

"""
Defines the ordering of the types of hands.
"""
ORDERING = Dict(
    FiveOfAKind => 7,
    FourOfAKind => 6,
    FullHouse => 5,
    ThreeOfAKind => 4,
    TwoPair => 3,
    OnePair => 2,
    HighCard => 1,
)

"""
Defines the rules for the comparisions of different hands (First Part).
"""
function Base.isless(c1::AbstractNormalHand, c2::AbstractNormalHand)
    if typeof(c1) == typeof(c2)
        for (card1, card2) in zip(c1.cards, c2.cards)
            if card1 == card2
                continue
            end
            return isless(CARDS[card1], CARDS[card2])
        end
    else
        return isless(ORDERING[typeof(c1)], ORDERING[typeof(c2)])
    end
end

"""
Counts each card and returns the number of cards associated with their number of occurences.
"""
function count_cards!(counter::AbstractDict{Char,Int64}, cards::AbstractVector{Char})
    for card in cards
        if haskey(counter, card)
            counter[card] += 1
        else
            counter[card] = 1
        end
    end
end

"""
Depending on the number of same cards in a hand, creates the corresponding hand type.
"""
struct Hand{T} <: AbstractNormalHand
    cards::Vector{Char}
    bid::T
    function Hand(cards::AbstractString, bid::Integer)
        cards = convert_to_chars(cards)
        Hand(cards, bid)
    end

    function Hand(cards::AbstractVector{<:AbstractChar}, bid::Integer)
        counter = Dict{Char,Int64}()
        count_cards!(counter, cards)
        v = collect(values(counter))
        if maximum(v) == 5
            return FiveOfAKind(cards, bid)
        elseif maximum(v) == 4
            return FourOfAKind(cards, bid)
        elseif maximum(v) == 3 && length(v) == 2
            return FullHouse(cards, bid)
        elseif maximum(v) == 3 && length(v) == 3
            return ThreeOfAKind(cards, bid)
        elseif maximum(v) == 2 && length(v) == 3
            return TwoPair(cards, bid)
        elseif maximum(v) == 2 && length(v) == 4
            return OnePair(cards, bid)
        elseif length(v) == 5
            return HighCard(cards, bid)
        end

        nothing
    end
end

"""
Parses the string of the hand to create one of the hand types and associates the bid with it.
"""
function create_hands(data::AbstractVector{<:AbstractString})
    hands = Vector{AbstractNormalHand}(undef, length(data))
    for i in eachindex(data)
        cards, bid_str = split(data[i])
        bid = parse(Int64, bid_str)
        hands[i] = Hand(cards, bid)
    end
    hands
end

"""
Adds up rank times bid.
"""
function calculate_result(hands::AbstractVector{<:AbstractHand})
    sum = 0
    for i in eachindex(hands)
        sum += i * hands[i].bid
    end
    sum
end

"""
Defines the ordering of the different cards with each other but the Joker now counts as a wildcard.
To compensate this, the value of a single Joker card is always the weakest.
"""
const JOKERCARDS = Dict(
    'A' => 13,
    'K' => 12,
    'Q' => 11,
    'T' => 9,
    '9' => 8,
    '8' => 7,
    '7' => 6,
    '6' => 5,
    '5' => 4,
    '4' => 3,
    '3' => 2,
    '2' => 1,
    'J' => 0,
)

struct JFiveOfAKind <: AbstractJokerHand
    cards::Vector{Char}
    bid::T where T
end
struct JFourOfAKind <: AbstractJokerHand
    cards::Vector{Char}
    bid::T where T
end
struct JFullHouse <: AbstractJokerHand
    cards::Vector{Char}
    bid::T where T
end
struct JThreeOfAKind <: AbstractJokerHand
    cards::Vector{Char}
    bid::T where T
end
struct JTwoPair <: AbstractJokerHand
    cards::Vector{Char}
    bid::T where T
end
struct JOnePair <: AbstractJokerHand
    cards::Vector{Char}
    bid::T where T
end
struct JHighCard <: AbstractJokerHand
    cards::Vector{Char}
    bid::T where T
end

"""
Defines the ordering of the types of hands.
"""
JOKERORDERING = Dict(
    JFiveOfAKind => 7,
    JFourOfAKind => 6,
    JFullHouse => 5,
    JThreeOfAKind => 4,
    JTwoPair => 3,
    JOnePair => 2,
    JHighCard => 1,
)

"""
Returns the corresponding card hand after changing the jokers to the card which makes the hand the strongest.
"""
struct JokerHand{T} <: AbstractJokerHand
    cards::Vector{Char}
    bid::T
    function JokerHand(cards::AbstractString, bid::Integer)
        cards = convert_to_chars(cards)
        JokerHand(cards, bid)
    end
    function JokerHand(cards::AbstractVector{<:AbstractChar}, bid::Integer)
        counter = Dict{Char,Int64}()
        count_cards!(counter, cards)
        v = collect(values(counter))
        k = collect(keys(counter))
        idxs = sortperm(k, rev=true, by=x -> JOKERCARDS[x])
        k = k[idxs]
        v = v[idxs]

        num_of_jokers = 0
        if 'J' in k  # remove the key: 'J' and the respective number of jokers from the vectors
            Jidx = findfirst(x -> x == 'J', k)
            num_of_jokers = popat!(v, Jidx)
            popat!(k, Jidx)
        end

        maxval, idx = (-1, -1)  # look for the maximum value in the remaining values
        for i in eachindex(v)
            if maxval < v[i]
                maxval, idx = v[i], i
            end
        end

        # add the number of jokers to the maximum (key,value) pair to maximize the strength of the hand.
        if num_of_jokers < 5
            v[idx] += num_of_jokers
        else
            return JFiveOfAKind(['J', 'J', 'J', 'J', 'J'], bid)  # deals with the case where the cards are 5x Joker.
        end

        if maximum(v) == 5
            return JFiveOfAKind(cards, bid)
        elseif maximum(v) == 4
            return JFourOfAKind(cards, bid)
        elseif maximum(v) == 3 && length(v) == 2
            return JFullHouse(cards, bid)
        elseif maximum(v) == 3 && length(v) == 3
            return JThreeOfAKind(cards, bid)
        elseif maximum(v) == 2 && length(v) == 3
            return JTwoPair(cards, bid)
        elseif maximum(v) == 2 && length(v) == 4
            return JOnePair(cards, bid)
        elseif length(v) == 5
            return JHighCard(cards, bid)
        end

    end
end

"""
Defines the rules for the comparisions of different hands.
"""
function Base.isless(c1::AbstractJokerHand, c2::AbstractJokerHand)
    if typeof(c1) == typeof(c2)
        for (card1, card2) in zip(c1.cards, c2.cards)
            if card1 == card2
                continue
            end
            return isless(JOKERCARDS[card1], JOKERCARDS[card2])
        end
    else
        return isless(JOKERORDERING[typeof(c1)], JOKERORDERING[typeof(c2)])
    end
end

"""
Creates Hands from input data where jokers are replaced by the card, which creates the strongest hand.
"""
function create_jokerhands(data::AbstractVector{<:AbstractString})
    jokerhands = Vector{AbstractJokerHand}(undef, length(data))
    for i in eachindex(data)
        cards, bid_str = split(data[i])
        bid = parse(Int64, bid_str)
        jokerhands[i] = JokerHand(cards, bid)
    end
    jokerhands
end

"""
Sort the hands by their ordering defined in `ORDERING` where the weakest hand is placed at position 1 and the strongest hand
at the last position.
If two hands are the same type, sort by comparing the first differing cards for each hand.
The result is the sum of the ranks of the hand multiplied by the `bids` for the respective hand (taken from the input data).
"""
function main(day::Day07{FirstPart{T}}) where {T<:AbstractString}
    data = day.part.data
    hands = create_hands(data)
    sort!(hands)
    result = calculate_result(hands)
    result
end

"""
Now 'J' represents a Joker which can take the place of the best fitting card to create a stronger hand.
If the Joker is directly compared to a single card, it is always considered to be weaker.
Otherwise the rules stay the same.
"""
function main(day::Day07{SecondPart{T}}) where {T<:AbstractString}
    data = day.part.data
    jokerhands = create_jokerhands(data)
    sort!(jokerhands)
    result = calculate_result(jokerhands)
    result
end

nothing

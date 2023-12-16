abstract type AbstractCard end

struct Day04{P<:AbstractPart} <: AbstractDay
    part::P
end

struct Card <: AbstractCard
    id::Int64
    winners::Int64
end

"""
Each scratchcard consists of three fields:
The first field is the Card ID followed by a ':'.
The second field is the list of winning_numbers followed by a '|'.
The third field is the list of numbers you have for this scratchcard.
Returns the 
"""
function parse_card(line::AbstractString)
    card, numbers = split(line, ":")
    winning_numbers, own_numbers = split(numbers, "|")
    return card, winning_numbers, own_numbers
end

"""
Converts the input data into Vectors for each field of a scratchcard
"""
function parse_cards(data::AbstractVector{<:AbstractString})
    cards = Vector{Int64}(undef, length(data))
    winning_numbers = Vector{Set{Int64}}(undef, length(data))
    numbers = Vector{Vector{Int64}}(undef, length(data))
    for (idx, line) in enumerate(data)
        card, card_winning_numbers, card_numbers = parse_card(line)
        cards[idx] = parse(Int64, strip(x -> !isdigit(x), card))
        winning_numbers[idx] = Set(parse.(Int64, split(card_winning_numbers)))
        numbers[idx] = parse.(Int64, split(card_numbers))
    end
    return cards, winning_numbers, numbers
end

"""
Check each number from the `numbers::Vector{Int64}` against 
the set of `winning_numbers::Vector{Set{Int64}}`.
Return the length of the indices of the found numbers which represent 
the number of winning numbers in a given scratchcard.
"""
function check_winning_cards(numbers::AbstractVector{V},
    winning_numbers::AbstractVector{S}) where {V<:AbstractVector{T},S<:AbstractSet{T}} where {T<:Integer}
    winners = Vector{Int64}(undef, length(numbers))
    for i in eachindex(numbers)
        winners[i] = length(findall(x -> x in winning_numbers[i], numbers[i]))
    end
    return winners
end

"""
For each winning number found in a scratchcard double the points earned by this card.
A card with 0 winners adds 0 points.
A card with 1 winners adds `2^(winners-1) = 2^0 = 1` points
A card with 2 winners adds `2^(winners-1) = 2^1 = 2` points
"""
function calculate_total_worth(winners::AbstractVector{<:Integer})
    result = Vector{Int64}(undef, length(winners))
    for i in eachindex(winners)
        if winners[i] == 0
            result[i] = 0
            continue
        end
        result[i] = 2^(winners[i] - 1)
    end
    result
end

"""
Returns a `Vector{Pair{Card,Int64}}` where each entry is a card with 
its number of occurences in the scratchcard deck set to one.
"""
function initialize_card_counter(cards::AbstractVector{<:AbstractCard})
    card_counter = Vector{Pair{Card,Int64}}(undef, length(cards))
    for i in eachindex(cards)
        card_counter[i] = cards[i] => 1
    end
    card_counter
end

"""
`card` holds the Card structure with a field `winners::Int64`.
This number represents how many winning numbers can be found in this scratchcard.
If a card has N winners:
Add a copy of the next N+1 cards to the deck (increment the counter of the next card by `1`).
Repeat for each card (original and copies).
Returns the updated card_counter
"""
function process_card_counter!(card_counter::Vector{Pair{C,T}}) where {C<:AbstractCard,T}
    for idx in eachindex(card_counter)
        card, counter = card_counter[idx]
        for _ in 1:counter
            for j in 1:card.winners
                next_card, next_counter = card_counter[idx+j]
                next_counter += 1
                card_counter[idx+j] = next_card => next_counter
            end
        end
    end
    card_counter
end

"""
Returns the number of scratchcard copies for each scratchcard.
"""
count_scratchcards(card_counter::AbstractVector{Pair{C,T}}) where {C<:AbstractCard,T<:Integer} = getproperty.(card_counter, :second)

"""
Each Card in the input data represents one scratchcard.
Each scratchcard has a field for winning numbers and one for the numbers the player got.
The scratchcard is worth points equal to 2^(winners-1).
For a scratchcard with no winners, the points equal 0.
The final result is the number of points added up for all scratchcards.
"""
function main(day::Day04{FirstPart{T}}) where {T<:AbstractString}
    data = day.part.data
    _, winning_numbers, numbers = parse_cards(data)
    winners = check_winning_cards(numbers, winning_numbers)
    result = calculate_total_worth(winners)
    sum(result)
end

"""
Each scratchcard wins the player more scratchcards.
If a scratchcard has N winners in the player numbers, the player gets 
one copy of the following N cards.
The final result is the number of scratchcards won by the player if all 
scratchcards are counted (originals and additional copies).
"""
function main(day::Day04{SecondPart{T}}) where {T<:AbstractString}
    data = day.part.data
    cards_ids, winning_numbers, numbers = parse_cards(data)
    winners = check_winning_cards(numbers, winning_numbers)
    cards = Card.(cards_ids, winners)
    card_counter = initialize_card_counter(cards)
    card_counter = process_card_counter!(card_counter)
    result = count_scratchcards(card_counter)
    sum(result)
end

nothing

abstract type AbstractGame end

struct Day02{P<:AbstractPart} <: AbstractDay
    part::P
end

struct Game{T} <: AbstractGame
    id::I where {I<:Integer}
    reds::Vector{T}
    blues::Vector{T}
    greens::Vector{T}
end

"""
Additional constructor for a tuple of colour number vectors
"""
function Game(id::Integer, colours::NTuple{3,AbstractVector{I}}) where {I<:Integer}
    Game(id, colours...)
end

"""
Check if all `colournums::Vector{Integer}` are smaller than maxnum.
"""
function check_colour(colournums::AbstractVector{<:Integer}, maxnum::Integer)
    for colournum in colournums
        colournum <= maxnum || return false
    end
    return true
end

"""
Check if all colours in a game are smaller than the respective max number.
If true return the game id, otherwise return 0
"""
function check_game(g::AbstractGame, maxnumbers::AbstractDict{Symbol,<:Integer})
    maxred = maxnumbers[:MaximumRed]
    maxblue = maxnumbers[:MaximumBlue]
    maxgreen = maxnumbers[:MaximumGreen]
    red = check_colour(g.reds, maxred)
    blue = check_colour(g.blues, maxblue)
    green = check_colour(g.greens, maxgreen)
    if red && blue && green
        return g.id
    else
        return 0
    end

end

"""
Return the product of the minimal necessary number of cubes per colour.
"""
function check_game(g::AbstractGame)
    red = maximum(g.reds)
    blue = maximum(g.blues)
    green = maximum(g.greens)
    return red * blue * green
end

"""
Search for `colour` in `clue` where `clue` is one round of a game.
"""
search_colour(colour::AbstractString, clue::AbstractString) = match(Regex("(?<num>\\d+) \\Q$colour\\E"), clue)

"""
Return the number parsed as an Int64.
"""
get_colournum(colourmatch::RegexMatch) = parse(Int64, colourmatch["num"])

"""
If the colour was not found, return 0 as the number.
"""
get_colournum(colourmatch::Nothing) = 0

"""
Each game consists of a number of rounds played.
Split the game into the rounds.
Check if and how many cubes of a specific colour where pulled out and return the respective numbers.
"""
function split_clues(clues_str::AbstractString)
    reds = Int64[]
    blues = Int64[]
    greens = Int64[]
    clues = split.(clues_str, ";")
    for clue in clues
        red = search_colour("red", clue)
        blue = search_colour("blue", clue)
        green = search_colour("green", clue)

        rednum = get_colournum(red)
        bluenum = get_colournum(blue)
        greennum = get_colournum(green)
        push!(reds, rednum)
        push!(blues, bluenum)
        push!(greens, greennum)
    end
    reds, blues, greens
end

"""
Each line starts with "Game <ID>: " where <ID> is an Integer.
Following are a number of rounds played separated by a semicolon.
Each round consists of a up to three colours with a respective number.
Colours can be missing in a round.
Parses each line and extracts the <ID> and creates Vectors of Integers in where each element 
represents the number of found colours in that specific round.
Index 1 in each of the three vectors represents the first round.
Index 2 the second round, and so on.
"""
function get_games(line::AbstractString)
    gameid_str, clues_str = split(line, r":")
    gameid = parse.(Int64, replace(gameid_str, "Game " => ""))
    clues = split_clues(clues_str)
    return Game(gameid, clues)
end

"""
Returns the maximum number for Red, Blue and Green.
"""
function set_input!(MAXNUMBER::AbstractDict{Symbol,<:Integer}, input::AbstractString)
    data = read_data(input)
    for line in data
        key, val = strip.(split(line, ":"))
        key = Symbol(key)
        val = parse(Int64, val)
        MAXNUMBER[key] = val
    end
end

"""
Checks if given a game in each round the number of colours found does not exceed the maximum number for that specific colour.
If the game is valid it stores its gameid in a vector.
If the game is not valid the stored id is 0.
The result is the sum of the stored gameids.
"""
function main(day::Day02{FirstPart{T}}) where {T<:AbstractString}
    data = day.part.data
    ids = []
    maxnumbers::Dict{Symbol,Int64} = Dict(:MaximumRed => -1, :MaximumBlue => -1, :MaximumGreen => -1)
    input = joinpath(day.part.directory, "Input.txt")
    set_input!(maxnumbers, input)
    for line in data
        game = get_games(line)
        id = check_game(game, maxnumbers)
        push!(ids, id)
    end
    sum(ids)
end

"""
Checks each game for the minimum number of each colour to be valid.
The product of the necessary numbers for a valid game is stored.
The result is the sum of the stored products.
"""
function main(day::Day02{SecondPart{T}}) where {T<:AbstractString}
    data = day.part.data
    ids = []
    for line in data
        game = get_games(line)
        id = check_game(game)
        push!(ids, id)
    end
    sum(ids)
end

nothing

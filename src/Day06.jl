struct Day06{P<:AbstractPart} <: AbstractDay
    part::P
end

struct Boat
    distance
    distance_to_beat::Int64
end

"""
Checks if the distance traveled by the boat is greater than the required distance to beat the record.
"""
haswon(b::Boat) = b.distance > b.distance_to_beat

mutable struct Race{P<:AbstractPart}
    boats::Vector{Boat}
    ways_to_win::Int64
end

"""
Returns the boats from the Vector of `Boat` in a `Race`.
"""
Base.iterate(r::Race{FirstPart}, state=1) = state > length(r.boats) ? nothing : (r.boats[state], state + 1)

"""
Multiplies the number of boats per race which are able to surpass the distance to beat.
"""
function calculate_result(races::AbstractVector{Race{FirstPart}})
    ret = 1
    for race in races
        ret *= race.ways_to_win
    end
    ret
end

"""
If a boat is able to win against the distance to beat, increase the counter in the current race by one.
Otherwise do not increase the counter.
"""
function analyse_race!(race::Race{FirstPart})
    for boat in race
        race.ways_to_win += haswon(boat) ? 1 : 0
    end
    race
end

"""
Checks the win condition of each race.
"""
function analyse_races!(races::Vector{Race{FirstPart}})
    for race in races
        analyse_race!(race)
    end
end

"""
After a boat is assigned a speed after chargeup, calculate the distance traveled depending on the time left for the boat.
"""
function calculate_distance(timeleft::Number, speed::Number)
    timeleft * speed
end

"""
Returns the vectors for the `speeds` and `timelefts` for each race where each element of the vectors 
represents one possible boat.
For each millisecond spend charging, the remaining time for the boat is decreased by one millisecond.
"""
function calculate_speeds(timeleft::Integer, chargespeed::Number=1)
    speeds = Vector{Int64}(undef, timeleft)
    timelefts = Vector{Int64}(undef, timeleft)
    for i in 1:timeleft  # for i==0: Boat has no speed due to no charging time --> 0 distance
        timelefts[i] = timeleft - i
        speeds[i] = i * chargespeed
    end
    timelefts, speeds
end

"""
Parses input data and converts it into the respective fields for `Boat` structs
"""
function create_races(data::AbstractVector{<:AbstractString})
    races = Race{FirstPart}[]
    times_str = split(data[1], ":")[2]
    times = parse_numbers_string(times_str)
    distances_str = split(data[2], ":")[2]
    distances_to_beat = parse_numbers_string(distances_str)
    chargespeed = 1  # 1 mm*s^-2
    for t in eachindex(times)
        boats = Boat[]
        timelefts, speeds = calculate_speeds(times[t], chargespeed)
        for i in eachindex(timelefts)
            distance = calculate_distance(timelefts[i], speeds[i])
            boat = Boat(distance, distances_to_beat[t])
            push!(boats, boat)
        end
        race = Race{FirstPart}(boats, 0)
        push!(races, race)
    end
    races
end

"""
Each pair of time and distance represents a race.
The time is the full time in milliseconds for the race where each millisecond can either be spend
charging the speed of the boat by 1 mm/s^2 or letting the boat run. The goal is to calculate the 
number of possibilities in which the boat can beat a specific given distance (the record).
The result is the product of the number of all possibilties for each race.
"""
function main(day::Day06{FirstPart{T}}) where {T<:AbstractString}
    data = day.part.data
    races = create_races(data)
    analyse_races!(races)
    calculate_result(races)
end

"""
Each input line is to be interpreted as one number instead of multiple different ones.
"""
function read_race_data(data::AbstractVector{<:AbstractString})
    time_str = replace(split(data[1], ":")[2], " " => "")
    distance_str = replace(split(data[2], ":")[2], " " => "")
    parse(Int64, time_str), parse(Int64, distance_str)
end

"""
Instead of having different races, now the input numbers need to be interpreted as one
number for the time and one number for the distance to beat.
The result is still the product of possible combinations which beat the record distance.
"""
function main(day::Day06{SecondPart{T}}) where {T<:AbstractString}
    data = day.part.data
    t, distance_to_beat = read_race_data(data)
    chargespeed = 1
    speeds = range(start=1, stop=t) .* chargespeed
    timelefts = range(start=t - 1, stop=0, step=-1)
    length(findall(timelefts .* speeds .> distance_to_beat))
end

nothing

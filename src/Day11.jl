abstract type AbstractGalaxy end

include("utils.jl")
@warn "Remove include statement in Day11.jl."

struct Day11{P<:AbstractPart} <: AbstractDay
    part::P
end

struct Galaxy{T} <: AbstractGalaxy
    x::T
    y::T
end

"""
Parses input data into array of chars.
"""
function parse_galaxy_data(data::AbstractVector{<:AbstractString})
    galaxies = Array{Char,2}(undef, length(data), length(data[1]))
    for y in eachindex(data)
        for x in eachindex(data[y])
            galaxies[y, x] = data[y][x]
        end
    end
    galaxies
end

"""
Creates an array similar to `galaxies` replacing the char with a `Tuple{Int64,Int64}`.
The tuple represents the coordinate of that character in the expanded version.
Walk through each index of the rows and afterwards through each index of the columns
and check if the column or row (respectively) contains a galaxy.
If the column or row is empty, the space needs to be expanded by `increase_by`.
To do this the tracker values `xval` or `yval` get increased by the value `increase_by`.
This represents an expansion of the array without having to increase the size of the actual 
array.
The `findall` call gives back the positions of the galaxies in the `galaxies` array.
Taking the index of the current running loop and the found indices from `findall` allows
it to replace the tuple coordinates in `newgalaxies` with the current `xval` for looping
through the rows or `yval` for looping through the columns, keeping the other value 
of the tuple untouched.
In the end, the `newgalaxies` array is filled with tuples representing the shifted galaxy
coordinates.
"""
function check_row_col(galaxies::AbstractArray{<:AbstractChar,2}, increase_by::Integer)
    newgalaxies = similar(galaxies, Tuple{Int64,Int64})
    xval = 1
    yval = 1
    for i in axes(galaxies, 1)
        found = findall(c -> c == '#', galaxies[i, :])
        if isempty(found)
            xval += increase_by
        else
            for f in found
                pos = newgalaxies[i, f]
                pos = (xval, 0)
                newgalaxies[i, f] = pos
            end
        end
        xval += 1
    end
    for i in axes(galaxies, 2)
        found = findall(c -> c == '#', galaxies[:, i])
        if isempty(found)
            yval += increase_by
        else
            for f in found
                pos = newgalaxies[f, i]
                pos = (pos[1], yval)
                newgalaxies[f, i] = pos
            end
        end
        yval += 1
    end
    newgalaxies
end

"""
Loop through the `galaxies` array and check for the positions of the 
galaxies by comparing the characters with '#'.
If a galaxy is found, take the respective coordinate tuple from `newgalaxies`
and convert it to a `Galaxy` struct with the x,y coordinates as field values.
Returns the found galaxies as a vector.
"""
function convert_to_structs(galaxies::AbstractArray{<:AbstractChar,2},
    newgalaxies::AbstractArray{<:Tuple{<:Integer,<:Integer},2})
    gs = Galaxy[]
    for x in axes(galaxies, 1)
        for y in axes(galaxies, 2)
            if galaxies[x, y] == '#'
                pos = newgalaxies[x, y]
                g = Galaxy(pos...)
                push!(gs, g)
            end
        end
    end
    gs
end

"""
To calculate the shortest distance, compare the x-values and y-values of all `Galaxy` combinations.
The distance for of two points `(x1,y1)` and `(x2,y2)` is calculated by `d = |x2 - x1| - |y2 - y1|`
where `|<...>|` is the absolute function `abs()`.
Returns a vector of the shortest paths.

Note: The challenge only allows steps taken in up, down, left, right direction. This prevents the use
of Pythagorean theorem and instead the Taxicab distance as defined above is used.
"""
function calculate_shortest_path(newgalaxies::AbstractVector{Galaxy})
    result = Int64[]
    for i in eachindex(newgalaxies)
        for j in eachindex(newgalaxies[i:end])
            g1 = newgalaxies[i]
            g2 = newgalaxies[i+j-1]
            dx = abs(g1.x - g2.x)
            dy = abs(g1.y - g2.y)
            push!(result, dx + dy)
        end
    end
    result
end

"""
The input is an observation of the universe. '.' represents empty space and '#' represents a galaxy.
If a row or a column contains no galaxies, the respective row or column is duplicated, increasing 
the size of the 'universe' array. Find all galaxies in the increased universe and measure the shortest 
distance between each pair of galaxies (ignoring repeated combinations). The distance needs to be measured
by taking steps only in up, down, left or right directions (not diagonally).
The result is the sum of the distances.
"""
function main(day::Day11{FirstPart{T}}) where {T<:AbstractString}
    data = day.part.data
    galaxies = parse_galaxy_data(data)
    newgalaxies = check_row_col(galaxies, 1)
    gs = convert_to_structs(galaxies, newgalaxies)
    result = calculate_shortest_path(gs)
    sum(result)
end

"""
For part two the challenge remains the same, but instead of duplicating each empty row or column in the universe,
this time the row or column needs to be replaced by `1 000 000`. 
Note: Because the empty line gets 'replaced' the increasing factor for the calculation is `1 000 000 - 1`.
"""
function main(day::Day11{SecondPart{T}}) where {T<:AbstractString}
    data = day.part.data
    galaxies = parse_galaxy_data(data)
    newgalaxies = check_row_col(galaxies, 1000000 - 1)
    gs = convert_to_structs(galaxies, newgalaxies)
    result = calculate_shortest_path(gs)
    sum(result)
end

nothing

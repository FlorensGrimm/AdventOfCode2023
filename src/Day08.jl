abstract type AbstractDesertMap end

struct Day08{P<:AbstractPart} <: AbstractDay
    part::P
end

struct DesertMap <: AbstractDesertMap
    first::Symbol
    middle::Symbol
    last::Symbol
end

DesertMap(x::AbstractString) = DesertMap(convert_to_chars(x))
DesertMap(xs::AbstractVector{<:AbstractChar}) = DesertMap(Symbol.(xs))
DesertMap(xs::AbstractVector{<:Symbol}) = DesertMap(xs...)

"""
Allows to check if the third value in a node is an 'A'.
"""
is_A(d::AbstractDesertMap) = d.last == :A

"""
Allows to check if the third value in a node is a 'Z'.
"""
is_Z(d::AbstractDesertMap) = d.last == :Z

@enum Direction L = 1 R = 2

"""
Splits up one line from the input into current position (k), left direction and right direction instructions.
"""
function create_node(line::AbstractString)
    k, v = split(line, " = ")
    left, right = split(v, ", ")
    left = strip(left, '(')
    right = strip(right, ')')
    return k, left, right
end

"""
Creates a Vector of Pairs where each Pair is a DesertMap pointing
at a tuple of DesertMaps where the first element represents a left direction
and the second element represents the right direction.
"""
function create_desertmaps(data::AbstractVector{<:AbstractString})
    mappings = Vector{Pair{DesertMap,Tuple{DesertMap,DesertMap}}}(undef, length(data))
    for i in eachindex(data)
        k, left, right = create_node(data[i])
        mappings[i] = DesertMap(k) => (DesertMap(left), DesertMap(right))
    end
    mappings
end

"""
Traverse each starting 'ghost' until it reaches a node ending in Z.
Save the required stepnum.
Return the Vector of stepnums for each of the 6 ghosts.

    Note: this assumes that each ghost only visits a node ending with Z once and
    that this node is the node at which all ghosts will overlap at one point.

    The idea is that the ghost cycle through the nodes with a different frequency,
    resulting in them arriving at the end node at different stepnums.
    The least-common multiple of these stepnums is the first time that all
    ghosts will be arriving at the end nodes at the same time.
"""
function traverse(directions::Iterators.Cycle{T},
    mappings::AbstractVector{Pair{D,Tuple{D,D}}}) where {T<:AbstractVector{<:Integer},D<:AbstractDesertMap}

    ks = getproperty.(mappings, :first)::Vector{DesertMap}
    vs = getproperty.(mappings, :second)::Vector{Tuple{DesertMap,DesertMap}}
    idxs = findall(d -> is_A(d), ks)  # check for all mapping keys ending with 'A'
    stepnums = Vector{Int64}()
    @inbounds for i in eachindex(idxs)
        current = vs[idxs[i]]::Tuple{DesertMap,DesertMap}  # select mapping tuples where mapping key ends with 'A'
        @inbounds for (stepnum, direction) in enumerate(directions)
            current = getindex(current, direction)::DesertMap  # select the corresponding next instructions from all mapping tuples
            # all(is_Z.(currents)) && return stepnum # check if all mapping keys end in a 'Z' and if true return stepnum
            if any(is_Z(current))
                push!(stepnums, stepnum)
                break
            end
            next_idx = findfirst(x -> isequal(x, current), ks)::Int64  # find the next mapping keys indices
            current = getproperty(mappings[next_idx], :second)  # set currents to the values of the next mapping keys
        end
    end
    return stepnums
end

"""
Executes the directions following the mappings until `:ZZZ` is reached.
Returns the number of steps required.
"""
function traverse(directions::Iterators.Cycle{T}, mappings::AbstractDict{Symbol,Tuple{Symbol,Symbol}}) where {T<:AbstractVector{<:Integer}}
    current = mappings[:AAA]
    for (stepnum, direction) in enumerate(directions)
        k = current[direction]
        if k == :ZZZ
            return stepnum
        end
        current = mappings[k]
    end
end

"""
Reads data input and converts it into a dictonary mapping
each node to its corresponding destination tuple.
"""
function create_map(data::AbstractVector{<:AbstractString})
    mapping = Dict{Symbol,Tuple{Symbol,Symbol}}()
    for line in data
        k, left, right = create_node(line)
        mapping[Symbol(k)] = (Symbol(left), Symbol(right))
    end
    return mapping
end


"""
Retrives the directions string from the input data.
Converts the left and right instructions into Enum type `Direction`.
Converts the Direction type into the equivalent Integer representation.
Returns a `Iterators.cycle` of the Integer representation of the directions.
"""
function get_directions(data::AbstractVector{<:AbstractString})
    input = strip(popfirst!(data))
    directions = Vector{Int64}(undef, length(input))
    for i in eachindex(input)
        direction = Symbol(input[i])  # convert direction character to Symbol
        direction = eval(direction)  # evaluate it into the corresponding Direction Enum
        direction = Int(direction)  # convert it into the Integer representation
        directions[i] = direction
    end
    return Iterators.cycle(directions)  # return the cycle iterator
end

function main(day::Day08{FirstPart{T}}) where {T<:AbstractString}
    data = day.part.data
    directions = get_directions(data)
    popfirst!(data)  # removes empty line following direction instructions
    mappings = create_map(data)
    result = traverse(directions, mappings)
    result
end

function main(day::Day08{SecondPart{T}}) where {T<:AbstractString}
    data = day.part.data
    directions = get_directions(data)
    popfirst!(data)  # removes empty line following direction instructions
    mappings = create_desertmaps(data)
    result = traverse(directions, mappings)
    lcm(result)  # lowest-commen-multiple
end

nothing

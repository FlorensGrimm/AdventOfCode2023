struct Day05{P<:AbstractPart} <: AbstractDay
    part::P
end

abstract type AbstractCategory end

struct SeedToSoil <: AbstractCategory end
struct SoilToFertilizer <: AbstractCategory end
struct FertilizerToWater <: AbstractCategory end
struct WaterToLight <: AbstractCategory end
struct LightToTemperature <: AbstractCategory end
struct TemperatureToHumidity <: AbstractCategory end
struct HumidityToLocation <: AbstractCategory end

struct Map{S<:AbstractCategory} <: AbstractCategory
    from_to::Vector{Pair{UnitRange,UnitRange}}
end

struct Seeds{T}
    ids::Vector{T}
end


STRUCTS = Dict(
    Symbol("seed-to-soil") => SeedToSoil,
    Symbol("soil-to-fertilizer") => SoilToFertilizer,
    Symbol("fertilizer-to-water") => FertilizerToWater,
    Symbol("water-to-light") => WaterToLight,
    Symbol("light-to-temperature") => LightToTemperature,
    Symbol("temperature-to-humidity") => TemperatureToHumidity,
    Symbol("humidity-to-location") => HumidityToLocation,
)

"""
Checks seed id if it is in one of the source mappings.
If found, finds the index of the `id` in the source mapping and 
updates `id` with the corresponding value in the destination mapping.
Returns the list of location ids.
"""
function find_location_id(seed_id::Integer, maps::AbstractVector{<:AbstractCategory})
    for mapping in maps
        for (from, to) in mapping.from_to
            if seed_id in from
                idx = searchsorted(from, seed_id)
                seed_id = to[idx.start]
                break
            end
        end
    end
    seed_id
end

"""
Creates an empty return vector for the translated ids.
Checks if `id.start` and `id.stop` is in the mapping range.
    If `id.start && !id.stop` or `!id.start && id.stop` are in the mapping range
    then only translate the slice of the id range to the mapped id range.
    The rest of the ids get shortened by the translated slice and 
    get checked for the respective other case again.
    If `id.start && id.stop` are both in the mapping range, translate the ids
    completly and set ids to `nothing`.
    It is assumed that the mapping ranges do not overlap.
    Any none-translated ids are also passed into the return value `ret`.
    If ids is set to `nothing`, all ids have been translated to the new mapping
    and are already contained in the return value `ret`. 
"""
function get_next_category_ids(seeds_ranges::AbstractVector{U},
    mappings::AbstractVector{T}) where {T<:Pair{<:U}} where {U<:AbstractUnitRange}
    ret = Vector{eltype(seeds_ranges)}()
    for i in eachindex(seeds_ranges)
        ids = seeds_ranges[i]
        ret_ids = []
        for mapping in mappings
            r1, r2 = mapping
            if in(ids.start, r1) && in(ids.stop, r1)
                f = searchsortedfirst(r1, ids.start)
                l = searchsortedlast(r1, ids.stop)
                push!(ret_ids, r2[f]:r2[l])
                ids = nothing
                break
            end
            if !in(ids.start, r1) && in(ids.stop, r1)
                f = searchsortedfirst(r1, r1.start)
                stop_idx = searchsortedfirst(ids, r1.start)
                l = searchsortedlast(r1, ids[end])
                push!(ret_ids, r2[f]:r2[l])
                ids = ids[1]:ids[stop_idx-1]
            end
            if in(ids.start, r1) && !in(ids.stop, r1)
                f = searchsortedfirst(r1, ids[1])
                start_idx = searchsortedfirst(ids, r1.stop)
                l = searchsortedlast(r1, r1.stop)
                push!(ret_ids, r2[f]:r2[l])
                ids = ids[start_idx+1]:ids[end]
            end
        end
        isnothing(ids) ? nothing : push!(ret_ids, ids)
        append!(ret, ret_ids)
    end
    ret
end

"""
Checks each seed id from the input file. (Second Part)
"""
function find_location_ids(seeds::Seeds{<:AbstractUnitRange}, maps::AbstractVector{<:AbstractCategory})
    ids = seeds.ids
    for i in eachindex(maps)
        ids = get_next_category_ids(ids, maps[i].from_to)
    end
    ids
end

"""
Checks each seed id from the input file. (First Part)
"""
function find_location_ids(seeds::Seeds{<:Integer}, maps::AbstractVector{<:AbstractCategory})
    ids = Int64[]
    for seed_id in seeds.ids
        id = find_location_id(seed_id, maps)
        push!(ids, id)
    end
    ids
end

"""
The seed ids represent ranges.
Every two values create a range where the first value is the starting value and
the second value is the length of the range.
"""
function parse_seeds(seeds_str::AbstractString, ::SecondPart{<:AbstractString})
    _, seeds_ids = split(seeds_str, ":")
    seeds_ids = parse_numbers_string(seeds_ids)
    start_values = seeds_ids[1:2:end]
    length_values = seeds_ids[2:2:end]
    seeds_ids = UnitRange[]
    for (start_val, length_val) in zip(start_values, length_values)
        ids = range(start=start_val, length=length_val)
        push!(seeds_ids, ids)
    end
    Seeds(seeds_ids)
end

"""
Converts the seeds string into a Seeds struct with the seed ids as a field.
"""
function parse_seeds(seeds_str::AbstractString, ::FirstPart{<:AbstractString})
    _, seeds_ids = split(seeds_str, ":")
    seeds_ids = parse_numbers_string(seeds_ids)
    Seeds(seeds_ids)
end

"""
Checks for the header of a category and creates corresponding struct.
Fills the from_ids and to_ids fields with `Vector{UnitRange}`
where each index of the two vectors corresponds to a mapping with each other.
"""
function convert_categories(categories::AbstractVector{T}) where T<:AbstractVector{<:AbstractString}
    mappings = Vector{Map}()
    for category in categories
        key = split(popfirst!(category))[1]  # removes the string "map:" from end
        mapping = STRUCTS[Symbol(key)]
        mapping_vec = Pair{UnitRange,UnitRange}[]
        for line in category
            destination, source, len = parse_numbers_string(line)
            r1 = range(start=source, length=len)
            r2 = range(start=destination, length=len)
            push!(mapping_vec, r1 => r2)
        end
        push!(mappings, Map{mapping}(mapping_vec))
    end
    mappings
end

"""
Reads input data and splits each section into its own category.
Pushes each category into the vector categories.
Returns the vector categories.
"""
function parse_categories(data::AbstractVector{<:AbstractString})
    seeds = popfirst!(data)
    popfirst!(data) # removes empty line after seeds string
    categories = Vector{String}[]
    category = String[]
    for (i, line) in enumerate(data)
        if isempty(line) || i == length(data)  # check for last category
            push!(categories, category)
            category = String[]

            continue
        end
        push!(category, line)
    end
    return seeds, categories
end

"""
The almanac (your puzzle input) lists all of the seeds that need to be planted. 
It also lists what type of soil to use with each kind of seed, what type of 
fertilizer to use with each kind of soil, what type of water to use with 
each kind of fertilizer, and so on. Every type of seed, soil, fertilizer 
and so on is identified with a number, but numbers are reused by each 
category - that is, soil 123 and fertilizer 123 aren't necessarily related 
to each other.

The almanac starts by listing which seeds need to be planted: seeds 79, 14, 55, and 13.

The rest of the almanac contains a list of maps which describe how 
to convert numbers from a source category into numbers in a destination category. 
That is, the section that starts with seed-to-soil map: describes how to 
convert a seed number (the source) to a soil number (the destination). 
This lets the gardener and his team know which soil to use with which seeds, 
which water to use with which fertilizer, and so on.

Rather than list every source number and its corresponding destination 
number one by one, the maps describe entire ranges of numbers that can 
be converted. Each line within a map contains three numbers: the destination
 range start, the source range start, and the range length.
 Using these maps, find the lowest location number that corresponds to any of the initial seeds.
"""
function main(day::Day05{FirstPart{T}}) where {T<:AbstractString}
    data = day.part.data
    seeds_str, categories = parse_categories(data)
    seeds = parse_seeds(seeds_str, day.part)
    maps = convert_categories(categories)
    result = find_location_ids(seeds, maps)
    minimum(result)
end

function main(day::Day05{SecondPart{T}}) where {T<:AbstractString}
    data = day.part.data
    file = day.part.file
    seeds_str, categories = parse_categories(data)
    seeds = parse_seeds(seeds_str, SecondPart(file))
    maps = convert_categories(categories)
    result = find_location_ids(seeds, maps)
    minimum(result).start
end

nothing

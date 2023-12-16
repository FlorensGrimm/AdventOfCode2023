struct Day03{P<:AbstractPart} <: AbstractDay
    part::P
end


isdot(c::Char) = c == '.'
issymbol(c::Char) = !isdigit(c) && !isdot(c)
isstar(c::Char) = c == '*'

"""
Check if the blocks surrounding the number contains a symbol other than dots.
    If true, adds the centre number to the result
    If false, adds zero to the result.
Return the results vector.
"""
function check_blocks(blocks::AbstractVector{Pair{I,T}}) where {I<:Integer,T<:AbstractVector{T1}} where {T1<:AbstractVector{<:AbstractChar}}
    result = Int64[]
    for block in blocks
        flags = Bool[]
        for row in block.second
            push!(flags, any(issymbol.(row)))
        end
        any(flags) ? push!(result, block.first) : push!(result, 0)
    end
    result
end

"""
Get the characters around the given range by creating blocks of UnitRanges which surround the character(s) given by the range.
Checks if the created range block would be out-of-bounds for the given `chars::Matrix{Char}`.
"""
function generate_blocks(chars::AbstractArray{<:AbstractChar,2},
    ranges::AbstractVector{T}) where {T<:AbstractVector{<:AbstractUnitRange}}
    results = []
    checks = Vector{Vector{Char}}[]
    for (rdx, rs) in enumerate(ranges)
        check = Vector{Char}[]
        for r in rs
            start = r.start == 1 ? 1 : r.start - 1
            stop = r.stop == size(chars)[1] ? r.stop : r.stop + 1
            if rdx != 1
                prev_indices = start:stop
                previous_row::Vector{Char} = chars[rdx-1, prev_indices]
                push!(check, previous_row)
            end
            current_indices = start:stop
            current_row::Vector{Char} = chars[rdx, current_indices]
            push!(check, current_row)
            if rdx != length(ranges)
                next_indices = start:stop
                next_row::Vector{Char} = chars[rdx+1, next_indices]
                push!(check, next_row)
            end
            str = join(chars[rdx, r])
            push!(results, tryparse(Int64, str))
            push!(checks, check)
            check = []
        end
    end
    results .=> checks
end

Char <: AbstractChar

"""
Fill a matrix with each character of the input file.
"""
function generate_char_matrix!(chars::AbstractArray{<:AbstractChar,2}, line::AbstractString, rdx::Integer)
    for (cdx, c) in enumerate(line)
        chars[rdx, cdx] = c
    end
    nothing
end

"""
Find all indices of for which `func` returns true if evaluated on a character.
Check if the difference of the previous and current index is one:
    If true, append it to the `r` list.
    If false, create a UnitRange where `start=r[1]` and `stop=r[end]`, generating 
    a list of UnitRanges where each UnitRange indexes the string of numbers.
"""
function get_ranges(line::AbstractString, func::Function)
    idxs = findall(c -> func(c), line)
    rs = UnitRange[]
    r = Int64[]
    for i in eachindex(idxs)[1:end-1]
        current = idxs[i]
        next = idxs[i+1]
        if next - current == 1
            push!(r, current)
        elseif next - current != 1
            push!(r, current)
            push!(rs, r[1]:r[end])
            r = []
        end
        if i + 1 == length(idxs)
            push!(r, next)
            push!(rs, r[1]:r[end])
        end

    end
    rs
end

"""
Generates the chars Matrix and the Vector of Vector{UnitRange} where each Vector{UnitRange} consists of the 
UnitRange for a number in string representation.
"""
function initialize(day::Day03, func::Function)
    data = day.part.data
    chars = Array{Char,2}(undef, length(data), length(data[1]))
    ranges = Vector{UnitRange}[]
    for (rdx, line) in enumerate(data)
        push!(ranges, get_ranges(line, func))
        generate_char_matrix!(chars, line, rdx)
    end
    chars, ranges
end

"""
Creates blocks of indices around the star character
"""
function get_indices(idx::Integer, chars::AbstractArray{<:AbstractChar,2})
    start = idx == 1 ? 1 : idx - 1
    stop = idx == size(chars)[1] ? idx : idx + 1
    collect(start:stop)
end

"""
Converts the ranges representing the numbers found in the input data into indices.
"""
function convert_ranges_to_indices(ranges_numbers::AbstractVector{T}) where {T<:AbstractVector{<:AbstractUnitRange}}
    indices_numbers = similar(ranges_numbers, Vector{Vector{Int64}})
    indices_row = Vector{Vector{Int64}}()
    for (i, range_number_vec) in enumerate(ranges_numbers)
        for range_number in range_number_vec
            push!(indices_row, collect(range_number))
        end
        indices_numbers[i] = indices_row
        indices_row = Vector{Vector{Int64}}()
    end
    indices_numbers
end

"""
Checks if the current character is a star symbol.
If true, creates a indices block around the character.
Checks the rows above, current and below the found star symbol in the data for digits.
Loops through each flag of the previous check and looks up the corresponding full number in indices_numbers.
Converts the found number and pushes it into the result for this star character.

"""
function calculate_gear_ratios(chars::AbstractArray{<:AbstractChar,2},
    indices_numbers::Vector{T}) where {T<:Vector{V}} where {V<:Vector{<:Integer}}
    final_result = Int64[]
    for rdx in axes(chars, 1)
        for cdx in axes(chars, 2)
            c::Char = chars[rdx, cdx]
            if !isstar(c)
                continue
            end

            row_indices::Vector{Int64} = get_indices(rdx, chars)
            col_indices::Vector{Int64} = get_indices(cdx, chars)

            star_result = Int64[]
            for row_index in row_indices
                row_result = Int64[]
                cs::Vector{Char} = chars[row_index, col_indices]  # One row of the input data
                flags::BitArray = isdigit.(cs)  # BitMask of digits found
                # If [true, false, true] is found in the BitMask, there exists the possibility 
                # that both numbers found are two distinct number with the same value.
                two_numbers_found::Bool = flags == [true, false, true] ? true : false
                for (fdx, flag) in enumerate(flags)
                    if !flag
                        continue
                    end
                    for indice_number in indices_numbers[row_index]  # Checks each collections of number indices against the current index
                        if col_indices[fdx] in indice_number
                            push!(row_result, parse(Int64, join(chars[row_index, indice_number])))
                        end
                    end
                end
                # If two_numbers_found is true, all numbers found should be treated as separate numbers
                # If two_numbers_found is false, multiple numbers in the row_result represent the same number in the input data and need to be filtered out.
                two_numbers_found ? append!(star_result, row_result) : append!(star_result, [elem for elem in Set(row_result)])
            end
            # If two numbers found: calculate the product and push it into final_result
            if length(star_result) == 2
                push!(final_result, star_result[1] * star_result[2])
            end
        end
    end
    final_result
end


"""
Finds any number in the input file which is adjacent, even diagonally, to at least one symbol which is not a dot.
Adds them up and returns the result.
"""
function main(day::Day03{FirstPart{T}}) where {T<:AbstractString}
    chars, ranges = initialize(day, isdigit)
    number_blocks = generate_blocks(chars, ranges)
    result = check_blocks(number_blocks)
    sum(result)
end

"""
Searches in the input file for '*' symbols which connect exactly two numbers.
The product of the two numbers is the 'gear ratio'.
The result is the sum of all gear ratios.
"""
function main(day::Day03{SecondPart{T}}) where {T<:AbstractString}
    chars, _ = initialize(day, isstar)
    _, ranges_numbers = initialize(day, isdigit)
    indices_numbers = convert_ranges_to_indices(ranges_numbers)
    result = calculate_gear_ratios(chars, indices_numbers)
    sum(result)
end

nothing

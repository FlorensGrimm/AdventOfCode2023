abstract type AbstractOasisSequence end

struct Day09{P<:AbstractPart} <: AbstractDay
    part::P
end

struct OasisSequence <: AbstractOasisSequence
    seq::Vector{Vector{T}} where {T}
end

"""
Using the current rows last (reverse=false)/ first (reverse=true) value, calculate the
corresponding next value for the following row.

reverse=false (Part 1):
	The last value of a sequence is the placeholder value.
	Therefore the last value of the current row added to the second-to-last value of the previous row
	gives the next extrapolated value.

reverse=true (Part 2):
	The first value of a sequence is the placeholder value.
	Therefore the first value of the current row subtracted from the second value of the previous row
	gives the next extrapolated value.

"""
function extrapolate_next_value!(oasis::AbstractOasisSequence, reverse::Bool)
    func1 = reverse ? first : last
    func2, offset = reverse ? (firstindex, +1) : (lastindex, -1)
    func3 = reverse ? firstindex : lastindex
    op = reverse ? Base.:- : Base.:+
    for i in eachindex(oasis.seq[1:end-1])
        last_val = func1(oasis.seq[i])
        seq = oasis.seq[i+1]
        idx = func2(seq) + offset
        next_val = op(seq[idx], last_val)
        idx = func3(seq)
        seq[idx] = next_val
    end
    nothing
end

"""
Calculate the extrapolated value and save it to the result vector.
Depending on the value of `reverse`, either the first or last value of the
last sequence need to be saved.
"""
function extrapolate_next_values!(oasises::AbstractVector{<:AbstractOasisSequence}, reverse::Bool)
    func = reverse ? first : last
    result = Vector{Float64}(undef, length(oasises))
    @inbounds for i in eachindex(oasises)
        oasis = oasises[i]::OasisSequence
        extrapolate_next_value!(oasis, reverse)
        result[i] = func(oasises[i].seq[end])
    end
    result
end

"""
Calculate the next sequence following the rules described in `main`.
Depending on reverse being true or false shifts the values used for the calculations
	and the break condition.
The break condition is achieved when all elements are 0 in a row except the placeholder value.
"""
function calculate_next_sequence!(oasis::AbstractOasisSequence, reverse::Bool)
    offset1, offset2 = reverse ? (2, 1) : (1, 0)
    viewstart, viewstop = reverse ? (2, 0) : (1, 1)
    while true
        seq = oasis.seq[1]
        next_seq = Vector{Float64}(undef, length(seq) - 1)
        for i in eachindex(seq[1:end-2])
            diff = seq[i+offset1] - seq[i+offset2]
            next_seq[i+offset2] = diff
        end
        pushfirst!(oasis.seq, next_seq)
        all(iszero.(view(next_seq, viewstart:length(next_seq)-viewstop))) && break
    end
    append_idx = reverse ? 1 : length(oasis.seq[1])
    oasis.seq[1][append_idx] = 0.0
    nothing
end

"""
Calcualte the next sequences for each OasisSequence in the oasises vector.
"""
function calculate_next_sequences!(
    oasises::AbstractVector{<:AbstractOasisSequence},
    reverse::Bool)
    for oasis in oasises
        calculate_next_sequence!(oasis, reverse)
    end
end

"""
Create an OasisSequence from each input line
reverse=false (Part 1):
	Add an additional placeholder at the end of the starting sequence.

reverse=true (Part 2):
Add an additional placeholder at the beginning of the starting sequence.

"""
function parse_oasis_data(data::AbstractVector{<:AbstractString}, reverse::Bool)
    oasises = OasisSequence[]
    for line in data
        input = [parse.(Float64, split(line))]
        reverse ? pushfirst!(input[1], NaN) : push!(input[1], NaN)
        oasis = OasisSequence(input)
        push!(oasises, oasis)

    end
    oasises
end

"""
Takes in input data and creates a Vector of OasisSequence.
While creating the sequences, adds a placeholder to the starting vector for later calculations.
For each OasisSequence:
Calculate the difference of each element with the following element and store it in the next row 
(this reduces the length of the result vector by 1)
Repeat this step with the newly calculated row until all elements are equal to 0.
Append an additional placeholder element to the result row and push it into the OasisSequence.
Extrapolate the next value by appending an additional 0 to the last line and afterwards
calculate the extrapolated value by adding the last value of the previous row with the value last value
of the current row.
Store the result in the placeholder position of the previous row.
Continue this process until all placeholder values are replaced by the calculation result.
The sum of all final extrapolated values is the result.
"""
function main(day::Day09{FirstPart{T}}) where {T<:AbstractString}
    data = day.part.data
    reverse = false
    oasises = parse_oasis_data(data, reverse)
    calculate_next_sequences!(oasises, reverse)
    result = extrapolate_next_values!(oasises, reverse)
    result = sum(result)
    Int(result)
end

"""
Instead of extrapolating the last value, reverse everything and predict the previous value of a OasisSequence.
The concepts stay the same, but the orders, positions and indices may change.
"""
function main(day::Day09{SecondPart{T}}) where {T<:AbstractString}
    data = day.part.data
    reverse = true
    oasises = parse_oasis_data(data, reverse)
    calculate_next_sequences!(oasises, reverse)
    result = extrapolate_next_values!(oasises, reverse)
    result = sum(result)
    Int(result)
end

nothing

struct Day11{P<:AbstractPart} <: AbstractDay
	part::P
end

function main(day::Day11{FirstPart{T}}) where {T<:AbstractString}
end

function main(day::Day11{SecondPart{T}}) where {T<:AbstractString}
end

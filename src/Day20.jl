struct Day20{P<:AbstractPart} <: AbstractDay
	part::P
end

function main(day::Day20{FirstPart{T}}) where {T<:AbstractString}
end

function main(day::Day20{SecondPart{T}}) where {T<:AbstractString}
end

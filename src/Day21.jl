struct Day21{P<:AbstractPart} <: AbstractDay
	part::P
end

function main(day::Day21{FirstPart{T}}) where {T<:AbstractString}
end

function main(day::Day21{SecondPart{T}}) where {T<:AbstractString}
end

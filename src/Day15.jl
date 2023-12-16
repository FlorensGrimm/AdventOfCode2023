struct Day15{P<:AbstractPart} <: AbstractDay
	part::P
end

function main(day::Day15{FirstPart{T}}) where {T<:AbstractString}
end

function main(day::Day15{SecondPart{T}}) where {T<:AbstractString}
end

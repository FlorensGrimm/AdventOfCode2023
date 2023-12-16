struct Day12{P<:AbstractPart} <: AbstractDay
	part::P
end

function main(day::Day12{FirstPart{T}}) where {T<:AbstractString}
end

function main(day::Day12{SecondPart{T}}) where {T<:AbstractString}
end

struct Day18{P<:AbstractPart} <: AbstractDay
	part::P
end

function main(day::Day18{FirstPart{T}}) where {T<:AbstractString}
end

function main(day::Day18{SecondPart{T}}) where {T<:AbstractString}
end

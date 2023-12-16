struct Day17{P<:AbstractPart} <: AbstractDay
	part::P
end

function main(day::Day17{FirstPart{T}}) where {T<:AbstractString}
end

function main(day::Day17{SecondPart{T}}) where {T<:AbstractString}
end

struct Day14{P<:AbstractPart} <: AbstractDay
	part::P
end

function main(day::Day14{FirstPart{T}}) where {T<:AbstractString}
end

function main(day::Day14{SecondPart{T}}) where {T<:AbstractString}
end

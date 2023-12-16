struct Day22{P<:AbstractPart} <: AbstractDay
	part::P
end

function main(day::Day22{FirstPart{T}}) where {T<:AbstractString}
end

function main(day::Day22{SecondPart{T}}) where {T<:AbstractString}
end

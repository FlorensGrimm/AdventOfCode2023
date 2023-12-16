struct Day13{P<:AbstractPart} <: AbstractDay
	part::P
end

function main(day::Day13{FirstPart{T}}) where {T<:AbstractString}
end

function main(day::Day13{SecondPart{T}}) where {T<:AbstractString}
end

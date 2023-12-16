struct Day24{P<:AbstractPart} <: AbstractDay
	part::P
end

function main(day::Day24{FirstPart{T}}) where {T<:AbstractString}
end

function main(day::Day24{SecondPart{T}}) where {T<:AbstractString}
end

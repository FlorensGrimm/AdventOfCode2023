struct Day19{P<:AbstractPart} <: AbstractDay
	part::P
end

function main(day::Day19{FirstPart{T}}) where {T<:AbstractString}
end

function main(day::Day19{SecondPart{T}}) where {T<:AbstractString}
end

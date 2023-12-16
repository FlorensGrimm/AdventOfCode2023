struct Day25{P<:AbstractPart} <: AbstractDay
	part::P
end

function main(day::Day25{FirstPart{T}}) where {T<:AbstractString}
end

function main(day::Day25{SecondPart{T}}) where {T<:AbstractString}
end

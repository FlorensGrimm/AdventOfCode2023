struct Day23{P<:AbstractPart} <: AbstractDay
	part::P
end

function main(day::Day23{FirstPart{T}}) where {T<:AbstractString}
end

function main(day::Day23{SecondPart{T}}) where {T<:AbstractString}
end

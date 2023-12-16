struct Day16{P<:AbstractPart} <: AbstractDay
	part::P
end

function main(day::Day16{FirstPart{T}}) where {T<:AbstractString}
end

function main(day::Day16{SecondPart{T}}) where {T<:AbstractString}
end

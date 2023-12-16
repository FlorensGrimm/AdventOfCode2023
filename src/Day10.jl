abstract type AbstractDirection end

include("utils.jl")
@warn("Remove include statement from Day10.jl")

@kwdef struct Stop <: AbstractDirection
    dx::Int64 = 0
    dy::Int64 = 0
end

@kwdef struct East <: AbstractDirection
    dx::Int64 = 1
    dy::Int64 = 0
end
@kwdef struct West <: AbstractDirection
    dx::Int64 = -1
    dy::Int64 = 0
end
@kwdef struct North <: AbstractDirection
    dx::Int64 = 0
    dy::Int64 = -1
end
@kwdef struct South <: AbstractDirection
    dx::Int64 = 0
    dy::Int64 = 1
end

@kwdef struct Start <: AbstractDirection
    up::Tuple{Int64,Int64} = (0, -1)
    down::Tuple{Int64,Int64} = (0, 1)
    left::Tuple{Int64,Int64} = (-1, 0)
    right::Tuple{Int64,Int64} = (1, 0)
end

Base.iterate(S::Start) = (S.up, Val(:down))
Base.iterate(S::Start, ::Val{:down}) = (S.down, Val(:left))
Base.iterate(S::Start, ::Val{:left}) = (S.left, Val(:right))
Base.iterate(S::Start, ::Val{:right}) = (S.right, Val(:done))
Base.iterate(::Start, ::Val{:done}) = nothing

const PIPES = Dict(
    '|' => (North(), South()),
    '-' => (East(), West()),
    'L' => (North(), East()),
    'J' => (North(), West()),
    '7' => (South(), West()),
    'F' => (South(), East()),
    '.' => (Stop(), Stop()),
    'S' => (Start(), Start()),
)

struct Pipe{D1<:AbstractDirection,D2<:AbstractDirection}
    entry1::D1
    entry2::D2
    posx::Int64
    posy::Int64
end

mutable struct Position
    startx::Int64
    starty::Int64
    prevx::Int64
    prevy::Int64
    currentx::Int64
    currenty::Int64
    steps::Int64
    prevs::Vector{Tuple{Int64,Int64,Int64}}
end

Base.getindex(pipes::Array{Pipe,2}, p::Position) = pipes[p.currentx, p.currenty]

function move!(p::Position, direction::Tuple{Integer,Integer})
    p.prevx = p.currentx
    p.prevy = p.currenty
    p.currentx += direction[1]
    p.currenty += direction[2]
    push!(p.prevs, (p.steps, p.prevx, p.prevy))
    p.steps += 1
    nothing
end
function check_move(pos::Position, direction::AbstractDirection)
    pos.currentx + direction.dx == pos.prevx || return false
    pos.currenty + direction.dy == pos.prevy || return false
    return true
end
move!(pos::Position, direction::AbstractDirection) = move!(pos, (direction.dx, direction.dy))
# start!(pos::Position, ::Pipe{Start,Start}) =
function stop!(pos::Position, ::Pipe{Stop,Stop})
    pos.steps = -1
    println("STOP!")
end
function move!(pos::Position, pipe::Pipe{<:AbstractDirection,<:AbstractDirection})
    if check_move(pos, pipe.entry1)
        move!(pos, pipe.entry2)
    elseif check_move(pos, pipe.entry2)
        move!(pos, pipe.entry1)
    elseif isa(pipe, Pipe{Stop,Stop})
        stop!(pos, pipe)
    else
        stop!(pos, Pipe(Stop(), Stop(), -1, -1))
    end
end

struct Day10{P<:AbstractPart} <: AbstractDay
    part::P
end

"""
"""
function create_pipes(data)
    pipes = Array{Pipe,2}(undef, length(data), length(data[1]))
    pos = Position(0, 0, 0, 0, 0, 0, 0, [])
    for y in eachindex(data)
        for x in eachindex(data[y])
            d1, d2 = PIPES[data[y][x]]
            p = Pipe(d1, d2, x, y)
            if isa(p, Pipe{Start,Start})
                pos.startx = pos.currentx = x
                pos.starty = pos.currenty = y

            end
            pipes[x, y] = p
        end
    end
    pipes, pos
end

function main(day::Day10{FirstPart{T}}) where {T<:AbstractString}
    data = day.part.data
    pipes, startpos = create_pipes(data)

end

function main(day::Day10{SecondPart{T}}) where {T<:AbstractString}
end

file = joinpath("input", "Day10", "Day10.txt")
# file = joinpath("input", "Day10", "Sample.txt")
isfile(file)
pipes, pos = main(Day10(FirstPart(file)))
run = deepcopy(pos)
result = []
for direction in Start()
    move!(run, direction)
    if any([run.currentx, run.currenty] .== 0)
        continue
    end
    if any([run.currentx, run.currenty] .> length(pipes))
        continue
    end
    while (run.startx != run.currentx) || (run.starty != run.currenty)
        if run.steps == -1
            break
        end
        move!(run, pipes[run])
    end
    run.steps != -1 && push!(result, (direction, run.prevs))
    run = deepcopy(pos)
end
result[1][2]


xs = [point[2] for point in result[1][2]]
ys = [point[3] for point in result[1][2]]
linear = [(y - 1) * 140 + x for (x, y) in zip(xs, ys)]

for i in eachindex(pipes)
    if !isa(pipes[i], Pipe{Stop,Stop}) && !in(i, linear)
        println(pipes[i])
    end
end

pipes[44, 93]

pipes[1, 1]
pipes[2, 1]
pipes[3, 1]

pipes[(1-1)*140+1]



length(result[1][2]) / 2
# run = deepcopy(pos)


main(Day10(SecondPart(file)))
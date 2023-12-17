abstract type AbstractDirection end

struct Day10{P<:AbstractPart} <: AbstractDay
    part::P
end

@kwdef struct DummyStop <: AbstractDirection
    dx::Int64 = 0
    dy::Int64 = 0
end

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

struct MazeResult
    direction::Tuple{Int64,Int64}
    prevs::Vector{Tuple{Int64,Int64,Int64}}
end

"""
Allows to iterate through the four different starting directions.
"""
Base.iterate(S::Start) = (S.up, Val(:down))
Base.iterate(S::Start, ::Val{:down}) = (S.down, Val(:left))
Base.iterate(S::Start, ::Val{:left}) = (S.left, Val(:right))
Base.iterate(S::Start, ::Val{:right}) = (S.right, Val(:done))
Base.iterate(::Start, ::Val{:done}) = nothing

const NS = Union{North,South}
const WE = Union{West,East}
const NE = Union{North,East}
const NW = Union{North,West}
const SE = Union{South,East}
const SW = Union{South,West}

const S = Union{DummyStop,Stop}

"""
Allows to replace the `Start` pipe by its corresponding pipe type.
"""
const DIRECTIONS = Dict(
    (0, 1) => South(),
    (0, -1) => North(),
    (1, 0) => East(),
    (-1, 0) => West(),
)

"""
Associates a symbol to a pipe entry type.
"""
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


"""
Allows to represent the maze in a more human frindly way instead of 
using the abstract symbols from the input data.
"""
showmaze(io::IO, ::Pipe{<:T,<:T}) where {T<:NS} = print(io, '│')
showmaze(io::IO, ::Pipe{<:T,<:T}) where {T<:WE} = print(io, '─')
showmaze(io::IO, ::Pipe{<:T,<:T}) where {T<:NE} = print(io, '└')
showmaze(io::IO, ::Pipe{<:T,<:T}) where {T<:NW} = print(io, '┘')
showmaze(io::IO, ::Pipe{<:T,<:T}) where {T<:SE} = print(io, '┌')
showmaze(io::IO, ::Pipe{<:T,<:T}) where {T<:SW} = print(io, '┐')
showmaze(io::IO, ::Pipe{Stop,Stop}) = print(io, ".")
showmaze(io::IO, ::Pipe{DummyStop,DummyStop}) = print(io, ",")

function showmaze(io::IO, pipes::Array{Pipe,2})
    for x in axes(pipes, 1)
        for y in axes(pipes, 2)
            showmaze(io, pipes[y, x])
        end
        println(io)
    end
end

"""
Specialises the different pipe combinations on when they are encountered
by the diagonal ray tracing to either switch the `inside` flag value or not.
"""
(::Pipe{<:NS,<:NS})(inside::Bool) = !inside
(::Pipe{<:WE,<:WE})(inside::Bool) = !inside
(::Pipe{<:SE,<:SE})(inside::Bool) = inside
(::Pipe{<:NE,<:NE})(inside::Bool) = !inside
(::Pipe{<:NW,<:NW})(inside::Bool) = inside
(::Pipe{<:SW,<:SW})(inside::Bool) = !inside
(::Pipe{<:S,<:S})(inside::Bool) = inside

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

"""
Sets the `prevx` and `prevy` coordinates to the `currentx` and `currenty` variables, respectivly.
Afterwards advances the `Position` variable in the direction of the pipe exit.
Also saves the encountered field into the result vector.
Increases the step counter by one.
"""
function move!(p::Position, direction::Tuple{Integer,Integer})
    p.prevx = p.currentx
    p.prevy = p.currenty
    p.currentx += direction[1]
    p.currenty += direction[2]
    push!(p.prevs, (p.steps, p.prevx, p.prevy))
    p.steps += 1
    nothing
end

"""
Checks if the `Position` variable was able to use an available
pipe entry to enter the current field.
"""
function check_move(pos::Position, direction::AbstractDirection)
    pos.currentx + direction.dx == pos.prevx || return false
    pos.currenty + direction.dy == pos.prevy || return false
    return true
end

"""
Extracts the corresponding move direction for the pipe type.
"""
move!(pos::Position, direction::AbstractDirection) = move!(pos, (direction.dx, direction.dy))

"""
Sets `step` value of `Position` to -1 to signal to the while loop,
that a `Stop` pipe has been encountered.
"""
function stop!(pos::Position, ::Pipe{Stop,Stop})
    pos.steps = -1
end

"""
Checks through which entry point the field was entered:
If entered through entry1, move the `Position` variable
to the corresponding field of following the `entry2` field of the
pipe.
If a `Stop` pipe is encountered, set the `steps` field of the `Position`
variable to -1 which breaks out of the current iteration.
If a field is encountered which has no fitting pipe entry, then also signal 
to break out of the loop.
This happens if the `Position` variable enters a field from a direction in
which no pipe entry is available.
"""
function move!(pos::Position, pipe::Pipe{<:AbstractDirection,<:AbstractDirection})
    if isa(pipe, Pipe{Stop,Stop})
        stop!(pos, pipe)
    elseif check_move(pos, pipe.entry1)
        move!(pos, pipe.entry2)
    elseif check_move(pos, pipe.entry2)
        move!(pos, pipe.entry1)

    else
        stop!(pos, Pipe(Stop(), Stop(), -1, -1))
    end
end

"""
Parse each character from the input file and create pipes
with the corresponding entries (compare with `PIPES`).
Also creates `Position` and sets it to the starting point
encountered in the input data.
"""
function create_pipes(data::AbstractVector{<:AbstractString})
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

"""
Starting from the `Start` pipe, move into all four direction and check
if the encountered pipe at these positions lead around the main loop or not.
A pipe which moves the `Position` variable to a pipe which is not directly
connected to the current pipe, sets the `steps` field of `Position` to `-1`
which stops the current try and starts from the beginning.
If the pipes connect, the `while-loop` follows through the use of `move!`
the pipes until the starting position is reached again.
Count the number of steps needed to traverse the main loop and save the 
walked (x,y) coordinates together with the required number of steps into the
`result` vector.
The `move!` function is specialised on the type of pipe encountered,
setting the `Position` variable to the next field, following the direction
of the pipe.
"""
function count_loop(pos::Position, pipes::AbstractArray{Pipe,2})
    result = MazeResult[]
    run = deepcopy(pos)
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
        if run.steps != -1
            mazeresult = MazeResult(direction, run.prevs)
            push!(result, mazeresult)
        end

        run = deepcopy(pos)
    end
    result
end

"""
Prepares the construction of the expanded pipes.
Replaces the start pipe by the correct pipe type
and creates the vectors for the x- any y-coordinates
of the main loop pipes.
"""
function prepare_expanded_pipes!(pipes::AbstractArray{Pipe,2},
    result::AbstractVector{MazeResult})
    mazeresult1, mazeresult2 = result
    points = mazeresult2.prevs
    dr1 = mazeresult1.direction
    dr2 = mazeresult2.direction
    entry1 = DIRECTIONS[dr1]
    entry2 = DIRECTIONS[dr2]
    _, posx, posy = mazeresult1.prevs[1]
    xs = [point[2] for point in points]::Vector{Int64}
    ys = [point[3] for point in points]::Vector{Int64}
    pipes[xs[1], ys[1]] = Pipe(entry1, entry2, posx, posy)

    pipes, xs, ys
end

"""
After creating the expanded pipes array, fills all fields with 
Stop type pipes if the field corresponds to a real field in the normal
pipe array.
Otherwise fills it with a DummyStop pipe.
"""
function clear_expanded_pipes!(pipes_expanded::AbstractArray{Pipe,2})
    for x in axes(pipes_expanded, 2)
        for y in axes(pipes_expanded, 1)
            if x % 2 == 0
                if y % 2 == 0
                    pipes_expanded[x, y] = Pipe(Stop(), Stop(), x, y)
                else
                    pipes_expanded[x, y] = Pipe(DummyStop(), DummyStop(), x, y)
                end
            elseif y % 2 == 0
                if x % 2 == 0
                    pipes_expanded[x, y] = Pipe(Stop(), Stop(), x, y)
                else
                    pipes_expanded[x, y] = Pipe(DummyStop(), DummyStop(), x, y)
                end
            else
                pipes_expanded[x, y] = Pipe(DummyStop(), DummyStop(), x, y)
            end
        end
    end
end

"""
Creates an expanded pipes array of double the size.
This creates fields for gaps between pipes which do not have
a field in the normal pipes array.
Recreate the main pipe loop in the expanded array.
Fill any gaps between the now expanded pipes with straight pipe types (N-S, W-E)
"""
function fill_expanded_pipes(pipes::AbstractArray{Pipe,2},
    xs::AbstractVector{<:Integer}, ys::AbstractVector{<:Integer})
    pipes_expanded = Array{Pipe,2}(undef, 2 .* size(pipes))
    clear_expanded_pipes!(pipes_expanded)
    for (x, y) in zip(xs, ys)
        nx = 2 * x
        ny = 2 * y
        pipes_expanded[nx, ny] = pipes[x, y]
        for entry in [pipes[x, y].entry1, pipes[x, y].entry2]
            if entry isa North
                pipes_expanded[nx, ny-1] = Pipe(South(), North(), x, y - 1)
            elseif entry isa South
                pipes_expanded[nx, ny+1] = Pipe(North(), South(), x, y + 1)
            elseif entry isa West
                pipes_expanded[nx-1, ny] = Pipe(West(), East(), x - 1, y)
            elseif entry isa East
                pipes_expanded[nx+1, ny] = Pipe(East(), West(), x + 1, y)
            end
        end
    end
    pipes_expanded
end

"""
Any field enclosed by the main loop counts towards the result.
Due to doubling the size of the array, additional fields were created
which should not be counted.
These were previously filled with `DummyStop` pipes.
These do not count towards the result.
To count the enclosed fields, the ray tracing method is used.
Start at a point outside of the loop and move diagonally through the
array. 
The method we step through the maze is shown here:

.....   |  x.... | xx... | xxx.. | xxxx. | xxxxx | xxxxx | xxxxx | xxxxx
.....   |  ..... | x.... | xx... | xxx.. | xxxx. | xxxxx | xxxxx | xxxxx
.....   |  ..... | ..... | x.... | xx... | xxx.. | xxxx. | xxxxx | xxxxx
.....   |  ..... | ..... | ..... | x.... | xx... | xxx.. | xxxx. | xxxxx

If a pipe is crossed check if the pipe crossing would result in being inside 
the loop or not and if true set the `inside` flag to true.
If it is set to true start increasing the `count` for any field which is 
a `Stop` field. Any other field is either a `DummyStop` field or another pipe.
Both of which do not count to the result.
If another pipe is encounter check again if this results in being inside or outside
of the main loop (negate the current `inside` value.)
Like this we walk each field of the maze to count the number of enclosed fields.
"""
function count_tiles(pipes_expanded::AbstractArray{Pipe,2})
    HEIGHT, WIDTH = size(pipes_expanded)
    count = 0
    inside = false
    for k in 1:WIDTH+HEIGHT
        j = 1
        while j < k
            i = k - j
            if i <= HEIGHT && j <= WIDTH
                pipe = pipes_expanded[i, j]
                inside = pipe(inside)
                if inside
                    count += isa(pipe, Pipe{Stop,Stop}) ? 1 : 0
                end
            end
            j += 1
        end
    end
    count
end

"""
Follow the pipes (starts at field 'S') and count the steps which
are necessary to complete a full loop.
The result is the number of steps to reach the furthest point
from the start.
"""
function main(day::Day10{FirstPart{T}}) where {T<:AbstractString}
    data = day.part.data
    pipes, pos = create_pipes(data)
    result = count_loop(pos, pipes)
    Int(length(result[1][2]) / 2)
end

"""
Count any fields which are enclosed by the loop.
Fields are counted as being inside only if they are 
completly enclosed in the pipes. Gaps between
pipes (even if they are not in their own fields) allow fields to
be counted as being outside.
"""
function main(day::Day10{SecondPart{T}}) where {T<:AbstractString}
    data = day.part.data
    pipes, pos = create_pipes(data)
    result = count_loop(pos, pipes)
    pipes, xs, ys = prepare_expanded_pipes!(pipes, result)
    pipes_expanded = fill_expanded_pipes(pipes, xs, ys)
    count_tiles(pipes_expanded)
end

nothing

abstract type AbstractDay end
abstract type AbstractPart end

@kwdef struct Result{T1,T2}
    FirstPart::T1
    SecondPart::T2
end

"""
If both result values are not set in the `Result.txt` file.
"""
function check_results(::Result{Nothing,Nothing}, ::Result{Nothing,Nothing})
    missing, missing
end

"""
If only the value for part 1 is set in the `Result.txt` file.
"""
function check_results(r1::Result{T,Nothing}, r2::Result{T,Nothing}) where {T}
    isequal(r1.FirstPart, r2.FirstPart), missing
end

"""
If both the values are set in the `Result.txt` file.
"""
function check_results(r1::Result{T,T}, r2::Result{T,T}) where {T}
    isequal(r1.FirstPart, r2.FirstPart), isequal(r1.SecondPart, r2.SecondPart)
end

struct FirstPart{T<:AbstractString} <: AbstractPart
    data::Vector{T}
    directory::T
    file::T
    function FirstPart(file::AbstractString)
        data = read_data(file)
        directory = dirname(file)
        new{eltype(data)}(data, directory, file)
    end
end

struct SecondPart{T<:AbstractString} <: AbstractPart
    data::Vector{T}
    directory::T
    file::T
    function SecondPart(file::AbstractString)
        data = read_data(file)
        directory = dirname(file)
        new{eltype(data)}(data, directory, file)
    end
end

"""
Read input file and returns `data::Vector{String}`.
"""
function read_data(file::AbstractString)
    isfile(file) || error("File $file not Found.")
    open(file, "r") do f
        readlines(f)
    end
end

"""
Parses a `Result.txt` file to extract the expected results and returns a `Result` struct.
"""
function get_results(file::AbstractString)
    data = read_data(file)
    firstpart, secondpart = split.(data, ":")
    kwargs = Dict(
        Symbol(firstpart[1]) => tryparse(Int64, firstpart[2]),
        Symbol(secondpart[1]) => tryparse(Int64, secondpart[2]))
    Result(; kwargs...)
end


"""
Checks the result and returns the corresponding string.
"""
function get_solve_str(res)
    if ismissing(res)
        return "Not solved"
    end
    return res ? "Passed" : "Failed"
end

"""
Solves a `Day` directory and checks if the results are correct
"""
function solve(path::AbstractString)
    ispath(path) || error("Path $path not found.")
    name = splitpath(path)[end]
    print("Solving $name...")
    file = joinpath(path, "$name.txt")
    sym = Symbol(name)
    isdefined(AdventOfCode, sym) || return missing
    day = eval(sym)
    p1 = day(FirstPart(file))
    p2 = day(SecondPart(file))
    res1 = main(p1)
    res2 = main(p2)
    result = Result(res1, res2)

    result_file = joinpath(path, "Result.txt")
    expected_result = get_results(result_file)
    res1, res2 = check_results(expected_result, result)
    s1 = get_solve_str(res1)
    s2 = get_solve_str(res2)

    print("Part 1: $s1, ")
    print("Part 2: $s2")
    if !ismissing(res1) && !ismissing(res2) && (res1 && res2)
        println("\t Good Job.")
    else
        println()
    end
    nothing
end

"""
Reads in all `Day` directories and calls solve on each of them.
"""
function solve()
    dirs = readdir("input", join=true)
    for dir in dirs
        ismissing(solve(dir)) && continue
    end
end


"""
Parses a string of space separated numbers into a `Vector{Int64}`
"""
parse_numbers_string(nums::AbstractString) = parse.(Int64, split(nums))


"""
Converts a `AbstractString` into a `Vector{AbstractChar}`
"""
function convert_to_chars(str::AbstractString)
    ret = Vector{Char}(undef, length(str))
    for i in eachindex(str)
        ret[i] = str[i]
    end
    ret
end

input = joinpath(pwd(), "input")
srcdir = joinpath(pwd(), "src")

modulefile = joinpath(srcdir, "AdventOfCode.jl")
open(modulefile, "w") do f
    println(f, "module AdventOfCode")
    println(f)
    println(f, "include(\"utils.jl\")")
    println(f, "export FirstPart, SecondPart")
    println(f)
end

for i in 1:25
    day = "Day$(lpad(i, 2, "0"))"

    open(modulefile, "a") do f
        println(f, "include(\"$(day).jl\")")
    end
    srcfile = joinpath(srcdir, "$day.jl")
    isfile(srcfile) && continue
    open(srcfile, "w") do f
        println(f, "struct $day{P<:AbstractPart} <: AbstractDay")
        println(f, "\tpart::P")
        println(f, "end")
        println(f)
        println(f, "function main(day::$day{FirstPart{T}}) where {T<:AbstractString}")
        println(f, "end")
        println(f)
        println(f, "function main(day::$day{SecondPart{T}}) where {T<:AbstractString}")
        println(f, "end")
    end
    directory = joinpath(input, day)
    file1 = joinpath(input, directory, "$day.txt")
    file2 = joinpath(input, directory, "Result.txt")
    file3 = joinpath(input, directory, "Sample.txt")
    if isdir(directory)
        continue
    end
    mkdir(directory)
    touch(file1)
    touch(file2)
    open(file2, "w") do f
        println(f, "FirstPart: ")
        println(f, "SecondPart: ")
    end
    touch(file3)
end

open(modulefile, "a") do f
    println(f, "export solve")
    println(f)
    println(f, "end")
end
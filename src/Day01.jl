struct Day01{P<:AbstractPart} <: AbstractDay
    part::P
end


const STRS::Vector{String} = ["one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "zero"]
const VALS::Vector{Int64} = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0]

"""
Each occurence of a string representation of a number needs to be converted.
"twone" converts to "21"
Start with an empty `check string` `s`.
Add the next character from the `input string` `line` to the `check string`.
Check if the `check string` contains one of the string representations of numbers.
If not continue building up the `check string` with additional characters.
If an occurence is found, get the index of the occurence in the `STRS` Vector and replace the string_representation 
with the number in the `check_string` `s`.
Returns the `updated_string` as well as the `index + 1` of the starting character of the number string representation.
Combined with the function `convert` in which the returned string gets integrated into the original `line`, the first character of 
the string representation gets converted into its number representation.
If no more string representations are found, returns the original line and the length of the line.
"""
function findnumber(line::AbstractString)
    s = ""
    for (idx, c) in enumerate(line)
        s *= c
        flag = findfirst(occursin.(STRS, s))
        if !isnothing(flag)
            string_representation = STRS[flag]
            number = VALS[flag]
            updated_string = replace(s, string_representation => number)
            wordlength = length(STRS[flag])
            return (updated_string, idx - (wordlength - 1))
        end
    end
    return line, length(line)
end

"""
Gradually replaces all starting characters of string representations of numbers with its numerical representation.
Breaks out of the `while`-loop if the length of the line is returned from `convert`.
Returns the converted line.

##################################
Example: 

    line = "qstwonepcd3twosixrmcnxhfzv"

    julia> res, i = findnumber(line)
    ("qs2", 3)

    julia> line = res * line[i+1:end]
    "qs2wonepcd3twosixrmcnxhfzv"

    julia> res, i = findnumber(line)
    ("qs2w1", 5)

    julia> line = res * line[i+1:end]
    "qs2w1nepcd3twosixrmcnxhfzv"

    julia> res, i = findnumber(line)
    ("qs2w1nepcd32", 12)

    julia> line = res * line[i+1:end]
    "qs2w1nepcd32wosixrmcnxhfzv"

    julia> res, i = findnumber(line)
    ("qs2w1nepcd32wo6", 15)

    julia> line = res * line[i+1:end]
    "qs2w1nepcd32wo6ixrmcnxhfzv"

    julia> res, i = findnumber(line)
    ("qs2w1nepcd32wo6ixrmcnxhfzv", 26)

    julia> line = res * line[i+1:end]
    "qs2w1nepcd32wo6ixrmcnxhfzv"

############################
"""
function convert(line::AbstractString)
    i = 0
    while i < length(line)
        res, i = findnumber(line)
        line = res * line[i+1:end]
    end
    return line
end

"""
Calls `convert` on each `line` in vector `data` and mutates `data` to contain the result.
"""
function convert!(day::Day01)
    data = day.part.data
    for (idx, line) in enumerate(data)
        data[idx] = convert(line)
    end
end

"""
Find all indices of numbers in numeric representation in each line of `data`.
Select only the found characters from `line` and combine them as the string of a number.
Select the first and last character of this string representation of the number and combine them as the string of a two-digit number.
Parse them into an integer and `push!` them into the result vector.
Return the sum of all the numbers.
"""
function calculate_calibration(day::Day01)
    data = day.part.data
    nums = Int64[]
    for line in data

        idxs = findall(c -> isdigit(c), line)
        nums_str = line[idxs]
        first_and_last_num_str = nums_str[[1, end]]
        num = parse(Int64, first_and_last_num_str)
        push!(nums, num)
    end
    sum(nums)
end

"""
Find the first and last digit in the string and read them as a two-digit number.
Sum up all the two digit numbers.
"""
function main(day::Day01{FirstPart{S}}) where {S<:AbstractString}
    calculate_calibration(day)
end

"""
Convert strings representing numbers (e.g.: "one", "two", "three", ... "nine") into their respective digit representation.
Find the first and last digit in the string and read them as a two-digit number.
Sum up all the two digit numbers.
"""
function main(day::Day01{SecondPart{S}}) where {S<:AbstractString}
    convert!(day)
    calculate_calibration(day)
end

nothing

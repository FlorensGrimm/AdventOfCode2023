seeds_ranges = [1848591090 462385043 2611025720 154883670 1508373603 11536371 3692308424 16905163 1203540561 280364121 3755585679 337861951 93589727 738327409 3421539474 257441906 3119409201 243224070 50985980 7961058]

### seed-to-soil
mappings = [
    range(start=98, length=2) => range(start=50, length=2)
    range(start=50, length=48) => range(start=52, length=48)
]
ret = []
while length(seeds_ranges) != 0
    ids = popfirst!(seeds_ranges)
    ret_ids = []
    for mapping in mappings
        r1, r2 = mapping
        if in(ids.start, r1) && in(ids.stop, r1)
            f = searchsortedfirst(r1, ids.start)
            l = searchsortedlast(r1, ids.stop)
            append!(ret_ids, [r2[f]:r2[l]])
            ids = nothing
            break
        end
        if !in(ids.start, r1) && in(ids.stop, r1)
            f = searchsortedfirst(r1, r1.start)
            stop_idx = searchsortedfirst(ids, r1.start)
            l = searchsortedlast(r1, ids[end])
            append!(ret_ids, [r2[f]:r2[l]])
            ids = ids[1]:ids[stop_idx-1]
        end
        if in(ids.start, r1) && !in(ids.stop, r1)
            f = searchsortedfirst(r1, ids[1])
            start_idx = searchsortedfirst(ids, r1.stop)
            l = searchsortedlast(r1, r1.stop)
            append!(ret_ids, [r2[f]:r2[l]])
            ids = ids[start_idx+1]:ids[end]
        end
    end
    isnothing(ids) ? nothing : push!(ret_ids, ids)
    append!(ret, [elem for elem in Set(ret_ids)])
end
ret
seeds_ranges = deepcopy(ret)



### soil-to-fertilizer
mappings = [
    range(start=15, length=37) => range(start=0, length=37)
    range(start=52, length=2) => range(start=37, length=2)
    range(start=0, length=15) => range(start=39, length=15)
]

ret = []
while length(seeds_ranges) != 0
    ids = popfirst!(seeds_ranges)
    ret_ids = []

    for mapping in mappings
        r1, r2 = mapping
        if in(ids.start, r1) && in(ids.stop, r1)



            f = searchsortedfirst(r1, ids.start)
            l = searchsortedlast(r1, ids.stop)
            append!(ret_ids, [r2[f]:r2[l]])
            ids = nothing
            break

        end
        if !in(ids.start, r1) && in(ids.stop, r1)



            f = searchsortedfirst(r1, r1.start)
            stop_idx = searchsortedfirst(ids, r1.start)
            l = searchsortedlast(r1, ids[end])
            append!(ret_ids, [r2[f]:r2[l]])
            ids = ids[1]:ids[stop_idx-1]

        end
        if in(ids.start, r1) && !in(ids.stop, r1)



            f = searchsortedfirst(r1, ids[1])
            start_idx = searchsortedfirst(ids, r1.stop)
            l = searchsortedlast(r1, r1.stop)
            append!(ret_ids, [r2[f]:r2[l]])
            ids = ids[start_idx+1]:ids[end]

        end
    end
    isnothing(ids) ? nothing : push!(ret_ids, ids)




    append!(ret, [elem for elem in Set(ret_ids)])
end

seeds_ranges = deepcopy(ret)




### fertilizer-to-water
mappings = [
    range(start=53, length=8) => range(start=49, length=8)
    range(start=11, length=42) => range(start=0, length=42)
    range(start=0, length=7) => range(start=42, length=7)
    range(start=7, length=4) => range(start=57, length=4)
]
ret = []
while length(seeds_ranges) != 0
    ids = popfirst!(seeds_ranges)
    ret_ids = []

    for mapping in mappings
        r1, r2 = mapping
        if in(ids.start, r1) && in(ids.stop, r1)



            f = searchsortedfirst(r1, ids.start)
            l = searchsortedlast(r1, ids.stop)
            append!(ret_ids, [r2[f]:r2[l]])

            ids = nothing
            break
        end
        if !in(ids.start, r1) && in(ids.stop, r1)



            f = searchsortedfirst(r1, r1.start)
            stop_idx = searchsortedfirst(ids, r1.start)
            l = searchsortedlast(r1, ids[end])
            append!(ret_ids, [r2[f]:r2[l]])
            ids = ids[1]:ids[stop_idx-1]

        end
        if in(ids.start, r1) && !in(ids.stop, r1)



            f = searchsortedfirst(r1, ids[1])
            start_idx = searchsortedfirst(ids, r1.stop)
            l = searchsortedlast(r1, r1.stop)
            append!(ret_ids, [r2[f]:r2[l]])
            ids = ids[start_idx+1]:ids[end]

        end
    end
    isnothing(ids) ? nothing : push!(ret_ids, ids)




    append!(ret, [elem for elem in Set(ret_ids)])
end

#=
ids = range(47, 59)
r1 = range(53, 60)
r2 = range(84, length=length(r1))
f = searchsortedfirst(r1, r1.start)
stop_idx = searchsortedfirst(ids, r1.start)
l = searchsortedlast(r1, ids[end])
append!(ret_ids, [ids[1]:ids[stop_idx-1], r2[f]:r2[l]])

ids = range(57, length=13)
r1 = range(53, 60)
r2 = range(49, length=length(r2))
f = searchsortedfirst(r1, ids[1])
start_idx = searchsortedfirst(ids, r1.stop)
l = searchsortedlast(r1, r1.stop)
append!(ret_ids, [r2[f]:r2[l], ids[start_idx+1]:ids[end]])
=#

seeds_ranges = deepcopy(ret)



### water-to-light
mappings = [
    range(start=18, length=7) => range(start=88, length=7)
    range(start=25, length=70) => range(start=18, length=70)
]
ret = []
while length(seeds_ranges) != 0
    ids = popfirst!(seeds_ranges)
    ret_ids = []

    for mapping in mappings
        r1, r2 = mapping
        if in(ids.start, r1) && in(ids.stop, r1)



            f = searchsortedfirst(r1, ids.start)
            l = searchsortedlast(r1, ids.stop)
            append!(ret_ids, [r2[f]:r2[l]])

            ids = nothing
            break
        end
        if !in(ids.start, r1) && in(ids.stop, r1)



            f = searchsortedfirst(r1, r1.start)
            stop_idx = searchsortedfirst(ids, r1.start)
            l = searchsortedlast(r1, ids[end])
            append!(ret_ids, [r2[f]:r2[l]])
            ids = ids[1]:ids[stop_idx-1]

        end
        if in(ids.start, r1) && !in(ids.stop, r1)



            f = searchsortedfirst(r1, ids[1])
            start_idx = searchsortedfirst(ids, r1.stop)
            l = searchsortedlast(r1, r1.stop)
            append!(ret_ids, [r2[f]:r2[l]])
            ids = ids[start_idx+1]:ids[end]

        end
    end
    isnothing(ids) ? nothing : push!(ret_ids, ids)




    append!(ret, [elem for elem in Set(ret_ids)])
end
seeds_ranges = deepcopy(ret)



### light-to-temperature
mappings = [
    range(start=77, length=23) => range(start=45, length=23)
    range(start=45, length=19) => range(start=81, length=19)
    range(start=64, length=13) => range(start=68, length=13)
]
ret = []
while length(seeds_ranges) != 0
    ids = popfirst!(seeds_ranges)
    ret_ids = []

    for mapping in mappings
        r1, r2 = mapping
        if in(ids.start, r1) && in(ids.stop, r1)



            f = searchsortedfirst(r1, ids.start)
            l = searchsortedlast(r1, ids.stop)
            append!(ret_ids, [r2[f]:r2[l]])

            ids = nothing
            break
        end
        if !in(ids.start, r1) && in(ids.stop, r1)



            f = searchsortedfirst(r1, r1.start)
            stop_idx = searchsortedfirst(ids, r1.start)
            l = searchsortedlast(r1, ids[end])
            append!(ret_ids, [r2[f]:r2[l]])
            ids = ids[1]:ids[stop_idx-1]

        end
        if in(ids.start, r1) && !in(ids.stop, r1)



            f = searchsortedfirst(r1, ids[1])
            start_idx = searchsortedfirst(ids, r1.stop)
            l = searchsortedlast(r1, r1.stop)
            append!(ret_ids, [r2[f]:r2[l]])
            ids = ids[start_idx+1]:ids[end]

        end
    end
    isnothing(ids) ? nothing : push!(ret_ids, ids)




    append!(ret, [elem for elem in Set(ret_ids)])
end
seeds_ranges = deepcopy(ret)



mappings = [
    range(start=69, length=1) => range(start=0, length=1)
    range(start=0, length=69) => range(start=1, length=69)
]
ret = []
while length(seeds_ranges) != 0
    ids = popfirst!(seeds_ranges)
    ret_ids = []

    for mapping in mappings
        r1, r2 = mapping
        if in(ids.start, r1) && in(ids.stop, r1)





            first_val = ids.start
            last_val = ids.stop
            first_val = ids.start
            last_val = ids.stop
            f = searchsortedfirst(r1, first_val)
            l = searchsortedlast(r1, last_val)
            append!(ret_ids, [r2[f]:r2[l]])
            ids = nothing
            break

        end
        if !in(ids.start, r1) && in(ids.stop, r1)





            first_val = r1.start
            last_val = ids.stop
            f = searchsortedfirst(r1, r1.start)
            stop_idx = searchsortedfirst(ids, r1.start)
            l = searchsortedlast(r1, ids[end])
            append!(ret_ids, [r2[f]:r2[l]])
            ids = ids[1]:ids[stop_idx-1]

        end
        if in(ids.start, r1) && !in(ids.stop, r1)





            f = searchsortedfirst(r1, ids[1])
            start_idx = searchsortedfirst(ids, r1.stop)
            l = searchsortedlast(r1, r1.stop)
            append!(ret_ids, [r2[f]:r2[l]])
            ids = ids[start_idx+1]:ids[end]

        end
    end
    isnothing(ids) ? nothing : push!(ret_ids, ids)




    append!(ret, [elem for elem in Set(ret_ids)])
end
seeds_ranges = deepcopy(ret)



### humidity-to-location
mappings = [
    range(start=56, length=37) => range(start=60, length=37)
    range(start=93, length=4) => range(start=56, length=4)
]
ret = []
while length(seeds_ranges) != 0
    ids = popfirst!(seeds_ranges)
    ret_ids = []

    for mapping in mappings
        r1, r2 = mapping
        if in(ids.start, r1) && in(ids.stop, r1)



            f = searchsortedfirst(r1, ids.start)
            l = searchsortedlast(r1, ids.stop)
            append!(ret_ids, [r2[f]:r2[l]])

            ids = nothing
            break
        end
        if !in(ids.start, r1) && in(ids.stop, r1)



            f = searchsortedfirst(r1, r1.start)
            stop_idx = searchsortedfirst(ids, r1.start)
            l = searchsortedlast(r1, ids[end])
            append!(ret_ids, [r2[f]:r2[l]])
            ids = ids[1]:ids[stop_idx-1]

        end
        if in(ids.start, r1) && !in(ids.stop, r1)



            f = searchsortedfirst(r1, ids[1])
            start_idx = searchsortedfirst(ids, r1.stop)
            l = searchsortedlast(r1, r1.stop)
            append!(ret_ids, [r2[f]:r2[l]])
            ids = ids[start_idx+1]:ids[end]

        end
    end
    isnothing(ids) ? nothing : push!(ret_ids, ids)




    append!(ret, [elem for elem in Set(ret_ids)])
end
seeds_ranges = deepcopy(ret)



minimum(seeds_ranges)
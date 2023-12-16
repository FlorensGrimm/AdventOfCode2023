seeds_ranges = [range(start=79, length=14), range(start=55, length=13)]
### seed-to-soil
mappings = [
     range(1699909104 ,length=39566623) =>range(start=3305253869,length= 39566623)
     range(1130725752 ,length=384459310) =>range(start=3344820492,length= 384459310)
     range(1739475727 ,length=60572442) =>range(start=3244681427,length= 60572442)
     range(1800048169 ,length=868898709) =>range(start=951517531,length= 868898709)
     range(951517531 ,length=179208221) =>range(start=1820416240,length= 179208221)
     range(2668946878 ,length=219310925) =>range(start=1999624461,length= 219310925)
     range(1515185062 ,length=184724042) =>range(start=3729279802,length= 184724042)
     range(2898481077 ,length=1015522767) =>range(start=2218935386,length= 1015522767)
     range(2888257803 ,length=10223274) =>range(start=3234458153,length= 10223274)
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
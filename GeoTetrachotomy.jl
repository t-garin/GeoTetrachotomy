using ArgCheck
using BenchmarkTools
import Base: bitstring
using Plots
# using DataStructures: DiBitVector
# struct Tetra
#     # DiBitVector to represent the tetrachotomy
#     dbv::DiBitVector
# end

struct LatLon
    # latitude
    lat::Number
    # longitude
    lon::Number
end

struct Tetra
    #webit: West-East bit
    # 1 bit bitvector, not bool cause
    # use 8bit by default
    webit::BitVector
    lat::BitVector
    lon::BitVector
end

function bitstring(tt::Tetra)
    latbit = replace(bitstring(tt.lat), " " => "")
    lonbit = replace(bitstring(tt.lon), " " => "")
    return bitstring(tt.webit)*join([blat*blon for (blat, blon) in zip(latbit, lonbit)])
end

function bitstring(ll::LatLon)
    bitstring(ll.lat)*bitstring(ll.lon)
end

function _dicho(value::Number, n::Int, lmin::Number, lmax::Number)
    dicho = BitVector(undef, n)
    for i in 1:n
        lmid = mean((lmin, lmax))
        if lmin <= value <= lmid
            dicho[i] = 0
            # new upper bound is now the mid
            lmax = lmid
        else
            dicho[i] = 1
            # new lower bound is now the mid
            lmin = lmid
        end 
    end
    return dicho
end

const NSrng = (-90, 90)
const Whemi = (-180, 0)
const Ehemi = (0, +180)
lat_dicho(value:: Number, n:: Int) = _dicho(value, n, NSrng...)
lonWdicho(value:: Number, n:: Int) = _dicho(value, n, Whemi...)
lonEdicho(value:: Number, n:: Int) = _dicho(value, n, Ehemi...)

function isEast(lon::Number)::Bool
    if Whemi[1] ≤ lon ≤ Whemi[2]
        return false
    elseif Ehemi[1] ≤ lon ≤ Ehemi[2]
        return true
    else
        @error "lon is neither in Whemi nor in Ehemi"
    end
end

function dicho(ll::LatLon, precision::Int)::Tetra
    webit = BitVector(undef, 1)
    if isEast(ll.lon)
        webit[1] = 1 
        return Tetra(webit, lat_dicho(ll.lat, precision), lonEdicho(ll.lon, precision))
    else 
        webit[1] = 0
        return Tetra(webit, lat_dicho(ll.lat, precision), lonWdicho(ll.lon, precision))
    end
    
end

function getlatlon(tt::Tetra)::LatLon
    lat, lon = 0, 0
 
    for i in 1:length(tt.lat)
        step = 45/(2^(i-1))
        tt.lat[i] == 1 ? lat += step : lat -= step 
    end

    for i in 1:length(tt.lon)
        step = 45/(2^(i-1))
        tt.lon[i] == 1 ? lon += step : lon -= step 
    end

    tt.webit == 1 ? lon -= 90 : lon += 90

    return LatLon(lat, lon)
end
randlat(n::Int)::Vector{Float64} = (rand(n).-0.5) * 180
randlon(n::Int)::Vector{Float64} = (rand(n).-0.5) * 360

randLatLon() = LatLon(randlat(1)[1], randlon(1)[1])


distance(t1::Tuple, t2::Tuple) = sqrt((t1[1]-t2[1])^2 + (t1[2]-t2[2])^2)
distance(ll1::LatLon, ll2::LatLon) = distance((ll1.lat, ll1.lon), (ll2.lat, ll2.lon))

function test(npoints::Int, precision::Int)
    latlon = [LatLon(lat, lon) for (lat, lon) in zip(randlat(npoints), randlon(npoints))]
    tetras = [dicho(ll, precision) for ll in latlon]
    dist = Vector(undef, npoints)
    for (ll, tt, i) in zip(latlon, tetras, 1:npoints)
        @show ll.lat, ll.lon
        print("\n Latlon ", bitstring(ll), "\n $(length(bitstring(ll))) bits")
        print("\n Tetra  ", bitstring(tt), "\n $(length(bitstring(tt))) bits\n\n")

        newll = getlatlon(tt)
        @show newll.lat, newll.lon
        @show distance(ll, newll)
        dist[i] = distance(ll, newll)
        
    end
    return dist
end

d = test(100, 8)
plot(sort(d))
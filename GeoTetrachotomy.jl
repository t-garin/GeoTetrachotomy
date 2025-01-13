using ArgCheck
using BenchmarkTools
import Base: bitstring

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
    bitstring(tt.webit)*join([blat*blon for (blat, blon) in zip(bitstring(tt.lat), bitstring(tt.lon))])
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
    return dicho#, abs(lmax - lmin)
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
    else 
        webit[0] = 0
    end
    Tetra(webit, lat_dicho(ll.lat, precision), lonEdicho(ll.lon, precision))
end


function test(npoints::Int, precision::Int)
    randlat(n::Int)::Vector{Float64} = (rand(n).-0.5) * 180
    randlon(n::Int)::Vector{Float64} = (rand(n).-0.5) * 360

    latlon = [LatLon(lat, lon) for (lat, lon) in zip(randlat(npoints), randlon(npoints))]
    tetras = [dicho(ll, precision) for ll in latlon]
    return tetras[1]
    for (ll, tt) in zip(latlon, tetras)
        @show ll.lat, ll.lon
        print("\n Latlon ", bitstring(ll), " bits")
        print("\n Tetra  ", bitstring(tt), " bits")
    end
end
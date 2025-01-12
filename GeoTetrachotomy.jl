using BenchmarkTools
using DataStructures: DiBitVector

struct Tetra
    # DiBitVector to represent the tetrachotomy
    dbv::DiBitVector
end

struct TetraBV
    lat::BitVector
    lon::BitVector
end

struct TetraVB
    lat::Vector{Bool}
    lon::Vector{Bool}
end

"geopoint representation using latlon"
struct LatLon
    # latitude
    lat::Number
    # longitude
    lon::Number
end

ll = LatLon(Float64(0), Float64(0))

a = [0,1,1,0,0,1,0,1,0]
b = [1,0,1,0,0,1,0,1,0]

bv = TetraBV(a, b)
vb = TetraVB(a, b)

#check different sizes
varinfo()
sizeof(vb)
sizeof(bv)

function _get_dicho(value::Number, n::Int, lmin::Number, lmax::Number)
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
    return dicho, (lmin, lmax)
end

latdicho(value:: Number, n:: Int) = _get_dicho(value, n,  -90,  90)
londicho(value:: Number, n:: Int) = _get_dicho(value, n, -180, 180)

randlat(n::Int) = (rand(n).-0.5) * 180
randlon(n::Int) = (rand(n).-0.5) * 360
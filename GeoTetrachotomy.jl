using BenchmarkTools

# using DataStructures: DiBitVector
# struct Tetra
#     # DiBitVector to represent the tetrachotomy
#     dbv::DiBitVector
# end

struct Tetra
    #webit: West-East bit
    webit::Bool
    lat::BitVector
    lon::BitVector
end

struct LatLon
    # latitude
    lat::Number
    # longitude
    lon::Number
end

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
    return dicho, abs(lmax - lmin)
end

latdicho(value:: Number, n:: Int) = _get_dicho(value, n,  -90,  90)
londicho(value:: Number, n:: Int) = _get_dicho(value, n, -180, 180)

randlat(n::Int)::Vector{Float16} = (rand(n).-0.5) * 180
randlon(n::Int)::Vector{Float16} = (rand(n).-0.5) * 360

function dicho(ll::LatLon, precision::Int)::TetraBV
    return TetraBV(
        latdicho(ll.lat, precision)[1],
        londicho(ll.lon, precision)[1]
    )
end

function delta(ll::LatLon, precision::Int)
    return (latdicho(ll.lat, precision)[2], londicho(ll.lon, precision)[2])
end
function test(npoints::Int, precision::Int)
    latlon = [LatLon(lat, lon) for (lat, lon) in zip(randlat(npoints), randlon(npoints))]
    tetras = [dicho(ll, precision) for ll in latlon]
    deltas = [delta(ll, precision) for ll in latlon]
    
    pprint(ll::LatLon) = print(length(bitstring(ll.lat)), " & ", length(bitstring(ll.lon)), " bits")
    pprint(tt::TetraBV) = print(length(bitstring(tt.lat)), " & ", length(bitstring(tt.lon)), " bits")

    for (ll, tt, ds) in zip(latlon, tetras, deltas)
        @show ll.lat, ll.lon, ds
        pprint(ll)
        print('\t')
        pprint(tt)
        print('\n')
    end
end
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
print("Size of ll: ", sizeof(ll), " bytes")
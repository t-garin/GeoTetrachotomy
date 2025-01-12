using BenchmarkTools
using DataStructures: DiBitVector

"geopoint representation using tetrachotomy"
struct Tetra
    # DiBitVector to represent the tetrachotomy
    dbv::DiBitVector
end

"geopoint representation using latlon"
struct LatLon
    # latitude
    lat::Float
    # longitude
    lon::Float
end

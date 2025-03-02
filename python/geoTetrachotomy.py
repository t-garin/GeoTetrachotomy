import numba
import geopy
import bitstring
# conda env export --no-builds | grep -v "prefix" > env.yml

type Number = float|int

class LatLon():
    
    def __init__(self, lat: Number, lon: Number) -> None:
        self.lat = lat
        self.lon = lon

    def toTetra(self, precision: int):
        """
            - ebit: east bit, 1 if in eastern hemisphere, 0 otherwise
            - x
            - y 
        """
        ebit = True if _isEast(self.lon) else False

        if _isEast(self.lon):
            ebit = True
            lonInf, lonSup = 0, 180
        else:
            ebit = False
            lonInf, lonSup = 180, 360 

        x = _getDichotomy(
            target = self.lon, precision = precision,
            inf = lonInf, sup = lonSup
        )
        y = _getDichotomy(
            target = self.lat, precision = precision, 
            inf = -90, sup = 90
        )
        return ebit, x, y
            

@numba.njit
def _isEast(lon: Number) -> bool:
    """
    Given a [0, 360[ longitude, the convention is:
        - [0,   180[ is east
        - [180, 360[ is west
    """
    if 0 <= lon < 180: 
        return True
    elif 180 <= lon < 360:
        return False
    else: 
        raise ValueError("longitude 'lon' is out of the range [0, 360[")

@numba.njit
def _getDichotomy(target: Number, precision: int, inf: Number, sup: Number) -> list[bool]:
    """
    Given a target in [inf, sup], ...
    """
    dicho = []
    for i in range(precision):
        mid = (inf + sup)/2
        
        if inf <= target < mid: 
            dicho.append(False) # bit = 0
            sup = mid # new upper bound is now mid
        
        elif mid < target <= sup:
            dicho.append(True) # bit = 1
            inf = mid # new lower bound is now mid

        # for now, if exactly equal to mid, bit is 1
        # this should be changed in the future
        elif target == mid:
            dicho.append(True) # bit = 1
            inf = mid # new lower bound is now mid
        
        else: 
            raise ValueError("'target' is not in range [inf, sup]")

    return dicho


# class Tetra():

#     def __init__(self, webit, x, y) -> None:
#         ...

#     def toLatLon(self):
#         ...


if __name__ == '__main__':
    print(_isEast(179))
    print(bitstring.BitArray(_getDichotomy(57.8999, 25, 0, 90)))

    ll = LatLon(46.66, 8.90)
    print(ll.toTetra(25))
import numba
import geopy
import bitstring
# conda env export --no-builds | grep -v "prefix" > env.yml

type Number = float|int

class LatLon():
    
    def __init__(self, lat: Number, lon: Number) -> None:
        self.lat = lat
        self.lon = lon

    def __repr__(self):
        return f"({self.lat}, {self.lon})"

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
        return Tetra(ebit, x, y)

class Tetra():

    def __init__(self, ebit: bool, x: list[bool], y: list[bool]) -> None:
        self.ebit = ebit
        self.x = x 
        self.y = y
        
        self.xy = [
            item for pair in zip(self.x, self.y)
            for item in pair
        ]
        
        self.bitArray = bitstring.BitArray(
            [self.ebit] + self.xy
        )

        self.base4repr = self._base4repr()

    def __repr__(self) -> None:
        return f"{self.bitArray.bin} | {self.base4repr}"

    def _base4repr(self) -> None:
        base4 = "+" if self.ebit else "-"
        for x, y in zip(self.x, self.y):
            if x == False and y == False:
                base4 += "0" # 00
            elif x == False and y == True:
                base4 += "1" # 01
            elif x == True and y == False:
                base4 += "2" # 10
            elif x == True and y == True:
                base4 += "3" # 11
            else:
                raise ValueError("")
        return base4

    def toLatLon(self):
        lat, lon = 0, 0
        lon += 90 if self.ebit else -90
        
        for i, bit in enumerate(self.x):
            step = 45/(2**i)
            lon += step if bit else -step
        
        for i, bit in enumerate(self.y):
            step = 45/(2**i)
            lat += step if bit else -step

        return LatLon(lat, lon)

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



if __name__ == '__main__':
    ll = LatLon(46.66, 8.90)
    tt = ll.toTetra(8)
    
    print(tt)
    print(tt.toLatLon())

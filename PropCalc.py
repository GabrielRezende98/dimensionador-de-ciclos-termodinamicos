import sys
from CoolProp.CoolProp import PropsSI


a = [n for n in sys.argv]

def response():
    try:
        return PropsSI(a[1], a[2], float(a[3]), a[4], float(a[5]), a[6])
    except:
        return 0
print(response())

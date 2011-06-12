import sys
sys.path.insert(0, './obj')

import os
import cydwarf
dw = cydwarf.Dwarf(os.open('/home/proger/dev/cwm/cwm', 0))

import dwarf

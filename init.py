import sys
sys.path.insert(0, './obj')

import os
import libdwarf
dw = libdwarf.Dwarf(os.open('/home/proger/dev/cwm/obj/cwm', 0))

import dwarf

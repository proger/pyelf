#!/usr/bin/env python

import sys
import os
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '../obj'))

import libdwarf

if __name__ == '__main__':
    assert len(sys.argv) > 1
    fd = os.open(sys.argv[1], 0)
else:
    fd = os.open('/netbsd', 0)

dwarf = libdwarf.Dwarf(fd)
print 'compilation units: %d' % len(dwarf.cu())

def dieprint(die, level):
    print '%s%s' % (' ' * level, repr(die))

def dietraverse(die, callback, level=0):
    callback(die, level)
    for child in die.children:
        dietraverse(child, callback, level + 1)

if __name__ == '__main__':
    dwarf.cu_foreach(lambda dw, cu: dietraverse(cu, dieprint))
    os.close(fd)

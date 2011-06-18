# Copyright (c) 2011 Vladimir Kirillov <proger@wilab.org.ua>
# 
# Permission to use, copy, modify, and distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
# 
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

import sys
import cydwarf

class DwarfObject(object):
    def __init__(self, die):
        self.die = die

    def __repr__(self):
        return '<%s: %s>' % (self.__class__.__name__, repr(self.die))

class Type(DwarfObject):
    tags = (
        'DW_TAG_array_type',
        'DW_TAG_class_type',
        'DW_TAG_enumeration_type',
        'DW_TAG_reference_type',
        'DW_TAG_string_type',
        'DW_TAG_subroutine_type',
        'DW_TAG_ptr_to_member_type',
        'DW_TAG_set_type',
        'DW_TAG_subrange_type',
        'DW_TAG_base_type',
        'DW_TAG_const_type',
        'DW_TAG_packed_type',
        'DW_TAG_thrown_type',
        'DW_TAG_interface_type',
        'DW_TAG_unspecified_type',
        'DW_TAG_shared_type',
        'DW_TAG_rvalue_reference_type',
        'DW_TAG_typedef',
    )

    @property
    def real(self):
        return self

    @property
    def name(self):
        return self.die.name

    @property
    def size(self):
        return self.die.attributes['DW_AT_byte_size'][1]

class ConcealedType(Type):
    tags = (
        'DW_TAG_volatile_type',
        'DW_TAG_restrict_type',
    )

    @property
    def real(self):
        return objectify(self.die.attributes['DW_AT_type'][1])

class PointerType(Type):
    tags = (
        'DW_TAG_pointer_type',
    )

    @property
    def name(self):
        return 'void *'

class ArrayType(Type):
    tags = (
        'DW_TAG_array_type',
    )

    @property
    def size(self):
        return self.die.children[0].attributes['DW_AT_upper_bound'][1] + 1

class Struct(Type):
    tags = (
        'DW_TAG_structure_type',
        'DW_TAG_union_type',
    )

    def __init__(self, *args, **kw):
        super(Struct, self).__init__(*args, **kw)
        self._members_dict = dict((name, (type, offset)) for offset, type, name in self.members)

    @property
    def members(self):
        # (offset, type, name)
        return [
            (c.attributes['DW_AT_data_member_location'][1],
                objectify(c.attributes['DW_AT_type'][1]).real,
                c.name)
            for c in filter(lambda c: c.tag == 'DW_TAG_member', self.die.children)
        ]

    def member(self, name):
        return self._members_dict.get(name)

types = (Type, ConcealedType, PointerType, ArrayType, Struct)
tagindex = reduce(lambda d, ty: dict(d.items() + [(t, ty) for t in ty.tags]), types, {})

objectify = lambda die: tagindex.get(die.tag, DwarfObject)(die)

def dieprint(die, level):
    print '%s%s' % (' ' * level, repr(die))

def locatebyname(dwarf, name):
    match = dwarf.die_foreach(lambda die, level: die if die.name == name else None)
    return objectify(match) if match else None

def locateallbyname(dwarf, name):
    matches = []
    def collect(die, level):
        if die.name == name:
            matches.append(die)
    dwarf.die_foreach(collect)
    return map(objectify, matches)

if __name__ == '__main__':
    import os
    dw = cydwarf.Dwarf(os.open('/home/proger/dev/cwm/obj/cwm', 0))

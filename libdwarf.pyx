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

from libc.stdint cimport *
from libelf cimport *
from libdwarf cimport *

# Results of calling dwarf_siblingof() depend on the internal
# state of libdwarf: you always have to 'rewind' the library
# to the matching compilation unit of the DIE being used.
#
# For efficiency reasons library users should want to do
# all required work during a single Dwarf.cu_foreach
# traversal.
#
# Do not call cu_rewind() from cu_foreach() or bad things can happen.

cdef class DIE
cdef DIE die_wrap(_dwarf, Dwarf_Die _die, object cu=None):
    cdef DIE d = DIE()
    d._dwarf = _dwarf
    d._die = _die
    d._cu = cu
    dwarf_dieoffset(d._die, &d._offset, NULL)
    return d

cdef class Dwarf:
    cdef int _fd
    cdef Elf *_elf
    cdef Dwarf_Debug _debug
    cdef DIE _cu_context

    def __cinit__(self, elf_fd):
        cdef Dwarf_Error err

        elf_version(EV_CURRENT)

        self._fd = elf_fd
        self._elf = elf_begin(self._fd, ELF_C_READ, NULL)

        if self._elf == NULL:
            raise ValueError('elf_begin')

        if dwarf_elf_init(self._elf, DW_DLC_READ, NULL, NULL,
                &self._debug, &err) != DW_DLV_OK:
            raise ValueError(_dwarf_errmsg(&err))

        self._cu_context = None

    def __dealloc__(self):
        dwarf_finish(self._debug, NULL)
        elf_end(self._elf)

    def cu_foreach(self, callback):
        cdef Dwarf_Unsigned next_offset = 0
        cdef Dwarf_Die die_cu
        cdef object ret

        while dwarf_next_cu_header_b(self._debug, NULL, NULL, NULL, NULL,
                NULL, NULL, &next_offset, NULL) == DW_DLV_OK:
            dwarf_siblingof(self._debug, NULL, &die_cu, NULL)
            self._cu_context = die_wrap(self, die_cu)
            self._cu_context._cu = self._cu_context

            ret = callback(self, self._cu_context)
            if not ret:
                return self._cu_context

        self._cu_context = None

    def cu_rewind(self, cu):
        cdef DIE ccu = <DIE>cu
        test = lambda dw, x: not <DIE>cu == <DIE>x

        if <DIE>self.cu_foreach(test) == <DIE>cu:
            return True

        # may be needed if state is already touched
        if <DIE>self.cu_foreach(test) == <DIE>cu:
            return True
        return False

    def cu(self):
        cdef list culist = []
        self.cu_foreach(lambda dw, x: culist.append(x) or True)
        return culist

    cdef die_context_prepare(self, DIE die):
        if die._cu._offset != self._cu_context._offset:
            self.cu_rewind(die._cu)

        cdef Dwarf_Error err
        if dwarf_offdie(self._debug, die._offset,
                &die._die, &err) != DW_DLV_OK:
            raise ValueError(_dwarf_errmsg(&err))

    cdef object retwrap(self, Dwarf_Die obj, int ret, Dwarf_Error err):
        if ret == DW_DLV_NO_ENTRY:
            return None
        elif ret != DW_DLV_OK:
            raise ValueError(_dwarf_errmsg(&err))
        return die_wrap(self, obj, self._cu_context)

    cdef DIE siblingof(self, DIE die):
        cdef Dwarf_Die sibling = NULL
        cdef Dwarf_Error err
        cdef int ret

        self.die_context_prepare(die)

        ret = dwarf_siblingof(self._debug, die._die if die else NULL,
                &sibling, &err)
        return self.retwrap(sibling, ret, err)

    cdef DIE childof(self, DIE die):
        cdef Dwarf_Die child = NULL
        cdef Dwarf_Error err
        cdef int ret

        self.die_context_prepare(die)

        ret = dwarf_child(die._die, &child, &err)
        return self.retwrap(child, ret, err)

cdef class DIE:
    cdef Dwarf_Die _die     # volatile across CU context changes
    cdef Dwarf _dwarf
    cdef Dwarf_Off _offset  # stable -- offset to section base
    cdef DIE _cu         # topmost parent DIE

    def __cinit__(self):
        self._dwarf = None
        self._die = NULL
        self._cu = None

    def __bool__(self):
        return self._die != NULL

    def __richcmp__(DIE self, DIE other, int op):
        #print '%d %s %s' % (op, self, other)
        if op == 2:     # __eq__
            return self._offset == other._offset
        elif op == 3:   # not __eq__
            return self._offset != other._offset
        return False

    def next_sibling(self):
        return self._dwarf.siblingof(self)

    def child(self):
        return self._dwarf.childof(self)

    property children:
        def __get__(self):
            cdef DIE child = self.child()
            cdef list children_list = []

            while child:
                children_list.append(child)
                child = child.next_sibling()
            return children_list

    property tag:
        def __get__(self):
            cdef Dwarf_Half tag
            cdef const_char_ptr tagname = NULL
            dwarf_tag(self._die, &tag, NULL)
            dwarf_get_TAG_name(tag, &tagname)

            return tagname if tagname else 'unknown tag %d' % tag

    property name:
        def __get__(self):
            cdef char *name = NULL
            dwarf_diename(self._die, &name, NULL)
            return name if name else ''

    property offset:
        def __get__(self):
            return self._offset

    def __repr__(self):
        assert bool(self), 'NULL DIE'
        return '<DIE: %s %s (offset %d)>' % (self.tag, self.name, self.offset)

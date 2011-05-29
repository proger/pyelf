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

cdef class Dwarf:
    cdef int _fd
    cdef Elf *_elf
    cdef Dwarf_Debug _debug

    def __cinit__(self, elf_fd):
        elf_version(EV_CURRENT)

        self._fd = elf_fd
        self._elf = elf_begin(self._fd, ELF_C_READ, NULL)

        if self._elf == NULL:
            raise ValueError(elf_errno())

        cdef Dwarf_Error err
        if dwarf_elf_init(self._elf, DW_DLC_READ, NULL, NULL,
                &self._debug, &err) != DW_DLV_OK:
            raise ValueError(err.err_error)

    def __dealloc__(self):
        dwarf_finish(self._debug, NULL)
        elf_end(self._elf)

    def cu_foreach(self, callback):
        cdef Dwarf_Unsigned next_offset
        cdef Dwarf_Die die_cu
        while dwarf_next_cu_header_b(self._debug, NULL, NULL, NULL, NULL,
                NULL, NULL, &next_offset, NULL) == DW_DLV_OK:
            dwarf_siblingof(self._debug, NULL, &die_cu, NULL)
            callback(self, <long>die_cu) # TODO

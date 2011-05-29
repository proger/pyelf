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

cdef extern from *:
    ctypedef char * const_char_ptr "const char *"

cdef extern from "libdwarf/libdwarf.h":
    ctypedef void *Dwarf_Debug
    ctypedef void *Dwarf_Handler    # actually a function pointer
    ctypedef void *Dwarf_Die

    ctypedef int Dwarf_Bool
    ctypedef int64_t Dwarf_Off
    ctypedef uint64_t Dwarf_Unsigned
    ctypedef uint16_t Dwarf_Half
    ctypedef uint8_t Dwarf_Small
    ctypedef int64_t Dwarf_Signed
    ctypedef uint64_t Dwarf_Addr
    ctypedef void *Dwarf_Ptr

    ctypedef struct Dwarf_Error:
        int err_error
        int err_elferror
        char *err_func
        int err_line
        char err_msg[1024]

    const_char_ptr _dwarf_errmsg(Dwarf_Error *)

    # access modes
    cdef enum:
        DW_DLC_READ = 0
        #DW_DLC_WRITE = 1
        #DW_DLC_RDWR = 2

    int dwarf_init(int fd, int mode, Dwarf_Handler errhand,
            Dwarf_Ptr errarg, Dwarf_Debug *ret, Dwarf_Error *err)

    int dwarf_elf_init(Elf *elf, int mode, Dwarf_Handler errhand,
             Dwarf_Ptr errarg, Dwarf_Debug *ret, Dwarf_Error *err)

    int dwarf_finish(Dwarf_Debug, Dwarf_Error *)

    # return values
    cdef enum:
        DW_DLV_NO_ENTRY = -1
        DW_DLV_OK = 0
        DW_DLV_ERROR = 1
        DW_DLV_BADADDR = 0
        DW_DLV_NOCOUNT = -1

    int dwarf_child(Dwarf_Die die, Dwarf_Die *ret_die, Dwarf_Error *err)
    int dwarf_siblingof(Dwarf_Debug dbg,
            Dwarf_Die die, Dwarf_Die *ret_die,
            Dwarf_Error *err)

    int dwarf_next_cu_header_b(Dwarf_Debug dbg, Dwarf_Unsigned *cu_length,
            Dwarf_Half *cu_version, Dwarf_Off *cu_abbrev_offset,
            Dwarf_Half *cu_pointer_size, Dwarf_Half *cu_offset_size,
            Dwarf_Half *cu_extension_size, Dwarf_Unsigned *cu_next_offset,
            Dwarf_Error *err)

    int dwarf_diename(Dwarf_Die, char **, Dwarf_Error *)

    int dwarf_tag(Dwarf_Die, Dwarf_Half *, Dwarf_Error *)
    int dwarf_get_TAG_name(unsigned, const_char_ptr *)

    # offset by die
    int dwarf_dieoffset(Dwarf_Die, Dwarf_Off *, Dwarf_Error *)

    # die by offset
    int dwarf_offdie(Dwarf_Debug, Dwarf_Off, Dwarf_Die *, Dwarf_Error *)


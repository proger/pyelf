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
    ctypedef void *Dwarf_Attribute

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
        DW_DLC_READ   = 0
        #DW_DLC_WRITE = 1
        #DW_DLC_RDWR  = 2

    int dwarf_init(int fd, int mode, Dwarf_Handler errhand,
            Dwarf_Ptr errarg, Dwarf_Debug *ret, Dwarf_Error *err)

    int dwarf_elf_init(Elf *elf, int mode, Dwarf_Handler errhand,
             Dwarf_Ptr errarg, Dwarf_Debug *ret, Dwarf_Error *err)

    int dwarf_finish(Dwarf_Debug, Dwarf_Error *)

    #
    # DIE: Debugging Information Entry
    #   essential nested DWARF data structure
    # 
    # contains a tag, and a set of key-value attributes
    #       key is a number
    #       value is typed by attribute form
    #   

    # return values
    cdef enum:
        DW_DLV_NO_ENTRY = -1
        DW_DLV_OK       = 0
        DW_DLV_ERROR    = 1
        DW_DLV_BADADDR  = 0
        DW_DLV_NOCOUNT  = -1

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

    int dwarf_attrlist(Dwarf_Die, Dwarf_Attribute **, Dwarf_Signed *,
            Dwarf_Error *)
    int dwarf_whatattr(Dwarf_Attribute attr, Dwarf_Half *retcode,
            Dwarf_Error *err)
    int dwarf_attr(Dwarf_Die, Dwarf_Half, Dwarf_Attribute *,
            Dwarf_Error *)
    int dwarf_get_AT_name(unsigned, const_char_ptr *)

    cdef enum Dwarf_Form_Class:
        DW_FORM_CLASS_UNKNOWN,
        DW_FORM_CLASS_ADDRESS,
        DW_FORM_CLASS_BLOCK,
        DW_FORM_CLASS_CONSTANT,
        DW_FORM_CLASS_EXPRLOC,
        DW_FORM_CLASS_FLAG,
        DW_FORM_CLASS_LINEPTR,
        DW_FORM_CLASS_LOCLISTPTR,
        DW_FORM_CLASS_MACPTR,
        DW_FORM_CLASS_RANGELISTPTR,
        DW_FORM_CLASS_REFERENCE,
        DW_FORM_CLASS_STRING

    int dwarf_whatform(Dwarf_Attribute, Dwarf_Half *, Dwarf_Error *)
    int dwarf_get_FORM_name(unsigned, const_char_ptr *)

    int dwarf_attrval_flag(Dwarf_Die, Dwarf_Half, Dwarf_Bool *, Dwarf_Error *)
    int dwarf_attrval_signed(Dwarf_Die, Dwarf_Half, Dwarf_Signed *, Dwarf_Error *)
    int dwarf_attrval_string(Dwarf_Die, Dwarf_Half, const_char_ptr *, Dwarf_Error *)
    int dwarf_attrval_unsigned(Dwarf_Die, Dwarf_Half, Dwarf_Unsigned *, Dwarf_Error *)

    # offset by die
    int dwarf_dieoffset(Dwarf_Die, Dwarf_Off *, Dwarf_Error *)
    # die by offset
    int dwarf_offdie(Dwarf_Debug, Dwarf_Off, Dwarf_Die *, Dwarf_Error *)

cdef enum:
    DW_FORM_addr         = 0x01
    DW_FORM_block2       = 0x03
    DW_FORM_block4       = 0x04
    DW_FORM_data2        = 0x05
    DW_FORM_data4        = 0x06
    DW_FORM_data8        = 0x07
    DW_FORM_string       = 0x08
    DW_FORM_block        = 0x09
    DW_FORM_block1       = 0x0a
    DW_FORM_data1        = 0x0b
    DW_FORM_flag         = 0x0c
    DW_FORM_sdata        = 0x0d
    DW_FORM_strp         = 0x0e
    DW_FORM_udata        = 0x0f
    DW_FORM_ref_addr     = 0x10
    DW_FORM_ref1         = 0x11
    DW_FORM_ref2         = 0x12
    DW_FORM_ref4         = 0x13
    DW_FORM_ref8         = 0x14
    DW_FORM_ref_udata    = 0x15
    DW_FORM_indirect     = 0x16
    DW_FORM_sec_offset   = 0x17
    DW_FORM_exprloc      = 0x18
    DW_FORM_flag_present = 0x19
    DW_FORM_ref_sig8     = 0x20


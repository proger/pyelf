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

    int	dwarf_global_formref(Dwarf_Attribute, Dwarf_Off *, Dwarf_Error *)

    ctypedef struct Dwarf_Loc:
        Dwarf_Small lr_atom
        Dwarf_Unsigned lr_number
        Dwarf_Unsigned lr_number2
        Dwarf_Unsigned lr_offset

    ctypedef struct Dwarf_Locdesc:
        Dwarf_Addr ld_lopc
        Dwarf_Addr ld_hipc
        Dwarf_Half ld_cents
        Dwarf_Loc *ld_s

    int dwarf_loclist(Dwarf_Attribute, Dwarf_Locdesc **, Dwarf_Signed *,
            Dwarf_Error *)

cdef extern from "libdwarf/dwarf.h":
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

    cdef enum:
        DW_AT_sibling              = 0x01
        DW_AT_location             = 0x02
        DW_AT_name                 = 0x03
        DW_AT_ordering             = 0x09
        DW_AT_subscr_data          = 0x0a
        DW_AT_byte_size            = 0x0b
        DW_AT_bit_offset           = 0x0c
        DW_AT_bit_size             = 0x0d
        DW_AT_element_list         = 0x0f
        DW_AT_stmt_list            = 0x10
        DW_AT_low_pc               = 0x11
        DW_AT_high_pc              = 0x12
        DW_AT_language             = 0x13
        DW_AT_member               = 0x14
        DW_AT_discr                = 0x15
        DW_AT_discr_value          = 0x16
        DW_AT_visibility           = 0x17
        DW_AT_import               = 0x18
        DW_AT_string_length        = 0x19
        DW_AT_common_reference     = 0x1a
        DW_AT_comp_dir             = 0x1b
        DW_AT_const_value          = 0x1c
        DW_AT_containing_type      = 0x1d
        DW_AT_default_value        = 0x1e
        DW_AT_inline               = 0x20
        DW_AT_is_optional          = 0x21
        DW_AT_lower_bound          = 0x22
        DW_AT_producer             = 0x25
        DW_AT_prototyped           = 0x27
        DW_AT_return_addr          = 0x2a
        DW_AT_start_scope          = 0x2c
        DW_AT_bit_stride           = 0x2e
        DW_AT_stride_size          = 0x2e
        DW_AT_upper_bound          = 0x2f
        DW_AT_abstract_origin      = 0x31
        DW_AT_accessibility        = 0x32
        DW_AT_address_class        = 0x33
        DW_AT_artificial           = 0x34
        DW_AT_base_types           = 0x35
        DW_AT_calling_convention   = 0x36
        DW_AT_count                = 0x37
        DW_AT_data_member_location = 0x38
        DW_AT_decl_column          = 0x39
        DW_AT_decl_file            = 0x3a
        DW_AT_decl_line            = 0x3b
        DW_AT_declaration          = 0x3c
        DW_AT_discr_list           = 0x3d
        DW_AT_encoding             = 0x3e
        DW_AT_external             = 0x3f
        DW_AT_frame_base           = 0x40
        DW_AT_friend               = 0x41
        DW_AT_identifier_case      = 0x42
        DW_AT_macro_info           = 0x43
        DW_AT_namelist_item        = 0x44
        DW_AT_priority             = 0x45
        DW_AT_segment              = 0x46
        DW_AT_specification        = 0x47
        DW_AT_static_link          = 0x48
        DW_AT_type                 = 0x49
        DW_AT_use_location         = 0x4a
        DW_AT_variable_parameter   = 0x4b
        DW_AT_virtuality           = 0x4c
        DW_AT_vtable_elem_location = 0x4d
        DW_AT_allocated            = 0x4e
        DW_AT_associated           = 0x4f
        DW_AT_data_location        = 0x50
        DW_AT_byte_stride          = 0x51
        DW_AT_entry_pc             = 0x52
        DW_AT_use_UTF8             = 0x53
        DW_AT_extension            = 0x54
        DW_AT_ranges               = 0x55
        DW_AT_trampoline           = 0x56
        DW_AT_call_column          = 0x57
        DW_AT_call_file            = 0x58
        DW_AT_call_line            = 0x59
        DW_AT_description          = 0x5a
        DW_AT_binary_scale         = 0x5b
        DW_AT_decimal_scale        = 0x5c
        DW_AT_small                = 0x5d
        DW_AT_decimal_sign         = 0x5e
        DW_AT_digit_count          = 0x5f
        DW_AT_picture_string       = 0x60
        DW_AT_mutable              = 0x61
        DW_AT_threads_scaled       = 0x62
        DW_AT_explicit             = 0x63
        DW_AT_object_pointer       = 0x64
        DW_AT_endianity            = 0x65
        DW_AT_elemental            = 0x66
        DW_AT_pure                 = 0x67
        DW_AT_recursive            = 0x68
        DW_AT_signature            = 0x69
        DW_AT_main_subprogram      = 0x6a
        DW_AT_data_bit_offset      = 0x6b
        DW_AT_const_expr           = 0x6c
        DW_AT_enum_class           = 0x6d
        DW_AT_linkage_name         = 0x6e
        DW_AT_lo_user              = 0x2000
        DW_AT_hi_user              = 0x3fff

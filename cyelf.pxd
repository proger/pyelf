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

cdef extern from "libelf/libelf.h":
    ctypedef struct Elf:
        pass

    cdef enum Elf_Cmd:
        ELF_C_NULL = 0,
        ELF_C_CLR,
        ELF_C_FDDONE,
        ELF_C_FDREAD,
        ELF_C_RDWR,
        ELF_C_READ,
        ELF_C_SET,
        ELF_C_WRITE,
        ELF_C_NUM

    cdef enum:
        EV_CURRENT = 1
    int elf_version(int v)

    Elf *elf_memory(char *image, size_t size)
    Elf *elf_begin(int fd, Elf_Cmd cmd, Elf *elf)
    int elf_cntl(Elf *_elf, Elf_Cmd _cmd)
    int elf_end(Elf *_elf)
    int elf_errno()

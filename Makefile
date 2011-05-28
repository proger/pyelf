ELFTOOLCHAIN?=	${HOME}/dev/elftoolchain/trunk

CYTHON?=	cython --fast-fail
CYFLAGS=	-I${ELFTOOLCHAIN} -I${.CURDIR}

CYSRC=		libdwarf.pyx
CYOUT=		${CYSRC:S/.pyx/.c/g}

all: ${CYOUT}

clean:
	rm -f ${CYOUT}

.PHONY: clean

.SUFFIXES: .pyx

.pyx.c: ${.PREFIX}.pyx
	${CYTHON} ${CYFLAGS} -o ${.TARGET} ${.IMPSRC}

# TODO: python module building
CFLAGS=	-I/usr/pkg/include/python2.7	\
	-I${ELFTOOLCHAIN}		\
	-I${ELFTOOLCHAIN}/common	\
	-I${ELFTOOLCHAIN}/libelf	\
	-I${ELFTOOLCHAIN}/libdwarf
#	-Wl,-rpath,/usr/pkg/lib -L/usr/pkg/lib -lpython2.7 -L/home/proger/dev/elftoolchain/trunk/libdwarf/obj -L/home/proger/dev/elftoolchain/trunk/libelf/obj -Wl,-rpath,/home/proger/dev/elftoolchain/trunk/libdwarf/obj -Wl,-rpath,/home/proger/dev/elftoolchain/trunk/libelf/obj -lelf -ldwarf

.include <bsd.obj.mk>

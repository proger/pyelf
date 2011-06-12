ELFTOOLCHAIN?=	${HOME}/dev/inspect/toolchain

PYLIB=		cydwarf.so

# python module sources
CYTHON?=	cython --fast-fail
CYFLAGS=	-I${ELFTOOLCHAIN} -I${.CURDIR}

CYSRC=		cydwarf.pyx
CYOUT=		${CYSRC:S/.pyx/.c/g}

# python libraries
CC?=		cc

CFLAGS=		-g -fPIC -Wall

PATHS=	${ELFTOOLCHAIN}			\
	${ELFTOOLCHAIN}/common		\
	${ELFTOOLCHAIN}/libelf		\
	${ELFTOOLCHAIN}/libdwarf

#LDFLAGS=	-lpython2.7
LDFLAGS=
.for p in ${PATHS}
LDFLAGS+=	-Wl,-rpath,$p/obj -L$p/obj
.endfor

CPPFLAGS=	-I/usr/include/python2.7
.for p in ${PATHS}
CPPFLAGS+=	-I$p
.endfor

LDADD=		-lpython2.7 -lelf -ldwarf

COBJ=		${CYOUT:S/.c/.o/g}

.SUFFIXES: .pyx .c .o

.pyx.c: ${.IMPSRC}
	${CYTHON} ${CYFLAGS} -o ${.TARGET} ${.IMPSRC}

.c.o: ${.PREFIX}.c
	${CC} -c ${CFLAGS} ${CPPFLAGS} -o ${.TARGET} ${.IMPSRC}

${PYLIB}: ${COBJ}
	${CC} -shared ${LDFLAGS} ${COBJ} -o ${.TARGET} ${LDADD}

all: ${PYLIB}

clean:
	rm -f ${CYOUT} ${COBJ} ${PYLIB}

.PHONY: clean

.include <bsd.obj.mk>

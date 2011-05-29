ELFTOOLCHAIN?=	${HOME}/dev/elftoolchain/trunk

PYLIB=		libdwarf.so

# python module sources
CYTHON?=	cython --fast-fail
CYFLAGS=	-I${ELFTOOLCHAIN} -I${.CURDIR}

CYSRC=		libdwarf.pyx
CYOUT=		${CYSRC:S/.pyx/.c/g}

# python libraries
CC?=		cc

CFLAGS=		-fPIC

PATHS=	${ELFTOOLCHAIN}			\
	${ELFTOOLCHAIN}/common		\
	${ELFTOOLCHAIN}/libelf		\
	${ELFTOOLCHAIN}/libdwarf

LDFLAGS=	-Wl,-rpath,/usr/pkg/lib -L/usr/pkg/lib -lpython2.7
.for p in ${PATHS}
LDFLAGS+=	-Wl,-rpath,$p/obj -L$p/obj
.endfor

CPPFLAGS=	-I/usr/pkg/include/python2.7
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

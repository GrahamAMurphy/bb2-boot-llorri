VERSION_0 = 0
VERSION_1 = 1
VERSION_2 = 0
BRANCH = $(VERSION_0).$(VERSION_1)
VERSION = $(BRANCH).$(VERSION_2)
REBOOT = 10		# ROM/RAM mode.
REBOOT = 210

LANG=
export MAX_SIZE=fb00

SRC = *.fr 

RCS = *.fr Makefile .build t-load

all:	llorri-boot.bin

# For rom/ram version, reboot is at 010.
# for ram only version, reboot is at 210.
# Note two places to change below, though 2nd is probably ignoreable.

llorri-boot.bin: $(SRC)
	make version
	build
	@- /bin/echo -n "Build #" ; cat .build.num
	@-bin2prom -p 0 -e $(REBOOT) < llorri-boot.bin > llorri-boot-e.mem
	@-export BUILD=`cat .build.num` ; set -x +x ; \
	    /bin/cp llorri-boot-e.mem SREC/llorri-e.mem.$${BUILD} ; \
	    motor -s 2 -d 400000 -g 400$(REBOOT) llorri-boot-e.mem > SREC/llorri-e.mot.$${BUILD} ; \
	    /bin/cp SREC/llorri-e.mot.$${BUILD} SREC/llorri-e.mot.latest

clean:
	/bin/rm -f llorri-boot.bin

version:
	@- touch .cksum
	@- cat $(SRC) | cksum > .cksum_0
	@- if ( ! cmp -s .cksum .cksum_0 ) ; then \
	    date +%F\ %X\ `hostname` > .stamp ; \
	    cat .stamp >> .build ; \
	    export BUILD=`cat .build | wc -l ` ; \
	    cat $(SRC) | cksum > .cksum ; \
	    ci -q -l$(VERSION).$${BUILD} -m${VERSION}.$${BUILD} -t.stamp $(RCS) ; \
	    echo -n "New " ; \
	fi
	@- /bin/rm -f .cksum_0

	@- export BUILD=`cat .build | wc -l ` ; \
	    /bin/echo $${BUILD} > .build.num ; \
	    /bin/echo -n ': app-version ." ' > .version.fr ; \
	    /bin/echo -n "$(VERSION_0).$(VERSION_1).$(VERSION_2).$${BUILD}" >> .version.fr ; \
	    /bin/echo '" ;' >> .version.fr ; \
	    /bin/echo "d# $${BUILD} sw-build set" >> .version.fr ; 

	@- /bin/echo -n "Build #" ; cat .build.num

rcs:
	export BUILD=`cat .build.num` ; \
	ci -f -l$(BRANCH) -m${BRANCH} -t.stamp $(RCS) ; \
	ci -f -l$(VERSION).$${BUILD} -m${VERSION}.$${BUILD} -t.stamp $(RCS)
